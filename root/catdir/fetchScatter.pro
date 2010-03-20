;+
; NAME:
;  fetchScatter
;
; DESCRIPTION:
;  this procedure reads catdir files in the current folder and returns
;  the rms astrometric scatter
;
; MODIFICATION HISTORY:
;  January 2009- Adopted from plotScatter by cnb
;-

function fetchScatter, path

;-find catdir files
cpm = file_search( path + '/*/*.cpm') ;- measurements
cpn = file_search( path + '/*/*.cpn') ;- missed (unpopulated)
cps = file_search( path + '/*/*.cps') ;- secfilt
cpt = file_search( path + '/*/*.cpt') ;- averages

for k = 0, n_elements(cpm) -1 , 1 do begin
;    print, k+1, n_elements(cpm), format="('Reading file ', i1, ' of ', i1)";
    me = mrdfits(cpm[k], 1, /silent)
    av = mrdfits(cpt[k], 1,/silent)
   
    good = where(av.nmeas ge 3, ct)
    newscatter = fltarr(2, ct)
    print, ct
    j = 0
    for i = 0L, n_elements(av) - 1, 1 do begin
        if av[i].nmeas lt 3 then continue
        indices = av[i].offset + indgen(av[i].nmeas)
        mag = mean(me[indices].mag, /nan)
        delt = sqrt(mean( me[indices].d_ra ^ 2 + me[indices].d_dec ^ 2, /nan))
        newscatter[*,j++] = [mag, delt]
    endfor

    if n_elements(scatter) eq 0 then begin
        scatter = newscatter
    endif else begin
        tmp = fltarr(2, n_elements(scatter[0,*]) + n_elements(newscatter[0, *]))
        tmp[*, 0: n_elements(scatter[0,*]) - 1] = scatter
        tmp[*, n_elements(scatter[0,*]) : n_elements(tmp[0,*]) - 1] = newscatter
        scatter = tmp
    endelse

endfor

return, scatter

end        
