pro astrom_err_apply

  catdirs = file_search('/media/cave/catdir.[1-9]*', count = ncatdir)
  for i = 0, ncatdir - 1, 1 do begin
     print, catdirs[i]

     im = mrdfits(catdirs[i]+'/Images.dat', 1,h, /silent)
     
     ;- group images by image name
     names = strmid(im.name, 0, 14)
     names = names[uniq(names)]
     nexp = n_elements(names)

     ms = file_search(catdirs[i]+'/*/*.cpm', count = mct)
     ts = file_search(catdirs[i]+'/*/*.cpt', count = tct)

     ;- loop over measurements
     for j = 0, mct - 1, 1 do begin
        print, '       '+ms[j]

        outfile = ms[j]
        outfile = strsplit(outfile, '.', /extract)
        outfile = outfile[0]+'.'+outfile[1]+'.skymodel'
        if file_test(outfile) then continue

        ;- zero out large variables to free up memory
        m = 0
        t = 0
        nmeas = 0
        imname = 0
        marr = 0
        id = 0
        dx = 0
        dy = 0

        t = mrdfits(ts[j], 1, h, /silent)
        nobj = max(t.nmeasure + t.off_measure)
        many = where(t.nmeasure gt 50, manyct)
        if manyct eq 0 then continue
        
        cols = ['d_ra', 'd_dec', 'mag_err', $
                'image_id', 'ave_ref', $
                'psf_chisq', $
                'psf_ndof', 'psf_theta', $
                'fwhm_major', 'fwhm_minor', $
                'pltscale', 'phot_flags']
        cols = strupcase(cols)
        cols = [0, 1, 5, 15, 17, 22, 23, 27, 28, 29, 39, 41] + 1
        temp =  mrdfits(ms[j], 1, h, /silent, ra = [0,0], col = cols)
        nmeas = sxpar(h, 'naxis2')
        
        chix = fltarr(nexp) * !values.f_nan
        chiy = fltarr(nexp) * !values.f_nan
        dx = fltarr(nmeas) * !values.f_nan
        dy = fltarr(nmeas) * !values.f_nan

        imname = strarr(nmeas)
        measct = intarr(nmeas)
        m = replicate(temp, nmeas)

        for i = 0L, nmeas - 1, 500000 do begin
           m[i] = mrdfits(ms[j], 1, h, ra = [i, i + 500000 - 1],$
                             /silent, col = cols)
        endfor
        imname = im[m.image_id - 1].name
        measct = t[m.ave_ref].nmeasure
             
        ;- loop over images
        for k = 0, nexp - 1, 1 do begin
           print, k

           ;- find good images
           hit = where(strmatch(imname, names[k]+'*') and $
                       measct gt 50, hitct)
           if hitct lt 100 then continue
         
           subm = m[hit]

           xerr = subm.d_ra
           yerr = subm.d_dec
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

           if goodct eq 0 then continue
           ex = astrom_err_model(xerr[good], snr[good], psfx, chisq = cx)
           ey = astrom_err_model(yerr[good], snr[good], psfy, chisq = cy)
           dx[hit] = sqrt(ex[0]^2 + ex[1]^2 / snr^2 * psfx^2)
           dy[hit] = sqrt(ey[0]^2 + ey[1]^2 / snr^2 * psfy^2)
           chix[k] = cx
           chiy[k] = cy
        endfor ;- end image name loop
        
        ;- re-map skymodel variables to an array
        ;- with the same dimensions as the raw m table
        save, dx, dy, chix, chiy, file = outfile
        
     endfor                     ;- end catalog loop
  endfor                        ;- end catdir loop
  
end
