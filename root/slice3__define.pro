;+
; CLASS_NAME:
;  slice3
;
; PURPOSE:
;  Slice3 is a gui for interacting with 3D CNBgrImages. 
;  It presents a ds9-like "sliding slice" view of a cube. The user can
;  adjust the greyscale, slice position, and can pan and zoom through
;  the data. Multiple CNBgrImages can be displayed, with transparency.
;
; CATEGORY:
;  Data interaction
;
; SUPERCLASSES:
;  None
;
; SUBCLASSES:
;  None
;
; DESCRIPTION:
;  The user creates a slicer3 object and adds 1 or more CNBgrImage
;  objects. He or she then invokes the RUN class method, which creates
;  the gui. The object keeps track of which slice the user is viewing,
;  and keeps all of the CNBgrImage objects in sync with each other.
;
;  Slice3 is a standalone GUI that cannot be embedded into other
;  widget hierarchies. However, it _can_ pas events to other widgets
;  by setting the "widget listener" attribute. If this attribute
;  refers to a valid widget, then this GUI will pass events to that
;  widget. The event structure has the tags: 
;    X, Y, Z, L_CLICK, R_CLICK, L_RELEASE, R_RELEASE
;  where XYZ are in data coordinates, and correspond to the location
;  of the cursor. 
;
; CREATION:
;  see slice3::init
;
; METHODS:
;  SLICE3::RUN    Draws the gui to the screen and starts event handling
;  SLICE3::EVENT         Event handling routine
;  SLICE3::GET_IMAGES    returns all the CNBgrImages
;  SLICE3::UPDATE_IMAGES sync cube slices and redraw
;  SLICE3::REMOVE_IMAGE  removes an image
;  SLICE3::ADD_IMAGE     adds an image
;  SLICE3::REDRAW        Re-draws graphics to screen
;  SLICE3::ADD_GRAPHICS_ATOM: Add a new graphics item 
;  SLICE3::REMOVE_GRAPHICS_ATOM: Remove a graphics item
;  SLICE3::CLEANUP       Destroy the object, free heap memory
;  SLICE3::INIT          Creates a new object
;
; MODIFICATION HISTORY:
;  September 2010: Written by Chris Beaumont.
;-

;+
; PURPOSE:
;  This function is a wrapper to process widget events. It calls the
;  object method.
;-
function slice3_event, event
  widget_control, event.top, get_uvalue = obj
  return, obj->event(event)
end

;+
; PURPOSE:
;  This procedure is a wrapper to process widget events. It calls the
;  object method
;-
pro slice3_event, event
  junk = slice3_event(event)
end


;+
; PURPOSE:
;  This procedure destroys the widget hierarchy, and frees heap
;  memory. 
;-
pro slice3_kill, id
  widget_control, id, get_uvalue = obj
  obj_destroy, obj
end


;+
; PURPOSE:
;  This proedure realizes the widget, and starts event handling. 
;-
pro slice3::run
  widget_control, self.base, /realize, get_uvalue=uvalue
  xmanager, 'slice3', self.base, /no_block, $
            cleanup = 'slice3_kill'
end


;+
; PURPOSE:
;  This is the main event handling function
;
; INPUTS:
;  Event: the event structure
;
; RETURNS:
;  0, for now
;
; MODIFICATION HISTORY:
;  Sep 2010: Written by Chris Beaumont
;-
function slice3::event, event, draw_event = draw_event
  widget_control, event.top, get_uvalue = obj
  drawid = self.win->get_widget_id()
  case event.id of
     self.slider: begin ;- slice adjustment
        self->update_images
     end
     self.base: begin           ;- resize events
        g = widget_info(self.base, /geometry)
        g2 = widget_info(self.draw_base, /geometry)
        ratio = 1. * g2.scr_xsize / g2.scr_ysize

        x1 = g.scr_xsize & y1 = x1 /ratio
        y2 = g.scr_ysize & x2 = y2 * ratio
        if y1 le g.scr_ysize then begin
           widget_control, self.draw_base, scr_xsize = x1, $
                           scr_ysize = y1
        endif else begin
           widget_control, self.draw_base, scr_xsize = x2, $
                           scr_ysize = y2
        endelse
        self.win->request_redraw
     end  
     drawid: begin
        x = event.x
        y = event.y
        widget_control, self.slider, get_value = z
        draw_event = {slice3_event, $
                      ID:self.base, TOP:event.top, $
                      HANDLER:0L, $
                      base:self.base, $
                      x:x, y:y, z:z, $
                      LEFT_CLICK:event.LEFT_CLICK, $
                      LEFT_DRAG:event.LEFT_DRAG, $
                      LEFT_RELEASE:event.LEFT_RELEASE, $
                      RIGHT_CLICK: event.RIGHT_CLICK, $
                      RIGHT_DRAG: event.RIGHT_DRAG, $
                      RIGHT_RELEASE: event.RIGHT_RELEASE}
        if self.widget_listener ne 0 then $
           widget_control, self.widget_listener, $
                           send_event = draw_event
     end
     else:
  endcase

  return, 0
