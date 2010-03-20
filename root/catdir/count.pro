pro count, data, values, repeats, reverse_indices = reverse_indices
;+
; NAME:
;  count
;
; DESCRIPTION:
;  This function counts how many times each element appears in an
;  array.
; 
; CALLING SEQUENCE:
;  COUNT, data, values, repeats, [reverse_indices = reverse_indices]
;
; INPUT:
;  data: An array of data to count
;
; OUTPUT:
;  values:  A named variable which will hold a copy of each unique
;           element in data
;  repeats: A named variable which will hold how many times each
;           element in values appears in data.
;
; OPTIONAL OUTPUT KEYWORDS: 
;  reverse_indices: Similar to the reverse_indices keyword in
;                   histogram. It contains information about which 
;                   indices in the original data array correspond 
;                   to which unique value. For example, the indices
;                   of the original data array which contain the value
;                   in the ith index of values are:
;                     ri[ ri[i] :  ri[i + 1] - 1]
;                   where ri is the reverse_indices variable. Note
;                   that there will be repeats[i] such elements in
;                   that expression. 
;
; MODIFICATION HISTORY:
;  January 2009: Written by Chris Beaumont
;-
compile_opt idl2

arr = data
nelem = n_elements(arr)

;- determine if data are sorted
shift = shift(arr, 1)
off = arr - shift
off[0] = 0
if min(off) lt 0 then begin
   sort = sort(arr)
   arr = arr[sort]
endif else sort = indgen(n_elements(data))

;- find the unique indices

;- each +/- 1 is an index of a new element in arr
change = arr - shift(arr, 1) 
hit = where(change ne 0, ct)

;- special case - every element in arr is the same value
if ct eq 0 then begin
   values = arr[0]
   repeats = [n_elements(arr)]
   reverse_indices = [2, n_elements(arr) + 2, sort]
   return
endif


values = arr[hit]
nuniq = ct

repeats = shift(hit, -1) - hit
repeats[nuniq - 1] = nelem - hit[nuniq - 1] 


;- calculate reverse indices, if requested
if ~arg_present(reverse_indices) then return
reverse_indices = intarr(nelem + nuniq + 1)
reverse_indices[0 : nuniq - 1]  = hit + nuniq + 1
reverse_indices[nuniq] = nelem + nuniq + 1
reverse_indices[nuniq + 1: nuniq + nelem] = sort

return

end
