;+
; PURPOSE:
;  This procedure bins a group of observations by date, calculating
;  the mean value and uncertainty of the data in each bin. 
;
; CALLING SEQUENCE:
;  bin_by_date, jd, x, xerr, binsize, jdbin, xbin, binerr, pop
;
; INPUT:
;       jd: A vector of dates
;        x: Some quantity measured at each of these dates
;     xerr: The error on these quantities
;  binsize: The size of the output bins
;
; OUTPUT:
;    jdbin: The midpoint jd in each bin
;     xbin: The mean values of the measurements falling in each bin
;   binerr: The error on each binned mean
;      pop: The number of data points in each output bin
;
; MODIFICATION HISTORY:
;  March 2009 written by Chris Beaumont
;  May  2009: Added xerr input. cnb.
;-
pro bin_by_date, jd, x, xerr, binsize, jdbin, xbin, binerr, pop, noweight = noweight
compile_opt idl2
;on_error, 2

;-check inputs
if n_params() ne 8 then begin
   print, 'bin_by_date calling sequence'
   print,' bin_by_date, jd, x, xerr, binsize, jdbin, xbin, binerr, pop'
   return
endif

sz = n_elements(jd)
if n_elements(x) ne sz then message, 'jd and x must be the same size'
if n_elements(xerr) ne sz then message, 'xerr and x must be the same size'
if sz eq 0 then message, 'no data provided'

h = histogram(jd, reverse_indices = ri, loc = loc, binsize = binsize)
rms = (sz gt 1) ? stdev(x) : 0
;-output vectors
result_x = obj_new('stack')
result_y = obj_new('stack')
result_err = obj_new('stack')
result_pop = obj_new('stack')

catch, theError
if (theError ne 0) then begin
   catch, /cancel
   message, !error_state.msg, /continue
   goto, cleanup
endif

for i = 0L, n_elements(h)-1, 1 do begin
   if ri[i+1] eq ri[i] then continue
   data = x[ri[ri[i] : ri[i+1] - 1]]
   dates = jd[ri[ri[i] : ri[i+1] - 1]]
   assert, range(dates) lt binsize
   ndata = n_elements(data)
   ws = 1 / xerr[ri[ri[i] : ri[i+1]-1]]^2
   value = total(ws * data) / total(ws)
   
;- calculate chi-square for data
;   chi2 = total((data - value)^2  * ws)
;   prob = chisqr_pdf(chi2, ndata - 1)
   unc = sqrt( 1 / total(ws))
   
   if keyword_set(noweight) then begin
      unc = (ndata eq 1) ? rms : stdev(data) / sqrt(ndata)
   endif
   
   result_x -> push, (median(dates))
   result_y -> push, (value)
   result_err -> push, (unc)
   result_pop -> push, ndata
endfor

jdbin = result_x -> toArray()
xbin = result_y -> toArray()
binerr = result_err -> toArray()
pop = result_pop -> toArray()

cleanup:
obj_destroy, result_x
obj_destroy, result_y
obj_destroy, result_err
obj_destroy, result_pop

return

end
