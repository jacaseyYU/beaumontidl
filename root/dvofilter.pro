pro test_plot

restore, 'dvotilter.sav'

e_floor *= 1000
e_cntr *= 1000
e_net *= 1000

set_plot, 'ps'
device, /encapsulated, file='~/699_2/scatter.eps', /color, /land, yoff = 9.5, /in

!p.thick = 2
!p.charthick = 2
  ;- plot up results
  plot, mags, rms * 1000, psym = 3, xra = [10, 22], yra = [10, 300], $
        xtit = 'Apparent Magnitude', ytit = 'rms (mas)', /ylog, charsize = 1.5
  floor = .0149666

  oplot, mag_ind, e_floor, color = fsc_color('red'), linestyle = 1, thick = 3
  oplot, mag_ind, e_cntr, color = fsc_color('red'), linestyle = 1, thick = 3
  oplot, mag_ind, e_net, color = fsc_color('red'), thick = 3

device, /close
set_plot, 'X'
end

pro test
;  dir = '/media/data/catdir.98'
;  dir = '~/catdir.10test'
 dir = '~/catdir.98'
  m = mrdfits(dir+'/n0000/0148.cpm',1,h)
  t = mrdfits(dir+'/n0000/0148.cpt',1,h)
  nmin = 40

;  window, 0
;  window, 1
;  restore, '~/pro/uberplot/explore.test.sav'
;  nmin = 40

  sort = reverse(sort(t.nmeasure))
  t = t[sort]
  good = where(t.nmeasure gt nmin, ct)
  chi2s = dblarr(ct) * !values.d_nan
  ngood = chi2s
  nbad = chi2s
  mags = chi2s
  rms = chi2s

  t = t[good]
  for i = 0, ct - 1, 1 do begin
     wset, 0
     lo = t[i].off_measure
     hi = lo - 1 + t[i].nmeasure
     subm = m[lo:hi]
;     if subm[0].mag lt 17 then continue
     hit = where((subm.photcode / 100) eq 4, gct)
     if gct lt nmin then continue else subm = subm[hit]
     assert, range(subm.ave_ref) eq 0
     filter = dvofilter(subm, obj_flag)
     good = where(filter eq 0, gct, complement= bad, ncom= bct)
     ngood[i] = gct
     nbad[i] = bct

     goto, skipplot
     test = where((filter and 1) ne 0, outct)
     if outct eq 0 then goto, skipplot
;     !p.multi=[0,1,2]
     plot, subm.d_ra, subm.d_dec, /nodata
     colors = ['green','red']
     for j = 0, n_elements(subm)-1, 1 do begin
        oplot, subm[j].d_ra *[1], subm[j].d_dec * [1],$
              color = fsc_color(colors[(filter[j] ne 0)]), psym=4
        xyouts, subm[j].d_ra, subm[j].d_dec, $
                string(filter[j],format='(Z)'), /data
     endfor
     ind = findgen(n_elements(subm))
     wset, 1
     if gct ne 0 then begin
        plot, [subm[good].d_ra], [subm[good].d_dec], psym = 4, color = fsc_color('green'), $
              xra = minmax(subm[good].d_ra) + range(subm[good].d_ra) * [-1,1], $
              yra = minmax(subm[good].d_dec) + range(subm[good].d_dec) * [-1,1]
        if bct ne 0 then $
           oplot, [subm[bad].d_ra], [subm[bad].d_dec], psym = 4, color = fsc_color('red')
        for j = 0, n_elements(subm)-1, 1 do begin
           oplot, subm[j].d_ra *[1], subm[j].d_dec * [1],$
                  color = fsc_color(colors[(filter[j] ne 0)]), psym=4
           xyouts, subm[j].d_ra, subm[j].d_dec, $
                   string(filter[j],format='(Z)'), /data
        endfor
     endif
     print, bct, gct, format = "('bad: ', i, ' good: ', i)"
     stop
     skipplot:
     if (gct gt 5) then begin
        dx = subm[good].d_ra
        dy = subm[good].d_dec
        fwhm = (subm[good].fwhm_major)
        fwhm = fwhm * .187 / 100
        zero = where(fwhm eq 0, zct)
        if zct ne 0 then fwhm[zero] = .5 
        floor = .0149666
        ex = sqrt(floor^2 + (subm[good].x_ccd_err * .187 / 100)^2)
        ey = sqrt(floor^2 + (subm[good].y_ccd_err * .187 / 100)^2)
