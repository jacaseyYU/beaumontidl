pro uberplot_cleanup, id
  widget_control, id, get_uvalue = info, /no_copy
  wdelete, (*info).freewin
  ptr_free, (*info).subm, (*info).outliers, (*info).subchip
  ptr_free, (*info).outliers, info
end

pro uberplot_click_obj, event
   if event.release then return  
  widget_control, event.top, get_uvalue = infoptr

  uberplot_switch_plot, (*infoptr).obj_win
  uberplot_device2data, event.x, event.y, (*infoptr).obj_win, x, y
  ;- find matching data point
  subm = *(*infoptr).subm
  xs = subm.d_ra
  ys = subm.d_dec
  dist = (xs - x)^2 + (ys - y)^2
  low = min(dist, meas_id, /nan)
  uberplot_setmeasure, *infoptr, meas_id
  uberplot_replot, *infoptr
end

pro uberplot_switch_plot, newwin
wset, newwin.d.window
!x = newwin.x
!y = newwin.y
!z = newwin.z
end

pro uberplot_device2data, rx, ry, win, dx, dy
  vx = win.d.x_vsize
  vy = win.d.y_vsize
  ;- device coords to normal coords
  dx = 1.0 * rx / vx
  dy = 1.0 * ry / vy
  ;- normal coords to data coords
  dx = (dx - win.x.s[0]) / win.x.s[1]
  dy = (dy - win.y.s[0]) / win.y.s[1]
  return
end  

pro uberplot_data2device, dx, dy, win, rx, ry
  vx = win.d.x_vsize
  vy = win.d.y_vsize
  ;-data coords to normal coords
  rx = (dx * win.x.s[1]) + win.x.s[0]
  ry = (dy * win.y.s[1]) + win.y.s[0]
  ;- normal coords to device coords
  rx *= vx
  ry *= vy
  return
end

pro uberplot_click_chip, event
  if event.release then return
  widget_control, event.top, get_uvalue = infoptr
  uberplot_switch_plot, (*infoptr).chip_win
  uberplot_device2data, event.x, event.y, (*infoptr).chip_win, x, y

  ;- find matching data point
  subchip = *(*infoptr).subchip
  dist = (subchip.x_ccd - x)^2 + (subchip.y_ccd-y)^2
  dist += 999. * (~finite(subchip.mag))
  low = min(dist, match,/nan)

  ;- derive new object, meas ids
  obj_id = subchip[match].ave_ref
  lo = (*infoptr).t[obj_id].off_measure
  hi = lo + (*infoptr).t[obj_id].nmeasure-1
  subm = (*infoptr).m[lo:hi]
  meas_id = where(subm.image_id eq  subchip[match].image_id)

  uberplot_setobject, *infoptr, obj_id
  uberplot_setmeasure, *infoptr, meas_id
  uberplot_replot, *infoptr
end

pro uberplot_click_cat, event
  if event.release then return
  widget_control, event.top, get_uvalue = infoptr
  uberplot_switch_plot, (*infoptr).cat_win
  
  ;- find matching data point
  xs = (*infoptr).mag
  ys = (*infoptr).rms
  uberplot_data2device, xs, ys, (*infoptr).cat_win, dx, dy
  dist = sqrt((dx - event.x)^2 + (dy - event.y)^2)
  low = min(dist, match,/nan)
  
  ;- derive new object, meas ids
  obj_id = match
  uberplot_setobject, *infoptr, obj_id
  uberplot_replot, *infoptr
end

pro uberplot_event, event
  widget_control, event.top, get_uvalue = infoptr
  widget_control, event.id, get_uvalue = widget
  if widget eq 'meas_select' then begin
     widget_control, event.id, get_value = meas_id
     uberplot_setmeasure, *infoptr, meas_id
  endif else if widget eq 'obj_select' then begin
     widget_control, event.id, get_value = obj_id
     uberplot_setobject, *infoptr, long(obj_id)
  endif
  ;- plot cdf of scatter
  if widget eq 'outlier' then begin
     wset, (*infoptr).freewin
     subm = *(*infoptr).subm
     !p.multi = [0,2,5]
     colors = ['slateblue','forestgreen','crimson','orange','chocolate']
     xra = [-2, 2] * stdev(subm.d_ra)

     for i = 0, 4, 1 do begin
        hit = where(subm.photcode / 100 eq i, ct)
        if ct lt 10 then continue
        x = subm[hit].d_ra
        y = subm[hit].d_dec
        good = outliercdf(x,y, /verbose)
        good = where(good, ct)
        if ct le 10 then good=indgen(n_elements(x))
        hx = histogram(x, loc = xloc, binsize = range(x) / n_elements(x) / 10)
        hgood = histogram(x[good], loc = xgloc, binsize = range(x) / n_elements(x) / 10)
        cdf_good = 1D*total(hgood, /cumul) / total(hgood)
        
        xmed = interpol(xgloc, cdf_good, .5)
        xsigma = interpol(xgloc, cdf_good, gauss_pdf(1))
        xsigma = (xsigma - xmed)
        plot, xloc, 1D * total(hx, /cumul) / total(hx), color = fsc_color(colors[i]), $
              xra = xra, yra = [0,1]
        oplot, xloc, gauss_pdf((xloc -xmed) / xsigma), color = fsc_color(colors[i]), $
               linestyle = 3
     endfor

     xra = [-2,2] * stdev(subm.d_dec)
     for i = 0, 4, 1 do begin
        hit = where(subm.photcode / 100 eq i, ct)
        if ct lt 10 then continue
        x = subm[hit].d_ra
        y = subm[hit].d_dec
        good = outliercdf(x,y)
        good = where(good, ct)
        if ct le 10 then good = indgen(n_elements(x))
        hy = histogram(y, loc = yloc, binsize = range(y) / n_elements(y) / 10)
        hgood = histogram(y[good], loc = ygloc, binsize = range(x) / n_elements(x) / 10)
        cdf_good = 1D*total(hgood, /cumul) / total(hgood)
        
        ymed = interpol(ygloc, cdf_good, .5)
        ysigma = interpol(ygloc, cdf_good, gauss_pdf(1))
        ysigma = (ysigma - ymed)
        
        plot, yloc, 1D * total(hy, /cumul) / total(hy), color = fsc_color(colors[i]), $
              xra = xra, yra = [0,1]
        oplot, yloc, gauss_pdf((yloc - ymed) / ysigma), color = fsc_color(colors[i]), $
               linestyle = 3
     endfor
     !p.multi=0
     return
  endif
  uberplot_replot, *infoptr
