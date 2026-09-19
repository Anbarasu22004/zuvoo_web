import sys, math, numpy as np, cv2
from common import *

# ---------- static precompute ----------
yy,xx=np.mgrid[0:H,0:W].astype(np.float32)
MARGIN=200
WW=W+2*MARGIN

def ridge(x,seed):
    s=seed*1.37; r=np.zeros_like(x)
    for f,a in [(1.6,.6),(3.7,.28),(8.3,.1),(19,.04),(41,.015)]:
        r+=a*(1-np.abs(np.sin(x*f+s*f*0.7)))**1.6
    return r

layers=[ # base, amp, color BGR-ish hex, seed, rise pow, depth, fog
 (0.64,0.26,'#1c3a44',1,1.0,0.15),
 (0.70,0.28,'#15313a',2,1.2,0.30),
 (0.77,0.24,'#0f2830',3,1.4,0.50),
 (0.86,0.20,'#0a1f26',4,1.6,0.75),
 (0.95,0.14,'#06161b',5,1.8,1.00),
]
xs=np.linspace(-MARGIN/W,1+MARGIN/W,WW).astype(np.float32)
heights=[]
for base,amp,col,seed,rp,depth in layers:
    xr=np.clip(xs,0,1.2)
    h=base-amp*ridge(xs*1.2,seed)*(0.25+0.75*np.clip(xs,0,1)**rp)
    heights.append(h)

fogtiles=[fbm_tile(W,H,40+i,4,3) for i in range(3)]
sky_top=hexc('#030b0f'); sky_mid=hexc('#0b2a33'); horizon=hexc('#b9794a'); horizon2=hexc('#e8b27a')

# particles (3D, periodic orbits)
P=110
pr=np.random.default_rng(3)
px0=pr.uniform(-1,1,P); py0=pr.uniform(-0.55,0.15,P); pz=pr.uniform(0.6,2.2,P)
pph=pr.uniform(0,2*np.pi,P); pamp=pr.uniform(0.02,0.08,P); pspeed=pr.integers(1,3,P)

def frame(i):
    t=i/N; T=2*np.pi*t
    # Story arc within loop: 0..0.35 life (landscape), 0.35..0.75 tech (lines/network), 0.75..1 open (bright), then back
    tech=0.5-0.5*np.cos(T)          # 0 at start/end, 1 mid
    bright=0.5-0.5*np.cos(T)         # dawn intensifies mid-loop
    img=np.zeros((H,W,3),np.float32)
    v=yy/H
    # sky
    a=np.clip(v/0.62,0,1)[...,None]
    sky=sky_top*(1-a)+sky_mid*a
    glow=np.exp(-(((xx-W*0.52)/(W*0.42))**2+((yy-H*0.64)/(H*0.22))**2))[...,None]
    sky+=glow*(horizon*(0.55+0.45*bright))
    core=np.exp(-(((xx-W*0.52)/(W*0.12))**2+((yy-H*0.66)/(H*0.07))**2))[...,None]
    sky+=core*horizon2*(0.6+0.7*bright)
    img[:]=sky
    # god rays
    ang=np.arctan2(yy-H*0.66,xx-W*0.52)
    dist=np.sqrt((xx-W*0.52)**2+(yy-H*0.66)**2)/W
    rays=(0.5+0.5*np.sin(ang*11+np.sin(ang*5+T)*0.9))**3
    rays*=np.exp(-dist*2.2)*(yy<H*0.72)
    rays=cv2.GaussianBlur(rays.astype(np.float32),(0,0),6)
    img+=rays[...,None]*horizon2*0.12*(0.4+0.6*bright)
    # flowing light ribbons in the sky (technology arriving)
    for k in range(4):
        yc=H*(0.30+0.07*k)+np.sin(xx/W*6.28*(1+0.3*k)+T+k*1.3)*H*0.04
        d=np.abs(yy-yc)
        ribbon=np.exp(-(d/1.6)**2)+0.35*np.exp(-(d/10)**2)
        mask=np.clip(np.sin((xx/W)*np.pi),0,1)**1.5
        img+=(ribbon*mask)[...,None]*hexc('#9fe0da')*0.22*tech
    # network particles
    cam=np.sin(T)*0.05
    sx=(px0+pamp*np.sin(T*pspeed+pph)+cam*pz)/pz*W*0.55+W/2
    sy=(py0+pamp*np.cos(T*pspeed+pph))/pz*H*0.9+H*0.42
    pts=np.stack([sx,sy],1)
    lay=np.zeros((H,W,3),np.float32)
    alpha=0.25+0.75*tech
    for a_ in range(P):
        for b_ in range(a_+1,P):
            d=np.hypot(*(pts[a_]-pts[b_]))
            if d<95 and abs(pz[a_]-pz[b_])<0.6:
                c=float((1-d/95)*0.28*tech)
                cv2.line(lay,(int(sx[a_]),int(sy[a_])),(int(sx[b_]),int(sy[b_])),tuple((hexc('#7fd3cc')*c).tolist()),1,cv2.LINE_AA)
    for a_ in range(P):
        r=max(1,int(3.2/pz[a_]))
        tw=0.6+0.4*math.sin(T*3+pph[a_])
        col=(hexc('#ffe2b8') if a_%9==0 else hexc('#d8fff9'))*alpha*tw
        cv2.circle(lay,(int(sx[a_]),int(sy[a_])),r,tuple(col.tolist()),-1,cv2.LINE_AA)
    lay=lay+cv2.GaussianBlur(lay,(0,0),4)*1.4
    img+=lay
    # mountains with parallax and fog
    for li,(base,amp,col,seed,rp,depth) in enumerate(layers):
        off=int(MARGIN+np.sin(T)*MARGIN*0.9*depth)
        hcol=heights[li][off:off+W]*H+ np.cos(T)*6*depth
        m=(yy>=hcol[None,:]).astype(np.float32)
        m=cv2.GaussianBlur(m,(0,0),0.8+ (1-depth)*1.2)
        c=hexc(col)
        # rim light on ridge tops facing the sun
        rim=np.exp(-((yy-hcol[None,:])/4.0)**2)*(yy>=hcol[None,:]-3)*(li<=1)
        sunfall=np.exp(-((xx-W*0.52)/(W*0.35))**2)
        img=img*(1-m[...,None])+c*m[...,None]
        img+=(rim*sunfall)[...,None]*horizon2*0.22*(0.5+0.5*bright)
        if li<len(layers)-1:
            ft=fogtiles[li%3]
            shift=int((t*W*(0.5+depth))%W)
            ft=np.roll(ft,shift,axis=1)
            fy=int(H*(layers[li+1][0]-layers[li+1][1]*0.45))
            band=ft
            envy=np.exp(-((yy-fy)/(H*0.06))**2)
            fog=np.clip(band*1.6-0.45,0,1)*envy
            fogc=hexc('#9cc3c7')*0.55+horizon*0.25*bright
            img=img*(1-fog[...,None]*0.55)+fogc*fog[...,None]*0.55
    img=bloom(img,0.55,25,0.7)
    img=tonemap(img*1.05)
    img=vignette(img,0.6)
    img=grain(img,0.015,i)
    return img

if __name__=='__main__':
    if len(sys.argv)>1 and sys.argv[1]=='test':
        for i in [0,48,96]:
            cv2.imwrite(f'hero_{i}.jpg',(np.clip(frame(i),0,1)*255).astype(np.uint8))
    else:
        e=Encoder(sys.argv[1])
        for i in range(N):
            e.write(frame(i))
            if i%24==0: print(i,flush=True)
        e.close()
