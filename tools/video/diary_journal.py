import sys, math, numpy as np, cv2
from common_square import *

PW,PH=1400,1400
yy,xx=np.mgrid[0:H,0:W].astype(np.float32)
# ---- flat paper page ----
fib=fbm_tile(PW,PH,71,6,6,1.4)
fib2=fbm_tile(PW,PH,72,4,2,2.4)
paper=np.dstack([np.full((PH,PW),c,np.float32) for c in hexc('#efe5d3')])
paper*= (0.93+0.07*fib[...,None])*(0.96+0.06*fib2[...,None])
for k in range(3,30):
    y=int(k*PH/30)
    cv2.line(paper,(0,y),(PW,y),tuple((hexc('#9fb4c2')*0.9).tolist()),2,cv2.LINE_AA)
cv2.line(paper,(int(PW*0.14),0),(int(PW*0.14),PH),tuple(hexc('#d98f86').tolist()),2,cv2.LINE_AA)
paper=cv2.GaussianBlur(paper,(0,0),0.6)

# ---- handwriting paths on the page (3 lines) ----
rng=np.random.default_rng(9)
lines=[]
for li,(y0,x0,x1) in enumerate([(0.4,0.18,0.84),(0.4667,0.18,0.80),(0.5333,0.18,0.58)]):
    S=2600; s_=np.linspace(0,1,S)
    cyc=(30 if li<2 else 18)
    ph=2*np.pi*(s_*cyc)
    size=0.6+0.4*np.abs(np.sin(s_*2*np.pi*(5.3+li)+li))
    asc=np.clip(np.sin(s_*2*np.pi*(7+li*2)+1.1)-0.82,0,1)*6   # occasional tall letters
    x=PW*(x0+(x1-x0)*s_)-13*size*np.sin(ph)
    y=PH*y0-8-(20*size+asc*16)*(0.5-0.5*np.cos(ph))+3*np.sin(s_*2*np.pi*1.7+li)
    gaps=np.sin(s_*2*np.pi*(4+li)+0.4)>0.9
    lines.append((x,y,gaps))
total=sum(len(l[0]) for l in lines)

def page_with_ink(prog, inkfade):
    pg=paper.copy()
    ink=np.zeros((PH,PW),np.float32)
    drawn=int(total*prog); tip=None
    for (x,y,gaps) in lines:
        n=min(len(x),drawn); drawn-=n
        if n<2: continue
        for i in range(1,n):
            if gaps[i]: continue
            w=1.6+0.9*abs(math.sin(i*0.021))
            cv2.line(ink,(int(x[i-1]*4),int(y[i-1]*4)),(int(x[i]*4),int(y[i]*4)),1.0,max(1,int(round(w))),cv2.LINE_AA,shift=2)
        if n<len(x): tip=(x[n-1],y[n-1])
        elif drawn<=0 and tip is None: tip=(x[n-1],y[n-1])
    bleed=cv2.GaussianBlur(ink,(0,0),1.6)
    a=np.clip(ink*0.9+bleed*0.35,0,1)*inkfade
    pg=pg*(1-a[...,None])+hexc('#1d2a45')*a[...,None]
    return pg,tip

