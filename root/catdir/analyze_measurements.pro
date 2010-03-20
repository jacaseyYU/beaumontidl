function analyze_measurements, t, m, chipflag

if n_elements(chipflag) eq 0 then chipflag = bytarr(60000)+1B

assert, range(m.ave_ref) eq 0
assert, t.nmeasure eq n_elements(m)

u = where((m.photcode / 100) eq 1, uct)
g = where((m.photcode / 100) eq 2, gct)
r = where((m.photcode / 100) eq 3, rct)
i = where((m.photcode / 100) eq 4, ict)
z = where((m.photcode / 100) eq 5, zct)

umag = !values.f_nan
gmag = !values.f_nan
rmag = !values.f_nan
imag = !values.f_nan
zmag = !values.f_nan

dumag = !values.f_nan
dgmag = !values.f_nan
drmag = !values.f_nan
dimag = !values.f_nan
dzmag = !values.f_nan

rms = sqrt(t.ra_err^2 + t.dec_err^2)

if uct ne 0 then $
   umag = wmean(m[u].mag, m[u].mag_err, error = dumag,/nan)
if gct ne 0 then $
   gmag = wmean(m[g].mag, m[g].mag_err, error = dgmag,/nan)
if rct ne 0 then $
   rmag = wmean(m[r].mag, m[r].mag_err, error = drmag,/nan)
if ict ne 0 then $
   imag = wmean(m[i].mag, m[i].mag_err, error = dimag,/nan)
if zct ne 0 then $
   zmag = wmean(m[z].mag, m[z].mag_err, error = dzmag,/nan)

;- conditions for a good measurement:
;-  1) Not an outlier
;-  2) Does not match the astrom_bad_mask photflag
;- note: db_flags and '40'xl ne 0 pulls out stars used in updateObjects
good = detectoutlier(m.d_ra, m.d_dec, status, thresh = 3) and ($
       (m.phot_flags and 14472) eq 0 and (chipflag[m.image_id] eq 1))
hit = where(good, ct)

if ct ne 0 then begin
   myrms = sqrt(mean(m[hit].d_ra^2 + m[hit].d_dec^2,/nan))
   myra = mean(m[hit].d_ra) + t.ra
   mydec = mean(m[hit].d_dec) + t.dec
endif else begin
   myrms = !values.f_nan
   myra = !values.f_nan
   mydec = !values.f_nan
endelse

mag = wmean(m.mag, m.mag_err, /nan)

result = {meas_summary, mag : mag, $
          umag : umag, dumag : dumag, $
          gmag : gmag, dgmag : dgmag, $
          rmag : rmag, drmag : drmag, $
          imag : imag, dimag : dimag, $
          zmag : zmag, dzmag : dzmag, $
          rms : rms, myrms : myrms, $
          ra : t.ra, dec : t.dec, $
          myra : myra, mydec : mydec}
return, result

end
