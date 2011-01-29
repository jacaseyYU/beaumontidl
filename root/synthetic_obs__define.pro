function synthetic_obs::project_mask, mask
end

function synthetic_obs::deproject_mask, mask
end

function synthetic_obs::synthesize_obs, mask = mask
end

function synthetic_obs::init, vx, vy, vz, k, j, dx, $
                              transform = transform, 
  return, 1
end


pro synthetic_obs::cleanup
  ptr_free, [self.vx, self.vy, self.vz, self.k, self.j]
end

pro synthetic_obs__define
  data = { vx: ptr_new(), $     ;- x velocity in sim
           vy: ptr_ne(), $      ;- y velocity in sim
           vz: ptr_new(), $     ;- z velocity in sim
           k: ptr_new(), $      ;- attenuation coeff at each point in sim
           j: ptr_new(), $      ;- emissivity at each point in sim
           dx: 0D, $            ;- cell size
           transform: fltarr(3, 3), $ ;- transformation matrix (from sim to obs)
           output_grid: fltarr(3,3) $ ;- each row gives min, max, step for one dim
         }
end
