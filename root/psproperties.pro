;+
; PURPOSE:
;  Returns a structure defining properties of the PS1 3-pi survey
;
;  Values from Dupuy 2008 and Onaka 2008. Beta defined in Mighell
;  2003, ASP Conference Series Vol 295
;-
function psproperties
  result = {fwhm: 0D, sky:dblarr(5), f0:dblarr(5), area:0D, time:dblarr(5), $
            read_noise:0D, pix_size:0D, beta:0D, ast_floor:0D}
  result.fwhm = .8              ;- seeing in arcseconds                                  
                                ;- sky BG in DN s^-1 m^-2 "^-2 
  result.sky= [6.9, 22.5, 48.7, 77.6, 89.6]
                                ;- 0 mag flux (DN s^-1 m^-2)
  result.f0= [4.73, 5.87, 5.55, 3.78, 1.85] * 1d9
                                ;- collecting area in m^2
  result.area= 1.73
                                ;- 3 pi survey exposure time
  result.time=[60D, 38, 30, 30, 30]
                                ;- read noise sigma in DN / pixel
  result.read_noise= 5.
                                ;- arcsec / pixel                                                
  result.pix_size= .26
                                ;- effective bg area for PSF fitting
                                ;  (square arcseconds)
  result.beta= 4 * !dpi * (result.fwhm / (2 * sqrt(2 * alog(2))))^2
                                ;- single-epoch astrometric floor, in arcseconds
  result.ast_floor= .01
  return, result
end


          
  
