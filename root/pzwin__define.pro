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
;  The pzwin object is resizeable, but does not automatically size
;  itself. Use the resize method to set the approximate total size of
;  the pzwin (plot + buttons).
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
;  October 2010: Added rotation functionality for 3d models. Change
;  how resize events work. cnb.
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

  ;- in standalone mode, handle resize events
  if tag_names(event, /struct) eq 'WIDGET_BASE' then begin
     self->resize, event.x, event.y
     return, 1
  endif

  widget_control, self.draw, get_value = win
  widget_control, event.id, get_uvalue = uval

  case uval of
     'FILE': begin
        print, 'doing nothing'
        return, 1
     end
     'ROTATE': begin
        self.doRotate = 1
        self.doTranslate = 0
        self.doRescale = 0
        widget_control, self.translateButton, set_value = self.bmp_translate_deselect
        widget_control, self.rotateButton, set_value = self.bmp_rotate_select
        widget_control, self.resizeButton, set_value = self.bmp_resize_deselect
        return, 1
     end
     'TRANSLATE':begin
        self.doRotate = 0
        self.doTranslate = 1
        self.doRescale = 0
        widget_control, self.translateButton, set_value = self.bmp_translate_select
        widget_control, self.rotateButton, set_value = self.bmp_rotate_deselect
        widget_control, self.resizeButton, set_value = self.bmp_resize_deselect
        return, 1
     end
     'RESIZE':begin
        self.doRotate = 0
        self.doTranslate = 0
        self.doRescale = 1
        widget_control, self.translateButton, set_value = self.bmp_translate_deselect
        widget_control, self.rotateButton, set_value = self.bmp_rotate_deselect
        widget_control, self.resizeButton, set_value = self.bmp_resize_select
        return, 1
     end
     'DRAW': begin
        ;- calculate some helper info
        result = -1
        g = widget_info(self.base, /geom)
        outside = event.x lt 0 || event.y lt 0 || $
                  event.x ge g.scr_xsize || $
                  event.y ge g.scr_ysize
        junk = win->pickdata(self.view, self.model, [event.x, event.y], $
                             xyz)
        haveTransform = self.trackball->update(event, transform=qmat)

        case event.type of
           0: begin             ;- button press
              if event.press eq 1 then self.l_drag = 1
              if event.press eq 4 then self.r_drag = 1
              if self.l_drag && self.doRotate then self->toggleWireframe
              self.anchor = [event.x, event.y]
           end
           1: begin
              if self.l_drag && self.doRotate then self->toggleWireframe
              self.l_drag = 0B  ;- button release
              self.r_drag = 0B
              if self.updatePolys then self->updatePolys
           end
           2: begin             ;- mouse motion
              if ~self.l_drag && ~self.r_drag then break
              if outside then break
              if (self.modifiers ne 0) && $
                 (event.modifiers and self.modifiers) eq 0 then break
            
              self.redraw = 1

              ;-rotating, translate, or rescale?
              if self.doRotate then begin
                 if haveTransform ne 0 then begin
                    self.model->getProperty, transform=t
                    self.model->setProperty, transform=t#qmat
                    self.updatePolys = 1
                 endif
              endif else if self.doTranslate then begin
                 delta = [event.x, event.y] - self.anchor
                 g1 = widget_info(self.draw, /geom)
                 delta = delta / [g1.xsize, g1.ysize] * self.view_wid

                 ;- left mouse dragging pans
                 if self.l_drag then begin
                    self.view_cen = self.view_cen - delta
                    self.anchor = [event.x, event.y]
                    self->update_viewplane
                 endif
              endif else if self.doreScale then begin
                 delta = xyz[0:1] - self.anchor
                 
                 print, 'Rescaling Not yet implemented'
              endif

              ;- right mouse drag stretches an image
              if self.r_drag && self.isImage then begin
                 g = widget_info(self.draw, /geom)
                 bias = 0 > (1. * event.x / g.scr_xsize) < 1
                 contrast = 0 > (1. * event.y / g.scr_ysize) < 1
                 self.image->set_stretch, bias = bias, contrast = contrast
              endif
           end
           5:                   ;-keyboard release
           6:                   ;-keyboard release
           7: begin             ;- wheel motion
              self.redraw = 1
              zoomIn = event.clicks gt 0
              self->zoom, zoomIn, event.x, event.y, xyz
           end
           else:
        endcase                 ;- end of draw events
     end
     else:
  endcase                       ;- end of event identification
  
  ;-pass information up the hierarchy
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

