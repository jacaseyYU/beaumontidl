;+
; CLASS_NAME:
;  interwin
;
; PURPOSE:
;  A window to interact with graphical objects.
;
; CATEGORY:
;  Data visualization
;
; SUPERCLASSES:
;  None
;
; SUBCLASSES:
;  slice3, interplot
;
; DESCRIPTION:
;  interwin displays one or more graphics model objects in a
;  window. Several interactions are supported, including panning,
;  zooming, adjusting greyscale (for images), rotating (for 3D
;  objects), and saving to file. Interwin is designed to be the base
;  class for more specific interactive visualizations.
;
; EXAMPLE:
;  object = obj_new('interwin', graphics_model)
;  object->run
;
; EVENTS RETURNED BY INTERWIN:
;  If check_listen returns 1, then interwin::event returns an event
;  structure containing details about the mouse location (in data
;  coordinates), whether the mouse is clicking/dragging, pressing a
;  key, etc. This event structure can be used by subclasses to create
;  custom interactions, without having to parse widget events
;  directly. 
;
; HOW TO PROGRAMATICALLY UPDATE THE DISPLAY:
;  If a subclass or other program wants to update the graphics display
;  programatically, they should either
;   1) set the DRAW instance variable to 1 (if a subclass), or
;   2) call the request_redraw procedure. 
;
;  Other programs should not call the REDRAW procedure
;  directly. Interwin checks to make sure it doesn't update the
;  display too frequently (which can bog down the system), and thus
;  ocasionally ignores calls to redraw. Calling request_redraw, or
;  setting draw=1, ensures that the redraw request will not be
;  forgotten (though it may be postponed).
;
; METHODS:
;  Methods with an (*) are intended as "public." The remaining methods
;  are used internally, and should not be called by other programs
;
;  (*)request_redraw: Schedule a graphics update
;  (*)setbutton: Determine which of the translate, rotate, and resize
;             buttons to activate
;  (*)set_event_filter: Set a modifier key used to disable events
;  (*)clear_event_filter: Remove event filter
;  (*)resize: Update the size of the interwin window
;  (*)get_model: Get models from the graphics tree
;  (*)set_model: Set a new graphics model to display
;  (*)get_view: Get the view object
;  (*)add_graphics_atom: Insert a new graphic in the tree
;  (*)remove_graphics_atom: Remove a graphic from the tree
;  (*)get_draw: return draw object
;  (*)run: Realize and run the widget hierarchy
;  event: Main event handling loop
;  button_press_event: handle button events
;  button_release_event: handle button release events
;  button_motion_event: handle mouse motion
;  keyboard_event: handle keyboard events
;  getpolygonobjects: Recursively search the graphics tree for
;                     idlgrpolygon objects
;  togglewireframe: Turn wireframe rendering of 3d shapes on/off
;  updatepolys: Reorder polygons in the view so they are rendered in
;               the proper order
;  new_trackball: Create a new trackball for rotation
;  redraw: Update the graphics display
;  zoom: Zoom in/out
;  update_viewplane: Change the size and location of the view window
;  cleanup: De-allocate memory upon object destruction
;  get_widget_id: Return the base widget of the interwin hierarchy
;  check_listen: Update the listen status, and determine whether to
;                propagate events up the widget hierarchy
;  init: Create a new interwin object
;
; MODIFICATION HISTORY:
;  September 2010: Written by Chris Beaumont
;  October 2010: Added rotation functionality for 3d models. Change
;  how resize events work. cnb.
;  October 30 2010: Substantially re-worked. Interwin now behaves as a
;  standalone object, as opposed to a compound widget.
;-

;-----------------
; GUI Procedures (non-object)
pro interwin_realize, id
  ;- start the render loop
  child = widget_info(id, /child)
  widget_control, child, get_uvalue = info
  widget_control, info->get_draw(), timer=.03
end

pro interwin_kill, id
  widget_control, id, get_uvalue = info
  obj_destroy, info
end

function interwin_event, event
  compile_opt idl2
  child = widget_info(event.handler, /child)
  widget_control, child, get_uvalue = info
  return, info->event(event)
end

pro interwin_event, event
  junk = interwin_event(event)
end
;--------------------

;--------------------
; GUI Procedures (object oriented)
pro interwin::request_redraw, debug = debug
  self.redraw = 1
  if keyword_set(debug) then begin
     self.debug = 1
  endif
end

