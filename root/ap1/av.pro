;- JS CODE

pro av_var,C,meanvec,path=path,file=file

;;; Procedure to calculate directly the covariance matrix of the intrinsic color
;;; variations of a control sample of stars

  if not keyword_set(path) then path = '/Volumes/data/rhoOph/2MASS/'
  if not keyword_set(file) then file = 'control.dat'
  readcol,path+file,format='f,f,f,f,f,f,f,f', $
          ra,dec,j,je,h,he,k,ke,/silent
  
  c1 = j-h
  c1mean = mean(c1)
  c2 = h-k
  c2mean = mean(c2)
  meanvec = [c1mean,c2mean]

  ; calculate covariance matrix directly
  C = fltarr(2,2)
  C[0,0] = variance(c1)
  C[1,1] = variance(c2)
  C[0,1] = total((c1-mean(c1))*(c2-mean(c2)))/float(n_elements(c1))
  C[1,0] = total((c2-mean(c2))*(c1-mean(c1)))/float(n_elements(c1))

  return
end




pro get_av,Av,Averr,cloud=cloud,path=path,filter=filter
  if not keyword_set(cloud) then cloud = 'G028.53'
  if not keyword_set(path) then $
    path = '/Users/js/Astronomy/IRDCs/reductions/CFHT/processed/'
  readcol,path+cloud+'.phot.dat', $
          skipline=1,format='f,f,f,f,f,f,f,f', $
          ra,dec,j,je,h,he,k,ke

; select good colors from data based on variance in control data
  av_var,cov1,cmean
  c1 = j - h
  c2 = h - k
; Selective extinction coefficients
  k1 = 1./9.35   ; Rieke & Lebofsky (1985) + Carpenter (2001)
  k2 = 1./15.87
  kvec = [k1,k2]
  ext_slope = k1/k2

  if keyword_set(filter) then begin 
      c1rms = sqrt(cov1[0,0])
      c2rms = sqrt(cov1[1,1])

      c1err = sqrt(je^2. + he^2.)
      c2err = sqrt(ke^2. + he^2.)

;      c1fit = cmean[0] + ext_slope*(c2 - cmean[1])
;      makesym,10  
;      ploterror,c2,c1,c2err,c1err,psym=8
;      oplot,!x.crange,cmean[0] + ext_slope*(!x.crange - cmean[1]),color=!red
;      oplot,!x.crange,cmean[0] + ext_slope*(!x.crange - cmean[1])+1.5,color=!cyan 
;      oplot,!x.crange,cmean[0] + ext_slope/2.*(!x.crange - cmean[1])+2.45,color=!cyan
;      xvals = makearr(100,!x.crange[0],!x.crange[1])
;      oplot,xvals,abs(xvals/2.)^2.-0.3,color=!cyan

      binds = where(c1 lt abs(c2/2.)^2.-0.3 or $
                    (c1 gt cmean[0] + ext_slope*(c2 - cmean[1])+1.5 and $
                     c1 gt cmean[0] + ext_slope/2.*(c2 - cmean[1])+2.45),complement=ginds)
      ra = ra[ginds]
      dec = dec[ginds]
      c1 = c1[ginds]
      c2 = c2[ginds]
      j  = j[ginds]
      je  = je[ginds]
      h  = h[ginds]
      he  = he[ginds]
      k  = k[ginds]
      ke  = ke[ginds]
;      oplot,c2[ginds],c1[ginds],psym=8,color=!red
;      ploterror,c2[ginds],c1[ginds],c2err[ginds],c1err[ginds],psym=8

  endif

  ct = n_elements(ra)