end

function slice3::get_images, ct
  result = self.model->get(/all, isa='CNBgrImage')
  ct = n_elements(result)
  return, result
end

;+
; PURPOSE:
;  This procedure updates the data views
;-
pro slice3::update_images
  widget_control, self.slider, get_value = index

  ;- get all images, update slice
  ims = self->get_images(ct)
  for i = 0, ct - 1, 1 do $
     ims[i]->set_slice_index, index

  self.win->request_redraw
end


pro slice3::remove_image, image
  self.model->remove, image
end

pro slice3::add_image, image
  widget_control, self.slider, get_value = index
  image->set_slice_index, index

  self.model->add, image, /alias
  self.win->request_redraw
end

pro slice3::redraw, debug = debug
  if keyword_set(debug) then print, 'slice3 redraw'
  self.win->request_redraw, debug = debug
end

pro slice3::set_widget_listener, widget
  self.widget_listener = widget
end

function slice3::add_graphics_atom, atom, pos = pos
  self.model->add, atom, pos = pos
end

function slice3::remove_graphics_atom, atom
  self.model->remove, atom
end

function slice3::cleanup
  obj_destroy, self.model
  obj_destroy, self.win
end

function slice3::get_widget_id
  return, self.base
end

function slice3::init, cube, slice = slice, group_leader = group_leader, $
                       widget_listener = widget_listener, $
                       _extra = extra

  sz = size(cube)
  isPtr = size(cube, /type) eq 10
  ndim = isPtr ? size(*cube, /n_dim) : size(cube, /n_dim)
  if ndim ne 3 then begin
     print, 'cube must be a 3D array'
     return, 0
  endif

  
  image = obj_new('CNBgrImage', cube, slice = slice, _extra = extra)
  
  sz = image->get_2d_size()
  slice_sz = image->get_slice_size()
  slice = image->get_slice()

  self.model = obj_new('IDLgrModel')
  self.model-> add, image

  tlb = widget_base(/column, /tlb_size_event, $
                    title='Slice '+strtrim(slice,2), $
                    group_leader = group_leader, _extra = extra)
  self.draw_base = widget_base(tlb, _extra = extra)
  self.win = obj_new('pzwin', self.model, self.draw_base, $
                     xrange = [0, sz[0]], $
                     yrange = [0, sz[1]], $
                     image = image)
  self.slider = widget_slider(tlb, min = 0, max = slice_sz-1, $
                         value = slice_sz/2, /drag)
  self.base = tlb
  widget_control, tlb, set_uvalue = self

  if keyword_set(widget_listener) then self.widget_listener=widget_listener

  return, 1
end

pro slice3__define
  data = {slice3, $
          base:0L, $            ;- top level base
          slider:0L, $          ;- slider widget id
          draw_base:0L, $       ;- base which holds pzwin
          model:obj_new(), $    ;- model object, holds all the image cubes
          win:obj_new(), $      ;- pzwin object
          widget_listener:0L$   ;- a widget to which this object sends events
         }
end

pro s_test_event, event
;  help, event, /struct
end

pro s_test
  listen = widget_base()
  im = rebin(dist(100), 100, 100, 100)
  s = obj_new('slice3', im, slice = 2, widget_listen = listen)
  s->run
  widget_control, listen, /realize
  xmanager, 's_test', listen
end
