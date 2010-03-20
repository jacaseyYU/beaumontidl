;-debug avmap
pro mapdebug
infile='/users/cnb/analysis/dered/testregion.dered'

readcol,infile,l,b,j,dj,h,dh,k,dk,i1,di1,i2,di2,i3,di3,i4,di4,st,av,var

good=where(av lt 99)
avcat=transpose([[l[good]],[b[good]],[av[good]],[var[good]]])

avmap,avcat,5/60.,header,map,/auto,sigma=3
stop

end
