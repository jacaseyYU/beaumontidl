pro wedit, index, xsize = xsize, ysize = ysize, show = show
  
    catch, theError
    if theError ne 0 then begin
       catch, /cancel
       goto, newwindow
    endif
    wset, index
    catch,/cancel
    if keyword_set(show) then wshow, index
    if (keyword_set(xsize) && !d.x_size ne xsize) || $
       (keyword_set(ysize) && !d.y_size ne ysize) then goto, newwindow
    return

    newwindow:
    if keyword_set(xsize) then begin
       if keyword_set(ysize) then $
          window, index, xsize = xsize, ysize = ysize $
       else window, index, xsize = xsize
    endif else begin
       if keyword_set(ysize) then $
          window, index, ysize = ysize $
       else window, index
    endelse
    return
end