end

pro uberplot_setmeasure, info, meas_id
  meas_id = meas_id[0]
  ;- update information
  info.meas_id = meas_id
  ;- find other measurements on the same exposure
  hit = where(info.m.image_id eq (*info.subm)[meas_id].image_id)
  sub = info.m[hit]
  x = (*info.subm)[meas_id].x_ccd
  y = (*info.subm)[meas_id].y_ccd
  hit = where(abs(sub.x_ccd - x) lt 500 and abs(sub.y_ccd - y) lt 500)
  *info.subchip = sub[hit]
  ;- update widgets
  widget_control, info.meas_select, set_value = meas_id
  uberplot_listmeasure, info
end

pro uberplot_setobject, info, obj_id
  obj_id = obj_id[0]
  off_measure = info.t[obj_id].off_measure
  nmeasure = info.t[obj_id].nmeasure
  
  *info.subm = info.m[off_measure : off_measure + nmeasure - 1]
  *info.outliers = outliercdf((*info.subm).d_ra, (*info.subm).d_dec)
  ;- update information
  info.obj_id = obj_id
  info.off_measure = off_measure
    
  ;- update widgets
  widget_control, info.meas_select, set_value = 0
  widget_control, info.meas_select, set_slider_max = nmeasure-1
  widget_control, info.obj_select, set_value = strtrim(obj_id,2)

  uberplot_setmeasure, info, 0
  uberplot_listmeasure, info
end

pro uberplot_listmeasure, info
  obj_id = info.obj_id
  off_measure = info.off_measure
  meas_id = info.meas_id
  nmeasure = info.t[obj_id].nmeasure
  assert, info.t[obj_id].off_measure eq off_measure
  lo = off_measure
  hi = off_measure + nmeasure - 1
  subm = info.m[lo:hi]
  assert, range(subm.ave_ref) eq 0
  point = subm[meas_id]
  print, point.d_ra, point.d_dec, point.x_ccd, point.y_ccd, $
         format='("Measurement dra: ", f6.2, " ddec :", f6.2, " (x,y) : (", i4, ", ", i4,")")'
  print, point.mag, format='("mag: ", f5.1)'
  print, info.rms[obj_id], format='("rms: ", f6.2)'
end

pro uberplot_replot, info
colors = ['slateblue','forestgreen','crimson','orange','chocolate']
     
;- details about the selected point
subm = *info.subm
subchip = *info.subchip
point = subm[info.meas_id]
lo = info.off_measure
;- plot rms vs mag for catalog
uberplot_switch_plot, info.cat_win
plot, info.mag, info.rms, psym = 3, yra = [0,.3], xra = [12, 22]
oplot, [info.mag[info.obj_id]], [(info.rms)[info.obj_id]], color = fsc_color('purple'), $
       psym = symcat(16), symsize = 1.5
info.cat_win = {d : !d, x : !x, y : !y, z : !z}

;- plot scatter of current object
uberplot_switch_plot, info.obj_win
good = *info.outliers
plot, [subm.d_ra], [subm.d_dec], /nodata
hit = where(good, ct)
if ct ne 0 then begin
   xra = minmax(subm[hit].d_ra) + .5 * range(subm[hit].d_ra)+[-1,1]
   yra = minmax(subm[hit].d_dec) + .5 * range(subm[hit].d_dec)+[-1,1]
endif else begin
   xra = minmax(subm.d_ra)
   yra = minmax(subm.d_dec)
endelse
plot, [subm.d_ra], [subm.d_dec], xra = xra, yra = yra, /nodata, $
      /xsty, /ysty
