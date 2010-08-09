pro venn, n1, n2, n12, title1 = title1, title2 = title2
  ;- scale largest radius to 1

  bigR = 1.
  r = 1. * (n1 < n2) / (n1 > n2)

  r1 = (n1 gt n2) ? bigR : r
  r2 = (n1 gt n2) ? r : bigR

  a = 1. * n12 / (n1 > n2) * !pi

  d = arrgen(0., !pi, nstep = 100)
  a_guess = r^2 * acos((d^2 + r^2 - bigR^2) / (2 * d * r)) + $
            bigR^2 * acos((d^2 + bigR^2 - r^2) / (2 * d * bigR)) - $
            .5 * sqrt( (-d + r + bigR) * (d + r - bigR) * $
                       (d - r + bigR) * (d + r + bigR) )

  diff = abs(a_guess - a)
  min = min(diff, loc,/nan)
  
  d = d[loc]
  erase

  plot, [-1, 2], [-bigR,bigR], xsty = 5, ysty = 5, /nodata
  tvcircle, r1 , 0 , 0, /data
  tvcircle, r2 , d , 0, /data

  if keyword_set(title1) then xyouts, 0, 0, title1, align = 0.5
  if keyword_set(title2) then xyouts, d, 0, title2, align = 0.5
end

pro test
  for i = 0., 5, .1 do begin
     venn, 10, 5, i, title1='Name 1', title2 = 'name 2'
  endfor
end
