function cloudiso::event, event
  super = self->interwin::event(event)
  if event.id eq self.slider then begin
     s = self.hub->getCurrentStructure()
     i = self.hub->getCurrentID()
     self->notifyStructure, i, s, /force
  endif
  if size(super, /tname) eq 'STRUCT' then self.hub->receiveEvent, super

;  self->update_axes

  return, 0
end

pro cloudiso::notifyStructure, index, structure, force = force
  if ~keyword_set(force) then return
  
  self->recalculateIso, index, structure
  self->mergeIsos
  self->request_redraw
end

pro cloudiso::recalculateIso, index, structure
  obj_destroy, self.sub_isos[index]
  ptr = self.hub->getData()
  
  
  ind = substruct(structure, ptr, /single)
  if min(structure) lt 0 then return
  if n_elements(ind) lt 5 then return

  ;- create a cube
  sz = size((*ptr).cluster_label)
  ndim = [sz[1], sz[2], sz[3]]
  xyz = array_indices(ndim, ind, /dim)
  lo = min(xyz, dim = 2, max = hi, /nan)
  assert, n_elements(lo) eq 3
  range = hi - lo
  xyz[0,*] -= lo[0] & xyz[1,*] -= lo[1] & xyz[2,*] -= lo[2]
  cube = fltarr(range[0] > 2, range[1] > 2, range[2] > 2)
  cube[ xyz[0,*], xyz[1,*], xyz[2,*] ] = (*ptr).value[ind]
  nanswap, cube, 0

  ;- approximate the cdf of intensities
  r = floor(randomu(seed, 1000) * n_elements(ind))
  r = (*ptr).value[ind[r]]
  r = r[sort(r)]
  widget_control, self.slider, get_value = lev
  self.slider_val[index] = lev
  lev = r[0 > (lev * n_elements(r)) < (n_elements(r)-1)]
  
  ;- turn cube into isosurface
  if size(cube, /n_dim) ne 3 then return
  isosurface, cube, lev, v, c

  if size(v, /n_dim) ne 2 then return
  v[0,*] += lo[0] & v[1,*] += lo[1] & v[2,*] += lo[2]

  color = self.hub->getColors(index)
  alpha = color[3] / 255.
  color = color[0:2]
  o = obj_new('idlgrpolygon', v, poly = c, color = color, alpha = alpha)
  self.sub_isos[index] = o
end

pro cloudiso::mergeIsos
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
  endfor
  
  if n_elements(verts) eq 0 then return
  self.merged = obj_new('idlgrpolygon', verts, poly = conn, $
                        vert_colors = colors)
  self.model->add, self.merged
  self->updatePolys
end

pro cloudiso::notifyCurrent, id
  widget_control, self.slider, set_value = self.slider_val[id]
end

pro cloudiso::notifyColor, index, color
  if ~obj_valid(self.sub_isos[index]) then return
  self.sub_isos[index]->setProperty, color = color[0:2], $
                                        alpha = color[3]
  self->mergeIsos
end

pro cloudiso::run
  self->interwin::run
end

pro cloudiso::cleanup
  for i = 0, 11, 1 do begin
     self.axes[i]->getProperty, title = text
     obj_destroy, text
     obj_destroy, self.axes[i]
  endfor
  obj_destroy, [self.sub_isos, self.axes, self.merged]
  self->interwin::cleanup
  self->cloudviz_client::cleanup
end

function cloudiso::init, hub
  if ~self->cloudviz_client::init(hub) then return, 0

  ptr = hub->getData()
  sz = size((*ptr).cluster_label)
  if sz[0] ne 3 then $
     message, 'Data within hub is not a 3D cube'
  
  ;- determine bounding box
  xra = [0, sz[1]]
  yra = [0, sz[2]]
  zra = [0, sz[3]]
  
  self.scale = [1., 1., 1. * (sz[1] + sz[2]) /2. / sz[3]]
  self.xcen = mean(xra) & self.ycen = mean(yra) & self.zcen = mean(zra)

  zra = [min([xra, yra, zra], max=hi), hi]
  zra += 2 * range(zra) * [-1, 1]
  zra = reverse(zra)
  sz[1:3] *= self.scale

  model = obj_new('idlgrmodel')
  ;- light objects
  l1 = obj_new('idlgrlight', type = 2, loc = [sz[1], sz[2], 2*sz[3]], $
               color=[255,255,255], inten=.7)
  l2 = obj_new('idlgrlight', type = 0, inten = 0.5, $
               color = [255,255,255])
  l3 = obj_new('idlgrlight', type = 2, loc = [-sz[1], -sz[2], -2*sz[3]], inten=.7)
  model->add, l1
  model->add, l2
  model->add, l3
  
  ;- axis objects
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
  
  result = self->interwin::init(model, $
                                bgcolor=byte([20, 20, 20]), $
                                xra = xra, yra = yra, zra = zra, $
                                _extra = extra, /rotate, $
                                title=keyword_set(title) ? title : 'Isosurfaces')
  if ~result then return, 0
  self->set_rotation_center, sz[1:3]/2.
  self.slider = cw_fslider(self.base, min = 0., max = 1., value = 0.5)
  self.slider_val[*] = .5
  return, 1
end

pro cloudiso__define
  data = {cloudiso, $
          inherits cloudviz_client, $
          inherits interwin, $
          sub_isos:objarr(8), $
          slider_val:fltarr(8), $
          axes:objarr(12), $
          xcen:0., ycen:0., zcen:0., $
          merged:obj_new(), $
          scale:[1., 1., 1.], $
          slider:0L $
         }
end
