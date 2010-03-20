pro tr2,infile

;given a region file with 2MASS, IRAC photometry and an estimated
;distance, find TR^2

;-CHECK INPUTS, READ FILE

infile='/users/cnb/analysis/dered/36_interior.dered'

;if n_params() eq 0 then begin
;    infile=dialog_pickfile(path='/users/cnb/analysis/dered/',title='Pick an input catalog')
;endif
if ~file_test(infile) then message, 'Error: '+infile+' DNE'

dist=6.2
;read,dist,prompt='Enter distance to region in Kpc '

openr,1,infile
A=''
data=dblarr(19,50000)
nrec=0

while ~eof(1) do begin
    readf,1,A
    line=strsplit(A,' ',/extract)
    data[*,nrec]=line
    nrec++
endwhile
close,1
data=data[*,0:nrec-1]

;CALCULATE FLUXES 

;-magnitude zero points in Janskys
;-Glimpze 2.0 Data Release Document, p17
zero=[1594,1024,666.7,280.9,179.7,115.0,64.13]

nu=[3.545,4.442,5.675,7.760]*1D-6
nu=3D8/nu

flux=dblarr(4,nrec)
flux[0,*]=zero[3]*10^(-data[8,*]/2.5)
flux[1,*]=zero[4]*10^(-data[10,*]/2.5)
flux[2,*]=zero[5]*10^(-data[12,*]/2.5)
flux[3,*]=zero[6]*10^(-data[14,*]/2.5)

;- convert from Jy to SI
flux*=(1D-26)
kpc2met=3.089d19
kb=1.38D-23
c=3d8

x=!pi*2*kb*nu^2. /((c*dist*kpc2met)^2.)
tr2=dblarr(nrec)

window,0,xsize=500,ysize=500,retain=2,xpos=0,ypos=0

for i=0,nrec-1, 1 do begin
    ;- skip if deredenning failed
    if data[18,i] ge 90 then continue
    
    ;- skip if source has IR XS
    if data[16,i] ne 3 then continue

    tr2[i]=regress(x,flux[*,i],status=stat,const=const)
    if stat ne 0 then message,'bad fit!'
    ;- plot and check
    ;plot,nu,flux[*,i],psym=4,xtitle='Nu (Hz)', Ytitle='Flux (W m^-2 Hz)'
    ;oplot,nu,2*!pi*kb*nu^2/(c*dist*kpc2met)^2*tr2[i]+const
    ;wait,.1
    
endfor

;-order 
;good=where(data[17,*] le 90)
plot,alog10(tr2),yra=[24,27],/ysty


end
