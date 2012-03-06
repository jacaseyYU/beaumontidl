function pad, array
  sz = size(array)

  if sz[0] eq 1 then begin
     result = replicate(0, sz[1] + 2)
     result[1:sz[1]] = array
  endif else if sz[0] eq 2 then begin
     result = replicate(0, sz[1] + 2, sz[2] + 2)
     result[1:sz[1], 1 : sz[2]] = array
  endif else if sz[0] eq 3 then begin
     result = replicate(0, sz[1] + 2, sz[2] + 2, sz[3] + 2)
     result[1:sz[1], 1:sz[2], 1:sz[3] ] = array
  endif else message, 'array shape not supported'

  return, result

end

  
