import sys, math, numpy as np, cv2
from common_square import *

yy,xx=np.mgrid[0:H,0:W].astype(np.float32)
S=620  # object canvas

def puffy(mask, base, spec_col=(1,1,1), gloss=0.5, rough=24):
    """Shade a flat silhouette as a soft 3D object from its distance field."""
    m=(mask>0.5).astype(np.uint8)
    dist=cv2.distanceTransform(m,cv2.DIST_L2,5).astype(np.float32)
    h=np.sqrt(dist)*6
    h=cv2.GaussianBlur(h,(0,0),14)
    gx=cv2.Sobel(h,cv2.CV_32F,1,0,ksize=5)/32; gy=cv2.Sobel(h,cv2.CV_32F,0,1,ksize=5)/32
    nz=1/np.sqrt(gx*gx+gy*gy+1); nx=-gx*nz; ny=-gy*nz
    L=np.array([-0.5,-0.65,0.58]); L/=np.linalg.norm(L)
    diff=np.clip(nx*L[0]+ny*L[1]+nz*L[2],0,1)
    Hv=L+np.array([0,0,1]); Hv/=np.linalg.norm(Hv)
    sp=np.clip(nx*Hv[0]+ny*Hv[1]+nz*Hv[2],0,1)**rough*gloss
    rim=np.clip(nx*0.8+ny*0.2,0,1)**2*(1-nz)
    col=base*(0.28+0.8*diff)[...,None]+np.array(spec_col,np.float32)*sp[...,None]+hexc('#9b8cff')*rim[...,None]*0.35
    a=cv2.GaussianBlur(mask.astype(np.float32),(0,0),1.2)
    return np.dstack([col*a[...,None],a]).astype(np.float32)

def bag():
    m=np.zeros((S,S),np.float32)
    cv2.fillPoly(m,[np.array([[150,250],[470,250],[520,540],[100,540]],np.int32)],1)
    m=(cv2.GaussianBlur(m,(0,0),14)>0.5).astype(np.float32)
    body=puffy(m,hexc('#b5794a'),gloss=0.35)
    h=np.zeros((S,S),np.float32); cv2.ellipse(h,(310,250),(120,130),0,180,360,1,24,cv2.LINE_AA)
    hand=puffy(h,hexc('#8a5634'),gloss=0.4)
    out=hand.copy(); a=body[...,3:4]; out=out*(1-a)+body
    cv2.line(out,(150,330),(470,330),(0.08,0.12,0.2,1),3,cv2.LINE_AA)
    cv2.rectangle(out,(290,340),(330,380),tuple((hexc('#e8c27a')).tolist())+(1,),-1,cv2.LINE_AA)
    return out
def sneaker():
    m=np.zeros((S,S),np.float32)
    # side profile: heel at left, toe at right
    up=np.array([[95,420],[92,330],[120,285],[175,270],[215,300],[250,285],[300,245],[350,230],
                 [395,255],[440,300],[505,335],[555,365],[572,405],[560,432],[95,440]],np.int32)
    cv2.fillPoly(m,[up],1); m=(cv2.GaussianBlur(m,(0,0),10)>0.5).astype(np.float32)
    upper=puffy(m,hexc('#ece9e2'),gloss=0.55)
    s=np.zeros((S,S),np.float32)
    cv2.fillPoly(s,[np.array([[80,420],[578,410],[590,445],[570,478],[95,480],[72,455]],np.int32)],1)
    s=(cv2.GaussianBlur(s,(0,0),8)>0.5).astype(np.float32)
    sole=puffy(s,hexc('#f4f2ee'),gloss=0.3)
    out=upper.copy(); a=sole[...,3:4]; out=out*(1-a)+sole
    cv2.line(out,(84,462),(582,452),(0.25,0.27,0.32,1),6,cv2.LINE_AA)
    cv2.ellipse(out,(350,375),(190,48),-8,195,340,tuple(hexc('#35c2b3').tolist())+(1,),12,cv2.LINE_AA)
    cv2.ellipse(out,(160,300),(34,24),0,0,360,(0.18,0.2,0.25,1),-1,cv2.LINE_AA)   # collar opening
    for k in range(5):
        x=250+k*30; y=292-k*9
        cv2.line(out,(x,y),(x+26,y+22),(0.22,0.24,0.3,1),4,cv2.LINE_AA)
    return out
