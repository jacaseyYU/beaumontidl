function rotation_dialog
  tlb = widget_base()
  desc = [ $
         '0, LABEL, Rotation around each axis', $
         '0, TEXT, , LABEL_LEFT=X:, WIDTH=5, TAG=x', $
         '0, TEXT, , LABEL_LEFT=Y:, WIDTH=5, TAG=y', $
         '0, TEXT, , LABEL_LEFT=Z:, WIDTH=5, TAG=z', $
         '0, BUTTON, OK, QUIT, TAG=ok', $
         '2, BUTTOn, Cancel, QUIT, TAG=cancel']

  b = cw_form(desc, /column)

  nan = !values.f_nan
  if b.cancel eq 1 then return, [nan, nan, nan]
  catch, the_error
  if the_error ne 0 then begin
     catch, /cancel
     print, "Error: non-numeric inputs"
     return, [nan, nan, nan]
  endif
  result = float([b.x, b.y, b.z])
  catch, /cancel
  return, result
  
end
  
