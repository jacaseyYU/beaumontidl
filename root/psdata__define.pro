pro psdata__define
  data = {psdata, $
          l: 0D, b: 0D, $           ;- lon, lat in degrees
          pi: 0D, sigma_pi: 0D, $   ;- parallax and error in arcsec
          flux : fltarr(5), $       ;- flux in units of zero mag flux
          sigma_flux : fltarr(5), $ ;- flux errors
          mu : 0D, $
          mux: 0D, $
          muy: 0D, $
          sigma_mu: 0D $        ;- proper motions and error, in mas yr^-1. 
         }
end