def frame(i):
    t=i/N; T=2*np.pi*t
    prog=np.clip((t-0.04)/0.74,0,1)
    prog=prog*prog*(3-2*prog)
    inkfade=1-np.clip((t-0.86)/0.12,0,1)
    pg,tip=page_with_ink(prog,inkfade)
    # soft hand/pen shadow near the writing tip
    if tip is not None and inkfade>0.05 and prog<1:
        sh=np.zeros((PH,PW),np.float32)
        cv2.ellipse(sh,(int(tip[0]+160),int(tip[1]+220)),(260,120),35,0,360,1.0,-1)
        sh=cv2.GaussianBlur(sh,(0,0),60)
        pg*=(1-0.35*sh[...,None])
        ang=math.radians(-38)
        d=np.array([math.cos(ang),math.sin(ang)])      # from tip toward the hand (up-right)
        nrm=np.array([-d[1],d[0]])
        tp=np.array(tip)
        def quad(t0,t1,w0,w1):
            return np.array([tp+d*t0+nrm*w0,tp+d*t1+nrm*w1,tp+d*t1-nrm*w1,tp+d*t0-nrm*w0],np.int32)
        # shadow of the pen
        shp=np.zeros((PH,PW),np.float32)
        cv2.fillPoly(shp,[quad(30,1000,10,20)+np.array([70,90])],1.0)
        shp=cv2.GaussianBlur(shp,(0,0),18)
        pg*=(1-0.45*shp[...,None])
        cv2.fillPoly(pg,[quad(0,26,1,7)],tuple(hexc('#9aa3a8').tolist()),cv2.LINE_AA)
        cv2.fillPoly(pg,[quad(26,110,7,15)],tuple(hexc('#c9b58a').tolist()),cv2.LINE_AA)
        cv2.fillPoly(pg,[quad(110,1000,15,19)],tuple(hexc('#173f45').tolist()),cv2.LINE_AA)
        cv2.line(pg,tuple((tp+d*130+nrm*9).astype(int)),tuple((tp+d*1000+nrm*12).astype(int)),tuple(hexc('#5f8f93').tolist()),3,cv2.LINE_AA)
        cv2.line(pg,tuple((tp+d*40+nrm*3).astype(int)),tuple((tp+d*100+nrm*9).astype(int)),tuple(hexc('#fff3d2').tolist()),2,cv2.LINE_AA)
    # camera: slow drift + perspective tilt
    dx=math.sin(T)*40; dy=math.cos(T)*25; z=1+0.04*math.sin(T)
    src=np.float32([[0,0],[PW,0],[PW,PH],[0,PH]])
    cx,cy=PW*0.52+dx,PH*0.5+dy
    half=PW*0.47*z
    top=half*0.72
    dst_src=np.float32([[cx-top,cy-half*0.55],[cx+top,cy-half*0.55],[cx+half,cy+half*0.95],[cx-half,cy+half*0.95]])
    Mx=cv2.getPerspectiveTransform(dst_src,np.float32([[0,0],[W,0],[W,H],[0,H]]))
    img=cv2.warpPerspective(pg,Mx,(W,H),flags=cv2.INTER_LINEAR,borderMode=cv2.BORDER_REFLECT)
    # tilt-shift depth of field (top of frame further away)
    far=cv2.GaussianBlur(img,(0,0),7)
    m=np.clip((0.42-yy/H)/0.42,0,1)**1.3
    m2=np.clip((yy/H-0.9)/0.1,0,1)
    mm=np.clip(m+m2*0.6,0,1)[...,None]
    img=img*(1-mm)+far*mm
    # window-blind light sweeping slowly
    ang=0.55
    u=(xx*math.cos(ang)+yy*math.sin(ang))/W
    blinds=0.5+0.5*np.sin((u*5+t*1.0)*2*np.pi)
    blinds=np.clip((blinds-0.35)*2.2,0,1)
    blinds=cv2.GaussianBlur(blinds,(0,0),14)
    warm=np.exp(-(((xx-W*0.8)/(W*0.7))**2+((yy-H*0.05)/(H*0.8))**2))
    light=0.78+0.28*blinds*warm+0.18*warm
    img=img*light[...,None]
    img+=hexc('#ffb86b')[None,None,:]*(0.06*blinds*warm)[...,None]
    # dust in the light
    lay=np.zeros((H,W,3),np.float32)
    r=np.random.default_rng(4)
    for k in range(60):
        px=(r.random()+0.02*math.sin(T+k))%1; py=(r.random()-t*(0.2+0.3*r.random()))%1
        rad=int(1+r.random()*3)
        cv2.circle(lay,(int(px*W),int(py*H)),rad,tuple((hexc('#fff1d6')*0.5*(0.5+0.5*math.sin(T*3+k))).tolist()),-1,cv2.LINE_AA)
    img+=cv2.GaussianBlur(lay,(0,0),1.5)*(0.3+0.7*warm[...,None])
    # warm grade
    img=img*np.array([0.92,0.98,1.06],np.float32)
    img=bloom(img,0.85,20,0.35)
    img=np.clip(img,0,1.2); img=img/(1+img*0.25)*1.15
    img=vignette(img,0.32)
    img=grain(img,0.014,i)
    return img

if __name__=='__main__':
    if sys.argv[1]=='test':
        for i in [20,110,180]: cv2.imwrite(f'dj_{i}.jpg',(np.clip(frame(i),0,1)*255).astype(np.uint8))
    else:
        e=Encoder(sys.argv[1])
        for i in range(N):
            e.write(frame(i))
            if i%24==0: print(i,flush=True)
        e.close()