function pzwin::getPolygonObjects, count
  objs = self.model->get(/all, count = ct)
  i = 0
  while i lt n_elements(objs) do begin
     if obj_isa(objs[i], 'IDLGRPOLYGON') then $
        result = append(result, objs[i])
     if obj_isa(objs[i], 'IDLGRMODEL') then begin
        new = objs[i]->get(/all, count = ct)
        if ct ne 0 then objs = [objs, new]
     endif
     i++
  endwhile
  count = n_elements(result)
  if count gt 0 then return, result else return, -1
end

pro pzwin::toggleWireframe
  return
  polys = self->getPolygonObjects(ct)
  for i = 0, ct - 1, 1 do begin
     polys[i]->getProperty, style = s
     polys[i]->setProperty, style = (s eq 2) ? 1 : 2
  endfor
end

pro pzwin::updatePolys
  print, 'updating polygons'
  polys = self->getPolygonObjects(ct)
  self.model->getProperty, transform = t
  for i = 0, ct - 1, 1 do begin
     polys[i]->getProperty, poly = p, data = d
     pnew = orderpolys(d, p, t)
     polys[i]->setProperty, poly = pnew
  endfor
  self.redraw=1
end

;- resizes widgets, when tlb is resized to xsz, ysz
pro pzwin::resize, xsz, ysz
  widget_control, self.base, update = 0
  g1 = widget_info(self.menubase, /geom)
  g2 = widget_info(self.buttonbase, /geom)
  pad = 3.
  widget_control, self.menubase, xsize = xsz - pad
  widget_control, self.buttonbase, xsize = xsz - pad
  widget_control, self.draw, xsize = xsz - pad, ysize = ysz - g1.ysize - g2.ysize - 5 * pad
  g = widget_info(self.base, /geom)
  self.base_sz = [g.scr_xsize, g.scr_ysize]

  widget_control, self.base, update = 1
  self->new_trackball
  self.redraw = 1
end

pro pzwin::new_trackball
  obj_destroy, self.trackball
  g = widget_info(self.drawbase, /geom)
  self.trackball = obj_new('trackball', [g.xsize/2, g.ysize/2], (g.xsize < g.ysize) /2)
end

pro pzwin::redraw
  compile_opt idl2
  t = systime(/seconds)
  max_rate = 20.
  ;- continue the draw loop
  widget_control, self.draw, timer=.05

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
  obj_destroy, self.trackball
end

function pzwin::get_widget_id
  return, self.base
end

