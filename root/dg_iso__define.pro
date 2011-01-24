pro dg_iso::set_current, id
  self->dg_client::set_current, id
;  self->center_on_substruct, id
end

pro dg_iso::redraw
  if ~(self.is_merged) then self->merge_isos
  self->interwin::redraw
end

pro dg_iso::merge_isos
  self.is_merged = 1
  offset = 0L
  self.model->remove, self.merged
  obj_destroy, self.merged
  for i = 0, 7 do begin
     o = self.sub_isos[i]
     if ~obj_valid(o) then continue
     o->getProperty, color = col, alpha = a, data = v, poly = c
     v[0,*] *= self.scale[0] & v[1,*] *= self.scale[1] & v[2,*] *= self.scale[2]
     if n_elements(verts) eq 0 then verts = v else $
        verts = [[verts], [v]]
     nv = n_elements(v[0,*])
     ind = lindgen(n_elements(c)/4)*4
     c[ind+1] += offset
     c[ind+2] += offset
     c[ind+3] += offset
     offset += nv
     conn = append(conn, c)
     new = byte(rebin([col, 255*a], 4, nv))
     if n_elements(colors) eq 0 then colors = new $
     else colors = [[colors], [new]]
     self.model->remove, o
  endfor
  if n_elements(verts) eq 0 then return
    self.merged = obj_new('idlgrpolygon', verts, poly = conn, $
                        vert_colors = colors)
  self.model->add, self.merged
  self->updatePolys
end

pro dg_iso::set_substruct, index, substruct, force = force
  old = *self.substructs[index]
  if ~keyword_set(force) && array_equal(substruct, old) then return
  self.is_merged = 0
  self.model->remove, self.merged
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

  ;- trying something new here: 
  ;- isosurfacing on the data produces a cleaner surface
  ;- than working with a binary mask. However, if all id's 
  ;- don't belong to a single structure hierarchy, there is 
  ;- no unique level to isosurface on. We should test for this and 
  ;- correct in the future.
  if min(range) le 1 then return, obj_new()
  cube = fltarr(range[0], range[1], range[2])
  cube[(*ptr).x - lo[0], (*ptr).y - lo[1], (*ptr).v - lo[2]] = (*ptr).t
  nanswap, cube, 0
  mask = bytarr(range[0], range[1], range[2])
  mask[x,y,z] = 1
  mask_0 = mask

  lev = min((*ptr).t[ind], /nan)

  ;- include neighboring, low-level emission
  ;- will make the isosurface smoother
  mask or= (cube lt lev)
  bad = where(~mask, ct)
  
  if ct ne 0 then mask[bad] = lev / 10.

  ;-cube to surface
  if size(cube, /n_dim) ne 3 then return, obj_new()
;  isosurface, cube, lev, v, c
  isosurface, mask_0, lev, v, c

  if size(v, /n_dim) ne 2 then return, obj_new()
  v[0,*] += lo[0] & v[1,*] += lo[1] & v[2,*] += lo[2]
  o = obj_new('idlgrpolygon', v, poly = c, _extra = extra)
  return, o
  
  ;- surface to polygon
  cube[x, y, z] = (*ptr).t[ind]
  lo2 = min(cube) & hi2 = max(cube)
  rgb = bytarr(256, 3)
  rgb[*,0] = extra.color[0]
  rgb[*,1] = extra.color[1]
  rgb[*,2] = extra.color[2]

  struct = max(id)
  val = (*ptr).height[struct]
  val = (val - lo2) / (hi2 - lo2) * 255
  alpha = byte(50 * exp(-(indgen(256) - val)^2 / 75))
  plot, alpha
  o = obj_new('idlgrvolume', bytscl(cube), $
              rgb_table0 = rgb, opacity_table0=alpha, $
              /interpolate, hint=3, /light)
  m = obj_new('idlgrmodel')
  t = [[1.,0,0,lo[0]], [0,1,0,lo[1]], [0,0,1,lo[2]],[0,0,0,1]]
  m->setProperty, tran=t
  m->add, o
  return, m
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
  if size(super, /tname) eq 'STRUCT' && self.listener gt 0 then $
     widget_control, self.listener, $
                     send_event = create_struct(super, name='DG_ISO_EVENT')
  
  return, 1
