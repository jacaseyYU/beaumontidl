pro mhdProjector::updateIndices
  message, 'function not implemented'
end

function mhdProjector::projectMask, mask
  message, 'Function not implemented'
end

function mhdProjector::deProjectMask, mask
  message, 'Function not implemented'
end

function mhdProjector::simulateObs, mask = mask
  message, 'Function not implemented'
end

function mhdProjector::init, sim, outHeader, rt = rt, transform = transform

  if ~keyword_set(transform) then transform = [[1., 0, 0], [0, 1., 0], [0, 0, 1]]
  sz = size(transform)
  if sz[0] ne 3 || sz[1] ne 3 || sz[2] ne 3 || sz[3] ne 3 then $
     message, 'transform must be a 3x3 array'

  if keyword_set(rt) && (~obj_valid(rt) || ~obj_isa(rt, 'mhdRT')
                             
  return, 1
end

pro mhdprojector::applyTransform, x0, y0, z0, x, y, z, back = back
  t = keyword_set(back) ? invert(self.transform) : self.transform
  x = x0 * t[0,0] + $
      y0 * t[0,1] + $
      z0 * t[0,2]

  y = x0 * t[1,0] + $
      y0 * t[1,1] + $
      z0 * t[1,2]

  z = x0 * t[2,0] + $
      y0 * t[2,1] + $
      z0 * t[2,2]
end

pro mhdProjector::setTransform, transform
  sz = size(transform)
  if sz[0] ne 3 || sz[1] ne 3 || sz[2] ne 3 || sz[3] ne 3 then $
     message, 'transform must be a 3x3 array'
  self.transform = transform
  self.validIndices = 0B
end

pro mhdProjector__define
  data = {mhdProjector, $
          mhdRT: obj_new(), $
          transform: fltarr(3,3), $
          header:ptr_new(), $
          s2o:ptr_new(), $
          o2s:ptr_new(), $
          validIndices:0B, $  
         }
end
