; a test
pro test, bad = bad

restore, 'astrom_test.sav'
good = where((subm.phot_flags and 14728) eq 0)
subm = subm[good]
subt = subt[good]


delta = sqrt(subm.d_ra^2 + subm.d_dec^2)
plot, subm.mag, delta, psym = 3

weird = where(subm.mag lt 20 and delta gt .5)

plot, subm.mag, delta, psym = 3
bad = where(subm.psf_chisq / subm.psf_ndof gt 11)
;bad = where(subm.psf_ndof lt 900)
oplot, subm[bad].mag, delta[bad], psym = 4, color = fsc_color('green')
return

x = tag_names(subm)
ntags = n_elements(x)
for i = 0, ntags - 1, 1 do begin
   plot, subm.mag, subm.(i), psym = 3, $
         xtit = 'Mag', ytit = x[i]
   oplot, subm[weird].mag, subm[weird].(i), color = fsc_color('green'), psym = 4
   stop
endfor

return

oplot, subm[weird].mag, delta[weird], color = fsc_color('blue'), psym = 3
codes = get_photcodes()
;bad = where((subm.phot_flags and codes.SIZE_SKIPPED) ne 0 and $
;            (subm.phot_flags and codes.LINEAR_FIT) ne 0)
bad = where(subm.phot_flags eq 301989888)
help, bad
oplot, subm[bad].mag, delta[bad], color = fsc_color('green'), psym = 4

photcodes2text, subm[weird].phot_flags

print, subm[weird].phot_flags
print, ''
print, subm.phot_flags


return

plot, uint(subm.x_ccd_err), uint(subm.y_ccd_err), psym = 4
oplot, uint(subm[weird].x_ccd_err), uint(subm[weird].y_ccd_err), psym = 4, color = fsc_color('red')
print, minmax(uint(subm.x_ccd_err))
print, minmax(subm.time)


if ~keyword_set(bad) then return
bad = where(subt.nmeasure eq 1)
oplot, subm[bad].mag, delta[bad], psym = 3, color = fsc_color('red')



end
