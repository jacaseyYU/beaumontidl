pro coma


d = 2.8 ;-km
au2km = 1.5 * 1d13 * 1d-5 ;- km in an au

r = (1 + findgen(1000)) / 1000 * 5 ;-earth-comet distance in au

theta = d / (r * au2km) * 206265. ;- theta in "

set_plot,'ps'
device, filename='coma.ps'
plot, r, alog10(theta), charsize = 1.5, $
      xtit = "Earth-Comet Distance (AU)", $
      ytit = "Log(angular size in arcsec)"
device,/close
set_plot,'X'
end