pro interwin::set_rotation_center, center
  self.model->getProperty, transform = t
  ;- where does rotation center currently project?
  off = [[center[0]],[center[1]],[center[2]],[1]] # t
  ;- this point should move to origin
  self.rot_cen = off[0:2]
  self->request_redraw
end

function interwin::event, event
  ;- widget timer events tell us when to update display
  if tag_names(event, /structure_name) eq 'WIDGET_TIMER' then begin
     self->redraw
     return, 1
  endif

  if event.id eq self.mbar then begin
     self->menu_event, event
     return, 1
  endif

  ;- in standalone mode, handle resize events
  if tag_names(event, /struct) eq 'WIDGET_BASE' then begin
     self->resize, event.x, event.y
     return, 2
  endif

  ;- menu events
  if event.id eq self.mbar then begin
     print, 'menu'
     return, 3
  endif

  widget_control, self.draw, get_value = win
  widget_control, event.id, get_uvalue = uval
  if n_elements(uval) eq 0 then return, 1
  case uval of
     'ROTATE': begin
        self->setButton, /rotate
        return, 4
     end
     'TRANSLATE':begin
        self->setButton, /translate
        return, 5
     end
     'RESIZE':begin
        self->setButton, /resize
        return, 6
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
        info = {win:win, g:g, outside:outside, xyz:xyz, haveTransform:haveTransform, $
                qmat:haveTransform ? qmat : 0, hit:junk}
        case event.type of
           0: self->button_press_event, event, info
           1: self->button_release_event, event
           2: self->button_motion_event, event, info
           5: self->keyboard_event, event
           6: ;- non-ascii key
           7: begin             ;- wheel motion
              self.redraw = 1
              zoomIn = event.clicks gt 0
              self->zoom, zoomIn, event.x, event.y, xyz
           end
           else:
        endcase                 ;- end of draw events
     end
     else: return, 1
  endcase                       ;- end of event identification
  
  ;-pass information up the hierarchy
  result = {interwin_event, ID: event.handler, TOP: event.top, HANDLER:0L, $
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

pro interwin::menu_event, event
  case event.value of
     'File.Save as image': 
     'File.Save view': begin
        file=dialog_pickfile(default_extension='vew', /write, /overwrite_prompt)
        view = self.view
        if file ne '' then save, view, file=file
        return
     end
     'File.Save model': begin
        file=dialog_pickfile(default_extension='mod', /write, /overwrite_prompt)
        model = self.model
        if file ne '' then save, model, file=file
        return
     end
     'View.Reset': 
     'View.3D rotation.reset': begin
        self.model->setProperty, tran=[[1.,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]]
     end
     'View.3D rotation.Fix x axis':self->new_trackball, axis=0
     'View.3D rotation.Fix y axis':self->new_trackball, axis=1
     'View.3D rotation.Fix z axis':self->new_trackball, axis=2
     else:
  endcase
end

pro interwin::button_press_event, event, info
  if event.press eq 1 then begin
     self.l_drag = 1
     if self.doRescale then begin
        self.rescale_plot = obj_new('idlgrplot', $
                                    [event.x, event.x], $
                                    [event.y, event.y], $
                                    color=[255,0,0])
        self.rescale_model->add, self.rescale_plot
                                ;- ctrl + left click sets new rotation center
     endif
     if info.hit && (event.modifiers and 2) ne 0 then $
           self->set_rotation_center, info.xyz
  endif
  if event.press eq 4 then self.r_drag = 1
  if self.l_drag && self.doRotate then self->toggleWireframe
  self.anchor = [event.x, event.y]
end

pro interwin::button_release_event, event
  if self.l_drag && self.doRotate then self->toggleWireframe
  wasL = self.l_drag eq 1B
  self.l_drag = 0B  
  self.r_drag = 0B
  if self.updatePolys then self->updatePolys
  if self.doRescale && wasL then begin
     self.rescale_model->remove, self.rescale_plot
     self.redraw = 1
     obj_destroy, self.rescale_plot
     old = self.anchor
     new = [event.x, event.y]
     cen = (old + new) / 2
     wid = abs(old - new)
     if new[0] gt old[0] && min(wid) gt 10 then begin
        g1 = widget_info(self.draw, /geom)
        delta = cen - [g1.xsize/2, g1.ysize/2]
        delta = delta / [g1.xsize, g1.ysize] * self.view_wid
        magnify = wid / [g1.xsize, g1.ysize]
        if self.isImage then magnify[1] = magnify[0]
        self.view_cen += delta
        self.view_wid *= magnify
        self->update_viewplane      
     endif
  endif
end

pro interwin::button_motion_event, event, info
  if ~self.l_drag && ~self.r_drag then return
  if (self.modifiers ne 0) && $
     (event.modifiers and self.modifiers) eq 0 then return
  
  self.redraw = 1
  
  ;-rotating, translate, or rescale?
  if self.doRotate then begin
     if info.haveTransform ne 0 then begin
        cen = self.rot_cen
        self.model->translate, -self.rot_cen[0], -self.rot_cen[1], -self.rot_cen[2]
        self.model->getProperty, transform=t
        self.model->setProperty, transform=t#info.qmat
        self.model->translate, self.rot_cen[0], self.rot_cen[1], self.rot_cen[2]
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
  endif else if self.doreScale && self.l_drag then begin
     ;- update rescale box
     junk = info.win->pickdata(self.view, self.rescale_model, $
                          [event.x, event.y], xyz1)
     junk = info.win->pickdata(self.view, self.rescale_model, $
                          self.anchor, xyz2)
     
     ;- if this is an image, preserve the aspect ratio
     if self.isImage then xyz1[1] = xyz2[1] + (xyz1[0] - xyz2[0]) * $
                                    self.view_wid[1]/self.view_wid[0] * $
                                    sign(xyz1[1] - xyz2[1])
     
     x = [xyz1[0], xyz2[0], xyz2[0], xyz1[0], xyz1[0]]
     y = [xyz1[1], xyz1[1], xyz2[1], xyz2[1], xyz1[1]]
     if x[0] lt x[1] then x*=!values.f_nan
     
     self.rescale_plot->setProperty, $
        datax= x, datay = y
  endif
  
  ;- right mouse drag stretches an image
  if self.r_drag && self.isImage && ~info.outside then begin
     g = widget_info(self.draw, /geom)
     bias = 0 > (1. * event.x / g.scr_xsize) < 1
     contrast = 0 > (1. * event.y / g.scr_ysize) < 1
     self.image->set_stretch, bias = bias, contrast = contrast
  endif
end

pro interwin::keyboard_event, event
  if ~event.release then return
  case strupcase(event.ch) of
     'R': if self.is3D then self->setButton, /rotate
     'T': self->setButton, /translate
     'Y': self->setButton, /resize
     else:
  endcase         
end

pro interwin::setButton, translate = translate, rotate = rotate, resize = resize
  if keyword_set(translate) then begin
     self.doRotate = 0
     self.doTranslate = 1
     self.doRescale = 0
     widget_control, self.translateButton, set_value = self.bmp_translate_select
     widget_control, self.rotateButton, set_value = self.bmp_rotate_deselect
     widget_control, self.resizeButton, set_value = self.bmp_resize_deselect
  endif else if keyword_set(rotate) then begin
     self.doRotate = 1
     self.doTranslate = 0
     self.doRescale = 0
     widget_control, self.translateButton, set_value = self.bmp_translate_deselect
     widget_control, self.rotateButton, set_value = self.bmp_rotate_select
     widget_control, self.resizeButton, set_value = self.bmp_resize_deselect
  endif else if keyword_set(resize) then begin
     self.doRotate = 0
     self.doTranslate = 0
     self.doRescale = 1
     widget_control, self.translateButton, set_value = self.bmp_translate_deselect
     widget_control, self.rotateButton, set_value = self.bmp_rotate_deselect
     widget_control, self.resizeButton, set_value = self.bmp_resize_select
  endif
end

pro interwin::set_event_filter, control = control, shift = shift
  if keyword_set(shift) then self.modifiers = 1
  if keyword_set(control) then self.modifiers = 2
end

pro interwin::clear_event_filter
  self.modifiers=0
end

function interwin::getPolygonObjects, count
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

pro interwin::toggleWireframe
;  return
  polys = self->getPolygonObjects(ct)
  for i = 0, ct - 1, 1 do begin
     polys[i]->getProperty, style = s
     polys[i]->setProperty, style = (s eq 2) ? 1 : 2
  endfor
end

pro interwin::updatePolys
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
pro interwin::resize, xsz, ysz
  widget_control, self.base, update = 0
  g1 = widget_info(self.mbar, /geom)
  g2 = widget_info(self.buttonbase, /geom)
  pad = 3.
;  widget_control, self.mbar, xsize = xsz - pad
  widget_control, self.buttonbase, xsize = xsz - pad
  widget_control, self.draw, xsize = xsz - pad, ysize = ysz - g1.ysize - g2.ysize - 5 * pad
  g = widget_info(self.base, /geom)

  widget_control, self.base, update = 1
  self->new_trackball
  self.redraw = 1
end

pro interwin::new_trackball, axis = axis
  obj_destroy, self.trackball
  g = widget_info(self.drawbase, /geom)
  self.trackball = obj_new('trackball', [g.xsize/2, g.ysize/2], (g.xsize < g.ysize) /2, $
                          axis = axis, constrain = n_elements(axis) ne 0)
end

pro interwin::redraw
  compile_opt idl2
  t = systime(/seconds)
  max_rate = 20.
  ;- continue the draw loop
  widget_control, self.draw, timer=.05

  ;- avoid unnecessary redraws
  if ~self.redraw || 1. / (t - self.last_render) gt max_rate then return
  if self.debug then print, 'interwin draw'
  widget_control, self.draw, get_value = win
  win->draw, self.view
  self.last_render = t
  self.redraw = 0
  return
end

pro interwin::zoom, zoomIn, x, y, xyz
  widget_control, self.draw, get_value = win
  self.view_wid = self.view_wid * (zoomIn ? .98 : 1.02)
  self->update_viewplane
  junk = win->pickdata(self.view, self.model, [x, y], $
                            xyz2)
  delta = xyz2 - xyz
  self.view_cen -= delta
  self->update_viewplane
end


pro interwin::update_viewplane
  compile_opt idl2, hidden

  rect = [self.view_cen[0] - self.view_wid[0]/2., $
          self.view_cen[1] - self.view_wid[1]/2., $
          self.view_wid[0], self.view_wid[1]]
  self.view->setProperty, viewplane = rect
end
;-----------------------


;-----------------------
; Non-GUI object methods

function interwin::get_model
  return, self.model
end

pro interwin::set_model, model
  self.view->remove, self.model
  obj_destroy, self.model
  self.model = model
  self.view->add, self.model
end

function interwin::get_view
  return, self.view
end

pro interwin::add_graphics_atom, atom, _extra = extra
  self.model->add, atom, _extra = extra
end

pro interwin::remove_graphics_atom, atom
  self.model->remove, atom
end

function interwin::get_draw
  return, self.draw
end

pro interwin::cleanup
  obj_destroy, self.view
  obj_destroy, self.trackball
end

function interwin::get_widget_id
  return, self.base
end

pro interwin::check_listen, event
   if event.LEFT_CLICK || event.RIGHT_CLICK then begin
     self.old_listen = self.listen
     self.listen = 0
  endif
  if event.LEFT_DRAG then self.drag = 1B
  if event.LEFT_RELEASE then begin
     if self.drag then self.listen = self.old_listen
     if ~self.drag then self.listen = ~self.old_listen
     self.drag = 0
  endif
  if event.RIGHT_RELEASE then begin
     self.listen = self.old_listen
  endif
end

function interwin::init, model, $
                         xrange = xrange, yrange = yrange, zrange = zrange, image = image, $
                         xoffset = xoffset, yoffset = yoffset, $
                         rotate = rotate, $
                         group_leader = group_leader, $
                         _extra = extra

  if n_params() eq 0 || ~obj_valid(model) || ~obj_isa(model, 'IDLGRMODEL') then begin
     print, 'calling sequence:'
     print, 'obj = obj_new("interwin", model, [xrange = xrange, yrange = yrange, zrange = zrange"'
     print, '               /rotate, group_leader = group_leader, _extra = extra])'
     return, 0
  endif

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

  self.rescale_model = obj_new('idlgrmodel')
  self.rescale_plot = obj_new('idlgrplot')
  view->add, model
  view->add, self.rescale_model
  self.rescale_model->add, self.rescale_plot
  if keyword_set(rotate) then $
     view->setProperty, zclip = zrange
  ;- set up widgets
  base = widget_base(event_func='interwin_event', notify_realize='interwin_realize', /col, frame = 3, $
                        /tlb_size_events, group_leader = group_leader, mbar = mbar, $
                     xoffset = xoffset, yoffset = yoffset)
  
  ;- a dummy base to hold the uvalue
  dummy = widget_base(base)

  ;-3 rows of bases
  base2 = widget_base(base,/row, xpad = 0, ypad = 0, frame = 3)
  base3 = widget_base(base, xpad = 0, ypad = 0, frame = 3)

  ;- menu bar
  self.mbar = mbar
  menu_desc = ['1\File', $
               '0\Save as image', $
               '0\Save view', $
               '2\Save model', $
               '1\View', $
               '0\Reset', $
               '1\3D rotation', $
               '0\reset', $
               '0\Fix x axis', $
               '0\Fix y axis', $
               '2\Fix z axis']
  menu = cw_pdmenu(mbar, menu_desc, /mbar, /return_full_name)
  widget_control, mbar, set_uvalue='mbar'
  
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
                     keyboard_events = 2, $
                     uvalue = 'DRAW')

  self.trackball = obj_new('Trackball', [xsize/2, ysize/2.], (xsize < ysize)/2.)
  self.doTranslate = 1B
  self.model = model
  self.view = view
  self.draw = draw
  self.base = base
  self.mbar = mbar
  self.buttonbase = base2
  self.drawbase = base3
  self.view_cen = cen
  self.view_wid = wid
  self.last_render=0.
  self.listen = 1
  self.standalone = keyword_set(standalone)
  self.isImage = keyword_set(image)
  self.is3D = keyword_set(rotate)
  self.redraw = 1
  if self.isImage then self.image = image

  child = widget_info(base, /child)
  widget_control, child, set_uvalue = self, $
                  kill_notify='interwin_kill'
  

  return, 1
