pro fits_bounds, file, extension = extension, bounds = bounds
  if n_params() eq 0 then begin
     print, 'calling sequence'
     print, ' fits_bounds, file, [extension = extension, bounds = bounds]'
     return
  endif
  
  if size(file, /tname) ne 'STRING' then $
     message, 'file must be a string'
  
  if ~file_test(file) then $
     message, 'File not found: '+file

  if n_elements(extension) eq 0 then extension = 0
  m = mrdfits(file, extension, h)
  if n_elements(m) eq 0 then $
     message, 'Could not read fits file: '+file+' extension: '+strtrim(extension,2)

  sz = size(m) & nd = sz[0]
  if nd eq 2 then begin
     indices, m, x, y
     xyad, h, x, y, a, d
  endif else if nd eq 3 then begin
     x = rebin(findgen(sz[1]), sz[1], sz[2])
     y = rebin(1#findgen(sz[2]), sz[1], sz[2])
     z = x * 0
     xyzadv, h, x, y, z, a, d, v
  endif else message, $
     'image must be 2 or 3 dimensonal'
        
  sys = guess_system(h)
  if sys eq '' then begin
     message, /con, 'Could not guess coordinate system. Assuming Equatorial'
     sys = 'EQ'
  endif
  
  case sys of
     'EQ': euler, a, d, l, b, 1
     'GAL': begin 
        euler, a, d, l, b, 2
        swap, a, l
        swap, d, b
     end
     else: message, 'Unrecognized coord system: '+sys
  endcase
  
  bounds={r:minmax(a), d:minmax(d), $
          l:minmax(l), b:minmax(b)}
  print, 'Image Bounds:'
  fmt = '("J2000: ra:(", d10.5, 3x, d10.5,") dec:(", d10.5, 3x, d10.5, ")")'
  print, bounds.r, bounds.d, format=fmt
  fmt = '("GAL:    l:(", d10.5, 3x, d10.5,")   b:(", d10.5, 3x, d10.5, ")")'
  print, bounds.l, bounds.b, format = fmt
end
     
  
