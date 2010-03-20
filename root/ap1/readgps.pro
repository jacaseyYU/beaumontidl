;-read in the information from the galactic plane survey
;catalogs. Return a structure

function readgps,diffuse=diffuse

if keyword_set(diffuse) then begin
    catalog='/users/cnb/MAGPIS/gpsextended.cat'
    skipline=3
    fmt='((f7.4, f7.4, 1x, f5.1, 1x, f5.1, 1x, f6.1, 1x, f6.4, 1x, f7.4, 1x, f7.3, 1x, A20))'
    record={l:0.,b:0.,boxsize:0.,scale:0., fpeak:0., peakl:0., peakb:0., Fint:0., comment:' '}
    nrow=398
endif else begin
    catalog='/users/cnb/MAGPIS/gps20.cat'
    fmt='((f7.3, f6.3, 1x, 2(i2, 1x), f6.3, 1x, i3, 1x, i2, 1x, f5.2, 2x, '+$ ;Long/Lat thru Dec
      'f4.2, 1x, d8.2, 1x, d9.2, 1x, d7.3, 1x, f6.2, 1x,'+$ ; Sprob thru MAJ
      'f6.2, 1x, f5.1, 1x, A7, 1x, A1 ))'
    record={l:0., b:0. ,rah:0,ram:0,ras:0.,dd:0,dm:0,ds:0.,$
            sprob:0., fpeak:0.D, Fint:0.D, RMS:0.D, Maj:0., Min:0., Pa:0., $
            Field:' ', OldGPS:' '}
    skipline=5
    nrow=5045
endelse

if ~file_test(catalog) then message,'ERROR: requested catalog '+catalog+' not found. Aborting'
close,1
openr,1, catalog
skip_lun,1,skipline,/lines

data=replicate(record,nrow)
readf,1,data,format=fmt
close,1

return,data
end