end

function dg_iso::init, ptr, color = color, alpha = alpha, title = title, listener = listener, $
                  _extra = extra
  junk = self->dg_client::init(ptr, listener, color = color, alpha = alpha)

  sz = (*ptr).sz
  xra = [0,sz[1]]
  yra = [0,sz[2]]
  zra = [0,sz[3]]
  self.scale = [1., 1., 1. * (sz[1] + sz[2]) /2. / sz[3]]
  model = obj_new('idlgrmodel')

  self.xcen = mean(xra) & self.ycen = mean(yra) & self.zcen = mean(zra)
  sz = [0, xra[1], yra[1], zra[1]]
  
  zra = [min([xra, yra, zra], max=hi), hi]
  zra += 2*range(zra) * [-1,1]
  zra = reverse(zra)

  ;- lights
  l1 = obj_new('idlgrlight', type = 2, loc = [sz[1], sz[2], 2*sz[3]], $
               color=[255,255,255], inten=.7)
  l2 = obj_new('idlgrlight', type = 0, inten = 0.5, $
               color = [255,255,255])
  l3 = obj_new('idlgrlight', type = 2, loc = [-sz[1], -sz[2], -2*sz[3]], inten=.7)
  sz[1:3] *= self.scale
  ;- axes
  for i = 0, 3, 1 do begin
     self.axes[i] = obj_new('idlgraxis', 0, range=[0, sz[1]], $
                            loc=[0, sz[2] * (i / 2), sz[3] * (i mod 2)], maj=0, min=0, $
                            thick=2, /exact, color=[255,255,255])
     
     self.axes[4 + i] = obj_new('idlgraxis', 1, range=[0, sz[2]], $
                                loc=[sz[1] * (i/2), 0, sz[3] * (i mod 2)], maj=0, min=0, $
                                thick=2, /exact, color=[255,255,255])

     self.axes[8 + i] = obj_new('idlgraxis', 2, range=[0, sz[3]], thick=2, $
                                loc=[sz[1] * (i/2), sz[2] *(i mod 2), 0], maj=0, min=0, /exact, $
                               color=[255,255,255])
     model->add, self.axes[i]
     model->add, self.axes[4+i]
     model->add, self.axes[8+i]
  endfor
  self.axes[0]->setProperty, title=obj_new('idlgrtext', 'X', color=[255,255,255])
  self.axes[4]->setProperty, title=obj_new('idlgrtext', 'Y', color=[255,255,255])
  self.axes[8]->setProperty, title=obj_new('idlgrtext', 'Z', color=[255,255,255])

  model->add, l1
  model->add, l2
  model->add, l3

  result = self->interwin::init(model, $
                                bgcolor=byte([20, 20, 20]), $
                                xra = xra, yra = yra, zra = zra, $
                                _extra = extra, /rotate, $
                                title=keyword_set(title) ? title : 'Isosurfaces')
  self->set_rotation_center, sz[1:3]/2.
  return, 1
end

pro dg_iso::cleanup
  for i = 0, 11, 1 do begin
     self.axes[i]->getProperty, title = text
     obj_destroy, text
     obj_destroy, self.axes[i]
  endfor
  obj_destroy, [self.sub_isos, self.axes, self.merged]
  self->interwin::cleanup
  self->dg_client::cleanup
end
  
pro dg_iso__define
  data = {dg_iso, $
          inherits interwin, $
          inherits dg_client, $
          sub_isos: objarr(8), $
          axes:objarr(12), $
          xcen:0., ycen:0., zcen:0., $
          merged:obj_new(), is_merged:0B, $
          scale:[1., 1., 1.]}
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
  
