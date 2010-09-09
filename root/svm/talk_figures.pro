pro talk_figures
  common talk_figures, m, rawm
  if 0 or n_elements(m) eq 0 then begin
     m =mrdfits('mosaic.fits',0,h)
     mask = total(finite(m), 3) ne 0
     mask = erode(mask, replicate(1, 10, 10))
     sz = size(m)
     m *= rebin(mask, sz[1], sz[2], sz[3])

     bad = where(~finite(m))
     nanswap, m, 0
     
     b = border_indices(m, [15, 15, 50])
     m = bytscl(m)
     m[b] = 0
     m[bad] = 0
  endif

  ;- postage stamp image
  wedit, 0, xsize = 1000, ysize = 500
  p1 = [0, 0, .33, 1]
  p2 = [.33, 0, .66, 1]
  p3 = [.66, 0, .99, 1]
  erase
  loadct, 1
  tvimage, m[108,*,*], pos = p1, /keep
  tvimage, m[*, 190, *], pos = p2, /keep
  tvimage, m[*, *, 185], pos = p3, /keep
  write_png, 'slice.png', tvrd(/true)


  ;- confusion image
  wedit, 0, xsize = 400, ysize = 800
  tvimage, m[138, *, *], /keep
  write_png, 'confusion.png', tvrd(/true)

  ;- training image
  restore, 'train_x172_cloud.sav'
  mask1 = reform(mask[172, *,*])
  restore, 'train_x172_snr.sav'
  mask2 = reform(mask[172,*,*])
  restore, 'train_x172_bg.sav'
  mask3 = reform(mask[172,*,*])

  erase
  pos = [.08, .08, .98, .98]
  tvimage, m[172, *, *], /keep, pos = pos
  write_png, 'train_nolabel.png', tvrd(/true)
  contour, mask1 * 0, /nodata, xsty = 5, ysty = 5, pos = pos, /noerase
  contour, mask1, color = fsc_color('crimson'), /over
  contour, mask2, color = fsc_color('white'), /over
  contour, mask3, color = fsc_color('green'), /over
  write_png, 'train_label.png', tvrd(/true)


  ;- animated gif of classification

end

pro talk_animation
  device, decomposed = 0
  common talk_figures, m, rawm
  if n_elements(m) eq 0 then begin
     m = mrdfits('mosaic.fits',0,h)
     mask = total(finite(m), 3) ne 0
     mask = erode(mask, replicate(1, 10, 10))
     sz = size(m)
     m *= rebin(mask, sz[1], sz[2], sz[3])

     bad = where(~finite(m))
     nanswap, m, median(m)
     
     b = border_indices(m, [15, 15, 50])
;     m -= min(m)
     rawm = m
     m = bytscl(sigrange(m))
     m[b] = 0
     m[bad] = 0
  endif
  
  
  h = headfits('mosaic.fits')
  cd = sxpar(h, 'cd2_2')
  npix = 10 / (cd * 3600 / 206265 * 3d3)
  print, npix / 2., npix / 2. * cd * 60

  common talk_animation, cloud, snr
  if 1 or n_elements(cloud) eq 0 then begin
     method='all'
     restore, method+'_classify.sav'
     
     nbad = total(mask le 0)
     ngood = total(mask ge 0)
     sz = size(m)
     mu = fltarr(sz[3]) & sigma = fltarr(sz[3])
     snr = rawm & cloud = rawm
     psf = psf_gaussian(npix = 7, fwhm = 2, /norm)
     iscloud = mask ge 0 and m ne 0
     issnr = mask lt 0 and m ne 0
     isdata = m ne 0
     for i = 0, sz[3] -1, 1 do begin
        if i mod 50 eq 0 then print, i
        mu = median(m[*,*,i]) & sigma = medabsdev(m[*,*,i], /sigma)
        hit = where(m[*,*,i] lt mu + 3 * sigma, ct)
        dat = (ct eq 0) ? m[*,*,i] : (m[*,*,i])[hit]
        mu = median(dat) & sigma = medabsdev(dat, /sigma)
        noise = (randomn(seed, sz[1], sz[2]) * sigma/2  + mu) * 0
        ;noise = convolve(noise, psf)
        noise = byte(0 > noise < 255)

        cloud[*,*,i] = m[*,*,i] * iscloud[*,*,i] + $
                       (~iscloud[*,*,i] and isdata[*,*,i]) * noise
        snr[*,*,i] = m[*,*,i] * issnr[*,*,i] + $
                     (~issnr[*,*,i] and isdata[*,*,i]) * noise
     endfor
  endif

