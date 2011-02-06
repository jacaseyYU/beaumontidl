pro cloudiso_deprojector::recalculateiso, index, structure

  obj_destroy, self.sub_isos[index]
  ptr = self.hub->getData()

  ind = substruct(structure, ptr, /single)
  if n_elements(ind) lt 5 then return
  
  ;- create a cube
  mask = byte((*ptr).cluster_label) * 0B
  mask[ind] = 1B

  deproject = self.projector->deProjectMask(mask)
  
  isosurface, deproject, 1, v, c
  color = self.hub->getColors(index)
  alpha = color[3]
  color = color[0:2]

  o = obj_new('idlgrpolygon', v, poly = c, color = color, alpha = alpha)
  self.sub_isos[index] = o
end
  
function cloudiso_deprojector::init, hub, projector
  if ~self->cloudiso::init(hub) then return, 0
  if ~obj_valid(projector) || ~obj_isa(projector, 'mhdprojector_ppv') $ 
     then message, 'projector must be a mhdprojector_ppv object'
  self.projector = projector
  widget_control, self.slider, sensitive = 0
  widget_control, self.base, title = 'PPV->PPP Deprojector'
  return, 1
end


pro cloudiso_deprojector__define
  data = {cloudiso_deprojector, $
          inherits cloudiso, $
          projector:obj_new() $
         }
end
