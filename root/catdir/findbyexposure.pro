;+ 
; Return the indices of objects in a measurement (.cpm) structure
; which correspond to combinations of exposure properties. 
;-
function findByExposure,  measure, image, expName = expName, $
                          expID = expID, camID = camID, ccd = ccd, $
                          VERBOSE = verbose, count = count
  compile_opt idl2
  on_error, 2

  if n_params() ne 2 then begin
     print, 'findByExposure calling sequence'
     print, 'id = findByExposure(measure, image, '
     print, '          [expName = expName, expID = expID,'
     print, '           camID = camID, ccd = ccd, /verbose]'
     return, -1
  endif
  
  nEn = n_elements(expName)
  nEi = n_elements(expID)
  nCi = n_elements(camID)
  ncc = n_elements(ccd)
  if ((nEn gt 0) + (nEi gt 0) + (nCi gt 0) + (ncc gt 0)) eq 0 then begin
     message, 'Must include a search parameter'
     return, -1
  endif

  regExp = ( nEn gt 0 ? expName : '[0-9]{6}') + "o\." + $
           ( nEi gt 0 ? expID   : '[0-9]{4}') + "\.cm\." + $
           ( nCi gt 0 ? camID   : '[0-9]{3}') + '\.smf\[' + $
           ( ncc gt 0 ? ccd     : '[0-9a-zA-Z]*') + '\]'

  match = stregex(image.name, regExp, /boolean)
  hit = where(match, ct)

  if ct eq 0 then begin
     message, 'No image names matching the regular expression ' + $
              regExp, /continue
     count = 0
     return, -1
  endif 
  nimage = ct

  stack = obj_new('stack')
  for i = 0, ct - 1, 1 do begin
     good = where(measure.image_id eq hit[i] + 1, gct)
     if gct eq 0 then continue
     tmp = stack -> push(good)
  endfor

  if stack->getSize() eq 0 then begin
     message, 'No measurements reference exposures matched by the regExp '+regExp, $
              /continue
     count = 0
     result = -1
  endif else begin
     result =  stack->toArray()
     count = stack->getSize()
  endelse

  obj_destroy, stack
  if keyword_set(verbose) then begin
     print, count, nimage, $
            format = '("Fetched ", i, " measurements from ", i, " images")'
  endif
  return, result
end