end

pro interwin::run
  widget_control, self.base, /realize
  xmanager, 'interwin', self.base, /no_block
end

pro interwin__define

  data = {interwin, $

          ;-objects
          model:obj_new(), $     ;- Model object. Provided on input
          view:obj_new(), $      ;- view object. Created during init
          trackball:obj_new(),$  ;- trackball to handle translation/rotation
          image:obj_new(), $     ;- the CNBgrImage object, if isImage is true
          
          ;-widgets
          base:0L, $            ;- root of the interwin widget hierarchy
          mbar:0L, $            ;- widget base for menubar
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

          ;- rescale objects. Used to draw a box when rescaling
          rescale_model:obj_new(), $
          rescale_plot:obj_new(), $
  
          ;- bit flags
          doRotate:0B, $        ;- mouse motion rotates?
          doTranslate:0B, $     ;- mouse motion translates?
          doRescale:0B, $       ;- mouse motion rescales?
          l_drag:0B, $          ;- left dragging?
          r_drag:0B, $          ;- right dragging
          standalone:0B, $      ;- widget a standalone object?
          isImage:0B, $         ;- does the model object hold a CNBgrImage object?
          is3D:0B, $            ;- is the graphic a rotateable, 3D model?
          debug: 0B, $
          redraw:0B, $           ;- request for redraw command
          updatePolys:0B, $      ;- request to re-order polygons for 3d polygons
          listen: 0B, $          ;- should other widgets listen to events from us?
          old_listen:0B, $       ;- value of listen before dragging started
          drag:0B, $             ;- drag bitflag used in check_listen
          ;- other state info
          modifiers:0B, $       ;- a keyboard modifier filter used to ignore events
          view_cen:[0.,0.], $   ;- center of viewport, in data coords
          view_wid:[0.,0.], $   ;- width of viewport, in data coords
          rot_cen:dblarr(3), $  ;- pivot point when rotating

          anchor:[0., 0.], $    ;- cursor pos at start of drag
          last_render:0D $      ;- systime of last render
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
  
  x = obj_new('interwin', model, image = plot, xrange=xrange, yrange = yrange, /standalone, /keyboard)  
  x->run
end

pro test_embed_event, ev
  widget_control, ev.top, get_uvalue = state
  if tag_names(ev, /struct) eq 'WIDGET_BASE' then begin
     pad = 3
     g = widget_info(state.button, /geom)
     state.interwin->resize, ev.x - pad, ev.y - g.ysize - pad
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

  obj = obj_new('interwin', model, pz_base, xrange=[0,11],yrange=[-1,1], /keyboard)
  button = widget_button(tlb, value='Hi There', xsize = 4)


  widget_control, tlb, /realize
  state={plot:plot, model:model, button:button, tlb:tlb, interwin:obj, pz_base:pz_base}
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
;  xs = [-0.5,1.0/xMax]
;  ys = [-0.5,1.0/yMax]
;  zs = [(-zMin2/(zMax2-zMin2))-0.5, 1.0/(zMax2-zMin2)]
  
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
  x = obj_new('interwin', oTop, image = plot, xrange=xrange, yrange = yrange, /standalone, /keyboard, /rotate  )
  x->run
end
