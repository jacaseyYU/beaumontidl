;+
; CLASS_NAME:
;  pzwin
;
; PURPOSE:
;  A _P_annable and _Z_oomable _WIN_dow, to interact with graphics.
;
; CATEGORY:
;  Data visualization
;
; SUPERCLASSES:
;  None
;
; SUBCLASSES:
;  None
;
; DESCRIPTION:
;  pzwin is created with a graphics model as input. It can either run
;  as a standalone gui (set the /STANDALONE keyword) or embedded into
;  a larger GUI. 
;
;  If pzwin runs as a standalone application, the gui is immediately
;  created and run in a new window.
;
;  If pzwin is to be embedded in another GUI, it should be placed into
;  its own widget_base, with nothing else inside. Failing to do so
;  leads to improper resizing.
;
;  A pzwin display will automatically resize itself to the size of the
;  widget base it is embedded into.
;
;  When running pzwin, left click-dragging drags the graphic. Mouse
;  scrolling zooms in our out. Right-click dragging adjusts the
;  greyscale when displaying a CNBgrImages.
;
;
; METHODS:
;  (p) denotes private method not intended for users
;
;  REQUEST_REDRAW:  Request a display update
;  EVENT:          (p) Event handling reoutine
;  RESIZE:         (p) Update the size of the draw window
;  REDRAW:         (p) Updates display, if necessary
;  ZOOM:           (p) Zoom in on the display
;  UPDATE_VIEWPLANE: (p) Change center of display
;  GET_MODEL:      Return graphics model
;  SET_MODEL:      Set the graphics model
;  GET_VIEW:       Get the graphics view
;  SET_VIEW:       Set the graphics view
;  ADD_GRAPHICS_ATOM: Add a graphics atom
;  REMOVE_GRAPHICS_ATOM: Remove a graphics atom
;  GET_DRAW:       Return the draw widget
;  CLEANUP:        (p) Destroy the object and free heap memory
;  INIT:           Create a new object
;
; MODIFICATION HISTORY:
;  September 2010: Written by Chris Beaumont
;-

;-----------------
; GUI Procedures (non-object)
pro pzwin_realize, id
  ;- start the render loop
  child = widget_info(id, /child)
  widget_control, child, get_uvalue = info
  widget_control, info->get_draw(), timer=.03
end

pro pzwin_kill, id
  widget_control, id, get_uvalue = info
  obj_destroy, info
end

function pzwin_event, event
  compile_opt idl2
  child = widget_info(event.handler, /child)
  widget_control, child, get_uvalue = info
  return, info->event(event)
end

pro pzwin_event, event
  junk = pzwin_event(event)
end
;--------------------

;--------------------
; GUI Procedures (object oriented)
pro pzwin::request_redraw, debug = debug
  self.redraw = 1
  if keyword_set(debug) then begin
     self.debug = 1
  endif
end

