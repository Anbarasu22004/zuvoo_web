import numpy as np, cv2, subprocess, os
W,H,FPS,SEC = 1280,720,24,8
N = FPS*SEC
rng = np.random.default_rng(7)

def hexc(h): h=h.lstrip('#'); return np.array([int(h[i:i+2],16)/255 for i in (0,2,4)],np.float32)[::-1]  # BGR

def tile_noise(w,h,cells,seed):
    """Tileable smooth noise via upscaled periodic random grid."""
    r=np.random.default_rng(seed).random((cells[1],cells[0])).astype(np.float32)
    r=np.vstack([r,r[:1]]); r=np.hstack([r,r[:,:1]])
    big=cv2.resize(r,(w+w//cells[0],h+h//cells[1]),interpolation=cv2.INTER_CUBIC)
    return big[:h,:w]

def fbm_tile(w,h,seed,octaves=4,base=4,beta=2.2):
    """Periodic fractal noise via spectral synthesis (seamless in x and y)."""
    r=np.random.default_rng(seed)
    wn=r.normal(size=(h,w))
    F=np.fft.fft2(wn)
    fy=np.fft.fftfreq(h)[:,None]*h/w; fx=np.fft.fftfreq(w)[None,:]
    f=np.sqrt(fx**2+fy**2); f[0,0]=1
    F=F/(f**beta); F[0,0]=0
    F[f>base*2**octaves/w*8]=0
    n=np.real(np.fft.ifft2(F)).astype(np.float32)
    n=(n-n.min())/(n.max()-n.min())
    return n

def grain(img,strength=0.035,seed=None):
    g=np.random.default_rng(seed).normal(0,strength,(H//2,W//2)).astype(np.float32)
    g=cv2.resize(g,(W,H),interpolation=cv2.INTER_LINEAR)
    return img+g[...,None]

def vignette(img,k=0.55):
    y,x=np.mgrid[0:H,0:W].astype(np.float32)
    d=np.sqrt(((x-W/2)/(W/2))**2*0.8+((y-H/2)/(H/2))**2)
    v=np.clip(1-k*d**2.2,0,1)
    return img*v[...,None]

def bloom(img,thresh=0.6,radius=31,amt=0.6):
    b=np.clip(img-thresh,0,None)
    b=cv2.GaussianBlur(b,(0,0),radius)
    return img+b*amt

def tonemap(img):
    img=np.clip(img,0,None)
    img=img/(1+img*0.35)*1.12
    return np.clip(img,0,1)

class Encoder:
    def __init__(self,path):
        self.p=subprocess.Popen(['ffmpeg','-y','-loglevel','error','-f','rawvideo','-pix_fmt','bgr24','-s',f'{W}x{H}','-r',str(FPS),'-i','-',
            '-c:v','libx264','-preset','slow','-crf','23','-pix_fmt','yuv420p','-movflags','+faststart','-an',path],stdin=subprocess.PIPE)
    def write(self,img): self.p.stdin.write((np.clip(img,0,1)*255).astype(np.uint8).tobytes())
    def close(self): self.p.stdin.close(); self.p.wait()
