pro lambda_write, data, file

  if n_params() ne 2 then begin
     print, 'calling sequence:'
     print, ' lambda_write, data, file'
  endif

  openw, lun, file, /get_lun
  
  printf, lun, '!MOLECULE'
  printf, lun, data.molecule

  printf, lun, '!MOLECULAR WEIGHT'
  printf, lun, data.weight

  printf, lun, '! NUMBER OF ENERGY LEVELS'
  printf, lun, n_elements(data.energy), format='(i0)'

  printf, lun, data.level_label
  c1 = string(indgen(n_elements(data.energy))+1, format='(i0)')
  c2 = string(data.energy, format='(f14.9)')
  c3 = string(data.g, format='(f5.1)')
  c4 = data.j
  out = transpose([ [c1], [c2], [c3], [c4] ])
  printf, lun, out, format='(a5, 2x, a14, 2x, a5, 2x, a10)'

  printf, lun, '! NUMBER OF RADIATIVE TRANSITIONS'
  printf, lun, n_elements(data.r_hi)
  printf, lun, '!TRANS + U + L + A(s^-1) + FREQ(GHz) + E_u/k(K)'
  
  c1 = string(indgen(n_elements(data.r_hi))+1, format='(i4)')
  c2 = string(data.r_hi, format='(i4)')
  c3 = string(data.r_lo, format='(i4)')
  c4 = string(data.a, format='(e11.3)')
  c5 = string(data.freq, format='(f15.9)')
  c6 = string(data.ex_temp, format='(f8.2)')
  out = transpose([ [c1], [c2], [c3], [c4], [c5], [c6] ])
  printf, lun, out, format='(a4, 2x, a4, 2x, a4, 2x, a11, 2x, a15, 2x, a8)'
  
  printf, lun, '!NUMBER OF COLL PARTNERS'
  printf, lun, '1'
  printf, lun, '!COLLISIONS BETWEEN'
  printf, lun, data.partner
  printf, lun, '!NUMBER OF COLL TRANS'
  printf, lun, n_elements(data.c_hi), format='(i0)'
  printf, lun, '!NUMBER OF COLL TEMPS'
  printf, lun, n_elements(data.temp), format='(i0)'
  printf, lun, '!COLL TEMPS'
  nt = n_elements(data.temp)
  fmt='(('+strtrim(nt-1)+'(f0.1, 3x), f0.1))'
  printf, lun, data.temp, format=fmt

  printf, lun, '!TRANS + UP + LOW + COLLRATES(cm^3 s^-1)'
  sz = size(data.c)
  out = strarr(sz[1]+3, sz[2])
  out[0,*] = indgen(sz[2])+1
  out[1,*] = data.c_hi
  out[2,*] = data.c_lo
  out[3:sz[1]+2,*] = string(data.c, format='(e14.4)')
  fmt='((i5, 2x, i4, 2x, i4, 2x, '+strtrim(sz[1],2)+'(e12.4, 2x)))'
  print, fmt
  printf, lun, out, format=fmt
  free_lun, lun
end

pro test
  x = lambda_read('~/lambda/a-ch3oh.dat')
  lambda_write, x, 'test.dat'
;  y = lambda_read('test.dat')

;  help, x, y, /struct
  print, x.c[*,0:1]
end
  