function pzwin::event, event
  if tag_names(event, /structure_name) eq 'WIDGET_TIMER' then begin
     self->redraw
     return, 1
  endif

  widget_control, self.draw, get_value = win
  result = -1

  ;- resize draw window
  g = widget_info(self.parent, /geom)
  if g.scr_xsize ne self.base_sz[0] || $
     g.scr_ysize ne self.base_sz[1] then begin
     self->resize, g.scr_xsize, g.scr_ysize
     self.redraw = 1
  endif

  outside = event.x lt 0 || event.y lt 0 || $
            event.x ge g.scr_xsize || $
            event.y ge g.scr_ysize
  
  junk = win->pickdata(self.view, self.model, [event.x, event.y], $
                       xyz)
  
  case event.type of
     0: begin                   ;- button press
        if event.press eq 1 then self.l_drag = 1
        if event.press eq 4 then self.r_drag = 1
        self.anchor = xyz[0:1]
     end
     1: begin
        self.l_drag = 0B          ;- button release
        self.r_drag = 0B
     end
     2: begin                   ;- mouse motion
        if ~self.l_drag && ~self.r_drag then break
        if outside then break
        if (self.modifiers ne 0) && $
           (event.modifiers and self.modifiers) eq 0 then break

        self.redraw = 1
        delta = xyz[0:1] - self.anchor
        ;- left mouse dragging pans
        if self.l_drag then begin
           self.view_cen = self.view_cen - delta
           self->update_viewplane
        ;- right mouse drag stretches an image
        endif else if self.r_drag && self.isImage then begin
           g = widget_info(self.draw, /geom)
           bias = 0 > (1. * event.x / g.scr_xsize) < 1
           contrast = 0 > (1. * event.y / g.scr_ysize) < 1
           self.image->set_stretch, bias = bias, contrast = contrast
        endif
     end
     5: ;-keyboard release
     6: ;-keyboard release
     7: begin                   ;- wheel motion
        self.redraw = 1
        zoomIn = event.clicks gt 0
        self->zoom, zoomIn, event.x, event.y, xyz
     end
     else:
  endcase

  result = {pzwin_event, ID: event.handler, TOP: event.top, HANDLER:0L, $
            x:xyz[0], y:xyz[1], $
            LEFT_CLICK: event.type eq 0 && event.press eq 1, $
            LEFT_DRAG: event.press eq 0 && self.l_drag, $
            LEFT_RELEASE: event.type eq 1 && event.release eq 1, $
            RIGHT_CLICK: event.type eq 0 && event.press eq 4, $
            RIGHT_DRAG: event.press eq 0 && self.r_drag, $
            RIGHT_RELEASE: event.type eq 1 && event.release eq 4, $
            press:event.press, type:event.type, release:event.release, $
            modifiers:event.modifiers, ch:event.ch, key:event.key}

  return, result
end

pro pzwin::set_event_filter, control = control, shift = shift
  if keyword_set(shift) then self.modifiers = 1
  if keyword_set(control) then self.modifiers = 2
end

pro pzwin::clear_event_filter
  self.modifiers=0
end

pro pzwin::resize, xsz, ysz
  widget_control, self.draw, draw_xsize = xsz, draw_ysize = ysz
  self.base_sz = [xsz, ysz]
end


pro pzwin::redraw
  compile_opt idl2
  t = systime(/seconds)
  max_rate = 20.
  ;- continue the draw loop
  widget_control, self.draw, timer=.02

  ;- avoid unnecessary redraws
  if ~self.redraw || 1. / (t - self.last_render) gt max_rate then return
  if self.debug then print, 'pzwin draw'
  widget_control, self.draw, get_value = win
  win->draw, self.view
  self.last_render = t
  self.redraw = 0
  return
end


pro pzwin::zoom, zoomIn, x, y, xyz
  widget_control, self.draw, get_value = win

  self.view_wid = self.view_wid * (zoomIn ? .98 : 1.02)
  self->update_viewplane
  junk = win->pickdata(self.view, self.model, [x, y], $
                            xyz2)
  delta = xyz2 - xyz
  self.view_cen -= delta
  self->update_viewplane
end


pro pzwin::update_viewplane
  compile_opt idl2, hidden

  rect = [self.view_cen[0] - self.view_wid[0]/2., $
          self.view_cen[1] - self.view_wid[1]/2., $
          self.view_wid[0], self.view_wid[1]]
  self.view->setProperty, viewplane = rect
end
;-----------------------


;-----------------------
; Non-GUI object methods

function pzwin::get_model
  return, self.model
end

pro pzwin::set_model, model
  self.view->remove, self.model
  obj_destroy, self.model
  self.model = model
  self.view->add, self.model
end

function pzwin::get_view
  return, self.view
end

pro pzwin::add_graphics_atom, atom, _extra = extra
  self.model->add, atom, _extra = extra
end

pro pzwin::remove_graphics_atom, atom
  self.model->remove, atom
end

function pzwin::get_draw
  return, self.draw
end

pro pzwin::cleanup
  obj_destroy, self.view
end

function pzwin::get_widget_id
  return, self.base
end

