pro ircolor, bubnum
on_error, 2
if n_params() eq 0 then message, 'calling sequence: ircolor, bubble number'

mipsdir = '/users/cnb/mipsgal/'
jcmtdir = '/users/cnb/harp/bubbles/reduced/'
iracdir = '/users/cnb/glimpse/fits/I3/'

;-read in images
jcmtfile = jcmtdir+'N'+string(bubnum,format="(i3.3)")+'.fits'
if ~file_test(jcmtfile) then message, 'No JCMT image for bubble'
jcmt = mrdfits(jcmtfile,0,hj)

irfile = iracdir+strtrim(string(bubnum),2)+'_I3.fits'
if ~file_test(irfile) then message, 'No IRAC image for bubble'
irac = mrdfits(irfile,0,hi)

;- parse info for mips image
iast = nextast(hi)
jast = nextast(hj)
b = jast.crval[1]
l = jast.crval[0]
mipsfile = mipsdir+'MG'+string(round(l),format="(i3.3)")+'0'
if b ge 0 then $
  mipsfile += 'p005_024.fits' $
else $
  mipsfile += 'n005_024.fits'
mips = mrdfits(mipsfile, 0, hm);
mast = nextast(hm)

;- register the images
ir = irac
sz = size(ir)
xind = rebin(findgen(sz[1]), sz[1],sz[2]) - sz[1] / 2. + mast.sz[0] / 2.
yind = rebin(1 # findgen(sz[2]), sz[1], sz[2]) - sz[2] / 2. + mast.sz[1] / 2.
loncen = sxpar(hm, 'lplate')
latcen = sxpar(hm, 'bplate')
;- offset
dx = -(loncen - l) / mast.cd[0,0]
dy = -(latcen - b) / mast.cd[1,1]
xind += dx
yind += dy

;- scale
mag = mast.cd[0,0] / iast.cd[0,0]
dx /= mag
dy /= mag
mi = mips[( 0 > xind < mast.sz[0]),(0 > yind < mast.sz[1])]

;-shift
correl_optimize, ir, mi, xoff, yoff
print, xoff, yoff
hm = shift(mi, xoff, yoff)

color = fltarr(3, sz[1], sz[2])
wi = 1.0
wm = 1.0

bad = where(~finite(mi), ct)
if ct ne 0 then mi[bad] = 0;
bad = where(~finite(ir),ct)
if ct ne 0 then ir[bad] = 0;

color[0,*,*] = bytscl(sigrange(mi, frac = .95))
color[2,*,*] =bytscl( sigrange(ir, frac=.95))

sz = size(color)
window,0, xsize = sz[2], ysize=sz[3]
tvscl, color, /true

stop

end
