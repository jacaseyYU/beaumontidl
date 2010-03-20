pro photcodes2text, photcodes

  num = n_elements(photcodes)
  codeRef = get_photcodes()
  codeNames = tag_names(codeRef)
  ntags = n_elements(codeNames)


  bitflags = intarr(ntags, num)

  for i = 0L, ntags - 1, 1 do begin
     bitflags[i, *] = (photcodes and codeRef.(i)) ne 0
  endfor

  for i = 0, num - 1, 1 do begin
     on = where(bitflags[*, i], ct)
     if ct eq 0 then begin
        print, i, ' has no set flags'
        continue
     endif
     print, i, format='(i0.3)'
     print, codeNames[on], format='("    ", a)'
  endfor

end
  
