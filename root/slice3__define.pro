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

  drawid = self.base
  if event.id eq self.slider then begin
     self->update_images 
     return, 0
  endif
  super = self->interwin::event(event)
  if size(super, /tname) ne 'STRUCT' then return, 1
  result = create_struct(super, 'Z', 0, $
                         name = 'SLICE3_EVENT')
  
  widget_control, self.slider, get_value = index
  if self.slice eq 0 then begin
     x = index & y = result.x & z = result.y
  endif else if self.slice eq 1 then begin
     x = result.x & y = index & z = result.z
  endif else begin
     x = result.x & y = result.y & z = index
  endelse
  result.x = x & result.y = y & result.z = z
  
  return, result
end

pro slice3::resize, x, y
  widget_control, self.base, update = 0

  b_g = widget_info(self.buttonbase, /geom)
  s_g = widget_info(self.slider, /geom)
  
  pad = 3.
  xnew = x - pad
  ynew =  y - b_g.ysize - s_g.ysize - 5*pad

  x1 = xnew & y1 = x1 * self.aspectRatio
  y2 = ynew & x2 = y2 / self.aspectRatio
  if x1 lt y1 then begin
     xnew = x1
     ynew = y1
  endif else begin
     xnew = x2
     ynew = y2
  endelse
        

  widget_control, self.buttonbase, xsize = xnew
  widget_control, self.draw, xsize = xnew, $
                  ysize = ynew
  widget_control, self.slider, xsize = xnew

  widget_control, self.base, update = 1
  self.redraw = 1

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

  self.redraw = 1
end

pro slice3::request_redraw
  self->update_images
  self.redraw = 1
end

pro slice3::remove_image, image
  self.model->remove, image
end

pro slice3::add_image, image, alias = alias
  widget_control, self.slider, get_value = index
  image->set_slice_index, index

  self.model->add, image, alias = alias
  self.redraw = 1

end

pro slice3::cleanup
  self->interwin::cleanup
end


function slice3::init, cube, slice = slice, $
                       _extra = extra

  sz = size(cube)
  isPtr = size(cube, /type) eq 10
  ndim = isPtr ? size(*cube, /n_dim) : size(cube, /n_dim)
  if ndim ne 2 && ndim ne 3 then begin
     print, 'cube must be a 2D or 3D array'
     return, 0
  endif
  if ~keyword_set(slice) then slice = 2
  if ndim eq 2 then self.is2D = 1
  if ndim eq 2 and slice ne 2 then $
     message, '2D images must set slice=2'

  image = obj_new('CNBgrImage', cube, slice = slice)
  
  sz = image->get_2d_size()
  slice_sz = image->get_slice_size()
  self.aspectRatio = 1. * sz[1] / sz[0]
  self.slice = slice

  model = obj_new('IDLgrModel')
  model-> add, image

  result = self->interwin::init(model, xrange=[0,sz[0]], $
                             yrange=[0,sz[1]], _extra = extra, image = image)
  if result eq 0 then return, 0

  self.slider = widget_slider(self.base, min = 0, max = (slice_sz-1)>1, $
                              value = slice_sz/2, /drag, sensitive = ~self.is2D)

;  if keyword_set(widget_listener) then self.widget_listener=widget_listener

  return, 1
end

pro slice3__define
  data = {slice3, $
          inherits interwin, $
          slider:0L, $          ;- slider widget id
          slice:0, $            ;- dimension to slice through
          widget_listener:0L,$  ;- a widget to which this object sends events
          is2D:0B, $             ;- is the data 2D instead of 3D?
          aspectRatio:0. $
         }
end

pro s_test
  m = fltarr(100,100,100)
  indices, m, x, y, z
  m = (x-50.)^2 + (y-50.)^2 + (z-50.)^2
  m *= sin(x/5.) * sin(y/10. - 10*sin(z/10.))
  s = obj_new('slice3', m, slice = 2)
  s->run
end
