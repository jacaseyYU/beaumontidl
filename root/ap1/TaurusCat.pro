;+
; NAME:
;  TAURUSCAT
; DESCRIPTION:
;  Reads in the file  taurus_spitzer.tbl and turns it into an IDL
;  structure
;-

pro tauruscat

openr, 1, 'taurus_spitzer.tbl'

skip_lun, 1, 13 ,/lines

temp=''

fmt = {id: '', ra: 0D, dec: 0D, magj: 0D, dmagj: 0D, magH: 0D, dmagH: 0D, $
       magK: 0D, dmagK: 0D, mag1: 0D, dmag1: 0D, mag2: 0D, dmag2: 0D, $
       mag3: 0D, dmag3: 0D, mag4: 0D, dmag4: 0D}

taurus = replicate(fmt, 188361)
cols = [0, 1, 2, 3, 4, 5, 6, 7, 8, 11, 12, 17, 18, 23, 24, 29, 30]

i = 0L
while  ~eof(1) do begin
    readf, 1, temp
    a = strsplit(temp, ' ',/extract)
    taurus[i].id    = a[cols[0]]
    taurus[i].ra    = a[cols[1]]
    taurus[i].dec   = a[cols[2]]
    taurus[i].magj  = -2.5 * alog10(a[cols[3]] / 1594d6)
    taurus[i].dmagj = -2.5 * alog10((-a[cols[4]] + a[cols[3]]) / 1594d6) - taurus[i].magj
    taurus[i].magh  = -2.5 * alog10(a[cols[5]] / 1024d6)
    taurus[i].dmagh = -2.5 * alog10((-a[cols[6]] + a[cols[5]]) / 1024d6) - taurus[i].magh
    taurus[i].magk  = -2.5 * alog10(a[cols[7]] / 667d6)
    taurus[i].dmagk = -2.5 * alog10((-a[cols[8]] + a[cols[7]])/ 667d6) - taurus[i].magk
    
    mag1 = float(a[[9,11,13]])
    emag1 = float(a[[10, 12, 14]])
    use1 = min(where(mag1 gt 0 and emag1 gt 0))
    if use1 eq -1 then continue else begin
        taurus[i].mag1 = -2.5 * alog10(mag1[use1] / 2809d5)
        taurus[i].dmag1 = -2.5 * alog10((-emag1[use1] + mag1[use1]) / 2809d5) - taurus[i].mag1
    endelse

    mag2 = float(a[[15, 17, 19]])
    emag2 = float(a[[16, 18, 20]])
    use2 = min(where(mag2 gt 0 and emag2 gt 0))
    if use2 eq -1 then continue else begin
        taurus[i].mag2 = -2.5 * alog10(mag2[use2] / 1797d5)
        taurus[i].dmag2 = -2.5 * alog10((-emag2[use2] + mag2[use2]) / 1797d5) - taurus[i].mag2
    endelse

    mag3 = float(a[[21, 23, 25]])
    emag3 = float(a[[22, 24, 26]])
    use3 = min(where(mag3 gt 0 and emag3 gt 0))
    if use3 eq -1 then continue else begin
        taurus[i].mag3 = -2.5 * alog10(mag3[use3] / 115d6)
        taurus[i].dmag3 = -2.5 * alog10((-emag3[use3] + mag3[use3]) / 115d6) - taurus[i].mag3
    endelse

    mag4 = float(a[[27, 29, 31]])
    emag4 = float(a[[28, 30, 32]])
    use4 = min(where(mag4 gt 0 and emag4 gt 0))
    if use4 eq -1 then continue else begin
        taurus[i].mag4 = -2.5 * alog10(mag4[use4] / 6413d4)
        taurus[i].dmag4 = -2.5 * alog10((-emag4[use4] + mag4[use4]) / 6413d4) - taurus[i].mag4
    endelse

    i++;
endwhile
close, 1

taurus = taurus[0:i-1]
av = nicer(taurus.magj, taurus.dmagj, taurus.magh, taurus.dmagh, taurus.magk, taurus.dmagk)
smoothmap, av[0,*], av[1,*], taurus.ra, taurus.dec, map, emap, ctmap, ct, /verbose, fwhm = 6 / 60., out = 'taurus'

save, taurus, file='taurus.sav'

in = where(((taurus.ra - 67.42)^2 + (taurus.dec - 25.50)^2) le (10.55 * .025)^2)
h = histogram(av[0,in], binsize=.2, loc=loc)
plot, loc, h, psym=10
stop
    
end    
