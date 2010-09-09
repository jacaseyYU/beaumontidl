pro generate_features, norm = norm
  regions = ['x232', 'y142', 'x172', 'y190']
  func = ['default_feature', 'moment_feature', 'edge_feature', 'edge2_feature', 'pca_feature']
;  func = ['pca_feature']
  dodata = 1
  doplane = 0
  do3 = 0
  for i = 0, 3, 1 do begin ;- regions
     for j = 1, 1, 1 do begin ;- functions
        print, i, j, systime()
        
        if dodata && i eq 0 then begin
           data = mask2feature('cube_mask.sav', $
                               featurefunction = func[j], $
                               bin = [2, 2, 3], norm = norm)
           feature = data
           outfile = 'data_'+strtrun(func[j],'_feature')
           out = feature2file(feature, outfile = outfile+'.dat')
           continue
        endif else if dodata then continue
        
        
        cloud = mask2feature('train_'+regions[i]+'_cloud.sav', $
                             featurefunction = func[j], $
                             bin = [2,2,3], norm = norm)
        snr = mask2feature('train_'+regions[i]+'_snr.sav', $
                           featurefunction=func[j], $
                           bin=[2,2,3], norm = norm)
        bg = mask2feature('train_'+regions[i]+'_bg.sav', $
                          featurefunction = func[j], label = -1, $
                          bin=[2,2,3], norm = norm)
        
        if do3 then begin
           bg.label = 1 & cloud.label = 2 & snr.label = 3
           feature = [bg, cloud, snr]
           outfile = 'feature_multi_'+regions[i]+'_'+strtrun(func[j],'_feature')
           print, outfile
           out = feature2file(feature, outfile=outfile+'.dat')
        endif
        
        ;- bg training set
        cloud.label = -1 & snr.label = -1 & bg.label = 1
        feature = [bg, cloud, snr]
        outfile = 'feature_bg_'+regions[i]+'_'+strtrun(func[j],'_feature')
        out = feature2file(feature, outfile=outfile+'.dat')
        
        if doplane ne 0 then begin
           plane = mask2feature('plane_'+regions[i]+'.sav', $
                             featurefunction = func[j], $
                             bin = [2, 2, 3], norm = norm)
           feature = plane
           outfile = 'plane_'+regions[i]+'_'+strtrun(func[j],'_feature')
           out = feature2file(feature, outfile=outfile+'.dat')
        endif
        

        ;- cloud training set
        cloud.label = 1 & snr.label = -1 & bg.label = -1
        feature = [cloud, snr, bg]
        outfile = 'feature_cloud_'+regions[i]+'_'+strtrun(func[j],'_feature')
        out = feature2file(feature, outfile=outfile+'.dat')
        
        ;- snr training set
        cloud.label = -1 & snr.label = 1 & bg.label = -1
        feature = [cloud, snr, bg]
        outfile = 'feature_snr_'+regions[i]+'_'+strtrun(func[j],'_feature')
        out = feature2file(feature, outfile=outfile+'.dat')
        
        ;- bg training set
        cloud.label = -1 & snr.label = -1 & bg.label = 1
        feature = [bg, cloud, snr]
        outfile = 'feature_bg_'+regions[i]+'_'+strtrun(func[j],'_feature')
        out = feature2file(feature, outfile=outfile+'.dat')
     endfor
  endfor
  ;- rescale and combine the data
;  unscale
;  rescale
;  combine
end


pro rescale
  func = ['default', 'moment', 'edge', 'edge2', 'pca']
  object=['multi','snr','cloud','bg']
  region = ['x232', 'y142', 'x172', 'y190']
;  for i = 0, n_elements(func)-1, 1 do begin ;- functions
  for i = 1, 1, 1 do begin
     ;- refresh lo, hi variables for each function
     lo = 0 & hi = 0
     junk = temporary(lo)
     junk = temporary(hi)
     assert, n_elements(lo) eq 0 && n_elements(hi) eq 0
     file = 'data_'+func[i]+'.sav'
     if file_test(file) then $
        svm_rescale, 'data_'+func[i]+'.sav', lo = lo, hi = hi

     for k = 0, n_elements(region)-1, 1 do begin ;- regions
        file='plane_'+region[k]+'_'+func[i]+'.sav'
        svm_rescale, file, lo = lo, hi = hi
        
        for j = 0, n_elements(object)-1, 1 do begin ;- object
           file='feature_'+object[j]+'_'+region[k]+'_'+func[i]+'.sav'
           svm_rescale, file, lo = lo, hi = hi
        endfor
     endfor
  endfor
end

pro combine
  func = ['default', 'moment', 'edge', 'edge2', 'pca']
  region=['snr','cloud','multi','bg']

  for i = 0, n_elements(func) - 1, 1 do begin
     for j = 0, n_elements(region)-1, 1 do begin
        tr1 = 'feature_'+region[j]+'_x232_'+func[i]
        tr2 = 'feature_'+region[j]+'_y142_'+func[i]
        te1 = 'feature_'+region[j]+'_x172_'+func[i]
        te2 = 'feature_'+region[j]+'_y190_'+func[i]
        spawn, 'cat '+tr1+'.dat '+tr2+'.dat > feature_'+region[j]+'_train_'+func[i]+'.dat'
        spawn, 'cat '+te1+'.dat '+te2+'.dat > feature_'+region[j]+'_test_'+func[i]+'.dat'
        spawn, 'cat '+tr1+'.dat '+tr2+'.dat '+te1+'.dat '+te2+'.dat > feature_'+region[j]+'_all_'+func[i]+'.dat'
        restore, tr1+'.sav' & f = feature
        restore, tr2+'.sav' & feature = [feature, f]
        save, feature,file='feature_'+region[j]+'_train_'+func[i]+'.sav'
        restore, te1+'.sav' & f = feature
        restore, te2+'.sav' & feature = [feature, f]
        print, 'feature_'+region[j]+'_test_'+func[i]+'.sav'
        save, feature,file='feature_'+region[j]+'_test_'+func[i]+'.sav'
     endfor
  endfor
end

pro unscale
  files = file_search('*_o.dat', count = ct)
  for i = 0, ct - 1, 1 do begin
     spawn, 'mv '+files[i]+' '+strtrun(files[i],'_o.dat')+'.dat'
     f = strtrun(files[i], '_o.dat')
     spawn, 'mv '+f+'_o.sav '+f+'.sav'
  endfor
end
