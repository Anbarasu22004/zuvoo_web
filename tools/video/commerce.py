import sys, math, numpy as np, cv2
from common import *

yy,xx=np.mgrid[0:H,0:W].astype(np.float32)
SR=110  # sprite radius

def sphere_sprite(base, spec=0.6, squash=1.0, stem=None):
    s=SR*2+20
    y,x=np.mgrid[0:s,0:s].astype(np.float32)
    nx=(x-s/2)/SR; ny=(y-s/2)/(SR*squash)
    r2=nx**2+ny**2
    inside=np.clip((1-r2)*SR*0.6,0,1)
    nz=np.sqrt(np.clip(1-r2,0,1))
    L=np.array([-0.5,-0.6,0.62]); L/=np.linalg.norm(L)
    diff=np.clip(nx*L[0]+ny*L[1]+nz*L[2],0,1)
    Hh=L+np.array([0,0,1]); Hh/=np.linalg.norm(Hh)
    sp=np.clip(nx*Hh[0]+ny*Hh[1]+nz*Hh[2],0,1)**40*spec
    rimTeal=np.clip(nx,0,1)**3*(1-nz)**1.5
    col=base*(0.18+0.9*diff)[...,None]+sp[...,None]*np.array([1,1,1],np.float32)+hexc('#6fd1c6')*rimTeal[...,None]*0.7
    # subsurface warmth on shadow side
    col+=base*0.12*(1-diff)[...,None]
    img=np.dstack([col*inside[...,None],inside]).astype(np.float32)
    if stem is not None:
        cv2.ellipse(img,(s//2,int(s/2-SR*squash*0.9)),(int(SR*0.26),int(SR*0.08)),0,0,360,(*(stem*0.8).tolist(),1.0),-1,cv2.LINE_AA)
    return img

def box_sprite(face, band):
    s=SR*2+20
    img=np.zeros((s,s,4),np.float32)
    x0,y0,x1,y1=30,40,s-30,s-20
    g=np.linspace(1.0,0.55,x1-x0,dtype=np.float32)[None,:,None]
    v=np.linspace(1.0,0.8,y1-y0,dtype=np.float32)[:,None,None]
    img[y0:y1,x0:x1,:3]=face*g*v
    img[y0:y1,x0:x1,3]=1
    bh=(y1-y0)//4; by=y0+(y1-y0)//2-bh//2
    img[by:by+bh,x0:x1,:3]=band*g[...,:]*v[by-y0:by-y0+bh]
    img[y0:y0+6,x0:x1,:3]=face*1.15
    mask=np.zeros((s,s),np.uint8); cv2.rectangle(mask,(x0,y0),(x1,y1),255,-1)
    img[...,3]=cv2.GaussianBlur(mask.astype(np.float32)/255,(0,0),1.2)
    img[...,:3]*=img[...,3:4]
    return img

sprites={
 'tomato':sphere_sprite(hexc('#d8412f'),0.9,0.92,hexc('#2f7a3c')),
 'orange':sphere_sprite(hexc('#ef8a26'),0.5,1.0,hexc('#3f8a40')),
 'lime':sphere_sprite(hexc('#7cbf3f'),0.7,1.0),
 'lemon':sphere_sprite(hexc('#f2cf4a'),0.6,0.86),
 'egg':sphere_sprite(hexc('#f3e6d2'),0.4,1.25),
 'box':box_sprite(hexc('#efe7da'),hexc('#1f6b73')),
 'box2':box_sprite(hexc('#2a6f78'),hexc('#f2a65a')),
}
kinds=list(sprites)
pr=np.random.default_rng(21)
M=13
items=[]
for k in range(M):
    ang=k/M*2*np.pi+pr.uniform(-0.2,0.2)
    rad=pr.uniform(1.5,2.6)
    items.append(dict(kind=kinds[k%len(kinds)], x=math.cos(ang)*rad, z=math.sin(ang)*rad, y=pr.uniform(-1.0,1.0),
                      size=pr.uniform(0.35,0.65), ph=pr.uniform(0,6.28), rot=pr.uniform(-40,40)))
STREAKS=[(pr.uniform(0.2,0.85),pr.integers(1,3),pr.uniform(0,1),pr.uniform(0.3,1)) for _ in range(12)]

def composite(img,spr,cx,cy,scale,blur,alpha,rot):
    size=max(6,int(spr.shape[0]*scale))
    s=cv2.resize(spr,(size,size),interpolation=cv2.INTER_AREA)
    if rot:
        Mx=cv2.getRotationMatrix2D((size/2,size/2),rot,1); s=cv2.warpAffine(s,Mx,(size,size),borderValue=(0,0,0,0))
    pad=int(blur*3)+2
    s=cv2.copyMakeBorder(s,pad,pad,pad,pad,cv2.BORDER_CONSTANT,value=(0,0,0,0))
    if blur>0.3: s=cv2.GaussianBlur(s,(0,0),blur,borderType=cv2.BORDER_CONSTANT)
    size=s.shape[0]
    x0=int(cx-size/2); y0=int(cy-size/2)
    xa,ya=max(0,x0),max(0,y0); xb,yb=min(W,x0+size),min(H,y0+size)
    if xb<=xa or yb<=ya: return
    sub=s[ya-y0:yb-y0,xa-x0:xb-x0]
    a=sub[...,3:4]*alpha
    img[ya:yb,xa:xb]=img[ya:yb,xa:xb]*(1-a)+sub[...,:3]*alpha

def frame(i):
    t=i/N; T=2*np.pi*t
    # studio background
    d=np.sqrt(((xx-W*0.5)/W)**2*1.2+((yy-H*0.42)/H)**2)
    img=(hexc('#0c2a30')*np.exp(-d*d*5)[...,None]*1.1+hexc('#030708')).astype(np.float32)
    spot=np.exp(-(((xx-W*0.62)/(W*0.25))**2+((yy-H*0.1)/(H*0.45))**2))
    img+=spot[...,None]*hexc('#f2a65a')*0.08
    # floor glow
    img+=np.exp(-((yy-H*0.9)/(H*0.12))**2)[...,None]*hexc('#1f6b73')*0.25

    # light streaks (speed / delivery) behind items
    st=np.zeros((H,W),np.float32)
    for (sy,k,ph,br) in STREAKS:
        x=((t*k+ph)%1.0)*(W+900)-450
        y=int(H*sy)
        for seg in range(12):
            a0=x-420+seg*35; a1=a0+35
            cv2.line(st,(int(a0),y),(int(a1),y),float(br*(seg/11)**2),1 if seg<9 else 2,cv2.LINE_AA)
    st=cv2.GaussianBlur(st,(0,0),1.5)+cv2.GaussianBlur(st,(0,0),12)*2
    ramp=np.clip(xx/W,0,1)
    img+=st[...,None]*(hexc('#8fe3d9')*0.18+hexc('#f2a65a')*0.08)

    yaw=0.45*math.sin(T)
    cy_,sy_=math.cos(yaw),math.sin(yaw)
    proj=[]
    for it in items:
        x=it['x']*cy_-it['z']*sy_; z=it['x']*sy_+it['z']*cy_
        y=it['y']+0.08*math.sin(T*2+it['ph'])
        zc=z+4.0
        sx=W/2+x/zc*W*0.62; syp=H*0.48+y/zc*W*0.62
        proj.append((zc,sx,syp,it))
    proj.sort(key=lambda p:-p[0])
    for zc,sx,syp,it in proj:
        scale=it['size']*3.2/zc
        focus=abs(zc-4.0)*5.5
        rot=it['rot']+10*math.sin(T+it['ph'])
        composite(img,sprites[it['kind']],sx,syp,scale,focus,1.0,rot if it['kind'].startswith('box') else 0)

    # route arc with a traveling light
    route=np.zeros((H,W),np.float32)
    pts=[]
    for k in range(200):
        u=k/199
        pts.append((W*(0.12+0.76*u), H*(0.86-0.18*math.sin(u*math.pi))))
    cv2.polylines(route,[np.array(pts,np.int32).reshape(-1,1,2)],False,0.35,1,cv2.LINE_AA)
    u=(t*2)%1.0
    px,py=W*(0.12+0.76*u), H*(0.86-0.18*math.sin(u*math.pi))
    dot=np.zeros((H,W),np.float32); cv2.circle(dot,(int(px),int(py)),4,1.0,-1,cv2.LINE_AA)
    route=route+cv2.GaussianBlur(dot,(0,0),14)*14+dot
    img+=route[...,None]*hexc('#f2a65a')*0.6

    img=bloom(img,0.6,25,0.5)
    img=tonemap(img*1.08)
    img=vignette(img,0.65)
    img=grain(img,0.013,2000+i)
    return img

if __name__=='__main__':
    if sys.argv[1]=='test':
        for i in [0,60]:
            cv2.imwrite(f'com_{i}.jpg',(np.clip(frame(i),0,1)*255).astype(np.uint8))
    else:
        e=Encoder(sys.argv[1])
        for i in range(N):
            e.write(frame(i))
            if i%24==0: print(i,flush=True)
        e.close()
