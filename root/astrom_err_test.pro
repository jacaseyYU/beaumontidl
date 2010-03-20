pro astrom_err_test

  common memory_block, m, t, im
  if n_elements(m) eq 0 then begin
     m = mrdfits('/media/cave/catdir.98/n0000/0148.cpm',1,h)
     t = mrdfits('/media/cave/catdir.98/n0000/0148.cpt',1,h)
     im = mrdfits('/media/cave/catdir.98/Images.dat', 1, h)
  endif

  ;- group images by image name
  nums = strmid(im.name, 0, 14)
  nums = nums[uniq(nums)]
  num = n_elements(nums)

  for i = 0, num - 1, 1 do begin
     hit = where(strmatch(im[m.image_id - 1].name, nums[i]+'*') and $
                 t[m.ave_ref].nmeasure gt 50, ct)
     if ct eq 0 then continue
     
     subm = m[hit]
     assert, range(subm.photcode / 100) eq 0
;     if subm[0].photcode / 100 ne 3 then continue
     dx = subm.d_ra
     dy = subm.d_dec
     snr = 1 / subm.mag_err
     
     good = where(subm.fwhm_major ne 0)
     major = mean(subm[good].fwhm_major * subm[good].pltscale) /1d2
     minor = mean(subm[good].fwhm_minor * subm[good].pltscale) /1d2
     theta = mean(subm[good].psf_theta) * !dtor
     psfx = abs(major * sin(theta)) > abs(minor * cos(theta))
     psfy = abs(major * cos(theta)) > abs(minor * sin(theta))
     bad = where((subm.phot_flags and 14728) ne 0 or $
                 (subm.psf_chisq gt 5 * subm.psf_ndof) or $
                 (abs(subm.d_ra) gt 5) or (abs(subm.d_dec) gt 5), badct, $
                 complement = good, ncomp = goodct)

     sig = astrom_err_model(dx[good], snr[good], psfx, /plot)
  endfor

end
