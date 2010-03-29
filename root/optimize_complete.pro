function optimize_function, x, data = data, psdata = psdata, $
                            complete = complete, $
                            e_complete = e_complete, $
                            _extra = extra
  compile_opt idl2

  thresh = .1                   ;- for completeness, in kpc
  
  inc = filter(x, psdata)
  n_miss = total(~inc and (data.dist lt thresh))
  complete = 1 - 1D * n_miss / total(data.dist lt thresh)
  
  e_complete = sqrt(1D * n_miss) / total(data.dist lt thresh)
  
  return, complete
end

function filter, x, psdata
  good = (psdata.pi gt x[0]  and $
          psdata.pi / psdata.sigma_pi gt x[1] and $
          psdata.mu gt x[2] and $
          psdata.mu / psdata.sigma_mu gt x[3])
  return, good
end


pro optimize, file
  data = read_besancon(file)
  psdata = besancon2psdata(data, /cut, /optimistic, /addnoise, /av)
  parallax = arrgen(0D, 7D, .5)
  pm = arrgen(0D, 100D, 5)
  output = fltarr(n_elements(parallax), n_elements(pm))
  output = transpose(output)
  complete = output
  reliable = output
  e_complete = output
  e_reliable = output
  
  for i = 0, n_elements(parallax) - 1, 1 do begin
     print, i
     for j = 0, n_elements(pm) - 1, 1 do begin
        output[j,i] = optimize_function([1/200D, parallax[i], 0, pm[j]], $
                                        data = data, psdata = psdata, $
                                        complete = c, thresh = .1, $
                                        e_com = ec)
        complete[j,i] = c
        number = total(data.dist lt .1)
        e_complete[j,i] = ec
     endfor
  endfor
  outfile = strtrun(file,'.txt')+'_com.sav'
  print, 'writing to '+outfile
  save, complete, e_complete, $
        parallax, pm, number, file=outfile
  return
  skip:
  out = 1
  if (out) then begin
     set_plot, 'ps'
      !p.font = 0
     device, /helvetica, /encap, ysize = 6, xsize= 10, /inches, file='complete.eps', /color
  endif else begin
     device, decomposed = 0
  endelse

  csz = 1.5
  cthk = 3
  lnthk = 5
  restore, 'optimize.sav'
  loadct, 0, /silent
  plot, [1],[1], xra = minmax(parallax), yra=[0,1], $
        xtit = textoidl('\pi / \sigma_\pi'), charsize = csz, charthick = cthk, /nodata, $
        ytit = 'Completeness', xthick = 5, ythick = 5
;  ctload, 20, /brewer
  loadct, 25, /silent
  parvec = arrgen(min(parallax), max(parallax), nstep = 100)
  print, minmax(parvec)
  for i = n_elements(pm)-1, 0, -1 do begin
;     oplot, parallax, output[*,i], color = i * 255 / n_elements(pm), thick = 2
  
     oploterror, parallax, complete[*, i], $
                 parallax * 0, e_complete[*, i], $
                 errcolor = i * 255 / n_elements(pm), line = 0, $
                 color = i * 255 / n_elements(pm), psym = 3
     x = spline(parallax, complete[*,i], parvec)
     oplot, parvec, x, color = i * 255 / n_elements(pm), $
            thick = lnthk
     xyouts, 6 + 2 * (i / ((n_elements(pm) + 1) / 2)), $
             .9 - .05 * (i mod ((n_elements(pm) + 1) / 2)), $
             textoidl('\mu / \sigma_\mu > '+strtrim(pm[i],2)), $
             color = i * 255 / n_elements(pm), charsize = csz * .8, $
             charthick = cthk

;     oploterror, parallax, reliable[*,i], $
;                 parallax * 0, e_reliable[*,i], $
;                 errcolor = i * 255 / n_elements(pm), line = 1, $
;                 color = i * 255 / n_elements(pm), psym = -3
  endfor
  if (out) then begin
     device, /close
     set_plot, 'X'
  endif
  loadct, 0
;  contour, complete, parallax, pm, /fill, nlev = 80
end

pro driver
  files = file_search('final_sims/*near.txt', count = ct)
  for i = 0, ct - 1, 1 do optimize, files[i]
end
