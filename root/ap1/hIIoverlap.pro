;+
; COMPARE THE PALADINI HII REGIONS TO BUBBLE LOCATIONS
;-

pro hIIoverlap

; set up colors - see www.dfanning.com
device,decomposed=0
loadct,0,ncol=250
tvlct,fsc_color('Crimson',/triple),251
tvlct,fsc_color('Sea Green',/triple),252
tvlct,fsc_color('Blue',/triple),253
tvlct,fsc_color('black',/triple),254
tvlct,fsc_color('white',/triple),255
tvlct, fsc_color('orange', /triple), 250
red=251
green=252
blue=253
black=254
white=255
purple=250

;- find which sources overlap bubble locations

;- HII region info
paladini = 'paladini.dat'
fmt = "((i8, '|', i4,'|',a11,'|',i2, 1x, i2, 1x, f4.1, '|', i3, 1x, i2, 1x, f4.1, '|', 28(f6.2,'|')))"
a=''
rec = {recno: 0, HII: 0, name: '', RA:[0,0,0.], Dec:[0,0,0.], sz:fltarr(28)};
hiicat = replicate(rec, 1442);

openr, 1, paladini
skip_lun, 1, 53,/lines
i=0
while ~eof(1) do begin
    if i ge 1442 then break
    a = ""
    readf, 1, a
    a = strsplit(a,'|',/extract)
    rec.recno = a[0]
    rec.hII = a[1]
    rec.name = a[2]
    rec.ra=strsplit(a[3],' ',/extract)
    rec.dec=strsplit(a[4],' ',/extract)
    rec.sz = float(a[5:32])
    hiicat[i++] = rec
endwhile
close, 1

sizes = max(hiicat.sz, dimension = 1)
ras = hiicat.ra[0] + hiicat.ra[1]/60. + hiicat.ra[2]/3600.
ras *=15.
decs = hiicat.dec[0] + hiicat.dec[1]/60. + hiicat.dec[2] / 3600.

euler, ras, decs, hiil, hiib, 1

;- Bubble region info
readcol,'/users/cnb/glimpse/glimpse1_north_bubbles.txt',skipline=44,delimiter=' '$
  ,num,l,b,a_in,b_in,a_out,b_out,e,r,dr,flags $
  ,format='a,f,f,f,f,f,f,f,f,f,a'

nhii = n_elements(ras)
nbub = n_elements(l)

;- distances
dist = (rebin(l, nbub, nhii) - rebin(1#hiil, nbub, nhii))^2 + $
  (rebin(b, nbub, nhii) - rebin(1#hiib, nbub, nhii))^2
thresh = (rebin(1#sizes, nbub, nhii)/120.)^2
thresh2 = (rebin(r, nbub, nhii)/60.)^2

inside = dist le thresh
inside2 = dist le thresh2

;- find bubble matches
match = 0
match2 = 0
for i=0, nbub-1, 1 do begin
    hit = where(inside[i,*], ct)
    hit2 = where(inside2[i,*],ct2)
    if(ct2 gt 0) then print, i+1, hit2+1
    match += (ct gt 0)
    match2+=(ct2 gt 0)
endfor
print, match
print,match2
stop


;- plot
!p.multi = [6,1,6]
!p.background=white
!p.color=black
erase
for i=0, 5, 1 do begin
    llow = 10 + 10*i
    lhi = llow+10
    plot, [0], [0], xra = [llow, lhi], yra=[-1,1],/xsty, /ysty, $
      /nodata, charsize=2.3
    
    for k = 0, nbub-1, 1 do begin
        if l[k] le llow or l[k] ge lhi then continue
        tvcircle, r[k]/60., l[k], b[k], /data, color=green, thick=2
    endfor
    oplot, l, b, psym=2, symsize=.2, color=green


    ;oplot, l, b, psym = 2, color='00ff00'xl
    for j=0, nhii-1, 1 do begin
        if hiil[j] le llow || hiil[j] ge lhi || $
          hiib[j] le (-1) || hiib[j] ge 1 then continue
        tvcircle, sizes[j]/120., hiil[j], hiib[j], /data, color=red, thick=2.0
    endfor
    oplot, hiil, hiib, psym=2, symsize=.2, color=red
endfor

out=tvrd(/true)
write_png, 'hiioverlap.png', out
end
