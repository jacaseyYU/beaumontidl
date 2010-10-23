pro splot, date, object, ra = ra, dec = dec, galactic = galactic

  if n_elements(object) ne 0 then $
     nobj = n_elements(object) $
  else obj = n_elements(ra)

  data = ptrarr(nobj)
  for i = 0, nobj - 1, 1 do begin
     if keyword_set(ra) then begin
        data[i] = ptr_new(sourcepos(date, $
                                    ra = ra[i], $
                                    dec = dec[i], $
                                    galactic = galactic))
     endif else begin
        data[i] = ptr_new(sourcepos(date, object[i], $
                                    galactic = galactic))
     endelse
  endfor
  if n_elements(object) eq 0 then $
     object = replicate(' ', nobj)
  
  plot, [0,24], [0,1], /nodata, yticks = 1, $
        ytickn = replicate(' ', 2)
  for i = 0, nobj - 1, 1 do begin
     thresh=[0, 30, 40, 50, 60, 70]
     y = .9D * (i+1) / nobj
     dy = [-.01, .01]
     d = *data[i]
     for j = 0, n_elements(thresh) - 1, 1 do begin        
        hit = where(d[1,*] ge thresh[j], ct)
        if ct eq 0 then continue
        oplot, minmax(d[0,hit]), [y,y]
        oplot, min(d[0,hit])+[0,0], y+dy
        oplot, max(d[0,hit])+[0,0], y+dy
        print, minmax(d[0,hit])
        xyouts, min(d[0,hit]), y+dy[1], strtrim(thresh[j],2)
        xyouts, max(d[0,hit]), y+dy[1], strtrim(thresh[j],2)
        if j eq 0 then $
           xyouts, mean(d[0,hit]), y+dy[1], object[i], $
                   charsize = 1.5
     endfor
  endfor

end

pro test
  readcol, '~/jcmt_may/bubbles.sou', $
           name, ep, yr, ra, dec, delim=' ', count=ct, $
           format='a, a, a, a, a'
  x = replicate(0., ct) & y = x
  for i = 0, ct - 1, 1 do begin
     s = strsplit(ra[i], ':', /extract)
     x[i] = ten(s[0], s[1], s[2])*15.
     s = strsplit(dec[i], ':', /extract)
     y[i] = ten(s[0], s[1], s[2])
  endfor
  hit = where(name eq 'N130')
  r=sourcepos( '20100613', name[hit], ra=x[hit], dec=y[hit])
  plot, r[0,*], r[1,*], yra = [0,max(r[1,*])]
;  splot, '20100613', name[hit], ra=x[hit], dec=y[hit]

  
end
