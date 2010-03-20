pro mlfunc, mass

;-low mass stars from 
;arxiv 0712.3642

;- mv to mass
lo = .1
hi = 1.086
mv = lo + (findgen(1000)/999) * (hi - lo)
logm = (.213 - .0250 * mv - .00275 * mv^2) * ((mv gt .5) and (mv lt 1.086)) + $
       (.982 - .128 * mv) * ((mv gt .28) and (mv le .5)) + $
       (4.77 - .714 * mv + .0224 * mv^2) * ((mv gt .1) and (mv le .28))

plot, logm, mv

end

;P(app mag is at dist d) = P(mag is abs mag M) * (dist modulus)
;given object with magnitude m
;P(dist) ddist = P(M) dM
;P(dist) = P(M) * dM / ddist
; m - M = 5 log(d / 10)
; m = M + 5 log(d / 10)
; d = 10*10^(m-M)/5)
;P(dist | par) = Integ(P(M) * dist(M,m) * P(obs par | dist))

;P(d | pi) = P(pi | d) P(d) / Sum((P(pi | d) * P(d))

;P(d)dD = P(M) * dM 
;P(d) = P(M) dM / dD
;dM / dD = -5 / d
;P(d) = P(M) * 5 / d
;P(d) = P(M) * .5 * 10^((M - m) / 5)
;log(a) + lob(b) = log(a*b)
;log(10) + log(10) = log(100)
