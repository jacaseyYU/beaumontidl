;- JS CODE
pro get_av,Av,Averr,cloud=cloud,path=path,filter=filter
  if not keyword_set(cloud) then cloud = 'G028.53'
  if not keyword_set(path) then $
    path = '/Users/cnb/glimpse/pro/'
  readcol,path+cloud+'.av.dat', $
          skipline=1,format='f,f,f,f,f,f,f,f', $
          ra,dec,j,je,h,he,k,ke, av, ave

; select good colors from data based on variance in control data
  av_var,cov1,cmean
  c1 = j - h
  c2 = h - k
; Selective extinction coefficients
  k1 = 1./9.35   ; Rieke & Lebofsky (1985) + Carpenter (2001)
  k2 = 1./15.87
  kvec = [k1,k2]
  ext_slope = k1/k2

  if keyword_set(filter) then begin 
      c1rms = sqrt(cov1[0,0])
      c2rms = sqrt(cov1[1,1])

      c1err = sqrt(je^2. + he^2.)
      c2err = sqrt(ke^2. + he^2.)

;      c1fit = cmean[0] + ext_slope*(c2 - cmean[1])
;      makesym,10  
;      ploterror,c2,c1,c2err,c1err,psym=8
;      oplot,!x.crange,cmean[0] + ext_slope*(!x.crange - cmean[1]),color=!red
;      oplot,!x.crange,cmean[0] + ext_slope*(!x.crange - cmean[1])+1.5,color=!cyan 
;      oplot,!x.crange,cmean[0] + ext_slope/2.*(!x.crange - cmean[1])+2.45,color=!cyan
;      xvals = makearr(100,!x.crange[0],!x.crange[1])
;      oplot,xvals,abs(xvals/2.)^2.-0.3,color=!cyan

      binds = where(c1 lt abs(c2/2.)^2.-0.3 or $
                    (c1 gt cmean[0] + ext_slope*(c2 - cmean[1])+1.5 and $
                     c1 gt cmean[0] + ext_slope/2.*(c2 - cmean[1])+2.45),complement=ginds)
      ra = ra[ginds]
      dec = dec[ginds]
      c1 = c1[ginds]
      c2 = c2[ginds]
      j  = j[ginds]
      je  = je[ginds]
      h  = h[ginds]
      he  = he[ginds]
      k  = k[ginds]
      ke  = ke[ginds]
;      oplot,c2[ginds],c1[ginds],psym=8,color=!red
;      ploterror,c2[ginds],c1[ginds],c2err[ginds],c1err[ginds],psym=8

  endif

  ct = n_elements(ra)

; Calculate Av using NICER (Lombardi & Alves 2001)
  Av = fltarr(ct)
  Averr = fltarr(ct)
for i = 0L,ct-1 do begin &$
  cov2 = [[je[i]^2.+he[i]^2.,-he[i]^2.],[-he[i]^2.,he[i]^2.+ke[i]^2.]] &$
  C = cov1 + cov2 &$
  b = transpose((invert(C) ## kvec)/total(kvec ## (invert(C) ## kvec)))  &$
  cvec = [c1[i],c2[i]] &$
  Av[i] = total(b*(cvec - cmean)) &$
  Averr[i] = sqrt(b ## (C ## b))  &$
endfor


; Write out Av data
  openw,1,path+cloud+'.Av_fix.dat'
  printf,1,format='(a2,11x,a3,8x,a1,8x,a5,2x,a1,8x,a5,2x,a1,8x,a5,6x,a2,7x,a6)', $
         'RA','DEC','J','J err','H','H err','K','K err','Av','Av err'
  printf,1,format='(f10.6,2x,f10.6,2x,f6.3,2x,f6.3,2x,f6.3,2x,f6.3,2x,f6.3,2x,f6.3,5x,f7.3,2x,f7.3)', $
         [transpose(ra),transpose(dec),transpose(j),transpose(je),transpose(h),transpose(he), $
          transpose(k),transpose(ke),transpose(av),transpose(averr)]
  close,1

  return
end



