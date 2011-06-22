;+
; PURPOSE:
;  Generate "clouds" of fractal turbulence
;
; INPUTS:
;  dim: An array specifying the pixel size of each dimension of the
;       output image.
;
; KEYWORD PARAMETERS:
;  beta: The power spectrum exponent of the turbulence in fourier
;        space. Defaults to 1.5
;  seed: Optional seed to feed to the random number generator
;
function cloud, dim, beta = beta, seed = seed


  if n_params() ne 1 then begin
     print, 'calling sequence:'
     print, ' result = cloud(dim, [beta = beta])'
     return, !values.f_nan
  endif

  if n_elements(dim) gt 8 then $
     message, 'Dim must have between 1 and 8 elements'
  if n_elements(beta) eq 0 then beta = 1.5

  fft_kind, make_array(dim, /float), k1, k2, k3, k4, k5, k6, k7, k8
  ndim = n_elements(dim)
  r = k1^2
  if ndim gt 1 then r += k2^2
  if ndim gt 2 then r += k3^2
  if ndim gt 3 then r += k4^2
  if ndim gt 4 then r += k5^2
  if ndim gt 5 then r += k6^2
  if ndim gt 6 then r += k7^2
  if ndim gt 7 then r += k8^2
  r = sqrt(r)

  phases = randomu(seed, n_elements(r)) * 2 * !pi
  phases = reshape(phases, r, /over)

  ;- make phases hermitian to get a real image
  ;- XXX how to do this for ndim images?
  ;negx = phases * 0
  ;negy = phases * 0
  ;for i = 1, ndim - 1, 1 do begin
  ;   negx[i, *] = ndim - i
  ;   negy[*, i] = ndim - i
  ;endfor
  ;phases = phases - phases[negx, negy]


  power = r^(-1 * beta)
  bad = where(r eq 0)
  power[bad] = 0

  ft = complex(power * cos(phases), power * sin(phases))
  inv = fft(ft, 1)  
  result = real_part(inv)
  result -= median(result)
  result /= medabsdev(result, /sigma)
  return, result
end
 
