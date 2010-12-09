pro flipy, im, true = true

  sz = size(im)
  nd = sz[0]

  if nd ne 2 && nd ne 3 then $
     message, 'Image must be 2- or 3-D'
  if n_elements(true) ne 0 && nd ne 3 then $
     message, 'Image must be 3D if TRUE is set'
  if n_elements(true) ne 0 && (true le 0 || true gt 3) then $
     message, 'True must be 1-3'
  if n_elements(true) ne 0 && nd eq 3 && sz[true] ne 3 $
     then message, 'Image must have 3 slices along TRUE dimension'

  if nd eq 3 && n_elements(true) eq 0 then true = 1

  if sz[0] eq 2 then im = rotate(im, 7) $
  else if true eq 1 then begin
     r = rotate( reform(im[0,*,*]), 7)
     g = rotate( reform(im[1,*,*]), 7)
     b = rotate( reform(im[2,*,*]), 7)
     im[0,*,*] = r
     im[1,*,*] = g
     im[2,*,*] = b
  endif else if true eq 2 then begin
     r = rotate( reform(im[*,0,*]), 7)
     g = rotate( reform(im[*,1,*]), 7)
     b = rotate( reform(im[*,2,*]), 7)
     im[*,0,*] = r
     im[*,1,*] = g
     im[*,2,*] = b
  endif else begin
     r = rotate( reform(im[*,*,0]), 7)
     g = rotate( reform(im[*,*,1]), 7)
     b = rotate( reform(im[*,*,2]), 7)
     im[*,*,0] = r
     im[*,*,1] = g
     im[*,*,2] = b
  endelse
end
