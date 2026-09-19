import sys, math, numpy as np, cv2
from common import *

CW,CH=640,360
n1=fbm_tile(CW,CH,101,4,3,2.8); n2=fbm_tile(CW,CH,202,4,3,2.8); n3=fbm_tile(CW,CH,303,6,3,2.2)
gx,gy=np.meshgrid(np.arange(CW,dtype=np.float32),np.arange(CH,dtype=np.float32))
yy,xx=np.mgrid[0:H,0:W].astype(np.float32)

def sample(n,x,y):
    return cv2.remap(n,x,y,cv2.INTER_LINEAR,borderMode=cv2.BORDER_WRAP)

bg1=hexc('#03090b'); bg2=hexc('#07181c'); inkA=hexc('#0e3a41'); inkB=hexc('#79b9b0'); gold=hexc('#f2a65a'); cream=hexc('#fff1dc')

pr=np.random.default_rng(11)
PAGES=[(pr.uniform(0.1,0.9),pr.uniform(0.15,0.85),pr.uniform(0.8,2.6),pr.uniform(-0.5,0.5),pr.uniform(0,6.28)) for _ in range(7)]
B=70
bx=pr.uniform(0,1,B); by=pr.uniform(0,1,B); bz=pr.uniform(0.5,2.5,B); bph=pr.uniform(0,6.28,B)

# handwriting path
S=900
s=np.linspace(0,1,S)
amp=(0.55+0.45*np.sin(s*2*np.pi*2.3))
ph=2*np.pi*(s*14+0.8*np.sin(s*2*np.pi*1.7))
hx=W*(0.2+0.6*s)+18*amp*np.sin(ph)
hy=H*0.7-16*amp*np.cos(ph)-12*np.sin(s*2*np.pi*1.1)

def frame(i):
    t=i/N; T=2*np.pi*t
    R=60
    wx=sample(n1,gx+R*math.cos(T),gy+R*math.sin(T))
    wy=sample(n2,gx-R*math.sin(T),gy+R*math.cos(T))
    u=gx+(wx-0.5)*160; v=gy+(wy-0.5)*160
    d=sample(n3,u+30*math.cos(T),v+30*math.sin(T))
    d=cv2.GaussianBlur(d,(0,0),0.6)
    dens=np.clip((d-0.5)/0.4,0,1)
    dens=dens*dens*(3-2*dens)
    gxm=cv2.Sobel(d,cv2.CV_32F,1,0,ksize=3); gym=cv2.Sobel(d,cv2.CV_32F,0,1,ksize=3)
    edge=np.clip(np.sqrt(gxm**2+gym**2)*3,0,1)*np.clip(dens*4,0,1)
    vg=gy/CH
    col=bg1*(1-vg[...,None])+bg2*vg[...,None]
    col=col*(1-dens[...,None])+inkA*dens[...,None]*1.05
    hi=np.clip((dens-0.6)/0.4,0,1)
    col+=inkB*(hi**2)[...,None]*0.45
    col+=gold*(edge*0.10)[...,None]
    d2=sample(n3,u*1.0+(wx-0.5)*120,v+(wy-0.5)*120)
    d2f=cv2.GaussianBlur(cv2.resize(d2,(W,H),interpolation=cv2.INTER_CUBIC),(0,0),1.0)
    densf=cv2.resize(dens,(W,H))
    wispf=np.exp(-((d2f-0.56)/0.010)**2)*0.5+np.exp(-((d2f-0.62)/0.007)**2)*0.3
    wispf*=np.clip(1-densf*0.6,0,1)
    img=cv2.resize(col,(W,H),interpolation=cv2.INTER_CUBIC)
    img=cv2.GaussianBlur(img,(0,0),1.2)
    img+=inkB*cv2.GaussianBlur(wispf,(0,0),0.7)[...,None]*0.4

    # soft morning light beam from top-left
    beam_d=np.abs((xx-W*0.18)*math.cos(0.9)-(yy+H*0.1)*math.sin(0.9))
    beam=np.exp(-(beam_d/(W*(0.12+0.015*math.sin(T))))**2)*np.clip(1-yy/H,0,1)
    img+=beam[...,None]*gold*0.10
    img*=1+beam[...,None]*0.5

    # handwriting of light: writes in, then fades — invisible at loop seam
    write=np.clip((t-0.12)/0.5,0,1)
    fade=1-np.clip((t-0.72)/0.18,0,1)
    if write>0 and fade>0:
        n=int(S*write)
        stroke=np.zeros((H,W),np.float32)
        pts=np.stack([hx[:n],hy[:n]],1).astype(np.int32).reshape(-1,1,2)
        if n>2:
            cv2.polylines(stroke,[pts],False,1.0,2,cv2.LINE_AA)
            glow=cv2.GaussianBlur(stroke,(0,0),6)*2.5+cv2.GaussianBlur(stroke,(0,0),22)*3
            img+=((stroke*0.9+glow)*fade)[...,None]*gold
            hxn,hyn=int(hx[n-1]),int(hy[n-1])
            if write<1:
                tip=np.zeros((H,W),np.float32); cv2.circle(tip,(hxn,hyn),3,1.0,-1,cv2.LINE_AA)
                tip=cv2.GaussianBlur(tip,(0,0),10)*18+tip
                img+=tip[...,None]*cream

    # bokeh drifting up
    bl=np.zeros((H,W,3),np.float32)
    for k in range(B):
        x=W*((bx[k]+0.02*math.sin(T+bph[k]))%1); y=H*((by[k]-t*(0.5 if k%2 else 1.0))%1)
        r=max(2,int(9/bz[k]))
        c=(gold if k%4==0 else inkB)*(0.35/bz[k])*(0.6+0.4*math.sin(T*2+bph[k]))
        cv2.circle(bl,(int(x),int(y)),r,tuple(c.tolist()),-1,cv2.LINE_AA)
    img+=cv2.GaussianBlur(bl,(0,0),2.2)

    img=bloom(img,0.5,21,0.6)
    img=tonemap(img*1.1)
    img=vignette(img,0.7)
    img=grain(img,0.014,1000+i)
    return img

if __name__=='__main__':
    if sys.argv[1]=='test':
        for i in [0,72,130]:
            cv2.imwrite(f'diary_{i}.jpg',(np.clip(frame(i),0,1)*255).astype(np.uint8))
    else:
        e=Encoder(sys.argv[1])
        for i in range(N):
            e.write(frame(i))
            if i%24==0: print(i,flush=True)
        e.close()
