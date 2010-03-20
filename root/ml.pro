function ml, mv, deriv = deriv, test = test

  result = mv * 0D
  deriv = mv * 0D

  result = mv * !values.d_nan
  deriv  = mv * !values.d_nan
  ;- range 1: Relationship from Malkov MNRAS 832 1073
  hit = where(mv ge -5 and mv le 9, ct)
  if ct ne 0 then begin
     result[hit] = .525 - .147 * mv[hit] + .00737 * mv[hit]^2
     deriv[hit] = -.147 + 2 * .00737 * mv[hit]
  endif

  ;- range 2: Relationship from Delfosse AA 2000, 364, 217
  hit = where(mv gt 9 and mv lt 17, ct)
  if ct ne 0 then begin
     result[hit] = 1d-3 * (.3 + 1.87 * mv[hit] + 7.6140 * mv[hit]^2 - $
                           1.698 * mv[hit]^3 + .060958 * mv[hit]^4)
     deriv[hit] = 1d-3 * (1.87 + 2 * 7.6140 * mv[hit] - $
                          3 * 1.698 * mv[hit]^2 + 4 * .060958 * mv[hit]^3)
  endif
  
  result = 10^result
  deriv = deriv * result * alog(10)
  return, result
end
  
pro ml_test

mv = findgen(10000)/9999* 32 - 10
m1 = 10^(.002456 * mv^2 -.0971 * mv + .4365)
m2 = 10^(-.1681 * mv + 1.4217)
m3 = 10^(.005257 * mv^2 - .2351 * mv + 1.4124)
hit1 = where(m1 gt .5 and m1 le 2)
hit2 = where(m2 gt .18 and m2 le .5)
hit3 = where(m3 gt .08 and m3 le .18)
plot, mv[hit1], m1[hit1], xra = [-5,20], yra = [.08,35], $
      xtit = 'Mv', ytit = 'Mass', charsize=2, /ylog, /xsty, /ysty
oplot,mv[hit2], m2[hit2], color = fsc_color('orange')
oplot, mv[hit3], m3[hit3], color = fsc_color('red')

hit4 = where(mv gt -5 and mv lt 9)
m4 = (10^(.525 - .147 * mv + .00737 * mv^2))
oplot, mv[hit4], m4[hit4], $
       color = fsc_color('green')

old = ml(mv, deriv = od, /old)
new = ml(mv, deriv = nd)
plot, mv, alog10(old),yra = [-2, 2]
oplot, mv, alog10(new), color = fsc_color('orange')
stop

plot, mv, alog10(abs(od))
oplot, mv, alog10(abs(nd)), color = fsc_color('orange')
end
