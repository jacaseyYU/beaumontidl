pro svm_rescale, file

  ;- rescale each attribute in the first feature vector to [0, 1]. 
  ;- repeat this scaling to subsequent feature vectors.
  nfile = n_elements(file)
  for i = 0, nfile - 1, 1 do begin
     restore, file[i]
     if i eq  0 then begin
        lo = min(feature.feature, dim=2, max = hi)
     endif
     sz = size(feature.feature)
     feature.feature = (feature.feature - rebin(lo, sz[1], sz[2])) / rebin(hi - lo, sz[1], sz[2])
     outfile=strtrun(file[i],'.sav')+'_r.dat'
     junk = feature2file(feature, outfile=outfile)
  endfor
end

  
