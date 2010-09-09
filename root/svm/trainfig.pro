pro trainfig

  dox = 0
  if dox then begin
     m = mrdfits('mosaic.fits',0,h)
     slice = 232
     sl=strtrim(slice,2)
     m = reform(m[slice,*,*])
     
     mask = erode(finite(m), replicate(1, 2, 2))
     m *= mask
     nanswap, m, 0
     indices, m, x, y
     x *= sxpar(h, 'cd2_2') * 60
     x -= median(x)
     y = sxpar(h, 'crval3') + (y - sxpar(h, 'crpix3')) * sxpar(h, 'cd3_3')
     
     restore, 'train_x'+sl+'_bg.sav' & bg = reform(mask[slice,*,*])
     restore, 'train_x'+sl+'_cloud.sav' & cloud = reform(mask[slice,*,*])
     restore, 'train_x'+sl+'_snr.sav' & snr = reform(mask[slice,*,*])
  endif else begin ;- do y
     m = mrdfits('mosaic.fits',0,h)
     slice = 190
     sl=strtrim(slice,2)
     m = reform(m[*,slice,*])
     
     mask = erode(finite(m), replicate(1, 2, 2))
     m *= mask
     nanswap, m, 0
     indices, m, x, y
     x *= sxpar(h, 'cd2_2') * 60
     x -= median(x)
     y = sxpar(h, 'crval3') + (y - sxpar(h, 'crpix3')) * sxpar(h, 'cd3_3')
     
     restore, 'train_y'+sl+'_bg.sav' & bg = reform(mask[*,slice,*])
     restore, 'train_y'+sl+'_cloud.sav' & cloud = reform(mask[*,slice,*])
     restore, 'train_y'+sl+'_snr.sav' & snr = reform(mask[*,slice,*])
  endelse   
  p1 = [.12, .1, .54, .99]
  p2 = [.55, .1, .97, .99]
  csz = 1 & cthk = 1 &  thk = 2
;  erase
  device, decomposed = 0
  sz = size(m)
;  window, xsize = 2.1 * sz[1], ysize = 1.1 * sz[2]
  
  set_plot, 'ps'
  !p.font = 0
  device, /encap, /color, file='train.eps', $
          xsize = 5, ysize = 4, /inch, /helvetica
  c1 = fsc_color('crimson', /triple)
  c2 = fsc_color('forestgreen', /triple)
  c3 = fsc_color('royalblue', /triple)

;  loadct, 3, /silent
;  ctload, 15, /brewer
  tvlct, c1, 1
  tvlct, c2, 2
  tvlct, c3, 3

  tvimage, 4 > (255B - bytscl(asinh(m > 0))), pos = p1, /keep
  contour, snr, x, y, /nodata, /xsty, /ysty, /noerase, pos = p1, $
           xtit = textoidl("\Delta\delta (arcmin)"), $
           ytit=textoidl("V_{LSR} (km s^{-1})"), $
           charsize = csz*.8, yra = [max(y), min(y)], xthick = thk, ythick = thk
  tvimage, 4 > (255B - bytscl(asinh(m > 0))), pos = p2, /keep
  contour, snr, x, y, c_color = 3, /xsty, /ysty, /noerase, pos = p2, $
           ytickn=replicate(' ', 7), $
           charsize = csz * .8, yra = [max(y), min(y)], xthick = thk, ythick = thk
  contour, cloud, x, y, /over, c_color = 2
  contour, bg, x, y, /over, c_color = 1

  xyouts, .15, .93, 'supernova', color = 3, /norm, charsize = csz, charthick = cthk
  xyouts, .15, .88,'foreground', color = 2, /norm, charsize = csz, charthick = cthk
  xyouts, .15, .83, 'noise', color = 1, /norm, charsize = csz, charthick = cthk
  
  device, /close
  set_plot, 'x'

  loadct, 0, /silent
end
