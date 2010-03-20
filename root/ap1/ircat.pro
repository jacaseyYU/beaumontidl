pro ircat, regionfile
;create a catalog of IR excess sources in a given region

;on_error, 2

;- Read region file, determine which GLIMPSE catalogs to view
if n_params() eq 0 then regionfile=dialog_pickfile(title='Select a region file',path='/users/cnb/analysis/reg')
if ~file_test(regionfile) then message,'Error -- File DNE'

readcol,regionfile,l,b,/silent
lmin=floor(min(l))
lmax=floor(max(l))
lcen=median(l)
bcen=median(b)

if lmax-lmin ge 2 then message, 'Error-- Regions are too big!'

;- read GLIMIC catalog

maxrec=100000L
nelem=0L
data=dblarr(maxrec,17)

cat='/users/cnb/glimpse/glimic/GLIMIC_l0'+strtrim(string(lmin),2)+'.tbl'
rep=1
tableread:

if ~file_test(cat) then message, 'Error-- GLIMIC catalog not found'
openr,1,cat
A=''
skip_lun,1,13,/lines

while ~eof(1) do begin
    readf, 1, A
    row=strsplit(A,' ',/extract)
    ;- cut 1: within .5 degrees of lcen, bcen
    if (row[4]-lcen)^2+(row[5]-bcen)^2 ge .25 then continue
    ;- cut 2: valid IRAC photometry
    if ((row[19] eq 99.999) || (row[21] eq 99.999) || (row[23] eq 99.999) || (row[25] eq 99.999)) then continue
    ;- Ra, Dec, 2MASS with errors, IRAC with Errors
    data[nelem,0:15]=row[[4,5,13,14,15,16,17,18,19,20,21,22,23,24,25,26]]
    nelem++
    if nelem eq maxrec then message,'Error -- table overflow'
endwhile 
close,1
;-do we need to read another file?
if (lmin ne lmax) and (rep eq 1) then begin
    cat='/users/cnb/glimpse/glimic/GLIMIC_l0'+strtrim(string(lmax),2)+'.tbl'
    message,'Region straddles two catalogs. Reading catalog 2...',/continue
    rep=0
    goto, tableread
endif

data=data[0:nelem-1,*]


;- cut 3: points lie inside the region
in=inside(data[*,0],data[*,1],l,b)
hit=where(in,ct)
if ct ne 0 then data=data[hit,*] else goto, theend
data[*,16]=sourcetag(data[*,8],data[*,10],data[*,12],data[*,14])

data=transpose(data)

;- calculate the area of the region
ar=poly_area(l,b)*3600
print,'Area of region: '+strtrim(string(fix(ar)),2)+' square arcmin'

;- output
outputfile=strsplit(regionfile,'/',/extract)
outputfile=strsplit(outputfile[n_elements(outputfile)-1],'.',/extract)
outputfile='/users/cnb/analysis/ircat/'+outputfile[0]+'.ircat'
fmt='(2D12.6,14D8.3,I2)'
openw, 1, outputfile
printf,1,data,format=fmt
close,1

theend:
end