; Calculate Av using NICER (Lombardi & Alves 2001)
  Av = fltarr(ct)
  Averr = fltarr(ct)
  for i = 0L,ct-1 do begin &$
      cov2 = [[je[i]^2.+he[i]^2.,-he[i]^2.],[-he[i]^2.,he[i]^2.+ke[i]^2.]] &$
      C = cov1 + cov2 &$
      b = (invert(C) # kvec)/(kvec # (invert(C) # kvec))  &$
      cvec = [c1[i],c2[i]] &$
      Av[i] = total(b*(cvec - cmean)) &$
      Averr[i] = b # C # b  &$
  endfor

; Write out Av data
  openw,1,path+cloud+'.Av.dat'
  printf,1,format='(a2,11x,a3,8x,a1,8x,a5,2x,a1,8x,a5,2x,a1,8x,a5,6x,a2,7x,a6)', $
         'RA','DEC','J','J err','H','H err','K','K err','Av','Av err'
  printf,1,format='(f10.6,2x,f10.6,2x,f6.3,2x,f6.3,2x,f6.3,2x,f6.3,2x,f6.3,2x,f6.3,5x,f7.3,2x,f7.3)', $
         [transpose(ra),transpose(dec),transpose(j),transpose(je),transpose(h),transpose(he), $
          transpose(k),transpose(ke),transpose(av),transpose(averr)]
  close,1

  return
end





pro do_fit,x,y,err,p0,pfit,avmax=avmax

  inds = where(x gt p0[1] and x lt avmax and y gt 0 and err gt 0)
  x = x[inds]
  y = y[inds]
  err = err[inds]

  npar    = n_elements(p0)
  parinfo = replicate( { fixed: 0b, $
                         limited: [0b,0], $
                         limits: dblarr(2) } $
                       ,npar)
    ; Amp limits
  parinfo[0].limited = 1b
  parinfo[0].limits = [0,1d6]

  ; cen limits
;  parinfo[1].limited = 1b
;  parinfo[1].limits = [-100,min(x)]

  ; mean limits
;  parinfo[2].limited = 1b
;  parinfo[2].limits = [0.1,0.9]

  ; wid limits
  parinfo[3].limited = 1b
  parinfo[3].limits = [0.01,20]


  fa = {x:x,y:y,err:err}
  pfit = mpfit('lognorm_func',p0,functargs=fa,maxiter=100,covar=covar,/quiet)


return
end


pro map_av,avmap,h,avemap,numstars,cdelt=cdelt,write=write, $
           Avmax=Avmax,cloud=cloud

; this procedure takes the Av data from get_av and uses it to create
; an extinction map

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; READ DATA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  path = '/Users/js/Astronomy/IRDCs/reductions/CFHT/processed/'
  file = file_search(path+cloud+'.Av.dat',count=fct)
  if fct ne 1 then get_av,cloud=cloud
  
  print,' Reading extinction data ...'
  readcol,file,format='f,f,f,f,f,f,f,f,f,f',ra_vec,dec_vec,j_vec, $
          je_vec,h_vec,he_vec,k_vec,ke_vec,Av_vec,Ave_vec,/silent
  print,' Read '+string(n_elements(j_vec))+' lines'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; CREATE MAP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; preliminary header values
  ; sine projection not explicitly accounted for in this small map
  ; (mapsize/2 ~ 0.004 radians)
  ctype1 = 'RA---TAN'
  ctype2 = 'DEC--TAN'

  rarange  = minmax(ra_vec)
  decrange = minmax(dec_vec)
  
  crval1 = mean(rarange)
  crval2 = mean(decrange)
  aspect = cos(crval2*!dtor)

  ; optimize pixel size
; !!! need to do this !!!
  if not keyword_set(Avmax) then Avmax = 30.
  ak       = Avmax*0.112

; !!! need to do this !!!
  ; number of sq. arcmin to get one star at Avmax
  if keyword_set(cdelt) then  cdelt  = cdelt > 0.1; else $
;    cdelt = sqrt((num/(kcoeff*10.^(0.25*(limk-ak))))) > 1.2
   
  ; odd # of pixels along each axis so central coordinates are
  ; on an integer pixel
  naxis1 = round(((rarange[1]-rarange[0])*60./cdelt)*aspect)/2*2 + 1
  naxis2 = round(((decrange[1]-decrange[0])*60./cdelt))/2*2  + 1
  crpix1 = (naxis1+1)/2
  crpix2 = (naxis2+1)/2
  
  ; square pixels
  cdelt2 = (decrange[1]-decrange[0])/naxis2
  cdelt1 = -1*cdelt2

  mkhdr,h,4,[naxis1,naxis2]
  sxdelpar,h,'COMMENT'
  sxaddpar,h,'EQUINOX',2000
  sxaddpar,h,'EPOCH',2000.0
  sxaddpar,h,'RADECSYS','FK5'
  sxaddpar,h,'CRVAL1',crval1
  sxaddpar,h,'CDELT1',cdelt1
  sxaddpar,h,'CTYPE1',ctype1  
  sxaddpar,h,'CRPIX1',crpix1
  sxaddpar,h,'CRVAL2',crval2
  sxaddpar,h,'CDELT2',cdelt2
  sxaddpar,h,'CTYPE2',ctype2  
  sxaddpar,h,'CRPIX2',crpix2
  sxaddpar,h,'BUNIT','AV'

  extast,h,ast
  
  avmap    = fltarr(naxis1,naxis2)   ; Av map
  numstars = fltarr(naxis1,naxis2)   ; number of stars included in each pixel 
  avemap   = fltarr(naxis1,naxis2)   ; Av error map

; ASSIGN AV VALUES TO EACH PIXEL ACCORDING TO SIGMA CLIPPED MEAN
  ra  = ra_vec
  dec = dec_vec
  Av  = Av_vec
  Ave = Ave_vec

  starttime = systime(/sec)
  spawn,'date',date
  print,' Starting gridding loop on '+date
  for i = 0, naxis1-1 do begin  
      for j = 0, naxis2-1 do begin 
          xy2ad,i,j,ast,rapix,decpix
          gcirc,1,rapix/15.,decpix,ra/15.,dec,dis 
          inds = where(dis lt 2*cdelt*60.,ct) 
          if ct eq 0 then begin 
              avmap[i,j] = !values.f_nan 
              avemap[i,j] = !values.f_nan 
              numstars[i,j] = 0 
          endif else begin      
              avs  = av[inds]   
              aves = ave[inds]  
              ws   = (aves)^(-1.)*exp(-dis[inds]^2./(2*(cdelt*60)^2.)) 
              avmap[i,j]  = total(ws*avs,/preserve)/total(ws,/preserve) 
              avemap[i,j] = 1./sqrt(total(ws,/preserve)) 
              numstars[i,j] = ct 
          endelse               
      endfor                    
      if i gt 0 and i mod 2 eq 0 then begin 
          percent = float(i)/float(naxis1-1) * 100. 
          elapse  = systime(/sec) - starttime 
          if elapse lt 60. then begin
              time = string(elapse,format='(f4.1)')
              unit = ' seconds'
          endif
          if elapse gt 60. and elapse lt 3600. then begin
              time = string(elapse/60.,format='(f4.1)')
              unit = ' minutes'
          endif
          if elapse gt 3600. and elapse lt 86400. then begin
              time = string(elapse/3600.,format='(f4.1)')
              unit = ' hours'
          endif
          if elapse gt 86400. then begin
              time = string(elapse/86400.,format='(f4.1)')
              unit = ' days'
          endif
          print,format='($,2x,a,a)',string(percent,format='(f5.1)')+'% done in '+ $
                time+unit,fifteenb()
      endif
  endfor 
  print,' '
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; WRITE FITS FILES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  if keyword_set(write) then begin
      sxaddpar,h,'DATAMAX',max(avmap,/nan)
      sxaddpar,h,'DATAMIN',min(avmap,/nan)
      meanclip,avemap,errmean,errsig
      sxaddpar,h,'RMS',errmean
      writefits,path+cloud+'.Av.fits',avmap,h

      he = h
      ; Av error map
      sxaddpar,he,'DATAMAX',max(avemap,/nan)
      sxaddpar,he,'DATAMIN',min(avemap,/nan)
      sxaddpar,he,'RMS',robust_sigma(avemap)
      writefits,path+cloud+'.Av.error.fits',avemap,he

      hn = h
      ; numstars map
      sxaddpar,hn,'DATAMAX',max(numstars,/nan)
      sxaddpar,hn,'DATAMIN',min(numstars,/nan)
      sxaddpar,hn,'RMS',robust_sigma(numstars)
      writefits,path+cloud+'.Numstars.fits',numstars,hn
      
  endif

  return
end






pro display_av,avmap=avmap,header=h,ps=ps,cloud=cloud,scuba=scuba, $
               title=title

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Display AV Map with Stanke Cores
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  path = '/Users/js/Astronomy/IRDCs/reductions/CFHT/processed/'

  if not keyword_set(header) then h = headfits(path+cloud+'.Av.fits')
  if not keyword_set(avmap) then avmap = readfits(path+cloud+'.Av.fits',h)

  extast,h,ast

  ; blank weird hole thing
;  rahole  = hms2dec('16 29 07')
;  dechole = hms2dec('-26 24 30')
;  ad2xy,rahole*15.,dechole,ast,xhole,yhole
;  rhole = 20./(sxpar(h,'cdelt2')*60)
;  djs_photfrac,xhole,yhole,rhole,xdimen=sxpar(h,'naxis1'), $
;               ydimen=sxpar(h,'naxis2'),pixnum=pix
;
;  avmap[pix] = !values.f_nan


  rms = sxpar(h,'RMS')
  range = [7,20.]
  
  sz = size(avmap)
  xy2ad,indgen(sz[1]),intarr(sz[1]),ast,ravec,dec_dummy
  xy2ad,intarr(sz[2]),indgen(sz[2]),ast,ra_dummy,decvec

  aspect = abs(max(ravec)-min(ravec))/abs(max(decvec)-min(decvec)) * $
           cos(!dtor*mean(decvec))

 ; make mask
  avreg = avmap
  inds = where(finite(avmap) eq 1)
  avreg[inds] = 1
  inds = where(finite(avmap) eq 0)
  avreg[inds] = 0
  
  thick = 1
  negative = 0
  if keyword_set(ps) then begin
      thick = 4
      psopen,cloud+'.Av',/color,/land
  endif

  xtitle = '!6 Right Ascension (J2000)'
  ytitle = 'Declination (J2000)'
  charsize = 1.2
  loadct,0
  ymargin = [6,2]
  xmargin = [12,15]
  display,avmap,ravec,decvec,/noimage,/nodisplay,aspect=aspect
  rdticks, raticks, ratickv, ratickname, decticks, dectickv, $
           dectickname, raminor=raminor, decminor=decminor, $
           CHARSIZE=charsize, XTHICK=thick,YTHICK=thick
  display,avmap,ravec,decvec,xticks=raticks,yticks=decticks, $
          xtickname=ratickname,ytickname=dectickname,xminor=raminor, $
          yminor=decminor,xtickv=ratickv,ytickv=dectickv, $
          xcharsize=charsize,min=range[0],max=range[1], $
          ycharsize=charsize,charsize=charsize, charthick=thick, $
          thick=thick,xthick=thick,ythick=thick,xmargin=xmargin, $
              ymargin=ymargin,title=title,negative=negative,aspect=aspect
  xyouts,!x.crange[0] - (!x.crange[1]-!x.crange[0])*.1, $
         mean(!y.crange), ytitle,charsize=charsize+0.3, $
         charthick=thick,align=0.5,/data,orient=90
  xyouts,mean(!x.crange),!y.crange[0] - (!y.crange[1]-!y.crange[0])*.11, $
         xtitle,charsize=charsize+0.3,charthick=thick,align=0.5,/data

  contour,avreg,ravec,decvec,/over,levels=[1],c_linestyle=1

  if keyword_set(scuba) then begin
      levels = [300]            ;,500,750,1000,1250,1500,1750,2000]
      labels = strcompress(str(levels),/rem)
      scuba = readfits('/Volumes/data/IRDCs/JCMT/SCUBA/'+cloud+'.SCUBA850.fits',hscuba)
      hastrom,scuba,hscuba,h,missing=!values.f_nan
      setcolors,/sys,/sil
      contour,scuba,ravec,decvec,/over,levels=levels, $
              c_thick=thick,c_color=!green,xmargin=xmargin
  endif

  dx = (!x.window[1] - !x.window[0])
  xpos0 = !x.window[1] + dx/50.
  xpos1 = (!x.window[1] + dx/50. + 0.025) < 1
  ypos0 = !y.window[0]
  ypos1 = !y.window[1]
  position = [xpos0,ypos0,xpos1,ypos1]
  loadct,0
  colorbar,/vert,position=position,xtitle=' ',ytitle=' ', $
           negative=negative,yticklen=0.25,crange=range,thick=thick,xthick=thick, $
           ythick=thick,charthick=thick

  sharpcorners, thick=thick

  if keyword_set(ps) then psclose
  setcolors,/sys,/sil

  return
