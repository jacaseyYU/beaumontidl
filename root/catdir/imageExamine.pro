pro imageExamine_display, im, x, y, m, nmeas
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
  
  stmp = congrid(stmp, xwin, ywin)
  sub = stmp[.4 * xwin : .6 * xwin, .4 * ywin : .6 * ywin]
  s = sort(sub)
  lo = sub[s[.02 * n_elements(sub)]]
  hi = sub[s[.98 * n_elements(sub)]]
;  lo = min(sub, max = hi)
  stmp = bytscl(lo > stmp < hi)
  stmp[.8 * xwin : *, *] = 0B

  tvscl, stmp
  scale = 1D * xwin / xstamp / 100
;  tvellipse, m.fwhm_major * scale, m.fwhm_minor * scale, xwin / 2, ywin / 2, m.psf_theta, $
;             thick = 3, color =fsc_color('purple')
  tvellipse, m.mxx * scale, m.myy * scale, xwin / 2, ywin / 2, $
             thick = 3, color =fsc_color('purple')
  

;- show which photflags are set
  color = fsc_color(['forestgreen', 'crimson'])
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
  for i = 0, nflag - 1, 1 do begin
     xyouts, .8, .95 - .02 * i, flagNames[i], $
             /norm, color = (m.phot_flags and flags[i]) eq 0 ? color[1] : color[0], $
             charsize = 1.5, charthick = 2
  endfor
  xyouts, .8, .95 - .02 * nflag, string(nmeas), charsize = 1.5, charthick = 2, $
          color = color[1], /norm


end

pro imageExamine
  
  
;-load image, catalogs, and select measurements from ccd00
  imname = '730998'
  
  save_file = '~/pro/'+imname+'.sav'
  image = mrdfits('/media/cave/catdir.98/Images.dat',1,h)

  if ~file_test(save_file) then begin
     m = mrdfits('/media/cave/catdir.98/n0000/0148.cpm', 1, h)
     t = mrdfits('/media/cave/catdir.98/n0000/0148.cpt', 1, h)
     nmeas = t[m.ave_ref].nmeasure
     good = where(strmatch(image[m.image_id - 1].name, '730998o*'), ct)
     m = m[good]
     nmeas = nmeas[good]
     save, m, nmeas, file=save_file
     print, 'Save file created. please re-run'
     return
  endif else restore, save_file

  sort = sort(randomu(seed, n_elements(m)))
  m = m[sort]
  nmeas = nmeas[sort]

  for i = 0, 35, 1 do begin
     print, i
     im = mrdfits('~/Desktop/'+imname+'o.fits', i+1, h, /silent)
     id = where(strmatch(image[m.image_id - 1].name, $
                         '730998o*ccd'+string(i,format='(i2.2)')+'*'), ct)
     if ct eq 0 then continue
  
     for i = 0, ct - 1, 1 do begin
        if (i + 1) mod 10 eq 0 then print, i, n_elements(id)
        imageExamine_display, im, m[id[i]].x_ccd + 33, m[id[i]].y_ccd + 1, $
                              m[id[i]], nmeas[id[i]]
        result = ''
        print, 'continue / [q]uit'
        read, result
        if string(result) eq 'q' then goto, die
     endfor
  endfor 

die:

end
   
