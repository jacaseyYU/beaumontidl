;+
; NAME:
;  mastercat
;
; DESCRIPTION:
;  Create the main table for the ApJ paper
;-
pro mastercat

catch, theError
if theError ne 0 then begin
    catch, /cancel
    help, !error_state, /struct
    print, theError
    if n_elements(lun) ne 0 then free_lun, lun
    return
endif

readcol,'~/glimpse/glimpse1_north_bubbles.txt',skipline=44,delimiter=' ' $
  ,num,l,b,a_in,b_in,a_out,b_out,e,r,dr,flags $
  ,format='a,f,f,f,f,f,f,f,f,f,a', /silent

readcol, '~/paper/cat/vbyeye.txt', vnum, vlo, vhi, /silent
readcol, '~/paper/cat/distcat.txt', dnum, dnear, dfar, derr, /silent

openw, lun, '~/paper/cat/mastercat.txt', /get_lun, width = 150

quan1 = 'Catalog Number & l     &    b  & <v>         & $\sigma_{v}$  &'
unit1 = '               & (deg) & (deg) & (km s^{-1}) & (km s^{-1})   &'
quan2 = ' dist_{near} & dist_{far} & \sigma_{dist} & <R>  & <T>  & 20 cm flux & Morphology \\'
unit2 = ' (kpc)       & (kpc)      & (kpc)         & (pc) & (pc) & (Jy)       &             \\'

printf, lun,  quan1+quan2
printf, lun,  unit1+unit2

for i=0, n_elements(dnum)-1, 1 do begin
    bubnum = dnum[i]
    hit = bubnum - 1
    bubname = 'N'+strtrim(floor(bubnum),2)
    
    vel = getbubblevel(bubnum)
    vcen = (vel[0] + vel[1]) / 2.
    deltav = (vel[1] - vel[0]) / 2.

    dist = getbubbledist(bubnum)
    lat = b[hit]
    lon = l[hit]
    
    arcmin2pc = 1/60. * !dtor * 1000. * dist[0]
    rad = r[hit] * arcmin2pc
    drad = dr[hit] * arcmin2pc

    morph = getBubbleMorph(bubnum)
    hII = getHIIflux(bubnum)
    if (finite(hII)) then begin
        hII = (hII eq 0) ? '0' :  string(hII, format='(e7.1)')
    endif else hII = 'N/A'

    fmt = "((A4, 1x, ' & ', 2(f6.3, ' & '), 2(f5.1, ' & '), 2(f4.1,' & '), f3.1, ' & ', 2(f5.2, ' & '), A9, ' & ', A9, ' \\ '))"

    printf, lun, bubname, lon, lat, vcen, deltav, dist[0], dist[1], dist[2], rad, drad, hII, morph, $
      format = fmt

    print, bubname, lon, lat, vcen, deltav, dist[0], dist[1], dist[2], rad, drad, hII, morph, $
      format = fmt

endfor

close, lun
free_lun, lun

end