function pzwin::init, model, parent, standalone = standalone, $
                      xrange = xrange, yrange = yrange, image = image, $
                      keyboard_events = keyboard_events, $
                      _extra = extra
  
  ;- set up view
  rect = [-1., -1, 2, 2]
  if keyword_set(xrange) then rect[[0,2]] = [xrange[0], xrange[1]-xrange[0]]
  if keyword_set(yrange) then rect[[1,3]] = [yrange[0], yrange[1]-yrange[0]]
  cen = [ (rect[0] + rect[2])/2., (rect[1] + rect[3])/2.]
  wid = [ rect[2] - rect[0], rect[3] - rect[1] ]
  view = obj_new('idlgrview', viewplane_rect=rect)
  view->add, model

  ;- set up widgets
  if keyword_set(standalone) then begin 
     base = widget_base(event_func='pzwin_event', notify_realize='pzwin_realize')
  endif else begin
     base = widget_base(parent, event_func='pzwin_event', notify_realize='pzwin_realize')
  endelse

  ratio = 1. * wid[1] / wid[0]
  if ratio gt 1 then begin
     xsize = 500
     ysize = 500 * ratio
  endif else begin
     xsize = 500 / ratio
     ysize = 500
  endelse
  if ~keyword_set(image) then begin
     xsize = 500 & ysize = 500
  endif
  
  draw = widget_draw(base, xsize = xsize, ysize = ysize, graphics_level = 2, $
                     /button_events, /wheel_events, /motion_events, $
                     keyboard_events = keyword_set(keyboard_events) ? 2 : 0)
  self.model = model
  self.view = view
  self.draw = draw
  self.base = base
  self.parent = keyword_set(standalone) ? base : parent
  self.view_cen = cen
  self.view_wid = wid
  self.last_render=0.
  self.standalone = keyword_set(standalone)
  self.isImage = keyword_set(image)
  self.redraw = 1
  if self.isImage then self.image = image

  child = widget_info(base, /child)
  widget_control, child, set_uvalue = self, $
                  kill_notify='pzwin_kill'

  if keyword_set(standalone) then begin
     widget_control, base, /realize
     xmanager, 'pzwin', base, /no_block
  endif
  
  return, 1
end

pro pzwin__define

  data = {pzwin, $
          model:obj_new(''), $  ;- Model object. Provided on input
          view:obj_new(''), $   ;- view object. Created during init
          draw:0L, $            ;- draw widget id. value -> draw object
          base:0L, $            ;- root of the pzwin widget hierarchy
          parent:0L, $          ;- widget into which pzwin is embedded (or base)
          base_sz:[0., 0.], $   ;- size of base widget
          view_cen:[0.,0.], $   ;- center of viewport, in data coords
          view_wid:[0.,0.], $   ;- width of viewport, in data coords
          l_drag:0B, $          ;- left dragging?
          r_drag:0B, $          ;- right dragging
          anchor:[0., 0.], $    ;- cursor pos at start of drag
          last_render:0D, $     ;- time of last render
          standalone:0B, $      ;- widget a standalone object?
          isImage:0B, $         ;- does the model object hold a CNBgrImage object?
          image:obj_new(), $    ;- the CNBgrImage object, if isImage is true
          debug: 0B, $
          redraw:0B, $           ;- request for redraw command
          modifiers:0B $         ;- a keyboard modifier filter used to ignore events
         }
end
          
pro test

  x = arrgen(1., 10., .1)
  y = sin(x)
  
;  plot = obj_new('idlgrplot', x, y)
  plot = obj_new('cnbgrimage', bytscl(dist(255)))
  model = obj_new('idlgrmodel')
  xrange = [0,255]
  yrange = [0,255]
  model->add, plot
  
  x = obj_new('pzwin', model, image = plot, xrange=xrange, yrange = yrange, /standalone, /keyboard)  
end

pro test_embed_event, ev
  help, ev, /struct
end

pro test_embed
  tlb = widget_base(/column)
  pz_base = widget_base(tlb)

  x = arrgen(1., 10., .1)
  y = sin(x)
  
  plot = obj_new('idlgrplot', x, y)
  model = obj_new('idlgrmodel')
  xrange = [0,11]
  yrange = [-1,1]
  model->add, plot

  obj = obj_new('pzwin', model, pz_base, xrange=[0,11],yrange=[-1,1], /keyboard)
  button = widget_button(tlb, value='Hi There', xsize = 4)


  widget_control, tlb, /realize

  xmanager, 'test_embed', tlb
  help, /heap
end
