pro robataille

root = '~/idl/data/robataille/'

;fmt = '((f7.0, 2x, f5.2, 1x, 99(e10.4, 2x), e10.4))'
i4 = fltarr(102, 200710)
openr, 1, root+'I4_y_full.ascii'
readf, 1, i4
close, 1
save, i4, file='i4.sav'
stop

return

readcol, root+'yso_parameters.ascii', $
         id, inc, age, massc, rstar, tstar, $
         mdot, rmax, theta, rmine, mdisk, $
         rmaxd, rmind, rmindau, zmin, a, b, $
         alpha, rhoconst, rhoamb, mdotdisk, $
         inc2, av_int, ltot, h100


save, id, inc, age, massc, rstar, tstar, $
      mdot, rmax, theta, rmine, mdisk, $
      rmaxd, rmind, rmindau, zmin, a, b, $
      alpha, rhoconst, rhoamb, mdotdisk, $
      inc2, av_int, ltot, h100, file='param.sav'

stop

end
