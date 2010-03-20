pro examine98
path = '/media/cave/catdir.98/s0000/4801'

file = path+'.good.sav'
restore, file

common examine98, skymodel_x, skymodel_y, xpsf, ypsf
if n_elements(xpsf) eq 0 then restore,  path+'.skymodel'


hit = where(par.parallax / sqrt(par.covar[4,4]) lt -3, ct)


read_object, path, t[hit[0]].obj_id, m2, t2
lo = t[hit[0]].off_measure
hi = lo + t[hit[0]].nmeasure - 1
xfloor = reform(skymodel_x[0,lo:hi])
psfx   = xpsf[lo:hi]
xfudge = reform(skymodel_x[1,lo:hi])
yfloor = reform(skymodel_y[0,lo:hi])
psfy   = ypsf[lo:hi]
yfudge = reform(skymodel_y[1,lo:hi])

reduce_object, m2, t2, $
               xfloor, psfx, xfudge, $
               yfloor, psfy, yfudge, $
               oflag, flag, mag, posi, pmo, parr, $
               /parplot, /verbose


end
