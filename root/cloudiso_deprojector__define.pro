pro cloudiso_deprojector::recalculateiso, index, structure

  obj_destroy, self.sub_isos[index]
  ptr = self.hub->getData()

  ind = substruct(structure, ptr, /single)
  if n_elements(ind) lt 5 then return
  
  ;- create a cube
  mask = byte((*ptr).cluster_label) * 0B
  mask[ind] = 1B

  deproject = self.projectForwards ? $
              ppp2ppv_mask(mask, *self.vel, *self.vcen) : $
              ppv2ppp_mask(mask, *self.vel, *self.vcen)
  
  isosurface, deproject, 1, v, c
  color = self.hub->getColors(index)
  alpha = color[3]
  color = color[0:2]

  o = obj_new('idlgrpolygon', v, poly = c, color = color, alpha = alpha)
  self.sub_isos[index] = o
end
  
pro cloudiso_deprojector::cleanup
  ptr_free,[self.vel, self.vcen]
end

function cloudiso_deprojector::init, hub, vel, vcen, ppp2ppv = ppp2ppv
  if ~self->cloudiso::init(hub) then return, 0
  sz = size(vel)
  if sz[0] ne 3 then $
     message, 'vel is not a data cube!'
  if (size(vcen))[0] ne 1 then $
     message, 'vcen is not a 1D array!'

  self.vel = ptr_new(vel)
  self.vcen = ptr_new(vcen)

  self.projectForwards = keyword_set(ppp2ppv)
  title = keyword_set(ppp2ppv) ? 'PPP->PPV Projection' : $
          'PPV->PPP Deprojection'
  widget_control, self.slider, /destroy
  widget_control, self.base, base_set_title = title
  return, 1
end


pro cloudiso_deprojector__define
  data = {cloudiso_deprojector, $
          inherits cloudiso, $
          vel:ptr_new(), $
          vcen:ptr_new(), $
          projectForwards:0B $
         }
end