function pzwin::init, model, parent, standalone = standalone, $
                      xrange = xrange, yrange = yrange, zrange = zrange, image = image, $
                      keyboard_events = keyboard_events, $ 
                      rotate = rotate, $
                      group_leader = group_leader, $
                      _extra = extra
  
  ;- set up view
  object_bounds, model, xra, yra, zra
  rect = [xra[0], yra[0], range(xra), range(yra)]
  print, 'bounds', xra, yra, zra
  print, 'rect: ', rect
  if keyword_set(xrange) then rect[[0,2]] = [xrange[0], xrange[1]-xrange[0]]
  if keyword_set(yrange) then rect[[1,3]] = [yrange[0], yrange[1]-yrange[0]]
  if ~keyword_set(zrange) then zrange= [max([xra, yra, zra], min=lo), lo]
  zrange = [max(zrange, min=lo), lo]
  zrange += .3 * range(zrange) * [1,-1]

  cen = [rect[0] + rect[2]/2., rect[1] + rect[3]/2.]
  wid = [rect[2], rect[3]]
  print, 'cen', cen
  print, 'wid', wid
  view = obj_new('idlgrview', viewplane_rect=rect, _extra = extra)
  view->add, model
  if keyword_set(rotate) then $
     view->setProperty, zclip = zrange
  ;- set up widgets
  if keyword_set(standalone) then begin 
     base = widget_base(event_func='pzwin_event', notify_realize='pzwin_realize', /col, frame = 3, $
                        /tlb_size_events, group_leader = group_leader)
  endif else begin
     base = widget_base(parent, event_func='pzwin_event', notify_realize='pzwin_realize', /col, frame = 3)
  endelse
  ;- a dummy base to hold the uvalue
  dummy = widget_base(base)

  ;-3 rows of bases
  base1 = widget_base(base,/row, xpad = 0, ypad = 0)
  base2 = widget_base(base,/row, xpad = 0, ypad = 0, frame = 3)
  base3 = widget_base(base, xpad = 0, ypad = 0, frame = 3)

  ;- menu bar
;  file = widget_button(base2, value='File', uvalue='FILE')

  ;-button bar
  file = file_which('move.bmp')
  if ~file_test(file) then message, 'cannot find move.bmp'
  move_im = read_image(file)
  move_im = transpose(congrid(move_im, 3, 20, 20), [1,2,0])
  select = move_im & select[*,*,0] = 255B
  self.bmp_translate_select = select
  self.bmp_translate_deselect = move_im
  move = widget_button(base2, value=select, uvalue='TRANSLATE', accelerator='Ctrl+t')
  self.translateButton = move

  file = file_which('resize.bmp')
  if ~file_test(file) then message, 'cannot find resize.bmp'
  resize_im = read_image(file)
  resize_im = transpose(congrid(resize_im, 3,20,20),[1,2,0])
  select = resize_im & select[*,*,0] = 255B
  self.bmp_resize_select = select
  self.bmp_resize_deselect = resize_im
  resize = widget_button(base2, value=resize_im, uvalue='RESIZE')
  self.resizeButton = resize

  file = file_which('rot.bmp')
  if ~file_test(file) then message, 'cannot find rot.bmp'
  rot_im = read_image(file)
  rot_im = transpose(congrid(rot_im, 3, 20, 20), [1,2,0])
  select = rot_im & select[*,*,0] = 255B
  self.bmp_rotate_select = select
  self.bmp_rotate_deselect = rot_im
  rot = widget_button(base2, value=rot_im, uvalue='ROTATE', sensitive=keyword_set(rotate), accelerator='Ctrl+r')
  self.rotateButton = rot

  ;-draw window
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
  
  draw = widget_draw(base3, xsize = xsize, ysize = ysize, graphics_level = 2, $
                     /button_events, /wheel_events, /motion_events, $
                     keyboard_events = keyword_set(keyboard_events) ? 2 : 0, $
                     uvalue = 'DRAW')

  self.trackball = obj_new('Trackball', [xsize/2, ysize/2.], (xsize < ysize)/2.)
  self.doTranslate = 1B
  self.model = model
  self.view = view
  self.draw = draw
  self.base = base
  self.menubase = base1
  self.buttonbase = base2
  self.drawbase = base3
  self.parent = keyword_set(standalone) ? base : parent
  self.view_cen = cen
  self.view_wid = wid
  self.last_render=0.
  self.standalone = keyword_set(standalone)
  self.isImage = keyword_set(image)
  self.is3D = keyword_set(rotate)
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

          ;-objects
          model:obj_new(), $     ;- Model object. Provided on input
          view:obj_new(), $      ;- view object. Created during init
          trackball:obj_new(),$  ;- trackball to handle translation/rotation
          image:obj_new(), $     ;- the CNBgrImage object, if isImage is true
          
          ;-widgets
          parent:0L, $          ;- widget into which pzwin is embedded (or base)
          base:0L, $            ;- root of the pzwin widget hierarchy
          menubase:0L, $        ;- widget base for menubar
          buttonbase:0L, $      ;- widget base for buttons
          drawbase:0L, $        ;- widget base for draw
          translateButton:0L, $
          rotateButton:0L, $
          resizeButton:0L, $
          draw:0L, $            ;- draw widget id. value -> draw object

          ;- button bitmaps
          bmp_translate_deselect:bytarr(20,20,3), $
          bmp_translate_select:bytarr(20,20,3), $
          bmp_rotate_deselect:bytarr(20,20,3), $
          bmp_rotate_select:bytarr(20,20,3), $
          bmp_resize_deselect:bytarr(20,20,3), $
          bmp_resize_select:bytarr(20,20,3), $
  
          base_sz:[0., 0.], $   ;- size of base widget
          view_cen:[0.,0.], $   ;- center of viewport, in data coords
          view_wid:[0.,0.], $   ;- width of viewport, in data coords
          doRotate:0B, $        ;- mouse motion rotates?
          doTranslate:0B, $     ;- mouse motion translates?
          doRescale:0B, $       ;- mouse motion rescales?
          l_drag:0B, $          ;- left dragging?
          r_drag:0B, $          ;- right dragging
          anchor:[0., 0.], $    ;- cursor pos at start of drag
          last_render:0D, $     ;- time of last render
          standalone:0B, $      ;- widget a standalone object?
          isImage:0B, $         ;- does the model object hold a CNBgrImage object?
          is3D:0B, $            ;- is the graphic a rotateable, 3D model?
          updatePolys:0B, $     ;- request to re-order polygons for 3d polygons
          debug: 0B, $
          redraw:0B, $           ;- request for redraw command
          modifiers:0B $         ;- a keyboard modifier filter used to ignore events
         }
