;+
; NAME:
;  plotScatter
;
; DESCRIPTION:
;  this procedure reads catdir files in the current folder, calculates
;  the rms astrometric scatter for each matched object, and plots the
;  distribution of this scatter.
;
; MODIFICATION HISTORY:
;  January 2009- Written by cnb
;-

pro plotScatter

;-find catdir files
cpm = file_search('*.cpm') ;- measurements
cpn = file_search('*.cpn') ;- unpopulated
cps = file_search('*.cps') ;- secfilt
cpt = file_search('*.cpt') ;- averages

scatter = 0

for i = 0, n_elements(cpm) -1 , 1 do begin
    print, i+1, n_elements(cpm), format="('Reading file ', i1, ' of ', i1)";
    im = mrdfits(cpm[i], 1,/silent)
    av = mrdfits(cpt[i], 1,/silent)

    h = histogram(im.ave_ref, reverse_indices = ri, loc = loc)
    newscatter = fltarr(n_elements(h))

    ;- group detections by id
    k = 0L;
    for j = 0L, n_elements(h) - 1, 1 do begin

        if ri[j+1] eq ri[j] then continue        

        ;- only consider objects with 50 or more detections
        if av[loc[j]].nmeas le 50 then continue

        indices = ri[ri[j]:ri[j+1]-1]
        newscatter[k++] =  sqrt(mean((im[indices].d_ra)^2 + (im[indices].d_dec)^2))
    endfor

    scatter = [scatter, newscatter[0:k-1]]
endfor

;- trim off the initial 0
scatter = scatter[1:n_elements(scatter) - 1]
h = histogram(scatter, binsize = .005, loc = loc)

plot, loc, h, psym = 10, xtitle = 'Astrometric Scatter (arcsec)', ytitle = 'Number of objects', $
  charsize = 1, title = 'Objects in SA 107 with more than 50 detections'




stop
end        