def watch():
    out=np.zeros((S,S,4),np.float32)
    st=np.zeros((S,S),np.float32); cv2.rectangle(st,(240,40),(380,580),1,-1); st=(cv2.GaussianBlur(st,(0,0),10)>0.5).astype(np.float32)
    strap=puffy(st,hexc('#2b3a4a'),gloss=0.3)
    c=np.zeros((S,S),np.float32); cv2.circle(c,(310,310),150,1,-1)
    case=puffy(c,hexc('#c9ced6'),gloss=0.9,rough=40)
    f=np.zeros((S,S),np.float32); cv2.circle(f,(310,310),118,1,-1)
    face=np.dstack([np.full((S,S,3),hexc('#0f1720'),np.float32)*f[...,None],f])
    for layer in (strap,case,face):
        a=layer[...,3:4]; out=out*(1-a)+layer
    for k in range(12):
        ang=k/12*2*np.pi; p1=(int(310+100*math.cos(ang)),int(310+100*math.sin(ang))); p2=(int(310+110*math.cos(ang)),int(310+110*math.sin(ang)))
        cv2.line(out,p1,p2,(0.9,0.9,0.9,1),3,cv2.LINE_AA)
    return out

objects=[(bag(),hexc('#f2a65a')),(sneaker(),hexc('#35c2b3')),(watch(),hexc('#9b8cff'))]
contours=[]
for o,_ in objects:
    m=(o[...,3]>0.5).astype(np.uint8)
    cs,_=cv2.findContours(m,cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_NONE)
    c=max(cs,key=len)[:,0,:]
    contours.append(c[::max(1,len(c)//34)])

def paste(img,spr,cx,cy,scale,alpha=1.0):
    size=int(S*scale); s=cv2.resize(spr,(size,size),interpolation=cv2.INTER_AREA)
    x0=int(cx-size/2); y0=int(cy-size/2)
    xa,ya=max(0,x0),max(0,y0); xb,yb=min(W,x0+size),min(H,y0+size)
    if xb<=xa or yb<=ya: return
    sub=s[ya-y0:yb-y0,xa-x0:xb-x0]; a=sub[...,3:4]*alpha
    img[ya:yb,xa:xb]=img[ya:yb,xa:xb]*(1-a)+sub[...,:3]*alpha

def frame(i):
    t=i/N; T=2*np.pi*t
    seg=t*3; k=int(seg)%3; local=seg-int(seg)
    obj,accent=objects[k]
    # background: deep ink studio with soft accent light
    d=np.sqrt(((xx-W*0.45)/W)**2+((yy-H*0.45)/H)**2)
    img=(hexc('#07060d')+hexc('#1a1830')*np.exp(-d*d*6)[...,None]).astype(np.float32)
    img+=accent*np.exp(-d*d*9)[...,None]*0.10
    # pedestal glow
    img+=hexc('#ffffff')*np.exp(-(((xx-W*0.45)/(W*0.28))**2+((yy-H*0.8)/(H*0.04))**2))[...,None]*0.08
    # object in/out
    fin=smooth01(local/0.14); fout=1-smooth01((local-0.86)/0.14)
    vis=fin*fout
    bob=math.sin(T*6)*6
    scale=1.05*(0.92+0.08*vis)
    cx,cy=W*0.45,H*0.47+bob+(1-vis)*30
    shadow=np.exp(-(((xx-cx)/(W*0.2))**2+((yy-H*0.78)/(H*0.025))**2))
    img*=(1-0.5*shadow*vis)[...,None]
    paste(img,obj,cx,cy,scale,vis)
    size=S*scale; ox=cx-size/2; oy=cy-size/2; f=scale
    lay=np.zeros((H,W,3),np.float32)
    scan=smooth01((local-0.16)/0.4)
    # scan beam sweeping down
    if 0<scan<1 and vis>0.5:
        by=int(oy+size*(0.08+0.84*scan))
        cv2.line(lay,(int(ox+size*0.05),by),(int(ox+size*0.95),by),tuple((accent*1.6).tolist()),2,cv2.LINE_AA)
        band=np.exp(-((yy-by)/28)**2)*((xx>ox)&(xx<ox+size))
        img+=accent*band[...,None]*0.10
    # feature points + mesh along the contour, revealed by the beam
    reveal=smooth01((local-0.2)/0.45)*fout
    pts=[(ox+px*f,oy+py*f) for px,py in contours[k]]
    shown=int(len(pts)*reveal)
    for j in range(shown):
        p=pts[j]
        cv2.circle(lay,(int(p[0]),int(p[1])),3,tuple((hexc('#ffffff')*0.9).tolist()),-1,cv2.LINE_AA)
        if j>0: cv2.line(lay,(int(pts[j-1][0]),int(pts[j-1][1])),(int(p[0]),int(p[1])),tuple((accent*0.5).tolist()),1,cv2.LINE_AA)
        if j%5==0 and j+9<len(pts): 
            q=pts[(j+9)%len(pts)]
            cv2.line(lay,(int(p[0]),int(p[1])),(int(q[0]),int(q[1])),tuple((accent*0.22).tolist()),1,cv2.LINE_AA)
    # corner brackets lock on
    lock=smooth01((local-0.5)/0.12)*fout
    if lock>0:
        xs=[int(ox+size*0.06),int(ox+size*0.94)]; ys=[int(oy+size*0.08),int(oy+size*0.92)]
        L=int(40*lock)+4
        for x0 in xs:
            for y0 in ys:
                sx=1 if x0==xs[0] else -1; sy=1 if y0==ys[0] else -1
                cv2.line(lay,(x0,y0),(x0+sx*L,y0),tuple((hexc('#ffffff')*lock).tolist()),3,cv2.LINE_AA)
                cv2.line(lay,(x0,y0),(x0,y0+sy*L),tuple((hexc('#ffffff')*lock).tolist()),3,cv2.LINE_AA)
    # matching suggestions slide in on the right
    sug=smooth01((local-0.58)/0.16)*fout
    if sug>0:
        for j in range(3):
            a=np.clip(sug*1.4-j*0.2,0,1)
            if a<=0: continue
            x=int(W*0.8+(1-a)*120); y=int(H*(0.26+j*0.22))
            card=np.zeros((H,W,3),np.float32)
            cv2.rectangle(card,(x-70,y-70),(x+70,y+70),tuple((hexc('#15142a')*1.0).tolist()),-1,cv2.LINE_AA)
            img[:]=img*(1-(card.sum(2)>0)[...,None]*0.85*a)+card*a
            cv2.rectangle(lay,(x-70,y-70),(x+70,y+70),tuple((accent*0.45*a).tolist()),1,cv2.LINE_AA)
            tint=[hexc('#b5794a'),hexc('#6b7a8f'),hexc('#c9a27a')][j] if k==0 else ([hexc('#e9e6df'),hexc('#1f2a33'),hexc('#d7564a')][j] if k==1 else [hexc('#c9ced6'),hexc('#d6b25e'),hexc('#2b3a4a')][j])
            spr=objects[k][0].copy(); spr[...,:3]=spr[...,:3]*0.45+tint*spr[...,3:4]*0.55
            paste(img,spr,x,y-8,0.19,a)
            cv2.line(lay,(x-44,y+50),(x+44,y+50),tuple((hexc('#ffffff')*0.35*a).tolist()),3,cv2.LINE_AA)
            cv2.line(lay,(x-44,y+58),(x+10,y+58),tuple((accent*0.7*a).tolist()),3,cv2.LINE_AA)
            # link from object to suggestion
            cv2.line(lay,(int(ox+size*0.94),int(cy)),(x-70,y),tuple((accent*0.25*a).tolist()),1,cv2.LINE_AA)
    img+=lay+cv2.GaussianBlur(lay,(0,0),6)*0.8
    img=bloom(img,0.7,18,0.4)
    img=tonemap(img*1.05)
    img=vignette(img,0.4)
    img=grain(img,0.012,5000+i)
    return img

def smooth01(x):
    x=min(1.0,max(0.0,x)); return x*x*(3-2*x)

if __name__=='__main__':
    if sys.argv[1]=='test':
        for i in [34,120,178]: cv2.imwrite(f'sa_{i}.jpg',(np.clip(frame(i),0,1)*255).astype(np.uint8))
    else:
        e=Encoder(sys.argv[1])
        for i in range(N):
            e.write(frame(i))
            if i%24==0: print(i,flush=True)
        e.close()
