;+
; Optimizes a data set for radial basis function kernels.
; x = [ln(c), ln(g)]
;-
function optimize_rbf, x, cloud = cloud, bg = bg, snr = snr, $
                       test = test, answer = answer, out2 = out2, $
                       single = single
  ;- 1=bg 2=cloud 3=snr
  c = exp(x[0]) & g = exp(x[1])
  if ~keyword_set(single) then begin
     m1 = svm_learn(bg, outfile='/tmp/model.1', $
                    kernel = 2, c = c, g = g, verbose = keyword_set(verbose))
     m2 = svm_learn(cloud, outfile='/tmp/model.2', $
                    kernel = 2, c = c, g = g, verbose = keyword_set(verbose))
     g1 = svm_classify(test, m1)
     g2 = svm_classify(test, m2)
  endif
  m3 = svm_learn(snr, outfile='/tmp/model.3', $
                 kernel = 2, c = c, g = g, verbose = keyword_set(verbose))

  g3 = svm_classify(test, m3)
  if keyword_set(single) then begin
     guess = g3 gt 0 
     result = total(guess eq 1 and answer eq 3)^2 / total(guess eq 1) / total(answer eq 3) 
     venn, total(guess eq 1), total(answer eq 3), total(guess eq 1 and answer eq 3), $
           title1='Classified', title2 = 'Truth'
     result = finite(result) && result gt 0 ? sqrt(result) : 0     
     out2 = result
     return, result
  endif else begin
     guess = (g1 gt (g2  > g3)) + 2 * (g2 gt (g1 > g3)) + 3 * (g3 gt (g1 > g2))
     return, optimize_eval(guess, answer, out2 = out2)
  endelse
end


function optimize_linear, x, cloud = cloud, bg = bg, snr = snr, $
                          test = test, answer = answer, out2 = out2, $
                          single = single
  
  c = exp(x)
  if ~keyword_set(single) then begin
     m1 = svm_learn(bg, outfile='/tmp/model.1', $
                    kernel = 0, c = c, verbose = keyword_set(verbose))
     m2 = svm_learn(cloud, outfile='/tmp/model.2', $
                    kernel = 0, c = c, verbose = keyword_set(verbose))
     g1 = svm_classify(test, m1)
     g2 = svm_classify(test, m2)
  endif
  m3 = svm_learn(snr, outfile='/tmp/model.3', $
                 kernel = 0, c = c, verbose = keyword_set(verbose))
  g3 = svm_classify(test, m3)
  
  if keyword_set(single) then begin
     guess = g3 gt 0 
     result = total(guess eq 1 and answer eq 3)^2 / total(guess eq 1) / total(answer eq 3)
     venn, total(guess eq 1), total(answer eq 3), total(guess eq 1 and answer eq 3), $
           title1='Classified', title2 = 'Truth'
     result = finite(result) && result gt 0 ? sqrt(result) : 0
     out2 = result
     return, result
  endif else begin
     guess = (g1 gt (g2  > g3)) + 2 * (g2 gt (g1 > g3)) + 3 * (g3 gt (g1 > g2))
     return, optimize_eval(guess, answer, out2 = out2)
  endelse
end


function optimize_eval, guess, answer, out2 = out2
  ;-out: geometric mean of precision, recall for everything
  ;-out2: geometric mean of precision, recal for answer 3 (snr)

  r = total(guess eq 1 and answer eq 1) / total(answer eq 1) * $
      total(guess eq 2 and answer eq 2) / total(answer eq 2) * $
      total(guess eq 3 and answer eq 3) / total(answer eq 3)
  p = total(guess eq 1 and answer eq 1) / total(guess eq 1) * $
      total(guess eq 2 and answer eq 2) / total(guess eq 2) * $
      total(guess eq 3 and answer eq 3) / total(guess eq 3)
  out2 = total(guess eq 3 and answer eq 3) / total(answer eq 3) * $
         total(guess eq 3 and answer eq 3) / total(guess eq 3)
  venn, total(guess eq 3), total(answer eq 3), total(guess eq 3 and answer eq 3), $
        title1 = 'Classified', title2 = 'Truth'
  out2 = sqrt(out2)
  return, (r * p)^(1D/6D)
end

