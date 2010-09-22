;+
; PURPOSE:
;  pzplot (pan-zoom-plot) is a simple widget for displaying plot
;  objects. The user can resize, zoom, and pan around the plot window.
;-

function pz_render, win, info
  compile_opt idl2, hidden
  t = systime(/seconds)
  max_rate = 15.

  if 1. / (t - info.last_render) gt max_rate then return, 0
  win->draw, info.view
  info.last_render = t
  return, 1
end


pro pz_realize, id
  compile_opt idl2, hidden

  child = widget_info(id, /child)
  widget_control, child, get_uvalue = info

  g = widget_info(id, /geometry)
  widget_control, info.draw, draw_xsize = g.scr_xsize, draw_ysize = g.scr_ysize
  info.parent_sz = [g.scr_xsize, g.scr_ysize]

  widget_control, child, set_uvalue = info
  widget_control, info.draw, get_value = win
  win->draw, info.view
end

;+
; PURPOSE:
;  Updates the view's viewplane_rect keyword
;
; INPUTS:
;  info: The info struct for pzplot
;-
pro pz_update_viewplane, info
  compile_opt idl2, hidden

  rect = [info.view_cen[0] - info.view_wid[0]/2., $
          info.view_cen[1] - info.view_wid[1]/2., $
          info.view_wid[0], info.view_wid[1]]
  info.view->setProperty, viewplane = rect
end

;+
; PURPOSE:
;  Event handler for pzplot
;
; INPUTS:
;  event: The event
;
; OUTPUTS:
;  A new event listing the xy coordinates (in data-space) of
;  the user's mouse, if the initial event was a non-drag,
;  mouse-motion event
;-
function pzplot_event, event
  compile_opt idl2, hidden
 
  child = widget_info(event.handler, /child)
  widget_control, child, get_uvalue = info
  widget_control, info.draw, get_value = win

  result = -1

  ;- window is resized
  g = widget_info(info.parent, /geometry)
  if g.scr_xsize ne info.parent_sz[0] || $
     g.scr_ysize ne info.parent_sz[1] then begin
     widget_control, info.draw, draw_xsize = g.scr_xsize, draw_ysize = g.scr_ysize
     info.parent_sz = [g.scr_xsize, g.scr_ysize]
  endif

  if event.id eq info.draw then begin
  ;- mouse event in draw window
                                
     junk = win->pickdata(info.view, info.model, [event.x, event.y], $
                          xyz)
     case event.type of
        0: begin                ;- button press
           info.drag = 1B
           info.anchor = xyz[0:1]
        end
        1: info.drag = 0B       ;- button release
        2: begin                ;- mouse motion
           if ~info.drag then begin
              ;- generate a new event
              result = {pzplot_event, ID: event.handler, TOP: event.top, HANDLER:0L, $
                        x:xyz[0], y:xyz[1]}
              info.model->add, obj_new('idlgrplot', [xyz[0]]+[0,.1], [xyz[1]]+[0,.1])
              break
           endif
           delta = xyz[0:1] - info.anchor
           info.view_cen = info.view_cen - delta
           pz_update_viewplane, info
        end
        7: begin                ;- wheel motion
           
           ;- wheel scroll = zoom in/out
           ;- pan so that cursor maps to the same data coordinate

           zoomIn = event.clicks gt 0
           info.view_wid = info.view_wid * (zoomIn ? .98 : 1.02)
           pz_update_viewplane, info
           junk = win->pickdata(info.view, info.model, [event.x, event.y], $
                                xyz2)
           delta = xyz2 - xyz
           info.view_cen -= delta
           pz_update_viewplane, info
        end
        else:
     endcase
  endif

  junk = pz_render(win, info)

  widget_control, child, set_uvalue = info
  return, result
end


pro pz_kill, wid
  compile_opt idl2, hidden

  widget_control, wid, get_uvalue = info
  widget_control, info.draw, get_value = win

  obj_destroy, info.view

;  print, 'Win object valid?', obj_valid(win)
;  print, 'View', obj_valid(info.view)
;  print, 'Model', obj_valid(info.model)
end

function pzplot, base, model, xrange = xrange, yrange = yrange, help = help, $
                 view = view

  compile_opt idl2

  if n_params() eq 0 || keyword_set(help) then begin
     print, 'calling sequence'
     print, 'id = pzplot(base, [model, xrange = xrange, yrange = yrange])'
     return, -1
  endif

  ;- set up a simple model object, if not provided
  if n_elements(model) eq 0 then begin
     x = arrgen(1., 10., .1)
     y = sin(x)
     
     plot = obj_new('idlgrplot', x, y)
     model = obj_new('idlgrmodel')
     xrange = [0,11]
     yrange = [-1,1]
     model->add, plot
  endif

  ;- set up view
  rect = [-1., -1, 2, 2]
  if keyword_set(xrange) then rect[[0,2]] = [xrange[0], xrange[1]-xrange[0]]
  if keyword_set(yrange) then rect[[1,3]] = [yrange[0], yrange[1]-yrange[0]]
  cen = [ (rect[0] + rect[2])/2., (rect[1] + rect[3])/2.]
  wid = [ rect[2] - rect[0], rect[3] - rect[1] ]
  view = obj_new('idlgrview', viewplane_rect=rect)
  view->add, model

  ;- set up widgets
  tlb = widget_base(base, event_func='pzplot_event', notify_realize='pz_realize')

  draw = widget_draw(tlb, xsize = 500, ysize = 500, graphics_level = 2, $
                     /button_events, /wheel_events, /motion_events)

  ;- state information
  info={tlb:tlb, $              ;- root widget of the pzplot compound iwdget
        draw:draw, $            ;- widget ID of the draw widget (value = idlgrwin)
        view:view, $            ;- IDLgrView object 
        model:model, $          ;- IDLgrModel object (supplied by user)
        parent:base, $          ;- base, supplied by user, that tlb is rooted in
        parent_sz:[0.,0.], $    ;- window size of parent
        view_cen:cen, $         ;- center of plot, in data coords
        view_wid:wid, $         ;- width of plot, in data coords
        drag:0B, $              ;- is user click-dragging?
        anchor:[0.,0.], $       ;- cursor position at start of click-drag
        last_render:systime(/seconds)} ;- time of last render
  
  ;- store state info
  child=widget_info(tlb, /child)
  widget_control, child, kill_notify='pz_kill'
  widget_control, child, set_uvalue = info

  return, tlb
end

pro test_event, event
  print, event.x, event.y
end

pro test
  help, /heap
  tlb = widget_base()
  x = pzplot(tlb, xrange=[0,11],yrange=[-1,1])
  
  widget_control, tlb, /realize
  xmanager, 'test', tlb
  help, /heap
end
