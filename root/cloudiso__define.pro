;+
; CLASS NAME:
;  cloudiso
;
; PURPOSE:
;  This is a visualization module in the cloudviz/dendroviz
;  library. It visualizes cloud substructures by rendering them as 3D
;  isosurfaces
;
; CATEGORY:
;  cloudviz, visualization
;
; SUPERCLASSES:
;  cloudviz_client, interwin
;
; SUBCLASSES:
;  none
;
; CREATION:
;  See cloudiso::init
;
;-


;+
; PURPOSE:
;  Processes widget events
;
; INPUTS:
;   event: A standard widget event structure
;
; OUTPUTS:
;  0
;-
function cloudiso::event, event
  super = self->interwin::event(event)
  if event.id eq self.slider then begin
     widget_control, self.base, /hourglass
     s = self.hub->getCurrentStructure()
     i = self.hub->getCurrentID()
     self->notifyStructure, i, s, /force
  endif else if event.id eq self.scale_slider then begin
     widget_control, self.scale_slider, get_value = val
     widget_control, self.scale_form, set_value = strtrim(val, 2)
     self.scale[2] = val
     self->mergeIsos
  endif else if event.id eq self.scale_form then begin
     widget_control, self.scale_form, get_value = val
     val = float(val)
     widget_control, self.scale_slider, set_value = val
     self.scale[2] = val
     self->mergeisos
  endif

  if size(super, /tname) eq 'STRUCT' then self.hub->receiveEvent, super

;  self->update_axes

  return, 0
end


;+
; PURPOSE:
;  Used by the hub to notify this mudle about a new substructure to
;  visualize.
;
; INPUTS:
;  index: The index (0-7) of the structure to render
;  structure: The list of structure IDs to assign to substructure
;  INDEX
;
; KEYWORD PARAMETERS:
;  force: If not set, do not update the display. We do this because
;         recalculating the isosurfaces is expensive.
;-
pro cloudiso::notifyStructure, index, structure, force = force
  if ~keyword_set(force) then return

  self->recalculateIso, index, structure
  self->mergeIsos
  self->request_redraw
end


;+
; PURPOSE:
;  Updates the isosurfaces to be rendered
;
; INPUTS:
;  index: Which isosurface (0-7) to update
;  structure: The structure IDs that will be assigned to this
;  isosurface
;-
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


;+
; PURPOSE:
;  Merge the 8 individual isosurfaces into a single IDLgrPolygon
;  object. This is needed to prevent rendering artifacts, since IDL is
;  bad at choosing which order to render and blend 3D images
;-
pro cloudiso::mergeIsos
  offset = 0L
  self.model->remove, self.merged
  obj_destroy, self.merged
  for i = 0, self.ncolor-1 do begin
     o = self.sub_isos[i]
     if ~obj_valid(o) then continue
     o->getProperty, color = col, alpha = a, data = v, poly = c

     cen = self.sz / 2
     v[0,*] = (v[0,*] - cen[0]) * self.scale[0] + cen[0]
     v[1,*] = (v[1,*] - cen[1]) * self.scale[1] + cen[1]
     v[2,*] = (v[2,*] - cen[2]) * self.scale[2] + cen[2]

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


;+
; PURPOSE:
;  Used by the hub to tell this module which isosurface is currently
;  being edited
;-
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

pro cloudiso::set_zscale, scale
  self.scale[2] = scale
end

function cloudiso::init, hub, zscale = zscale, _extra = extra
  if ~self->cloudviz_client::init(hub, _extra = extra) then return, 0

  ptr = hub->getData()
  sz = size((*ptr).cluster_label)
  if sz[0] ne 3 then $
     message, 'Data within hub is not a 3D cube'

  self.sz = sz[1:3]
  ;- determine bounding box
  xra = [0, sz[1]]
  yra = [0, sz[2]]
  zra = [0, sz[3]]

  self.scale = [1., 1., 1. * (sz[1] + sz[2]) /2. / sz[3]]
  if keyword_set(zscale) then self.scale[2] = zscale

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
  self.widget_base = self.base
  self->set_rotation_center, sz[1:3]/2.
  self.slider = cw_fslider(self.base, min = 0., max = 1., value = 0.0)
  default_stretch = 1.0
  row = widget_base(self.base, /row)
  self.scale_slider = cw_fslider(row, min = 0, max = 2.0, $
                                 value = default_stretch)
  self.scale_form = widget_text(row, /edit, value = strtrim(default_stretch, 2))
  self.slider_val[*] = 0.0
  return, 1
end

pro cloudiso__define
  data = {cloudiso, $
          inherits cloudviz_client, $
          inherits interwin, $
          sub_isos:objarr(30), $
          slider_val:fltarr(30), $
          axes:objarr(12), $
          xcen:0., ycen:0., zcen:0., $
          merged:obj_new(), $
          scale:[1., 1., 1.], $
          slider:0L, $
          scale_slider:0L, $
          scale_form:0L, $
          sz: lonarr(3) $
         }
end