;        ex = sqrt(.02^2 + (fwhm * subm[good].mag_err)^2)
;        ey = sqrt(.02^2 + (fwhm * subm[good].mag_err)^2)
        chi = total( (dx - median(dx))^2 / ex^2 + (dy - median(dy))^2 / ey^2, /nan)
        chi2s[i] = chi
        mags[i] = wmean(subm[good].mag, subm[good].mag_err,/nan)
        nice = where(finite(dx) and finite(dy), nct)
        if nct ne 0 then rms[i] = sqrt(stdev(dx[nice])^2 + stdev(dy[nice])^2)
        ;print, chi / gct, format='("Chi: ", f)'
        ;print, obj_flag, format='("Obj_flag: ", i2)'
        ;print, subm[good[0]].mag, format='("Mag: ", f)'
        ;stop
     endif
  endfor

  ;- plot up results
  plot, mags, rms * 1000, psym = 3, xra = [10, 22], yra = [1, 300], $
        xtit = 'Apparent Magnitude', ytit = 'rms (mas)', /ylog, charsize = 1.5
  floor = .0149666

  good = where(finite(m.mag))
  f = linfit(m[good].mag, alog10(m[good].mag_err))

  mag_ind = findgen(200) / 199 * 12 + 10
  e_floor = sqrt(2) * floor + mag_ind * 0
  e_cntr = 1 * 10^(f[0] + f[1] * mag_ind)
  e_net = sqrt(e_floor^2 + e_cntr^2)

  oplot, mag_ind, e_floor, color = fsc_color('red'), linestyle = 1
  oplot, mag_ind, e_cntr, color = fsc_color('red'), linestyle = 2
  oplot, mag_ind, e_net, color = fsc_color('red')

  save, mags, rms, e_floor, e_cntr, e_net, mag_ind, file='dvotilter.sav'


  stop
end


function dvofilter, m, obj_flag, mag

DEBUG = 0
assert, range(m.photcode / 100) eq 0 ;- measurements must be in the same filter
obj_flag = 0

;-measurement flags
OUT_CDF  = '1'x             ;- deemed an outlier from outliercdf
OUT_CLIP = '2'x             ;- a flagrant outlier, cliped from the beginning
OUT_MAG  = '4'x             ;- highly discrepant magnitude
BAD_MAG  = '8'x             ;- NAN magnitude
MULTI   = '10'x             ;- one of multiple detections in one exposure matched to the same object
PHOTFLAG = '20'x            ;- phot_flag encodes a bad astronmetry solution from ipp
names = ['out_cdf', 'out_clip', 'out_mag', 'bad_mag', 'MULTI', 'photflag']

;-object flags
MAG_SKIP   = '1'x               ;- skipped magnitude outlier detection                  
MAG_FAIL   = '2'x               ;- mag outlier detection failed
SKY_SKIP   = '4'x               ;- skipped sky outlier detection
SKY_FAIL   = '8'x               ;- sky outlier detection failed

;- magic numbers
ipp_bad = 14728                 ;- fail, sat, defect, cr, blend, satstar from IPP
OFF_THRESH = .6                 ;- objects more deviant than this are flagged automatically
few_frac = .5

flags = intarr(n_elements(m))

;- photflag cut
flags = flags or ((m.phot_flags and ipp_bad) ne 0) * PHOTFLAG

;- flagrant outlier cut
flags = flags or ((abs(m.d_ra) gt OFF_THRESH) or $
                  (abs(m.d_dec) gt OFF_THRESH)) * OUT_CLIP

;- bad magnitude cut
flags = flags or (~finite(m.mag)) * BAD_MAG

;- multiple detections / exposure cut
sz = n_elements(m)
for i = 0, sz-1, 1 do begin
   for j = i+1, sz - 1, 1 do begin
      if m[i].time eq m[j].time then flags[[i,j]] = flags[[i,j]] or MULTI
   endfor
endfor

;- magnitude outlier cut
good = where(flags eq 0, gct)
if gct lt 3 then begin
   obj_flag = obj_flag or MAG_SKIP
   return, flags
endif

if (DEBUG) then begin
   print, 'debugging outlier rejection'
   testoutlier, m[good].mag
   stop
endif

if 0 then begin
   flags[good] = flags[good] or (~outliercdf(m[good].mag, status)) * OUT_MAG
   if (status) then obj_flag = obj_flag or MAG_FAIL
   
;- spatial cut
   good = where(flags eq 0, gct)
   if gct lt 5 then begin
      obj_flag = obj_flag or SKY_SKIP
      return, flags
   endif
   
;flags[good] = flags[good] or (~outliersimple(m[good].d_ra)) * OUT_CDF
;flags[good] = flags[good] or (~outliersimple(m[good].d_dec)) * OUT_CDF
   flags[good] = flags[good] or (~outliercdf(m[good].d_ra, status1)) * OUT_CDF
   flags[good] = flags[good] or (~outliercdf(m[good].d_dec, status2)) * OUT_CDF
   if (status1 or status2) then obj_flag = obj_flag or SKY_FAIL
endif

;-XXX calculate magnitudes better
good = where(flags eq 0, gct)
if gct eq 0 then mag = !values.f_nan
if gct eq 1 then mag = m[good].mag
if gct gt 1 then mag = median(m[good].mag)

if max(flags) gt '40'x then stop
return, flags
end