;  writefits, 'cloud.fits',cloud, h
;  writefits, 'snr.fits', snr, h
;  return
  sz = size(m)

  domov = 1
  
  wedit, 0, xsize = sz[1], ysize = sz[2]
  wsz = size(tvrd())
  if domov then mov = mpeg_open([wsz[1], wsz[2]], quality = 100)
  
  loadct, 0 & tvlct, r1, g1, b1, /get
  loadct, 1 & tvlct, r2, g2, b2, /get
  ctload, 23, /brewer
  tvlct, r, g, b, /get
  r = reverse(r) & b = reverse(b) & g = reverse(g)
  tvlct, r, g, b
  colorbar, pos = [.05, .05, .95, .45]
  tvlct, b, g, r
  colorbar, pos = [.05, .5, .95, .95]
 ; return
  r[0] = 0 & g[0] = 0 & b[0] = 0
  ; loadct, 0, /silent
  erase
  p = [.025, 0, .475, .45] & p2 = [.285, .45, .725, .9] & p3 = [.525, 0, .975, .45]
  frame = 0
  delt = 1
  !p.font = 1
  csz = 2.5 & cthk = 1
  snrframe = 157
  for i = 80, 365 - 1, delt do begin
;     if not domov && i ne snrframe then continue
     hi = max(m[*,*,i])
     lo = min((m[*,*,i])[where(m[*,*,i] ne 0)])
     im1 = cloud[*,*,i] & im2 = m[*,*,i] & im3 = snr[*,*,i]
     if domov then lo = 0 & hi = 255
     f = bytarr(sz[1], sz[2], 3)
     f[*,*,0] = b[snr[*,*,i]] + r[cloud[*,*,i]]
     f[*,*,1] = g[snr[*,*,i] + cloud[*,*,i]]
     f[*,*,2] = r[snr[*,*,i]] + b[cloud[*,*,i]]
     p = [0, 0, 1, 1]
     tvimage, f, true = 3, pos = p, /keep
     contour, f[*,*, 0], /nodata, /noerase, pos = p, xsty = 5, ysty = 5
     oplot, [30, 30+npix/2], [250, 250], thick = 5, color = 0
;     help, f
;     return
;     tvimage, cloud[*,*,i]
     
     if domov then begin
        ;write_gif, 'classify.gif', tvrd(), /multiple, repeat = 0
        mpeg_put, mov, image=tvrd(/true, /order), frame = frame++
        ;write_png, 'classify_'+strtrim(frame,2)+'.png', tvrd(/true)
     endif

     continue
     im1 = byte(1. * ((lo > im1 < hi) - lo)/ (hi - lo) * 255)
     im2 = byte(1. * ((lo > im2 < hi) - lo)/ (hi - lo) * 255)
     im3 = byte(1. * ((lo > im3 < hi) - lo)/ (hi - lo) * 255)
     tvimage, im1, pos = p, /keep
     contour, cloud[*,*,i], pos = p, /nodata, /noerase, xsty = 5, ysty = 5
     oplot, [30, 30+npix/2], [250, 250], thick = 3
     tvimage, im2, pos = p2, /keep
     tvimage, im3, pos = p3, /keep
     xyouts, (p[0] + p[2])/2, p[3]+.0,  $
             'M17', /norm, charsize = csz, charthick = cthk, align=.5
     xyouts, (p2[0] + p2[2])/2, p2[3]+.0, $
             'Data', /norm, charsize = csz, charthick = cthk, align=.5
     xyouts, (p3[0] + p3[2])/2, p3[3]+.0, $
             'SNR', /norm, charsize = csz, charthick = cthk, align=.5
;     break
;     return

     if i eq snrframe then write_png, 'classify_snr.png', tvrd(/true)
     if abs(i - 323) lt 1 then write_png, 'classify_cloud.png', tvrd(/true)
;     return
  endfor
  if domov then begin
     mpeg_save, mov, file=method+'_classification.mpg'
     ;write_gif, 'classify.gif', tvrd(), /multiple, repeat = 0
     ;write_gif, 'classify.gif', tvrd(), /multiple, repeat = 0
     ;write_gif, 'classify.gif', tvrd(), /multiple, repeat = 0
     ;write_gif, 'classify.gif', tvrd(), /multiple, repeat = 0
     ;write_gif, /close
  endif
end

pro newsletter_fig

  im2 = read_png('classify_144.png')
  im3 = read_png('classify_136.png')
  im = read_png('classify_243.png')
  sz = size(im)
  big = bytarr(3, 3 *sz[2], sz[3])
  big[*, 0:sz[2]-1, *] = im3
  big[*, sz[2]:2*sz[2]-1, *] = im2
  big[*, 2*sz[2]:*,*]=im
  wedit, 0, xsize = 3 * sz[2], ysize = sz[3]
  tvimage, big, /true
  write_png, 'newsletter_fig.png', tvrd(/true)
end
