pro classifyImages_display, im, x, y
  sz = size(im)
  xsz = sz[1]
  ysz = sz[2]
  xwin = 600
  ywin = 600
  xstamp = 100
  ystamp = 100
  window, xsize = xwin, ysize = ywin
  xp =rebin(findgen(xstamp) - xstamp / 2., xstamp, ystamp)
  yp = rebin(1#(findgen(ystamp) - ystamp / 2.), xstamp, ystamp)
  
  subx =  0 > (xp + x) < (xsz - 1)
  suby = 0 > (yp + y) < (ysz - 1)
  stmp = im[subx, suby]
  
  tvscl, congrid(sigrange(stmp), xwin, ywin)
end

pro classifyImages

flagNames = ['psfMod', 'extMod', 'fitted', 'fail', $
             'poor', 'pair', 'psfstar', 'satstar', $
             'blend', 'external', 'badpsf', 'defect', $
             'saturated', 'cr_lim', 'ext_lim', 'moment_fail', $
             'sky_fail', 'skyvar_fail', 'below_mom_sn', 'big_rad', $
             'ap_mag', 'blend_fit', 'ext_fit', 'extend_stat', 'lin_fit', $
             'nonlin_fit', 'radial_flux', 'mode_sz_skip']
nflag = n_elements(flagNames)
flags = lonarr(nflag)
for i = 0L, nflag-1, 1 do flags[i] = 2L^long(i)


;-load image, catalogs, and select measurements from ccd00
;imname = '781110'
imname = '730998'
im = mrdfits('~/Desktop/'+imname+'o.fits', 9, h, /silent)

;loadCatdir, 'catdir.107.exp', m, a, s, n, image
m = mrdfits('~/Desktop/0148.cpm', 1, h, range = [1000000, 1200000])
image = mrdfits('~/Desktop/Images.dat',1,h)
id = where(strmatch(image[m.image_id - 1].name, '730998o*ccd08*'), ct)

if n_elements(id) eq 1 then begin
   print, 'skipping'
   return
endif


;-update old catalog to fix flags
;restore, 'classifications_original.sav'
;c = classifications
;subm = m[id]
;for i = 0, nflag-1, 1 do classifications[i,*] = (long(subm.phot_flags) and flags[i]) gt 0
;save, classifications, nflag, flags, flagnames, file='classifications.sav'

;return

;-result data
classifications = uintarr(nflag + 3,n_elements(id))

for i = 0, n_elements(id)-1, 1 do begin
   if (i + 1) mod 10 eq 0 then print, i, n_elements(id)
   classifyImages_display, im, m[id[i]].x_ccd + 33, m[id[i]].y_ccd + 1
   ask:
   print, '1:good 0:bad q:quit'
   read, result
   if string(result) eq 'q' then goto, die
   if result ne 1 && result ne 0 then begin
      print, 'invalid (1/0/q)'
      goto, ask
   endif

   for j = 0, nflag-1, 1 do $
      classifications[j,i] = (ulong64(m[id[i]].phot_flags) and flags[j]) gt 0
   magErr = m[id[i]].mag_err
   classifications[nflag, i] = finite(magErr) ? 5 * (magErr < .999) : 4
;   classifications[nflag + 1, i] = a[m[id[i]].ave_ref].nmeas
   classifications[nflag + 2, i] = result

endfor

die:
;save, flags, flagNames, nFlag, classifications, file='classifications.sav'
return

end
   