for i = 1, 5, 1 do begin 
   hit = where(good and ((subm.photcode / 100) eq i), nhit)
   miss = where(~good and ((subm.photcode /100) eq i), nmiss)
   if nhit ne 0 then $
      oplot, [subm[hit].d_ra], [subm[hit].d_dec], psym = symcat(16), $
             color = fsc_color(colors[i-1])
   if nmiss ne 0 then $
      oplot, [subm[miss].d_ra], [subm[miss].d_dec], psym = symcat(9), $
             color = fsc_color(colors[i-1])
endfor
oplot, [point.d_ra], [point.d_dec], psym = symcat(16), color = fsc_color('purple'), symsize=2

info.obj_win = {d : !d, x: !x, y : !y, z : !z}


;- plot sources around the object of interest, for the exposure of interest
uberplot_switch_plot, info.chip_win
xra = point.x_ccd+[-200,200]
yra = point.y_ccd+[-200,200]
plotstar, subchip.x_ccd, subchip.y_ccd, subchip.mag, $
            xra = xra, yra = yra, magrange = [12,21]
oplot, [point.x_ccd], [point.y_ccd], psym = symcat(9), color = fsc_color('purple'), symsize=2
info.chip_win = {d : !d, x : !x, y : !y, z : !z}

end
   
pro uberplot, t, m
restore, '~/pro/uberplot/explore.sav'

catch, theError
if (theError) ne 0 then begin
   catch,/cancel
   print, !error_state.msg
;uberplot_cleanup
   print,n_elements(tlb)
   if n_elements(tlb) ne 0 then widget_control, tlb, /destroy
   return
endif

device, get_screen_size = size
size = min(size) / 1.2
window, /free
freewin = !window

;- toolbar widgets
tlb = widget_base(column = 1, title = 'UberPlot', tlb_frame_att = 1, $
                  xoffset = 0, yoffset = 0)

obj_base = widget_base(tlb, row = 1)
obj_title = widget_label(obj_base, value='Object ID: ')
obj_select = widget_text(obj_base, value='0', /edit, uvalue = 'obj_select')

meas_base = widget_base(tlb, row = 1)
meas_title = widget_label(meas_base, value = 'Image ID:')
meas_select = widget_slider(meas_base, max = t[0].nmeasure - 1, uvalue = 'meas_select') 

plot_outlier = widget_button(tlb, value = 'Outliers', uvalue = 'outlier')

;- plot widgets
obj_plot_base = widget_base(group_leader = tlb, xoffset = size, yoffset = 0, title='Single Object Astrometry')
obj_plot_win = widget_draw(obj_plot_base, xsize = size, ysize = size, /button_events, uvalue = 'obj_win')

chip_plot_base = widget_base(group_leader = tlb, xoffset = size, yoffset = size, title='Chip Detections')
chip_plot_win = widget_draw(chip_plot_base, xsize = size, ysize = size, /button_events, uvalue='chip_win')

cat_plot_base = widget_base(group_leader = tlb,  xoffset = 0, yoffset = size, $
                       title = 'Catalog Astrometry')
cat_plot_win = widget_draw(cat_plot_base, xsize = size, ysize = size, /button_events, uvalue='cat_win')

widget_control, tlb, /realize
widget_control, obj_plot_base, /realize
widget_control, chip_plot_base, /realize
widget_control, cat_plot_base, /realize

widget_control, obj_plot_win, get_value = obj_win_id
widget_control, chip_plot_win, get_value = chip_win_id
widget_control, cat_plot_win, get_value = cat_win_id

wset, obj_win_id
obj_win = {d : !d, x : !x, y : !y, z : !z}
wset, chip_win_id
chip_win = {d : !d, x : !x, y : !y, z : !z}
wset, cat_win_id
cat_win = {d : !d, x : !x, y : !y, z : !z}
catch,/cancel
data = { $
       t : temporary(t), $
       m : temporary(m), $
       rms : info.myrms, $
       mag : info.imag, $
       obj_id : 0L, $           ;- t row of object
       meas_id : 0L, $          ;- m row of current measurement, starting from off_measure
       off_measure : 0L, $      ;- m row of first measurement of object
       obj_win : obj_win, $
       cat_win : cat_win, $
       chip_win : chip_win, $
       obj_select :  obj_select, $
       meas_select : meas_select, $
       outliers : ptr_new(3),  $
       subm : ptr_new(3), $
       subchip : ptr_new(3), $
       freewin : freewin $
       }

uberplot_setobject, data, 0
uberplot_setmeasure, data, 0
uberplot_replot, data
infoptr = ptr_new(data, /no_copy)
widget_control, tlb, set_uvalue = infoptr
widget_control, obj_plot_base, set_uvalue = infoptr
widget_control, cat_plot_base, set_uvalue = infoptr
widget_control, chip_plot_base, set_uvalue = infoptr
xmanager, 'uberplot', tlb, /no_block, cleanup = 'uberplot_cleanup'
xmanager, 'uberplot', obj_plot_base, /no_block, event_handler = 'uberplot_click_obj'
xmanager, 'uberplot', chip_plot_base, /no_block, event_handler = 'uberplot_click_chip'
xmanager, 'uberplot', cat_plot_base, /no_block, event_handler = 'uberplot_click_cat'


end       