pro svm_optimize, kernel = kernel, method = method, gvec = gvec, $
                  cvec = cvec, name = name, single = single, $
                  optimize2 = optimize2
  print, systime()

  head = headfits('mosaic.fits')
  nx = sxpar(head, 'naxis1') & ny = sxpar(head, 'naxis2')
  nz = sxpar(head, 'naxis3')

  methods = ['default', 'moment', 'edge', 'edge2', 'pca']
  m = methods[method]
  cloud = 'feature_cloud_train_'+m+'.dat'
  snr = 'feature_snr_train_'+m+'.dat'
  bg = 'feature_bg_train_'+m+'.dat'

  test = 'feature_multi_test_'+m
;  final='plane_x172_'+m+'.dat'
;  final_sav = 'plane_x172_'+m+'.sav'
  final='plane_y190_'+m+'.dat'
  final_sav = 'plane_y190_'+m+'.sav'

  restore, test+'.sav'
  answer = feature.label
  test+='.dat'

  ;- linear kernel
  if kernel eq 0 then begin
     if n_elements(cvec) eq 0 then message, 'must include cvec'
     cs = cvec
     best = cs * 0.
     best2 = best
     info = replicate({svm_info}, n_elements(cs))

     for i = 0, n_elements(cs) - 1, 1 do begin
        print, i, n_elements(cs)-1, systime()
        best[i] = optimize_linear(alog(cs[i]), snr = snr, cloud = cloud, bg = bg, $
                                  test = test, answer = answer, out2 = b, single = single)
        best2[i] = b
     endfor
     lo = max(best, loc)
     print, 'Min error is ', lo
     print, 'Best c is ', cs[loc]
     lab = ' c= '+string(cs[loc],format='(e0.2)')+$
           ' f= '+string(lo, format='(e0.2)')
     lo2 = max(best2, loc2)
     lab+= ' c= '+string(cs[loc2],format='(e0.2)')+$
           ' f= '+string(lo2,format='(e0.2)')
     bestc = keyword_set(optimize2) ? cs[loc] : cs[loc2]
     bestg = 1
     if n_elements(cs) gt 1 then begin
        loadct, 0, /silent
        plot, cs, best, psym = -4, /xlog, tit=lab
        oplot, cs, best2, psym = -4, color = fsc_color('red')
        print, systime()
     endif
     write_png, name+'.png', tvrd(/true)
  endif else if kernel eq 1 then begin
     ;- rbf kernel
     nc = n_elements(cvec)
     ng = n_elements(gvec)
     cs = rebin([cvec], nc, ng)
     gs = rebin(1#[gvec], nc, ng)
     best = cs * 0. & best2 = best
     for i = 0, nc - 1, 1 do begin
        for j = 0, ng - 1, 1 do begin
           print, i, j, ' '+systime()
           best[i,j] = optimize_rbf(alog([cvec[i], gvec[j]]), snr = snr, $
                                    cloud = cloud, bg = bg, answer = answer, test = test, $
                                    out2 = b, single = single)
           best2[i,j] = b
        endfor
     endfor
     print, systime()
     lo = max(best, loc)
     print, 'Min error is ', lo
     print, 'Best c is ', cs[loc]
     print, 'Best g is ', gs[loc]
     fmt = '(e0.2)'
     lab = ' c= '+string(cs[loc],format=fmt)+$
           ' g= '+string(gs[loc],format=fmt)+$
           ' f= '+string(lo,format=fmt)

     lo2 = max(best2, loc2)
     lab += ' c= '+string(cs[loc2],format=fmt)+$
            ' g= '+string(gs[loc2],format=fmt)+$
            ' f= '+string(lo2,format=fmt)
     
     if keyword_set(optimize2) then begin
        bestc = cs[loc2] & bestg = gs[loc2]
     endif else begin
        bestc = cs[loc] & bestg = gs[loc]
     endelse
     
     loadct, 0, /silent
     if n_elements(best) gt 1 then begin
        contour, best, cs, gs, nlev = 10, c_lab = replicate(1, 10), /xlog, /ylog, tit=lab, $
                 /xsty, /ysty
        contour, best2, cs, gs, nlev = 10, c_lab = replicate(1, 10), /over, c_color = fsc_color('red')
        oplot, [cs[loc]], [gs[loc]], psym = 4, symsize = 3
        oplot, [cs[loc2]], [gs[loc2]], psym = 4, symsize = 3, color = fsc_color('red')
     endif
     write_png, name+'.png', tvrd(/true)
  endif else message, 'Kernel must be 0 (linear) or 1 (rbf)'

  ;- write the best results to files
  if ~keyword_set(single) then begin
     m1 = svm_learn(bg, outfile='m1.dat', kernel = kernel*2, c = bestc, g = bestg)
     m2 = svm_learn(cloud, outfile='m2.dat', kernel = kernel*2, c = bestc, g = bestb)
     c1 = svm_classify(final, m1)
     c2 = svm_classify(final, m2)
  endif

  m3 = svm_learn(snr, outfile='m3.dat', kernel = kernel*2, c = bestc, g = bestg)
  c3 = svm_classify(final, m3)

  if ~keyword_set(single) then begin
     c = 1 * (c1 gt c2 and c1 gt c3) + $
         2 * (c2 gt c1 and c2 gt c3) + $
         3 * (c3 gt c1 and c3 gt c2)
  endif else begin
     c = 3 * (c3 gt 0) + 1 * (c3 le 0)
  endelse

  restore, final_sav
;  mask = fltarr(ny/2, nz/3)
;  mask[feature.y/2, feature.z/3] = c
;  mask = rebin(mask, ny/2*2, nz/3*3, /sample)
  mask = fltarr(nx/2, nz/3)
  mask[feature.x/2, feature.z/3]=c
  mask = rebin(mask, nx/2*2, nz/3*3, /sample)

  indices, mask, x, y
;  result = fltarr(ny, nz)
  result = fltarr(nx, nz)

  result[x,y] = mask
;  error = result[feature.y, feature.z] ne c
  error = result[feature.x, feature.z] ne c
  assert, max(error) eq 0
  m = mrdfits('mosaic.fits')
;  m = reform(m[172,*,*])
  m = reform(m[*,190,*])
  mask = erode(finite(m), replicate(1, 5, 5))
  m *= mask

  writefits, name+'_snr.fits', m * (result eq 3)
  writefits, name+'_cloud.fits', m * (result eq 2)
  writefits, name+'_bg.fits', m * (result eq 1)
  erase
  loadct, 3, /silent
;  window, xsize = 3 * nx, ysize = nz
  tvimage, nanscale(m * (result eq 1)), pos = [0, 0, .33, 1], /keep
  tvimage, nanscale(m * (result eq 2)), pos = [.33, 0, .66, 1], /keep
  tvimage, nanscale(m * (result eq 3)), pos = [.66, 0, .99, 1], /keep
  write_png, name+'_im.png', tvrd(/true)
  loadct, 0, /silent
  return

end
     
pro driver
  ;- method = 0, kernel = 0. c = .1-.3. 
  ;- method = 0, kernel = 1. c = .693 g = .0464
  ;- method = 2, kernel = 0. c = 1-10. _very_ flat fitness curve from 1-1d3
  ;- method = 2, kernel = 1. c=94 g=.3
  cvec = arrgen(1d-1, 2d1, nstep = 10, /log)
  gvec = arrgen(5d-6, 1d0, nstep = 10, /log)
;  print, 't0'
;  svm_optimize, kernel = 0, method=0, cvec = cvec, gvec = gvec, name='t0'
;  print, 't1'
;  svm_optimize, kernel = 0, method=2, cvec = cvec, gvec = gvec, name='t1'
;  print, 't2'
;  svm_optimize, kernel = 1, method=0, cvec = cvec, gvec = gvec, name='t2'
;  print, 't3'
;  svm_optimize, kernel = 1, method=2, cvec = cvec, gvec = gvec, name='t3'
;  print, 't4'
;  svm_optimize, kernel = 0, method = 1, cvec = cvec, gvec = gvec, name='t4'
;  print, 't5'
;  svm_optimize, kernel = 1, method = 1, cvec = cvec, gvec = gvec, name='t4'
;svm_optimize, kernel = 0, method = 0, cvec = cvec, gvec = gvec, name='t10'  
;svm_optimize, kernel = 0, method = 1, cvec = cvec, gvec = gvec, name='t11'  
;svm_optimize, kernel = 0, method = 2, cvec = cvec, gvec = gvec, name='t12'  
;svm_optimize, kernel = 0, method = 3, cvec = cvec, gvec = gvec, name='t13'  
;svm_optimize, kernel = 1, method = 0, cvec = cvec, gvec = gvec, name='t14'  
;svm_optimize, kernel = 1, method = 1, cvec = cvec, gvec = gvec, name='t15'  
;svm_optimize, kernel = 1, method = 2, cvec = cvec, gvec = gvec, name='t16'  
;svm_optimize, kernel = 1, method = 3, cvec = cvec, gvec = gvec,
;name='t17'  
;svm_optimize, kernel = 0, method = 4, cvec = cvec, gvec = gvec, name='t20'  
;svm_optimize, kernel = 0, method = 4, cvec = cvec, gvec = gvec,
;name='t20'  
;  svm_optimize, kernel = 0, method = 4, cvec = [1d-4, .27], name='t20a'
;  svm_optimize, kernel = 0, method = 4, cvec = [1d-4, 20], name='t20b', $
;                /optimize2

;  svm_optimize, kernel = 0, method = 0, cvec = arrgen(1d-3, 1, nstep = 10,/log), /single, name='t20'
;  svm_optimize, kernel = 0, method = 1, cvec = arrgen(1d-3, 1, nstep = 10,/log), /single, name='t21'
;  svm_optimize, kernel = 0, method = 2, cvec = arrgen(1d-3, 1, nstep = 10,/log), /single, name='t22'
;  svm_optimize, kernel = 0, method = 3, cvec = arrgen(1d-3, 1, nstep = 10,/log), /single, name='t23'
;  svm_optimize, kernel = 0, method = 4, cvec = arrgen(1d-3, 1, nstep = 10,/log), /single, name='t24'

;  svm_optimize, kernel = 1, method = 0, cvec = cvec, gvec = gvec, /single, name='t25'
;  svm_optimize, kernel = 1, method = 1, cvec = cvec, gvec = gvec, /single, name='t26'
;  svm_optimize, kernel = 1, method = 2, cvec = cvec, gvec = gvec, /single, name='t27'
;  svm_optimize, kernel = 1, method = 3, cvec = cvec, gvec = gvec, /single, name='t28'
;  svm_optimize, kernel = 1, method = 4, cvec = cvec, gvec = gvec, /single, name='t29'

;  svm_optimize, kernel = 0, method = 0, cvec = [4.64d-3], /single, name='t20a'
;  svm_optimize, kernel = 0, method = 1, cvec = [.1], /single, name='t21a'
;  svm_optimize, kernel = 0, method = 2, cvec = [1d-3], /single, name='t22a'
;  svm_optimize, kernel = 0, method = 3, cvec = [4.64d-2], /single, name='t23a'
;  svm_optimize, kernel = 0, method = 4, cvec = [1d-3], /single, name='t24a'

;  svm_optimize, kernel = 1, method = 0, cvec = [3.42], gvec = [1.13d-3], /single, name='t25a'
;  svm_optimize, kernel = 1, method = 1, cvec = [1.90], gvec = [1.71d-2], /single, name='t26a'
;  svm_optimize, kernel = 1, method = 2, cvec = [.585], gvec = [2.92d-4], /single, name='t27a'
;  svm_optimize, kernel = 1, method = 3, cvec = [1d-1], gvec = [5d-6], /single, name='t28a'
;  svm_optimize, kernel = 1, method = 4, cvec = [6.16], gvec = [1.13d-3], /single, name='t29a'
;- Aug 3: Found some bugs in calculating optimization
;  functions. starting to explore again
  cvec = arrgen(1d-3, 3d-1, nstep = 10, /log)
  gvec = arrgen(5d-6, 1d0, nstep = 10, /log)
   svm_optimize, kernel = 0, method = 3, cvec = cvec, gvec = gvec, /single, name='t50'
 
end


pro final_classify

;  goto, jump

  file = 'plane_x232'
  restore, file+'_pca.sav'
  test_data = feature

  dfile = file+'_pca'
  restore, dfile+'.sav'

  model = svm_learn('feature_cloud_x172_pca.dat', $
                    outfile = 'model_pca.dat', $
                    kernel = 2, c = 227, g = .08)
  model2 = svm_learn('feature_cloud_x172_default.dat', $
                     outfile = 'model_default.dat', $
                     kernel = 2, c = 278, g = 1)
  model3 = svm_learn('feature_snr_x172_pca.dat', $
                     outfile = 'model_pca_snr.dat', $
                     kernel = 2, c = 1d3, g = .464)

  class = sign(svm_classify(file+'_pca.dat', model))
  class2 = sign(svm_classify(file+'_default.dat', model2))
  class3 = sign(svm_classify(file+'_pca.dat', model3) * (-1))
  class = class + class2 + class3
  
  buffer = 0
  pos = where(class gt 0) & neg = where(class lt 0)
  issnr = where(class lt 0, complement = notsnr, ncomp = notsnrct)
  iscloud = where(class gt 0, complement = notcloud, ncomp = notcloudct)
  
  ;- negative examples
  m = mrdfits('mosaic.fits',0,h,/silent) & nanswap, m, 0
  m = bytscl(sigrange(m))
  ;m = reform(m[*, 142, *])
  m = reform(m[232, *, *])
  b = border_indices(m, [15, 50])
  m[b] = 0
  cloud = m & snr = m
  sig = medabsdev(m, /sigma) & mu = median(m)

  x = test_data.x & y = test_data.y & z = test_data.z
  sz = size(m)
  help, iscloud
;  snr[x[notsnr], z[notsnr]] = (randomn(seed, notsnrct) * sig + mu) > 0
;  cloud[x[notcloud], z[notcloud]] = (randomn(seed, notcloudct) * sig + mu) > 0
  snr[y[notsnr], z[notsnr]] = (randomn(seed, notsnrct) * sig + mu) > 0
  cloud[y[notcloud], z[notcloud]] = (randomn(seed, notcloudct) * sig + mu) > 0
;  stop
  save, snr, cloud, m, file = 'svm_optimize.sav'

  jump:
  restore, 'svm_optimize.sav'
  loadct, 0, /silent
  erase
  loadct, 3, /silent

  p = [0, .05, .33, .99]
  tvimage, cloud, pos = p, /keep
  p = [.33, .05, .66, .99]
;  loadct, 0, /silent
  tvimage, m, pos = p, /keep
  p = [.66, .05, .99, .99]
;  loadct, 3, /silent
  tvimage, snr, pos = p, /keep

end
  
pro classify_cube

  file = 'data_edge2.dat'

  ;- train SVM based on parameters determined from driver
  c = 5.85e-2 & g = 6.15e-1
  m1 = svm_learn('feature_bg_all_edge2.dat', $
                 outfile='m1.dat', kernel = 2, c = c, g=g)
  m2 = svm_learn('feature_cloud_all_edge2.dat', $
                 outfile='m2.dat', kernel = 2, c = c, g=g)
  m3 = svm_learn('feature_snr_all_edge2.dat', $
                 outfile='m3.dat', kernel = 2, c = c, g=g)
  m1 = 'm1.dat' & m2 = 'm2.dat' & m3 = 'm3.dat'

  ;- apply to full cube data (whose features are sampled on a 2x2x3 grid)
  restore, 'cube_mask.sav'
  restore, 'data_edge2.sav'
  sz = size(mask)
  mask = intarr(sz[1] / 2, sz[2] / 2, sz[3] / 3)
  
  c1 = svm_classify(file, m1)
  c2 = svm_classify(file, m2)
  c3 = svm_classify(file, m3)
  c = 1 * (c1 gt c2 and c1 gt c3) + $
      2 * (c2 gt c1 and c2 gt c3) + $
      3 * (c3 gt c1 and c3 gt c2)
  mask[feature.x/2, feature.y/2, feature.z/3] = c

  ;- bin back to full size
  mask = rebin(mask, sz[1]/2*2, sz[2]/2*2, sz[3]/3*3, /sample)
  indices, mask, x, y, z
  m = intarr(sz[1], sz[2], sz[3])
  m[x,y,z] = mask
  mask = m
  save, mask, file='cube_classify_edge2.sav'
  classify_image
end

pro classify_image
  restore, 'cube_classify_edge2.sav'
  m = mrdfits('mosaic.fits', 0, h)
  mu = .7 & sig = .39*2
  mu = .2 & sig = 0
  sz = size(m)
  shrink = 1.5
  noise = randomn(seed, sz[1]/shrink, sz[2]/shrink, sz[3]) * sig + mu
  noise = congrid(noise, sz[1], sz[2], sz[3])
  writefits, 'snr.fits', m * (mask eq 3) + noise * (mask ne 3), h
  writefits, 'cloud.fits', m * (mask eq 2) + noise * (mask ne 2), h
  writefits, 'bg.fits', m * (mask eq 1) + noise * (mask ne 1), h
end
