function get_photcodes
  return, {photcode,$ 
           PSFMODEL         : '00000001'xul,$ ; Source fitted with a psf model (linear or non-linear)
           EXTMODEL         : '00000002'xul,$ ; Source fitted with an extended-source model
           FITTED           : '00000004'xul,$ ; Source fitted with non-linear model (PSF or EXT ; good or bad)
           FAIL             : '00000008'xul,$ ; Fit (non-linear) failed (non-converge'xul,$ off-edge'xul,$ run to zero)
           POOR             : '00000010'xul,$ ; Fit succeeds'xul,$ but low-SN'xul,$ high-Chisq'xul,$ or large (for PSF -- drop?)
           PAIR             : '00000020'xul,$ ; Source fitted with a double psf
           PSFSTAR          : '00000040'xul,$ ; Source used to define PSF model
           SATSTAR          : '00000080'xul,$ ; Source model peak is above saturation
           BLEND            : '00000100'xul,$ ; Source is a blend with other sourcers
           EXTERNAL         : '00000200'xul,$ ; Source based on supplied input position
           BADPSF           : '00000400'xul,$ ; Failed to get good estimate of objects PSF
           DEFECT           : '00000800'xul,$ ; Source is thought to be a defect
           SATURATED        : '00001000'xul,$ ; Source is thought to be saturated pixels (bleed trail)
           CR_LIMIT         : '00002000'xul,$ ; Source has crNsigma above limit
           EXT_LIMIT        : '00004000'xul,$ ; Source has extNsigma above limit
           MOMENTS_FAILURE  : '00008000'xul,$ ; could not measure the moments
           SKY_FAILURE      : '00010000'xul,$ ; could not measure the local sky
           SKYVAR_FAILURE   : '00020000'xul,$ ; could not measure the local sky variance
           BELOW_MOMENTS_SN : '00040000'xul,$ ; moments not measured due to low S/N
           BIG_RADIUS       : '00100000'xul,$ ; poor moments for small radius'xul,$ try large radius
           AP_MAGS          : '00200000'xul,$ ; source has an aperture magnitude
           BLEND_FIT        : '00400000'xul,$ ; source was fitted as a blend
           EXTENDED_FIT     : '00800000'xul,$ ; full extended fit was used
           EXTENDED_STATS   : '01000000'xul,$ ; extended aperture stats calculated
           LINEAR_FIT       : '02000000'xul,$ ; source fitted with the linear fit
           NONLINEAR_FIT    : '04000000'xul,$ ; source fitted with the non-linear fit
           RADIAL_FLUX      : '08000000'xul,$ ; radial flux measurements calculated
           SIZE_SKIPPED     : '10000000'xul,$ ; size could not be determined
           ON_SPIKE         : '20000000'xul,$ ; peak lands on diffraction spike
           ON_GHOST         : '40000000'xul,$ ; peak lands on ghost or glint
           OFF_CHIP         : '80000000'xul } ; peak lands off edge of chip
  
end
