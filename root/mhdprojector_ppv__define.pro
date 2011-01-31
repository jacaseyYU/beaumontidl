pro mhdProjector_ppv::updateIndices
  
  self.validIndices = 1B
  return
  sim = self.mhdRT->getSim()
  s_sz = size(sim->getN())
  o_sz = [3, sxpar(*self.header, 'naxis1'), $
          sxpar(*self.header, 'naxis2'), $
          sxpar(*self.header, 'naxis3')]
  
  ptr_free, [self.o2s, self.s2o]
  
  o2s = objarr(o_sz[1], o_sz[2], o_sz[3])
  s2o = lonarr(s_sz[1], s_sz[2], s_sz[3])
  o_inds = ulindgen(o_sz[1], o_sz[2], o_sz[3])
  s_inds = ulindgen(s_sz[1], s_sz[2], s_sz[3])

  ;- build s2o
  vx = sim->getVx()
  vy = sim->getVy()
  vz = sim->getVz()
  self->applyTransform, vx, vy, vz, 0, 0, vr
  indices, o2s, x0, y0, z0
  self->applyTransform, x0, y0, z0, x, y, z
  advxyz, *self.header, x, y, vr, a, d, v
  s2o = o_inds[a,d,v]
  
  ;- build o2s
  ;- XXX can't do this with objects -- way too much overhead
end  


  

function mhdProjector_ppv::projectMask, mask
  if ~self.validIndices then self->updateIndices

  s_sz = size(mask)
  
  sim = self.mhdRT->getSim()
  vx = sim->getVx()
  vy = sim->getVy()
  vz = sim->getVz()

  sz0 = size(vx)

  if s_sz[0] ne 3 || ~array_equal(s_sz[0:3], sz0[0:3]) then $
     message, 'mask has incorrect size'

  mask = (mask ne 0)

  ;- project pixel centers in obs space to sim space
  result = bytarr(sxpar(*self.header, 'naxis1'), $
              sxpar(*self.header, 'naxis2'), $
              sxpar(*self.header, 'naxis3'))
  indices, result, x0, y0, z0
  o_sz = size(im)

  xyzadv, *self.header, x0, y0, z0, a, d, v
  self->applyTransform, a, d, v, x, y, z, /back
  self->applyTransform, vx, vy, vz, 0, 0, vr

  for i = 0, o_sz[3] - 1, 1 do begin     
     vchunk = reform(v[*,*,i])
     xchunk = reform(x[*,*,i])
     ychunk = reform(y[*,*,i])
     if i eq 0 then indices, ychunk, xplane, yplane

     for j = 0, s_sz[3] - 2, 1 do begin
        v0 = vr[xchunk, ychunk, xchunk * 0 + j]
        v1 = vr[xchunk, ychunk, ychunk * 0 + j + 1]
        cross = (v0 - vchunk) * (v1 - vchunk) lt 0
        hit = where(cross, ct)
        if ct eq 0 then continue
        result[xplane[hit], yplane[hit], i] or= $
           mask[xchunk[hit], ychunk[hit], xchunk[hit]*0+j]
     endfor
  endfor
  bad = where(x lt 0 or x ge s_sz[1] or $
              y lt 0 or y ge s_sz[2] or $
              z lt 0 or z ge s_sz[3], ct)
  if ct ne 0 then result[bad] = 0
  
  return, result
end

function mhdProjector_ppv::deProjectMask, mask
  if n_params() ne 1 then begin
     print, 'calling sequence'
     print, ' result = obj->deProjectMask(mask)'
     return, !values.f_nan
  endif
  if ~self.validIndices then self->updateIndices

  sz = size(mask)
  if sz[0] ne 3 || $
     sz[1] ne sxpar(*self.header, 'naxis1') || $
     sz[2] ne sxpar(*self.header, 'naxis2') || $
     sz[3] ne sxpar(*self.header, 'naxis3') then $
        message, 'Mask size is incorrect'

  ;- project simulation pixel centers into observation space
  sim = self.mhdRT->getSim()
  vx = sim->getVx()
  vy = sim->getVy()
  vz = sim->getVz()
  self->applyTransform, vx, vy, vz, 0, 0, vr
  indices, vr, x0, y0, z0
  self->applyTransform, x0, y0, z0, x, y, z
  advxyz, *self.header, x, y, vr, a, d, v

  result = mask[a, d, v]
  hit = where(a lt 0 or a ge sz[1] or $
              d lt 0 or d ge sz[2] or $
              v lt 0 or d ge sz[3], ct)
  if ct ne 0 then hit[bad] = 0

  return, result  
end


function mhdProjector_ppv::simulateObs, mask = mask
  if ~self.validIndices then self->updateIndices

  sim = self.mhdRT->getSim()
  vx = sim->getVx()
  sz0 = size(vx)

  hasMask = keyword_set(mask)
  if keyword_set(mask) then begin
     sz = size(mask)
     if sz[0] ne 3 || $
        sz[1] ne sz0[1] || sz[2] ne sz0[2] || sz[3] ne sz0[3] then $
           message, 'Mask size is incorrect'
  endif

  j = self.mhdRT->computeJ()
  k = self.mhdRT->computeK()

  message, 'not implemented!'
  return, !values.f_nan
end



pro mhdProjector_ppv__define
  data = {mhdProjector_ppv, $
          inherits mhdProjector, $
          s2o:ptr_new(), $
          o2s:ptr_new() }
end
