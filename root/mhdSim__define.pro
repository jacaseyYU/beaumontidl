function mhdSim::getN
  return, *self.n
end

function mhdSim::getT
  return, *self.t
end

function mhdSim::getVx
  return, *self.vx
end

function mhdSim::getVy
  return, *self.vy
end

function mhdSim::getVz
  return, *self.vz
end

function mhdSim::getBx
  return, ptr_valid(self.bx) ? *self.bx : !values.f_nan
end

function mhdSim::getBy
  return, ptr_valid(self.by) ? *self.by : !values.f_nan
end

function mhdSim::getBz
  return, ptr_valid(self.bz) ? *self.bz : !values.f_nan
end

function mhdSim::getGridSize
  return, self.gridSize
end

pro mhdSim::cleanup
  ptr_free, [self.n, self.t, $
             self.vx, self.vy, self.vz, $
             self.bx, self.by, self.bz]
end

function mhdSim::init, n, t, vx, vy, vz, bx, by, bz, gridSize = gridSize, $
                       no_copy = no_copy
  
  if n_params() ne 1 then begin 
     print, 'calling sequence'
     print, "o = obj_new('mhdSim', n, t, vx, vy, vz, [bx, by, bz, "
     print, "                      gridSize = gridSize, /no_copy'])"
     return, 0
  endif

  sz = size(n)
  if sz[0] ne 3 then $
     message, 'density must be a 3D cube'
  self.sz = sz
  self.n = ptr_new(n, no_copy = no_copy)

  if ~array_equal(sz[0:3], (size(t))[0:3]) then $
        message, 't has incorrect size'
  self.t = ptr_new(t, no_copy = no_copy)
  
  if ~array_equal(sz[0:3], (size(vx))[0:3]) then $
     message, 'vx has incorrect size'
  self.vz = ptr_new(vx, no_copy = no_copy)
  
  if ~array_equal(sz[0:3], (size(vy))[0:3]) then $
     message, 'vy has incorrect size'
  self.vy = ptr_new(vy, no_copy = no_copy)
  
  
  if ~array_equal(sz[0:3], (size(vz))[0:3]) then $
     message, 'vz has incorrect size'
  self.vz = ptr_new(vz, no_copy = no_copy)
  
  
  if keyword_set(gridSize) then self.gridSize = gridSize $
  else self.gridSize = 1.

  doB = keyword_set(bx) + keyword_set(by) + keyword_set(bz)
  if doB ne 0 && doB ne 3 then $
     message, 'must provide 0 or 3 b keywords'

  if doB eq 0 then return, 1

  if ~array_equal(sz[0:3], (size(bx))[0:3]) then $
     message, 'bx has incorrect size'
  self.bx = ptr_new(bx, no_copy = no_copy)
  
  if ~array_equal(sz[0:3], (size(by))[0:3]) then $
     message, 'by has incorrect size'
  self.by = ptr_new(by, no_copy = no_copy)
  
  if ~array_equal(sz[0:3], (size(bz))[0:3]) then $
     message, 'bz has incorrect size'
  self.bz = ptr_new(bz, no_copy = no_copy)
  
  return, 1
end

pro mhdSim__define
  data = {mhdSim, $
          sz:lonarr(6), $
          n: ptr_new(), $
          t: ptr_new(), $
          vx:ptr_new(), $
          vy:ptr_new(), $
          vz:ptr_new(), $
          bx:ptr_new(), $
          by:ptr_new(), $
          bz:ptr_new(), $
          gridSize:0D $
         }
end
