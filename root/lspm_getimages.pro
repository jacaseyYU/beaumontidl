pro lspm_getimages

;234.39911  0.22330  19.92000
;234.96025  0.22086  15.23000
m = mrdfits('/media/cave/catdir.107/n0000/0351.cpm',1,h)
t = mrdfits('/media/cave/catdir.107/n0000/0351.cpt',1,h)
images = mrdfits('/media/cave/catdir.107/Images.dat',1,h)
a = 234.39911
d = 0.22330
ccd = pos2ccd(m, t, images, a, d)
id = ccd2files(ccd, images, names = names)
for i = 0, n_elements(id) - 1, 1 do begin
   hit = where(m.image_id eq id[i]+1, ct)
   if ct lt 100 then continue
   sky2chip, t[m[hit].ave_ref].ra, $
             t[m[hit].ave_ref].dec, $
             m[hit].x_ccd, $
             m[hit].y_ccd, $
             a, d, x, y
   print, names[i], x, y
endfor
             

;- 92/0012
;13.67651  0.62852  18.66000
;13.79990  0.93264  10.63000
;14.05271  0.78376  19.28

;- 95/0066
;58.40364  0.08919  16.28000
;58.52146  0.18547  19.45000
;58.61957  0.44722  19.73000

;-96/0148
;102.54550  0.04455  17.86000

end
