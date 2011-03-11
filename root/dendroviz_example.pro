;+
; PURPOSE:
;  This is an demo of the cloudviz library. It restores a IDL save
;  file containing an example dendram, PPP cube, and structure
;  catalog. It then creates a dendroviz session with that data
;
;  The dendrogram is generated from the simulation data in Offner,
;  Klein and McKee (2008)
;   http://adsabs.harvard.edu/abs/2008ApJ...686.1174O
;
;-
pro dendroviz_example

  ;- find the example file
  file = file_which('dendroviz_example.sav')
  if ~file_test(file) then $
     message, 'Cannot find example .sav file dendroviz_example.sav'
  
  ;- restore it
  restore, file                 ;- restores ptr, ppp, and data
  
                                ;- start dendroviz
  dendroviz, ptr, $             ;- ptr describes the cloud hierarchy -- it is the main data structure
             ppp = ppp, $       ;- (optional) describes the PPP velocity field of this simulation -- used for deprojection
             data = data        ;- (optional) catalog of properties for each dendrogram structure. Used for scatterplots


end