end





pro av_in_out,ain,pfitin,aout,pfitout,cloud=cloud,path=path,avmax=avmax
  if not keyword_set(cloud) then cloud = 'G028.53'
  if not keyword_set(path) then path = '/Users/js/Astronomy/IRDCs/reductions/CFHT/processed/'
  

  avmap = readfits(path+cloud+'.Av.fits',hav)
  avemap = readfits(path+cloud+'.Av.error.fits',have)
  sz = size(avmap)
  extast,hav,ast

  bob = fltarr(sz[1],sz[2])
  x = where(bob eq 0) mod sz[1]
  y = where(bob eq 0) / sz[1]
           
  ra  = makeaxes(hav,/ra)
  dec = makeaxes(hav,/dec)



  insave = file_search(cloud+'.Av_in.sav',count=fct)
  if fct eq 0 then begin 
      
      display,avmap
      
      smapath = '/Users/js/Astronomy/IRDCs/reductions/combination/'+cloud+'/'
      sma = readfits(smapath+cloud+'_cont_SMA.fits',hsma)
      if cloud eq 'G028.53' then rms = readfits(smapath+'combined_cont.rms.fits',hrms)
      if cloud eq 'G030.88' then rms = readfits(smapath+'combined_cont.gain.fits',hrms)
      hastrom,sma,hsma,hav,missing=!values.f_nan
      hastrom,rms,hrms,hav,missing=!values.f_nan
      
      if cloud eq 'G028.53' then levels=[0.0057]
      if cloud eq 'G030.88' then levels=[1.0]
      contour,rms,/over,levels=levels,c_thick=thick,c_color=!yellow, $
              xmargin=xmargin,c_linestyle=2
      
      
      levels = [250]            ;,500,750,1000,1250,1500,1750,2000]
      labels = strcompress(str(levels),/rem)
      scuba = readfits('/Volumes/data/IRDCs/JCMT/SCUBA/'+cloud+'.SCUBA850.fits',hscuba)
      hastrom,scuba,hscuba,hav,missing=!values.f_nan
      setcolors,/sys,/sil
      contour,scuba,/over,levels=levels, $
              c_thick=thick,c_color=!white,xmargin=xmargin
      
      
      xpos = 1.
      inx = [0.]
      iny = [0.]
      makesym,10
      setcolors,/sys,/sil
      while xpos gt -0.5 do begin                          &$
          cursor,xpos,ypos,/up                             &$
          if xpos gt -0.5 then begin                       &$
              plots,xpos,ypos,psym=8,color=!green          &$
              inx = [inx,xpos]                             &$
              iny = [iny,ypos]                             &$
              plots,inx[1:*],iny[1:*],color=!green,thick=2 &$
          endif                                            &$
      endwhile
      
      ux = uniq(inx)
      inx = inx[ux]
      iny = iny[ux]
      
      inx = [inx,inx[1]] 
      iny = [iny,iny[1]] 
      inx = inx[1:*]
      iny = iny[1:*]

      plots,inx,iny,color=!green,thick=2 
      print,' Would you like to save this region? (y/n) '
      input = get_kbrd()
      if strcompress(input,/rem) eq 'y' then save,inx,iny,filename=cloud+'.Av_in.sav'
      
  endif else restore,filename=cloud+'.Av_in.sav'
  
  plots,inx,iny,color=!green,psym=8 
  plots,inx,iny,color=!green,thick=2 
  yn = inside(x,y,inx,iny)
  ininds = where(yn eq 1,complement=outinds)

  avwt = 1./avemap[ininds]^2.
  avval = avmap[ininds]

  avin    = total(avwt*avval,/pre)/total(avwt,/pre)
  avinerr = robust_sigma(avval)
  
  avwt = 1./avemap[outinds]^2.
  avval = avmap[outinds]

  avout    = total(avwt*avval,/pre,/nan)/total(avwt,/pre,/nan)
  avouterr = robust_sigma(avval)

  display_av,cloud=cloud,/scuba

  xyouts,0.6,0.75,/norm,charsize=1.5,'!6A!DV!N (inside) = '+ $
         strcompress(string(avin,format='(f7.2)'),/rem)+ $
         ' +/- '+strcompress(string(avinerr,format='(f5.2)'),/rem)

 xyouts,0.6,0.7,/norm,charsize=1.5,'!6A!DV!N (outside) = '+ $
         strcompress(string(avout,format='(f7.2)'),/rem)+ $
         ' +/- '+strcompress(string(avouterr,format='(f5.2)'),/rem)
  return
end


