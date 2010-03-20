pro irplot

shellfiles=file_search('/users/cnb/analysis/ircat/*shell.ircat',count=shct)
extfiles=file_search('/users/cnb/analysis/ircat/*exterior.ircat',count=exct)

shellarea=0.;
extarea=0.;

shellcolors=fltarr(4,1000000L)
extcolors=fltarr(4,1000000L)
shelltag=fltarr(1000000L)
exttag=fltarr(1000000L)
shellhist=fltarr(14)
exthist=fltarr(14)
sherr=fltarr(14)
eherr=fltarr(14)
ct=0L

for i=0, shct-1, 1 do begin
    readcol,shellfiles[i],l,b,j,dj,h,dh,k,dk,i1,di1,i2,di2,i3,di3,i4,di4,sourcetag,/silent
    new=n_elements(l)
    shellcolors[0,ct:ct+new-1]=i1
    shellcolors[1,ct:ct+new-1]=i2
    shellcolors[2,ct:ct+new-1]=i3
    shellcolors[3,ct:ct+new-1]=i4
    shelltag[ct]=sourcetag
    ct+=new
    regfile=strsplit(shellfiles[i],'/',/extract)
    regfile=regfile[n_elements(regfile)-1]
    regfile=strsplit(regfile,'.',/extract)
    regfile='/users/cnb/analysis/reg/'+regfile[0]+'.reg'
    readcol,regfile,l,b,/silent
    shellarea+=poly_area(l,b)
    shellhist[round(median(l)/5)]=n_elements(where(sourcetag ne 3))/poly_area(l,b)
    sherr[round(median(l)/5)]=sqrt(n_elements(where(sourcetag ne 3)))/poly_area(l,b)
endfor

shellcolors=shellcolors[*,0:ct-1]
shelltag=shelltag[0:ct-1]

ct=0L
for i=0,exct-1, 1 do begin
    readcol,extfiles[i],l,b,j,dj,h,dh,k,dk,i1,di1,i2,di2,i3,di3,i4,di4,sourcetag,/silent
    new=n_elements(l)
    extcolors[0,ct:ct+new-1]=i1
    extcolors[1,ct:ct+new-1]=i2
    extcolors[2,ct:ct+new-1]=i3
    extcolors[3,ct:ct+new-1]=i4
    exttag[ct]=sourcetag
    ct+=new
    regfile=strsplit(extfiles[i],'/',/extract)
    regfile=regfile[n_elements(regfile)-1]
    regfile=strsplit(regfile,'.',/extract)
    regfile='/users/cnb/analysis/reg/'+regfile[0]+'.reg'
    readcol,regfile,l,b,/silent
    extarea+=poly_area(l,b)
    exthist[round(median(l)/5)]=n_elements(where(sourcetag ne 3))/poly_area(l,b)
    eherr[round(median(l)/5)]=sqrt(n_elements(where(sourcetag ne 3)))/poly_area(l,b)
endfor

extcolors=extcolors[*,0:ct-1]
exttag=exttag[0:ct-1]

nxs_shell=n_elements(where(shelltag ne 3))
nxs_ext=n_elements(where(exttag ne 3))
err_shell=sqrt(nxs_shell)
err_ext=sqrt(nxs_ext)

nxs_shell/=shellarea
err_shell/=shellarea
nxs_ext/=extarea
err_ext/=extarea

print,nxs_shell,err_shell,format="('Shell IRXS frequency: ',i4,'+/-',i3,' sources/square degree')"
print,nxs_ext,err_ext,format="('Control IRXS frequency: ',i4,'+/-',i3,' sources/square degree')"
print,(nxs_shell-nxs_ext)/sqrt(err_shell^2+err_ext^2),format="('Significance: ',f4.2,' sigma')"
print,(nxs_shell-nxs_ext)/nxs_ext*100,format="('Enhancement: ',i2,' %')"
window,1,xsize=500,ysize=500,retain=2
plot,extcolors[2,*]-extcolors[3,*],extcolors[0,*]-extcolors[1,*],xrange=[-1,2.5],yrange=[-1,2.5],/xsty,/ysty,psym=3
oplot,shellcolors[2,*]-shellcolors[3,*],shellcolors[0,*]-shellcolors[1,*],psym=4,symsize=.06,color='ffff00'xl
oplot,[0.4,0.4,1.1,1.1,0.4],[0.0,0.8,0.8,0.0,0.0],color='00ff00'xl

window,2,xsize=500,ysize=500,retain=2
plot,indgen(14)*5,shellhist,psym=10
oploterr,indgen(14)*5,shellhist,sherr
oplot,indgen(14)*5,exthist,psym=10,color='ff00ff'xl
oploterr,indgen(14)*5,exthist,eherr
print,shellhist,sherr


;print,mean(shellcolors[2,*]-shellcolors[3,*]),stdev(shellcolors[2,*]-shellcolors[3,*])
;print,mean(shellcolors[0,*]-shellcolors[1,*]),stdev(shellcolors[0,*]-shellcolors[1,*])

;print,mean(extcolors[2,*]-extcolors[3,*]),stdev(extcolors[2,*]-extcolors[3,*])
;print,mean(extcolors[0,*]-extcolors[1,*]),stdev(extcolors[0,*]-extcolors[3,*])

end


