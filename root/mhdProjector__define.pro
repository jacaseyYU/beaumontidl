function mhdProjector::init, sim, outHeader, rt = rt, transform = transform

  if ~keyword_set(transform) then transform = [[1., 0, 0], [0, 1., 0], [0, 0, 1]]
  sz = size(transform)
  if sz[0] ne 3 || sz[1] ne 3 || sz[2] ne 3 || sz[3] ne 3 then $
     message, 'transform must be a 3x3 array'

  if keyword_set(rt) && (~obj_valid(rt) || ~obj_isa(rt, 'mhdRT')
                             
  return, 1
end
pro mhdProjector__define
  data = {mhdProjector, $
          mhdSim: obj_new(), $
          mhdRT: obj_new(), $
          transform: fltarr(3,3), $
          header:ptr_new() $
         }
end
