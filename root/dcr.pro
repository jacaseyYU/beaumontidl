;- initial exploration of dcr
;- two ways to measure - which works better??
; approach 1:
; 1) pick a single exposure
; 2) calculate the parallactic angle
; 3) Calculate d_pa (color)
; 4) Plot and remove any trend
; can follow weather, but limited by star count statistics in one
;- image
;  these plots certainly show structure. But is it real, or is it just
;- the weird placement of stars on the chips?
;
; approach 2:
;  1) Pick N images in a given filter over many X
;  2) Find PAs and d_pa
;  3) Plot surface of d_pa vs X, color
;  4) Remove trends
;   lots of stars to average over, but smears out weather changes
;   which is more important?
;   The scatter in a plot of dcr color slop vs airmass is bigger than
;- the error bars, but is centered at zero over all airmasses. Low
;  - airmasses show a bigger scatter in slope than high airmass. this
;    - is contrary to what I would have expected. However, there are
;      - many points at low airmass. it could just be that there are
;        - more outliers at that range. Maybe the scatter suggests
;          - that weather is more important than any mean
;            - trend? but shouldn't the slope be of the same sign??
pro dcr

  m = mrdfits('/media/cave/catdir.98/n0000/0148.cpm',1,h)
  t = mrdfits('/media/cave/catdir.98/n0000/0148.cpt',1,h)
  s = mrdfits('/media/cave/catdir.98/n0000/0148.cps',1,h)
  im = mrdfits('/media/cave/catdir.98/Images.dat',1,h)

  ;- group images by image name
  names = strmid(im.name, 0, 14)
  names = names[uniq(names)]
  nexp = n_elements(names)

  slopes = replicate(!values.f_nan, nexp)
  alts = replicate(!values.f_nan, nexp)
  
  m_names = strmid(im[m.image_id - 1].name, 0, 14)
  for i = 0, nexp - 1, 1 do begin
     ;- select all measurements from exposure i
     hit = where(m_names eq names[i] and $
                 t[m.ave_ref].nmeasure gt 50, ct)
     if ct lt 500 then continue
     subm = m[hit]
     ;- g- r color
     colors = s[subm.ave_ref * 5].mag - s[subm.ave_ref * 5 + 1].mag

     ;- displacement allong parallax angle
     jd = linux2jd(subm.time)
     eq2hor, t[subm[0].ave_ref].ra, t[subm[0].ave_ref].dec, jd[0], $
             alt, az, ha, $
             precess_=0, nutate_=0, aberration_=0, $
             refract_=0, obsname='cfht'
     assert, alt gt 0
     alts[i] = alt
     lat = ten([19,49,28])
     
     amass = 1/cos((90 - min(alt))*!dtor)
     par_angle = parangle(replicate(ha, n_elements(subm)), $
                          t[subm.ave_ref].dec, $
                          replicate(lat, n_elements(subm)), /degree)
     d_par = subm.d_ra * sin(par_angle) + $
             subm.d_dec * cos(par_angle)
    
     a = linfit(colors[where(finite(colors))], d_par[where(finite(colors))])
     slopes[i] = a[1]
  
     if alt gt 60 then continue
     plot, colors, d_par, psym = 3
     oplot, colors, a[0] + a[1] * colors, color = fsc_color('red')
     stop
     endfor
  plot, alts, slopes, psym = 3
  
  stop
  
end
