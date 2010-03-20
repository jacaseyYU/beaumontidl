;- look at scatter vs magnitude for an individual image

pro render, images, im, name
  
  ref = where(images.name eq name, ct)
  if ct eq 0 then begin
     plot, [0,0],[0,0],/nodata, psym = 4, $
;           xtitle = 'Magnitude', ytitle = 'd_dec (arcsec)', $
           title = name, charsize = 0.5, $
     xra = [10, 22], yra =[-.4, .4], /xsty, /ysty
     oplot, [0, 25], [0, 0], color = fsc_color('crimson')
     oplot, [17, 17], [-50,50], color = fsc_color('crimson')
     return
  endif
  
  ind = where(im.image_id eq ref[0], ct)
  if ct eq 0 then begin
     plot, [0,0],[0,0],/nodata, psym = 3, $
;           xtitle = 'Magnitude', ytitle = 'd_dec (arcsec)', $
           title = name, charsize = .5, $
           xra = [10, 22], yra =[-.4, .4], /xsty, /ysty
     oplot, [0, 25], [0, 0], color = fsc_color('crimson')
     oplot, [17, 17], [-50,50], color = fsc_color('crimson')
     return
  endif
  
  plot, im[ind].mag, im[ind].d_dec, psym = 4, $
;        xtitle = 'Magnitude', ytitle = 'd_dec (arcsec)', $
        title = name, charsize = .5, symsize = .25, $
        xra = [10, 22], yra =[-.4, .4], /xsty, /ysty
  oplot, [0, 25], [0, 0], color = fsc_color('crimson')
  oplot, [17, 17], [-50,50], color = fsc_color('crimson')
  
end

pro imageScatterDriver, fileName
  if n_elements(fileName) eq 0 then message, 'Include a file Name'

;-raw image info
  images = mrdfits('catdir.107/Images.dat', 1, h, /silent)
  nim = n_elements(images)
  names = strarr(nim)
  for i = 0, nim-1, 1 do  $
     names[i] = (strsplit(images[i].name, '[',/extract))[0]
  unique = names[uniq(names,sort(names))]
  nunique = n_elements(unique)
  
  files = file_search('catdir.107/*/*.cpm')
  im = mrdfits(files[0], 1, h, /silent)
  
  
;- gather .cpm tables
  for i = 1, n_elements(files) - 1, 1 do begin
     tmp = mrdfits(files[i], 1, h, /silent)
     im = [im,tmp]
  endfor
  im = im[where(finite(im.mag) and finite(im.d_dec))]
  
;- plot
  set_plot, 'ps'
  device, file = fileName, /color, xsize = 7.5, ysize = 7.5, $
          xoff = .5, yoff = .5, /inches

  ;- plot phu chips
  !p.multi = [0, 6, 6]
  for i = 0, nunique -1, 1 do begin
     render, images, im, unique[i] +'[PHU]'
  endfor

  for i = 0, nunique - 1, 1 do begin
     !p.multi = [0, 6, 6]
  
     
     for j = 0, 35, 1 do begin
        render, images, im, unique[i]+'[ccd' + $
                string(j, format='(i2.2)') + '.hdr]'
     endfor      
  endfor
  device,/close
  set_plot,'X'
  
end

pro imageScatter
  spawn, 'tar -xf catdir.107.iter0.tar'
  imageScatterDriver, 'chips.iter0.ps'
  
  spawn, 'tar -xf catdir.107.iter2.tar'
  imageScatterDriver, 'chips.iter2.ps'
  
  spawn, 'tar -xf catdir.107.iter11.tar'
  imageScatterDriver, 'chips.iter11.ps'
  
end
