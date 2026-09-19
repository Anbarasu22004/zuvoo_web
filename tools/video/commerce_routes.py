import sys, math, numpy as np, cv2
from common_square import *

MS=1600
rng=np.random.default_rng(12)
yy,xx=np.mgrid[0:H,0:W].astype(np.float32)

# ---- flat city map ----
base=np.zeros((MS,MS,3),np.float32); base[:]=hexc('#061015')
tex=fbm_tile(MS,MS,31,5,4,2.0)
base*= (0.8+0.4*tex[...,None])
# blocks
xs=np.cumsum(rng.integers(70,150,40)); xs=xs[xs<MS]
ys=np.cumsum(rng.integers(70,150,40)); ys=ys[ys<MS]
for i in range(len(xs)-1):
    for j in range(len(ys)-1):
        c=hexc('#0b1d23')*(0.7+0.6*rng.random())
        if rng.random()<0.07: c=hexc('#0d2a22')*1.1   # park
        cv2.rectangle(base,(int(xs[i])+7,int(ys[j])+7),(int(xs[i+1])-7,int(ys[j+1])-7),tuple(c.tolist()),-1)
streets=np.zeros((MS,MS),np.float32)
for x in xs:
    cv2.line(streets,(int(x),0),(int(x),MS),1.0 if rng.random()<0.25 else 0.55,3 if rng.random()<0.25 else 2)
for y in ys:
    cv2.line(streets,(0,int(y)),(MS,int(y)),1.0 if rng.random()<0.25 else 0.55,3 if rng.random()<0.25 else 2)
# river
pts=[(int(MS*u),int(MS*(0.78+0.08*math.sin(u*5)))) for u in np.linspace(0,1,60)]
cv2.polylines(base,[np.array(pts,np.int32)],False,tuple(hexc('#08263a').tolist()),46,cv2.LINE_AA)
base+=streets[...,None]*hexc('#1f4a52')*0.55
base=cv2.GaussianBlur(base,(0,0),0.7)

# ---- deliveries along streets ----
def nearest(v,arr): return int(arr[np.argmin(np.abs(arr-v))])
store=(nearest(MS*0.5,xs),nearest(MS*0.5,ys))
deliveries=[]
for k in range(9):
    tx=nearest(MS*(0.15+0.7*rng.random()),xs); ty=nearest(MS*(0.12+0.62*rng.random()),ys)
    if rng.random()<0.5:
        path=[store,(tx,store[1]),(tx,ty)]
    else:
        path=[store,(store[0],ty),(tx,ty)]
    seg=[np.hypot(path[i+1][0]-path[i][0],path[i+1][1]-path[i][1]) for i in range(2)]
    deliveries.append(dict(path=path,seg=seg,L=sum(seg)+1e-3,phase=k/9,cycles=1 if k%3 else 2))

def point_at(d,u):
    s=u*d['L']; p=d['path']
    for i in range(2):
        if s<=d['seg'][i] or i==1:
            f=min(1,s/max(d['seg'][i],1e-3))
            return (p[i][0]+(p[i+1][0]-p[i][0])*f, p[i][1]+(p[i+1][1]-p[i][1])*f)
        s-=d['seg'][i]

def frame(i):
    t=i/N; T=2*np.pi*t
    m=base.copy()
    glow=np.zeros((MS,MS,3),np.float32)
    for d in deliveries:
        c=(t*d['cycles']+d['phase'])%1.0
        u=np.clip(c/0.7,0,1)             # travel, then arrive + rest
        ease=u*u*(3-2*u)
        # full route faint
        cv2.polylines(glow,[np.array(d['path'],np.int32)],False,tuple((hexc('#3fb8ad')*0.18).tolist()),3,cv2.LINE_AA)
        # travelled trail
        n=24; tr=[point_at(d,ease*k/n) for k in range(n+1)]
        cv2.polylines(glow,[np.array(tr,np.int32)],False,tuple((hexc('#7fe3d6')*0.9).tolist()),4,cv2.LINE_AA)
        hx,hy=tr[-1]
        if u<1:
            cv2.circle(glow,(int(hx),int(hy)),9,tuple(hexc('#f2a65a').tolist()),-1,cv2.LINE_AA)
        # destination pin + arrival ripple
        dx,dy=d['path'][-1]
        cv2.circle(glow,(int(dx),int(dy)),7,tuple((hexc('#e8fffb')*0.8).tolist()),-1,cv2.LINE_AA)
        if u>=1:
            a=(c-0.7)/0.3
            cv2.circle(glow,(int(dx),int(dy)),int(12+70*a),tuple((hexc('#f2a65a')*(1-a)*1.2).tolist()),3,cv2.LINE_AA)
            cv2.circle(glow,(int(dx),int(dy)),10,tuple(hexc('#f2a65a').tolist()),-1,cv2.LINE_AA)
    # store beacon
    pulse=0.5+0.5*math.sin(T*4)
    cv2.circle(glow,store,16,tuple((hexc('#f2a65a')*1.4).tolist()),-1,cv2.LINE_AA)
    cv2.circle(glow,store,int(30+22*pulse),tuple((hexc('#f2a65a')*0.6).tolist()),3,cv2.LINE_AA)
    g=cv2.GaussianBlur(glow,(0,0),10)*1.6+cv2.GaussianBlur(glow,(0,0),3)*0.8+glow
    m=m+g
    # camera: tilted, slowly orbiting around the store
    yaw=math.sin(T)*0.12
    cx,cy=store[0]+math.sin(T)*40,store[1]+80+math.cos(T)*30
    half=MS*0.34
    near=half*0.95; far=half*1.35; depth=half*1.25
    def rot(px,py):
        return (cx+px*math.cos(yaw)-py*math.sin(yaw), cy+px*math.sin(yaw)+py*math.cos(yaw))
    quad=np.float32([rot(-far*1.9,-depth*1.5),rot(far*1.9,-depth*1.5),rot(near,depth*0.5),rot(-near,depth*0.5)])
    Mx=cv2.getPerspectiveTransform(quad,np.float32([[0,0],[W,0],[W,H],[0,H]]))
    img=cv2.warpPerspective(m,Mx,(W,H),flags=cv2.INTER_LINEAR,borderMode=cv2.BORDER_CONSTANT,borderValue=tuple(hexc('#040a0d').tolist()))
    # atmospheric haze toward horizon
    haze=np.clip(1-yy/(H*0.55),0,1)**1.6
    img=img*(1-haze[...,None]*0.75)+hexc('#0e2a31')[None,None,:]*haze[...,None]*0.6
    sky=np.exp(-((yy)/(H*0.18))**2)
    img+=hexc('#f2a65a')[None,None,:]*(sky*0.06)[...,None]
    img=bloom(img,0.6,18,0.5)
    img=tonemap(img*1.1)
    img=vignette(img,0.45)
    img=grain(img,0.012,3000+i)
    return img

if __name__=='__main__':
    if sys.argv[1]=='test':
        for i in [30,120]: cv2.imwrite(f'cr_{i}.jpg',(np.clip(frame(i),0,1)*255).astype(np.uint8))
    else:
        e=Encoder(sys.argv[1])
        for i in range(N):
            e.write(frame(i))
            if i%24==0: print(i,flush=True)
        e.close()
