function unpad, array
  sz = size(array)

  if sz[0] eq 1 then begin
     return, array[1 : sz[1]-2]
  endif else if sz[0] eq 2 then begin
     return, array[1 : sz[1]-2, 1: sz[2]-2]
  endif else if sz[0] eq 3 then begin
     return, array[1 : sz[2]-2, 1 : sz[2]-2, 1 : sz[3]-2]
  endif else message, 'array shape not supported'

end

  
