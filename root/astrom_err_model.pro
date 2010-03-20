function chisquare, a, params = params, data = data
  ;- assume we've already found the floor
  floor = params[0]
  psf = params[1]
  x = data[0, *]
  y = data[1, *]
  return, total( (y - sqrt(floor^2 + a^2 * psf^2 / x^2))^2, /nan)
end

function astrom_err_model, dx, snr, psf, plot = plot, chisq = chisq

  ;- check inputs
  if n_params() ne 3 then begin
     print, 'astrom_err_model calling sequence:'
     print, 'result = astrom_err_model(dx, snr, psf, [/plot]'
     print, 'result = [floor, fudge]'
  endif

  ;- bin data by SNR
  histo = histogram(alog(snr), nbins = 50, loc = loc, rev = ri)

  rms = loc * !values.f_nan

  for i = 0, n_elements(histo) - 1, 1 do begin
     if ri[i+1] lt ri[i] + 5 then continue
     
     s = dx[ri[ri[i] : ri[i+1] - 1]]
       
     rms[i] = medabsdev(s, /sigma)
  endfor
  loc = exp(loc)

  hisn = where(loc gt 100 and histo gt 5, hict)
  if hict eq 0 then return, !values.f_nan + [0,0]
  floor = median(rms[hisn])

  ;- determine best psf fudge factor
  params = [floor, psf]
  data = transpose([[loc],[rms]])
  if ~finite(floor) || ~finite(psf) then return, !values.f_nan + [0,0]

  bracket, 'chisquare', 1.0, 1.2, ax, bx, cx, fa, fb, fc, $
           data = data, params = params, /verbose
  fudge = brent('chisquare', ax, bx, cx, fa, fb, fc, $
                data = data, params = params, /verbose) 
    
  result = [floor, fudge]

  if arg_present(chisq) then begin
     chisq = total( dx^2 / (floor^2 + psf^2 / snr^2 * fudge^2), /nan) / $
           total(finite(dx))
  endif

  if ~keyword_set(plot) then return, result

  !p.multi = 0
  plot, snr, dx, /xlog, yra = [0, .3], psym = 3, /nodata, $
        xtit = 'SNR', ytit = 'Sigma_pos', charsize = 1.5
;  oplot, snr, dy, psym = 3, color = fsc_color('yellow')
 
  x = arrgen(1, 1d4, nstep = 500, /log)
  model = sqrt(floor^2 + fudge^2 * psf^2 / x^2)
  
  oplot, x, model
  oplot, loc, rms, psym = 5
  
  xyouts, .5, .8, string(floor, psf, fudge, $
                         format='("floor: ", f0.3, " psf: ", f0.3, " fudge: ", f0.2)'), $
                         color = fsc_color('white'), charsize = 1.5, /norm
  
  

  stop
  return, result
end
