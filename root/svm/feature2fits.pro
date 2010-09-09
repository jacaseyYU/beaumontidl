
pro feature2fits, feature, outfile, sav = sav, bin = bin
  common svmdata, data, h
  if n_elements(data) eq 0 then read_data
  result = fix(data)
  result[*] = 0

  if keyword_set(bin) then begin
     sz = size(result)
     nx = sz[1] / bin[0]
     ny = sz[2] / bin[1]
     nz = sz[3] / bin[2]
     binned = intarr(nx, ny, nz)
     x = (round(feature.x / bin[0])) < (nx-1)
     y = (round(feature.y / bin[1])) < (ny-1)
     z = (round(feature.z / bin[2])) < (nz-1)
     binned[x,y,z] = feature.label
     big = rebin(binned, nx * bin[0], ny * bin[1], nz * bin[2])
     result[0 : nx * bin[0] - 1, $
            0 : ny * bin[1] - 1, $
            0 : nz * bin[2] - 1] = big
  endif else result[feature.x, feature.y, feature.z] = feature.label
  writefits, outfile, result
  if keyword_set(sav) then begin
     mask = result
     save, mask, file=sav
  endif
end

