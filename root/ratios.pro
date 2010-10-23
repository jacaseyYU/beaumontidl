pro ratios

  ;- observed lines. Integrated flux (K km/s)
  dv = 11.8
  hcop = 4.00058
  co12 = 362.
  fhcop = 356.7343
  fco12 = 345.7960
  fco13 = 330.5880
  fhcn = 354.5055
  fh2co = 351.7686
  

  ;- model grids
  ngrid = 20
  temps = arrgen(30, 150, nstep = 20)
  dens = arrgen(1d3, 3d6, nstep = 20, /log)
  ncol = arrgen(1d15, 1d22, nstep = 20, /log)


  co12 = ptrarr(ngrid, ngrid, ngrid)
  co13 = ptrarr(ngrid, ngrid, ngrid)
  hcop = ptrarr(ngrid, ngrid, ngrid)
  hcn = ptrarr(ngrid, ngrid, ngrid)
  h2co = ptrarr(ngrid, ngrid, ngrid)

  to = systime(/seconds)
  for i = 0, ngrid - 1, 1 do begin
     print, i, systime(/seconds) - to
     for j = 0, ngrid - 1, 1 do begin
        for k = 0, ngrid - 1, 1 do begin
           co12[i,j,k] = ptr_new(radex('co.dat', fco12, .01, temps[i], $
                                       dens[j], 3., ncol[k], dv))
           co13[i,j,k] = ptr_new(radex('13co.dat', fco13, .01, temps[i], $
                                       dens[j], 3., ncol[k] / 60., dv))
           hcop[i,j,k] = ptr_new(radex('hco+@xpol.dat', fhcop, .01, temps[i], $
                                       dens[j], 3., ncol[k] / 1d4, dv))
           hcn[i,j,k] = ptr_new(radex('hcn@xpol.dat', fhcn, .01, temps[i], $
                                      dens[j], 3., ncol[k] / 1d4, dv))
           h2co[i,j,k] = ptr_new(radex('o-h2co.dat', fh2co, 20, temps[i], $
                                       dens[j], 3., ncol[k] / 1d4, dv))
        endfor
     endfor
  endfor

  save, temps, dens, ncol, co12, co13, hcop, hcn, h2co, file='ratios.sav'
end
  
pro ratios_examine
  restore, 'ratios.sav'
  dens = arrgen(1d3, 3d6, nstep = 20, /log)

  ;- contours of CO, HCO+
  for i = 0, 19, 1 do begin
     tco = fltarr(20, 20) & thcop = tco & thcn = tco & th2co = tco & t13co = tco
     tauco = tco
     for j = 0, 19, 1 do begin
        for k = 0, 19, 1 do begin
           tco[j,k] = (*co12[i,j,k]).tr
           thcop[j,k] = (*hcop[i,j,k]).tex
           thcn[j,k] = (*hcn[i,j,k]).tex
           th2co[j,k] = (*h2co[i,j,k])[0].tex
           tauco[j,k] = (*co12[i,j,k]).tau
           t13co[j,k] = (*co13[i,j,k]).tex
        endfor
     endfor
     contour, tco, dens, ncol, /xlog, /ylog, $
              nlev = 20, $
              c_lab = replicate(1, 20), $
              title = strtrim(temps[i],2), charsize = 2
     contour, tco, dens, ncol, /over, lev=[1], c_color = fsc_color('green')
     stop
     continue

     contour, tco, dens, ncol, lev=[362], c_lab = [1], $
              charsize = 1.5, /xlog, /ylog, tit = strtrim(temps[i],2), thick = 2
     contour, tco, dens, ncol, lev=[352, 372], /over
     contour, thcop, dens, ncol, /over, lev=[4.], c_lab=[1], $
              color = fsc_color('red'), thick = 2
     ;contour, thcop, dens, ncol, /over, lev=[3,5], color = fsc_color('red')
     contour, thcn, dens, ncol, /over, c_lab=replicate(1,2),  color = fsc_color('green'), $
              lev=[6.0, 6.5]
     
     stop
  endfor

end

pro ratios2
  common ratios2, grid
  nstep = 20
  dens = arrgen(1d3, 1d8, nstep = nstep, /log)
  cols = arrgen(1d16, 1d25, nstep = nstep, /log)
  temp = 50
  dv = 10

  if  n_elements(grid) eq 0 then begin
     grid = replicate(radex('co.dat', 345, 2, temp, $
                            1d5, 3., 1d20, dv), nstep, nstep)
     grid[*].tr = !values.f_nan & grid[*].tau = !values.f_nan
     for i = 0, nstep - 1, 1 do begin
        for j = 0, nstep - 1, 1 do begin
           result =  radex('co.dat', 345, 2, temp, $
                           dens[i], 3., cols[j], dv)
           if size(result, /type) eq 8 then grid[i,j] = result
        endfor
     endfor
  endif
  device, decomposed = 0
  loadct, 0, /silent
  
  plot, cols, grid[0, *].tau, charsize = 1.5, xtit='Tau', ytit='Tr', /xlog, /ylog, yra = [1d-2, 4]
  loadct, 25, /silent
  for i = 1, nstep - 1, 1 do oplot, cols, grid[i,*].tau, color = 255 / (nstep-1) * i
  for i = 0, nstep - 1, 1 do $
     xyouts, .8, .8 - .8/nstep*i, string(dens[i], format='(e0.1)'), charsize = 1.5, color = 255 / (nstep-1) *i, /norm
  taus = findgen(1d4)/1d3
;  oplot, taus, 42 * (1 - exp(-taus)), /line, thick = 3
end
