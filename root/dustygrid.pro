pro dustygrid

;- build a grid of mag (mass, age) based on dusty models
masses = [.01, .012, .015, .02, .03, .04, .05, .055, .06, .07, .072, .075, .08, .09, .1]
nmass = n_elements(masses)
ages = [.1, .5, 1, 5, 10]
nage = n_elements(ages)

vgrid = dblarr(nmass, nage)
rgrid = dblarr(nmass, nage)
igrid = dblarr(nmass, nage)
jgrid = dblarr(nmass, nage)
kgrid = dblarr(nmass, nage)
lgrid = dblarr(nmass, nage)
mgrid = dblarr(nmass, nage)

gridmass = masses
gridage = ages

;- populate the grid
files = ['0.1', '0.5', '1.0', '5.0', '10.0']
for i = 0, n_elements(files) - 1, 1 do begin
   file = '~/idl/data/dusty.'+files[i]+'Gyr.txt'
   readcol, file, masses, $
            ts, lums, gs, rads, lis, mv, mr, mi, mj, mk, ml, mm, $
            comment = '#', delimiter=' ', $
            format = 'f, f, f, f, f, f, f, f, f, f, f, f, f', /silent
   
   ;-at which mass does this table start ?
   start = where(masses[0] eq gridmass, ct)
   assert, ct eq 1
   start = start[0]
   for j = start, nmass -1, 1 do begin
      vgrid[j,i] = mv[j - start]
      rgrid[j,i] = mr[j - start]
      igrid[j,i] = mi[j - start]
      jgrid[j,i] = mj[j - start]
      kgrid[j,i] = mk[j - start]
      lgrid[j,i] = ml[j - start]
      mgrid[j,i] = mm[j - start]
   endfor

   ;- extrapolate out to the missing masses. This shouldn't
   ;- matter, since this regime is so faint anyways
   for j = 0, start - 1, 1 do begin
      vgrid[j,i] = vgrid[start, i] + (vgrid[start, i] - vgrid[start+1,i]) * (start - j)
      rgrid[j,i] = rgrid[start, i] + (rgrid[start, i] - rgrid[start+1,i]) * (start - j)
      igrid[j,i] = igrid[start, i] + (igrid[start, i] - igrid[start+1,i]) * (start - j)
      jgrid[j,i] = jgrid[start, i] + (jgrid[start, i] - jgrid[start+1,i]) * (start - j)
      kgrid[j,i] = kgrid[start, i] + (kgrid[start, i] - kgrid[start+1,i]) * (start - j)
      lgrid[j,i] = lgrid[start, i] + (lgrid[start, i] - lgrid[start+1,i]) * (start - j)
      mgrid[j,i] = mgrid[start, i] + (mgrid[start, i] - mgrid[start+1,i]) * (start - j)
   endfor

endfor

;- save results
save, vgrid, $
      rgrid, $
      igrid, $
      jgrid, $
      kgrid, $
      lgrid, $
      mgrid, $
      gridmass, $
      gridage, file = '~/idl/data/dustygrid.sav'
end
