;+
; PURPOSE:
;  This is an demo of the cloudviz library. It restores a IDL save
;  file containing an example dendram, PPP cube, and structure
;  catalog. It then creates a dendroviz session with that data
;-
pro dendroviz_example

  ;- find the example file
  file = file_which('dendroviz_example.sav')
  if ~file_test(file) then $
     message, 'Cannot find example .sav file dendroviz_example.sav'

  ;- restore it
  restore, file ;- restores ptr, ppp, and data

  ;- start dendroviz
  dendroviz, ptr, $             ;- ptr describes the cloud hierarchy -- it is the main data structure
             ppp = ppp, $       ;- describes the PPP velocity field of this simulation -- used for deprojection
             data = data        ;- catalog of properties for each dendrogram structure. Used for scatterplots


end