end
          
pro test_im

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
  widget_control, ev.top, get_uvalue = state
  if tag_names(ev, /struct) eq 'WIDGET_BASE' then begin
     pad = 3
     g = widget_info(state.button, /geom)
     state.pzwin->resize, ev.x - pad, ev.y - g.ysize - pad
  endif
end

pro test_embed
  tlb = widget_base(/column, /tlb_size_event)
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
  state={plot:plot, model:model, button:button, tlb:tlb, pzwin:obj, pz_base:pz_base}
  widget_control, tlb, set_uvalue = state

  xmanager, 'test_embed', tlb
end

pro test3d

  oTop = OBJ_NEW('IDLgrModel')
  oGroup = OBJ_NEW('IDLgrModel')
  oTop->Add, oGroup

  zData = BESELJ(SHIFT(DIST(40),20,20)/2,0)
  
  sz = SIZE(zData)
  zMax = MAX(zData, MIN=zMin)

  xMax = sz[1] - 1
  yMax = sz[2] - 1
  zMin2 = zMin - 1
  zMax2 = zMax + 1 

  ; Compute coordinate conversion to normalize.
  xs = [-0.5,1.0/xMax]
  ys = [-0.5,1.0/yMax]
  zs = [(-zMin2/(zMax2-zMin2))-0.5, 1.0/(zMax2-zMin2)]
  
  oSurface = OBJ_NEW('IDLgrSurface', zData, STYLE=2, SHADING=0, $
                     COLOR=[60,60,255], BOTTOM=[64,192,128], $
                     XCOORD_CONV=xs, YCOORD_CONV=ys, ZCOORD_CONV=zs)
  oGroup->Add, oSurface
  
  ; Create some lights.
  oLight = OBJ_NEW('IDLgrLight', LOCATION=[2,2,2], TYPE=1)
  oTop->Add, oLight
  oLight = OBJ_NEW('IDLgrLight', TYPE=0, INTENSITY=0.5)
  oTop->Add, oLight
  
  ; Place the model in the view.  
  x = obj_new('pzwin', oTop, image = plot, xrange=xrange, yrange = yrange, /standalone, /keyboard, /rotate  )
end
