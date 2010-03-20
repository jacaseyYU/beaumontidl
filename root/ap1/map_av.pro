;- JS CODE

pro map_av,avmap,h,avemap,numstars,cdelt=cdelt,write=write, $
           Avmax=Avmax,cloud=cloud

; this procedure takes the Av data from get_av and uses it to create
; an extinction map

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; READ DATA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  file = '/Users/cnb/glimpse/pro/G028.53.Av_fix.dat'
  
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
              ws   = (aves)^(-1.)*exp(-dis[inds]^2./(2*(cdelt*60)^2.))  ;-FIXED AVES
              avmap[i,j]  = total(ws*avs,/preserve)/total(ws,/preserve) 
              avemap[i,j] = 1./sqrt(total(ws,/preserve)) ;-FIXED WEIGHTS 
              ;avemap[i,j] = sqrt(total(ws^2 * aves^2) / total(ws^2))
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
          print,string(percent,format='(f5.1)')+'% done in '+ $
                time+unit
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


