pro intervol::set_data, data
  isPtr = size(data, /type) = 10
  self.data = isPtr ? data : ptr_new(data)
  dmin = isPtr ? min(*data, /nan, max = dmax) : min(data, /nan, max = dmax)
  widget_control, self.slider, set_value = [min, max, (min + max)/2]
  self.request_redraw
end
  
pro intervol::make_poly
  widget_control, self.slider, get_value = level
  
  isosurface, *self.data, level, v, c
  o = obj_new('idlgrpolygon', v, poly = c)
  cs = self.model->get(/all, count = ct)
  for i = 0, ct - 1, 1 do if obj_isa(cs[i], 'idlgrpolygon') then self.model->remove(cs[i])
  self.model->add, o
end

pro intervol::redraw
  if self.redraw && 1. / (systime(/seconds) - self.last_render) lt max_rate then self->make_poly
  self->interwin::redraw
end

pro intervol::cleanup
  ptr_free, self.data
end

function intervol::init, data, _extra = extra

  if n_params() ne 1 then begin
     print, 'calling sequence'
     print, ' obj = obj_new("intervol", data, [_extra = extra]'
     return, 0
  endif

  if n_elements(data) eq 0 then $
     message, 'data must be a 3D array, or a pointer to one'

  isPtr = haveData && size(data, /type) eq 10
  
  ndim = isPtr ? size(*data, /n_dim) : size(data, /n_dim)
  if ndim ne 3 then $
     message, 'Volume must be a 3D array'
  sz = isPtr ? size(*data) : size(data)

  model = obj_new('idlgrmodel')
  result = self->interwin::init(model, xrange = [0, sz[0]], $
                                yrange=[0, sz[1]], _extra = extra, $
                                title='Volume Viewer')
  if result eq 0 then return, 0

  dmin = isPtr ? min(*cube, /nan, max = dmax) : min(cube, /nan, max = dmax)
  self.slider = cw_fslider(self.base, min =dmin, max=dmax, $
                              value = (dmin + dmax) / 2)

  self.data = isPtr ? data : ptr_new(data)
  self.isPtr = isPtr
  return, 1
end


pro intervol__define
  data = {intervol, $
          inherits interwin, $
          slider: 0L, $
          isPtr:0B, $
          data: ptr_new(), $
          widget_listener:0L}
end
