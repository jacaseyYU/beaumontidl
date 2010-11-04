pro dg_iso::set_current, id
  self->dg_client::set_current, id
;  self->center_on_substruct, id
end

pro dg_iso::set_substruct, index, substruct
  old = *self.substructs[index]
  if array_equal(substruct, old) then return
  *self.substructs[index] = substruct

  ;- get substruct isosurface
  iso = self->make_polygon(substruct, color = self.colors[*, index], $
                           alpha = self.alpha[index])
  
  if obj_valid(self.sub_isos[index]) then begin
     self->remove_graphics_atom, self.sub_isos[index]
     obj_destroy, self.sub_isos[index]
  endif

  self.sub_isos[index] = iso
  if obj_valid(iso) then self->add_graphics_atom, iso
  self->request_redraw
end

pro dg_iso::center_on_substruct, index
  if ~obj_valid(self.sub_isos[index]) then return
  self.sub_isos[index]->getProperty, data = v, poly = c
  cen = [mean(v[0,*]), mean(v[1,*]), mean(v[2,*])]
  self->set_rotation_center, cen
end

function dg_iso::make_polygon, id, _extra = extra
  if min(id) lt 0 then return, obj_new()

  ind = substruct(id, self.ptr)
  if n_elements(ind) lt 5 then return, obj_new()

  ptr = self.ptr

  ;- create a cube
  x = (*ptr).x[ind] & y = (*ptr).y[ind] & z = (*ptr).v[ind]
  lo = [min(x, max=mx), min(y, max=my), min(z, max=mz)]
  hi = [mx, my, mz]
  range = hi - lo
  x -= lo[0] & y -= lo[1] & z -= lo[2]
  cube = fltarr(range[0], range[1], range[2])
  cube[x, y, z] = 1
  
  ;-cube to surface
  isosurface, cube, 1, v, c
  v = mesh_smooth(v, c)
  v[0,*] += lo[0] & v[1,*] += lo[1] & v[2,*] += lo[2]
  
  ;- surface to polygon
  o = obj_new('idlgrpolygon', v, poly = c, _extra = extra)
;  cube[x, y, z] = (*ptr).t[ind]
;  o = obj_new('idlgrvolume', cube, _extra = extra)
;  m = obj_new('idlgrmodel')
;  t = [[1.,0,0,lo[0]], [0,1,0,lo[1]], [0,0,1,lo[2]],[0,0,0,1]]
;  m->setProperty, tran=t
;  m->add, o
;  return, m
  return, o
end

pro dg_iso::update_axes
  ;-axes are constant size, always pointing up on view window
  self.model->getProperty, transform = tran
  updir = [[0.],[1.],[0],[1]] # invert(tran)
  baseline = [[1.],[0],[0],[1]] # invert(tran)
  
  updir = updir[0:2]
  baseline=baseline[0:2]

  self.axes[0]->getProperty, title = t1
  self.axes[4]->getProperty, title = t2
  self.axes[8]->getProperty, title = t3
  t1->setProperty, char_dim = .04 * self.view_wid, updir = updir, baseline=baseline
  t2->setProperty, char_dim = .04 * self.view_wid, updir = updir, baseline=baseline
  t3->setProperty, char_dim = .04 * self.view_wid, updir = updir, baseline=baseline
end

function dg_iso::event, event
  super = self->interwin::event(event)
  self->update_axes
  if size(super, /tname) eq 'STRUCT' && self.listener ne 0 then $
     widget_control, self.listener, $
                     send_event = create_struct(super, name='DG_ISO_EVENT')
  
  return, 1
end

function dg_iso::init, ptr, color = color, listener = listener, $
                  _extra = extra
  junk = self->dg_client::init(ptr, listener, color = color)

  sz = (*ptr).sz
  xra = [0,sz[1]]
  yra = [0,sz[2]]
  zra = [0,sz[3]]
  model = obj_new('idlgrmodel')

  self.xcen = mean(xra) & self.ycen = mean(yra) & self.zcen = mean(zra)
  sz = [0, xra[1], yra[1], zra[1]]
  
  zra = [min([xra, yra, zra], max=hi), hi]
  zra += 3*range(zra) * [-1,1]
  zra = reverse(zra)

  ;- lights
  l1 = obj_new('idlgrlight', type = 2, loc = [sz[1], sz[2], 2*sz[3]], $
               color=[255,255,255], inten=.7)
  l2 = obj_new('idlgrlight', type = 0, inten = 0.5, $
               color = [255,255,255])
  l3 = obj_new('idlgrlight', type = 2, loc = [-sz[1], -sz[2], -2*sz[3]], inten=.7)
  ;- axes
  for i = 0, 3, 1 do begin
     self.axes[i] = obj_new('idlgraxis', 0, range=[0, sz[1]], $
                            loc=[0, sz[2] * (i / 2), sz[3] * (i mod 2)], maj=0, min=0, $
                            thick=2, /exact)
     
     self.axes[4 + i] = obj_new('idlgraxis', 1, range=[0, sz[2]], $
                                loc=[sz[1] * (i/2), 0, sz[3] * (i mod 2)], maj=0, min=0, $
                                thick=2, /exact)

     self.axes[8 + i] = obj_new('idlgraxis', 2, range=[0, sz[3]], thick=2, $
                                loc=[sz[1] * (i/2), sz[2] *(i mod 2), 0], maj=0, min=0, /exact)
     model->add, self.axes[i]
     model->add, self.axes[4+i]
     model->add, self.axes[8+i]
  endfor
  self.axes[0]->setProperty, title=obj_new('idlgrtext', 'X')
  self.axes[4]->setProperty, title=obj_new('idlgrtext', 'Y')
  self.axes[8]->setProperty, title=obj_new('idlgrtext', 'Z')

  model->add, l1
  model->add, l2
  model->add, l3
  result = self->interwin::init(model, $
                                xra = xra, yra = yra, zra = zra, $
                                _extra = extra, /rotate, eye = 1.5 * max(zra), /depth_test_disable)
  self->set_rotation_center, sz[1:3]/2.
  return, 1
end

pro dg_iso__define
  data = {dg_iso, $
          inherits interwin, $
          inherits dg_client, $
          sub_isos: objarr(8), $
          axes:objarr(12), $
          xcen:0., ycen:0., zcen:0.}
end


pro test_event, event
end
pro test
  restore, '~/dendro/ex_ptr_small.sav'
  tlb = widget_base()
  widget_control, tlb, /realize
  di = obj_new('dg_iso', ptr, listen = tlb)
  di->set_substruct, 0, [18, 35, 30, 160]
  di->run
  xmanager, 'test', tlb, /no_block
end
  
