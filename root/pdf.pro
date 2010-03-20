function pdf, data, x, h = h, $
              method = method, $
              outh = outh
  compile_opt idl2
  on_error, 2
  
  ;- check inputs
  if n_params() ne 2 then begin
     print, 'pdf calling sequence:'
     print, 'result = pdf(data, x, [h = h, method = method, outh = outh)'
     print, 'methods: SNR (sample normal reference)'
     print,"          SROT (Silverman's rule of thumb)"
     print,"          OS (Oversmoothing)"
     print,"          CV (Cross Validation"
     return, !values.f_nan
  endif

  ndata = n_elements(data)
  if ndata lt 5 then $
     message, 'must provide at least 5 finite data points'

  fin   = where(finite(data), nfin)
  if nfin lt 5 then $
     message, 'must provide at least 5 finite data points'

  nx    = n_elements(x)
  if nx eq 0 then $
     message, 'must provide at least 1 value for x'

  if ~keyword_set(h) && ~keyword_set(method) then $
     message, 'Must provide either a smoothing bandwith (h)' + $
              'or a bandwidth selection method (method)'
  if keyword_set(h) && keyword_set(method) then $
     message, 'Cannot set both h and method'

  ;- calculate the bandwidth
  if keyword_set(method) then begin

     sigma = sqrt(variance(data,/nan))
     edf, data, ex, ey
     q1 = interpol(ex, ey, 0.25)
     q3 = interpol(ex, ey, 0.75)
     iqr = q3 - q1
     a = sigma < (iqr / 1.34)
     
     method = strupcase(method)
     case method of
        'SNR':  h = 1.06 * sigma * nfin^(-0.2)
        'SROT': h = 0.9 * a * nfin^(-0.2)
        'OS':   h = 1.144 * sigma * nfin^(-0.2)
        'CV': message, 'method CV not yet implemented'
        else: message, 'method not recognized'
     endcase
  endif

  result = x * 0

  ;- choose the smaller of the sets to loop over
  if nfin lt nx then begin
     for i = 0, nfin - 1, 1 do begin
        result += 1 / sqrt(2 * !pi) * exp(-(x - data[fin[i]])^2 / (2 * h^2))
     endfor
     result /= (nfin * h)
  endif else begin
     for i = 0, nx - 1, 1 do begin
        result[i] = 1 / (nfin * h * sqrt(2 * !pi)) * total(exp(-(x[i] - data[fin])^2 / (2 * h^2)))
     endfor
  endelse

  outh = h
  return, result
end
