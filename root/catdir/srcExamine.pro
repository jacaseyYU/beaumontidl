pro srcExamine, m, a, image

imname = '781110'

if n_params() ne 3 then $
   loadCatdir, 'catdir.107.exp', m, a, s, n, image

for i = 0, 35, 1 do begin
   print, i
   id = findByExposure(m, image, $
                       expName = imname, ccd='ccd'+string(i,format='(i2.2)')+'.hdr', $
                      /verbose)

   if n_elements(id) eq 1 then begin
      print, 'skipping'
      continue
   endif

   ;-load image
   im = mrdfits(imname+'o.fits', i+1, h, /silent)

   subm = m[id]
;   lo_q = '8'xl or '10'xl or '400'xl or '800'xl or '1000'xl or '2000'xl or '4000'xl
;   lo_q = uint(lo_q)

;   hit = where((uint(subm.phot_flags) and lo_q) eq 0, ct)
   hit = where(~finite(subm.mag), ct)
;   hit = where(intarr(n_elements(subm)) + 1, ct)
   if ct eq 0 then begin
      print, 'No defect measurements for this ccd'
      continue
   endif else begin
      print, 'Selecting '+strtrim(string(ct),2)+' images for inspection'
   endelse

   sort = a[subm[hit].ave_ref].nmeas
   sort = sort(sort)
   plotStamps, im, subm[hit[sort]].x_ccd + 33, subm[hit[sort]].y_ccd + 1, i

   ;-overplot sources
;   window, xsize = 900, ysize = 900, retain = 2
;   tvscl, sigrange(-im, frac=.995)
;   oplot, m[id].x_ccd, m[id].y_ccd, psym = 4, symsize = 3, color=fsc_color('crimson')
;   stop
endfor

end

pro plotStamps, im, x, y, index
  sz = size(im)
  xsz = sz[1]
  ysz = sz[2]
  xwin = 700
  ywin = 700
  xstamp = 50
  ystamp = 50
  window, xsize = xwin, ysize = ywin, title = 'CCD '+strtrim(string(index),2)
  xp =rebin(findgen(xstamp) - xstamp / 2., xstamp, ystamp)
  yp = rebin(1#(findgen(ystamp) - ystamp / 2.), xstamp, ystamp)
  xoff = fltarr(n_elements(x))
  yoff = fltarr(n_elements(x))
  k = 0L
  while (k lt n_elements(x)) do begin
     for i = 0L, xwin - xstamp, xstamp do begin
        for j = 0L, ywin - ystamp, ystamp do begin
           subx =  0 > (xp + x[k]) < (xsz - 1)
           suby = 0 > (yp + y[k]) < (ysz - 1)
           stmp = im[subx, suby]
           stmp[0:3,*] = min(stmp,/nan)
           stmp[*, 0:3] = min(stmp,/nan)
           stmp[*, ystamp - 4 : ystamp - 1]= min(stmp,/nan)
           stmp[xstamp-4:xstamp-1, *] = min(stmp,/nan)
           tvscl, sigrange(stmp), i, j
           xoff[k] = (xp[where(stmp eq max(stmp))])[0]
           yoff[k] = (yp[where(stmp eq max(stmp))])[0]
           k++
           if (k ge n_elements(x)) then goto, out
        endfor
     endfor
     out:
     stop
     erase
  endwhile
;  hx = histogram(xoff, loc = xloc)
;  hy = histogram(yoff, loc= yloc)
;  plot, xloc, hx, psym = 10
;  oplot, yloc, hy, psym = 10, color = fsc_color('crimson')
;  stop
end
