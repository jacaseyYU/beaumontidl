pro scatterbin

mname = '~/catdir.98/n0000/0148.cpm'
dates = [5, 10, 20, 30, 45, 60, 90, 120]
t = mrdfits('~/catdir.98/n0000/0148.cpt',1,h,/silent)
nt = n_elements(t)
rand = randomn(seed, nt)
rand = sort(rand)
t=t[rand]
restore, file='~/catdir.98/n0000/0148.sav'
for i = 0L, nt - 1, 1 do begin
   if t[i].nmeasure lt 150 then continue
   lo = t[i].off_measure
   hi = lo + t[i].nmeasure - 1
   good = where(flags[lo:hi] eq 0, gct)
   m = mrdfits(mname, 1, h, /silent, range=[lo,hi])
   if gct lt 60 then continue
   stop
   m = m[where(good)]
   jd = linux2jd(m.time)
   
   jdfine = min(jd) + findgen(range(jd))
   par_factor, t[i].ra, t[i].dec, jdfine, pR, pD
   
   for j = 0, n_elements(dates) - 1, 1 do begin
      bin_by_date, jd, m.d_ra, dates[j], jdbin, rabin, binerr, pop
  
      mean = total(rabin / binerr^2) / total(1 / binerr^2)
      nelem = n_elements(rabin)
      rms = sqrt(total((rabin - mean)^2 / binerr^2) / total(1 / binerr^2)) * sqrt(nelem / (nelem - 1.))
      ;rms = stdev(rabin)
      yra = minmax(rabin) + max(binerr) * [-1,1]
      xra = minmax(jd) + [-1, 1] - min(jd)
   
                             ; PLOT 0
; Overview of the data. Are the individual point error bars comparable
; to the sample stdev?
      wset, 0
      ploterror, jdbin-min(jdbin), rabin, $
                 fltarr(n_elements(jdbin)) + dates[j]/2, binerr, xra=xra, yra = yra, $
                 psym=3, xtit = 'Days', ytit = 'd_ra (arcsec)'
      oplot, range(jdbin)*[0,1], mean + rms * [1,1], color = fsc_color('grey')
      oplot, range(jdbin)*[0,1], mean + rms * [-1,-1], color = fsc_color('grey')
      oplot, jdfine - min(jdbin), .5 * pR * stdev(rabin) + yra[0] + .25 * range(yra), color = fsc_color('grey')
      for k = 0, n_elements(rabin) - 1, 1 do begin
         xyouts, jdbin[k]-min(jdbin), yra[0] + range(yra) * .2 * (k mod 5)/4., strtrim(pop[k],2),/data, $
                 color=fsc_color('green'), charsize=2
      endfor
      
;- PLOT 1
;- Is the sample consistent with each data point being drawn from a
;- gaussian distribution with a sigma equal to its error bar, and a mean
;- equal to the sample mean?
      
      wset, 1
      h = histogram(abs(rabin - mean) / binerr, binsize = 1d-2, loc = loc)
      plot, loc, total(h, /cumul) / total(h), $
            xtit = textoidl('\Delta_{ra} / \sigma_{ra}'), ytit= 'P( < x)', xra = [0,10],$
            charsize = 1.5
      px = findgen(300) / 30.
      oplot, px, 1-2 * gauss_pdf(-px), color = fsc_color('orange')
      xyouts, .5, .4, 'Binsize (days): '+strtrim(dates[j],2), charsize = 2, /norm
      xyouts, .5, .35, 'Magnitude: '+ $
              string(median(m.mag),format='(f4.1)')+' +/- ' +$
              string(median(m.mag_err), format='(f4.2)'), /norm, charsize = 2
      xyouts, .5, .3, 'Median ebar: '+string(median(binerr*1d3), format='(i4)')+' mas', $
              /norm, charsize=2
      xyouts, .5, .25, 'Sample rms: '+string(rms*1d3,format='(i3)')+' mas', $
              /norm, charsize=2
      
;- PLOT 3
; What is the cdf of error bar sizes? How does this compare to the
; sample rms?
      wset, 2
      h = histogram(binerr, binsize = 1d-4, loc = loc)
      cdf = total(h,/cumul) / total(h)
      med = interpol(loc, cdf, .5)
      fsig = interpol(cdf, loc, rms)
      plot, loc, cdf, xtit = 'Error Bar size (arcsec)', $
            ytit = 'P(ebar < x)', charsize=1.5
      oplot, [med, med, 0], [0, .5, .5], color = fsc_color('aqua')
      oplot, [rms, rms, 0], [0, fsig, fsig], color = fsc_color('orange')
      stop
            
   endfor

endfor

end
