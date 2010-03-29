pro interlopers

  ;- for now, get interloper count for nearby catalog (r=100pc)
  ;- fixed pi cut at 125 pc
  filter = {pi: 1D / 200, $
            pisnr : 0D, pm : 0D, pmsnr: 0D, $
            d_in : .1, d_out: .2}

  pmsigs = arrgen(0D, 100D, 5) & npm = n_elements(pmsigs)
  
;  pisigs = arrgen(0D, 7D, 1) & npi = n_elements(pisigs)
  pisigs = arrgen(0D, 7D, .5) & npi = n_elements(pisigs)

  f90 = file_search('final_sims/l90b00_far_?_?.sav', count = ct)
  a90 = replicate(.2, ct)
  f180 = file_search('final_sims/l180b00_far_?_?.sav', count=ct)
  a180 = replicate(1., ct)
  fb90 = file_search('final_sims/l180b90_far_?_?.sav', count = ct)
  ab90 = replicate(50., ct)
  files = [f90, f180, fb90]
  area = [a90, a180, ab90]
  doav = 1
  for i = 0, n_elements(files) - 1, 1 do begin
     outfile=strtrun(files[i],'.sav')+'_int.sav'
     ;if file_test(outfile) then continue
     print, 'loading file '+files[i]
     cut = obj_new('pscuts', sav=files[i], doav = doav)
     interlopers = fltarr(npm, npi)
     s = lonarr(npm, npi, 5)
     sp = dblarr(npm, npi, 5)
     for j = 0, npm - 1, 1 do begin
        ;print, 'Running pm cut '+strtrim(j,2)+' of '+strtrim(npm-1,2)
        for k = 0, npi - 1, 1 do begin
           filter.pisnr = pisigs[k]
           filter.pmsnr = pmsigs[j]
           interlopers[j, k] = $
              cut->interloperCount(filter, rel_noise = .05, $
                                   status = status, number = number, $
                                   s_prob = status_prob) / area[i]
           for ll = 0, 4, 1 do s[j, k, ll] = total(status eq ll)
           sp[j, k, *] = status_prob
           ;print, interlopers[j,k], long(total(status eq 1)), $
           ;       long(total(status eq 2)), $
           ;       long(total(status eq 3)), long(total(status eq 4)), number
           ;print, status_prob, format='(("* ", 5(e0.2, 3x)))'
        endfor
     endfor
     save, interlopers, pmsigs, pisigs, s, sp, file=outfile
     obj_destroy, cut
  endfor
end

pro int_plot

  files = file_search('l180b00_far_*_int.sav', count = ct)
  restore, 'complete.sav'
  restore, files[0]

  nx = n_elements(pisigs)
  ny = n_elements(pmsigs)
  x = interpol(indgen(10), parallax, pisigs)
  x = rebin(x, nx, ny)
  y = interpol(indgen(9), pm, pmsigs)
  y = rebin(1#y, nx, ny)
  yes = interpolate(complete * number, x, y)

  device, decomposed = 0
  window, 0, xsize = 900, ysize = 900
  
  loadct, 0, /silent
  plot, [0],[1], xra = [0, 7], yra = [0,1.1], /nodata, pos = [.05, .55, .95, .95], $
        ytit = 'Reliability', charsize = 2

  for i = 0, ct-1, 1 do begin
     restore, files[i]
     print, files[i]                   
     loadct, 25, /silent
     for j = 0, ny - 1, 1 do begin
        rel = yes[*, j] / (interlopers[j,*] + yes[*,j])
;        rel *= yes[*,j] / number
       oplot, pisigs, rel, color = 255 * j / ny, $
              psym = 4
       rx = arrgen(0, 7, .1)
       oplot, rx, spline(pisigs, rel, rx, 5) < 1, color = 255 * j / ny, thick = 2
    endfor
  endfor

  loadct, 0, /silent
  plot, [0],[1], xra = [0, 7], yra = [0,1.1], /nodata, pos = [.05, .05, .95, .45], $
        /noerase
  
  loadct, 25, /silent
  for j = 0, ny - 1, 1 do begin
     com = yes[*, j] / number
     ;com = complete[*,j]
     oplot, pisigs, com, color = 255 * j / ny, $
            psym = 4
     rx = arrgen(0, 7, .1)
     oplot, rx, spline(pisigs, com, rx, 5), color = 255 * j / ny, thick = 2
  endfor
  
  

end
