;+
; PURPOSE:
;  This function returns the sub-mm mass opacity, using data from
;  either Ossenkopf and Henning 1994 (A&A 291,943) for dense, corelike
;  material, or Li and Draine 2001 (ApJ 554:778-802) for the diffuse ISM. The units
;  are cm^2 g^-1.
;
; INPUTS:
;  The wavelength, in microns. Scalar or vector
;
; KEYWORD PARAMETERS: 
;  Model: Which model to use. 0 (default) uses the Ossenkopf, thin ice
;  mantle model, and n = 1d5 cm^-3. Models 1-2 use this model, with no
;  ice mantle and with thick ice mantles. Model 4 uses the Li and
;  Draine model appropriate for diffuse clouds.
;
; OUTPUTS:
;  opacity = kappa(wavelength), in cm^2 g^-1. Scalar or vector. For
;  wavelengths outside the range where data are available, NAN is returned.
;
; MODIFICATION HISTORY:
;  Feb 2009: Written by Chris Beaumont
;-
function mass_opacity, wavelength, model = model
  if n_params() ne 1 then begin
     print, ' calling sequence'
     print, ' kappa = mass_opacity(wavelength, [model = model, density = density])'
     print, '       model 0: Ossenkopf 1994, thin ice mantle. n=1d5 cm^-3 (DEFAULT)'
     print, '       model 1: Ossenkopf 1994, no ice mantle'
     print, '       model 2: Ossenkopf 1994, thick ice mantle'
     print, '       model 3: Li and Draine 2001 model. Diffuse ISM'
     return, !values.f_nan
  endif
  
  if ~keyword_set(model) then model = 0

  ;- do the Li and Draine case first
  if model eq 3 then begin 
     curve1 = 2.92d5 / 125. * wavelength^(-2.)
     curve2 = 3.58d4 / 125. * wavelength^(-1.68)     
     result = wavelength * !values.f_nan
     good = where(wavelength gt 20 and wavelength lt 700, ct)
     if ct ne 0 then result[good] = curve1[good]
     good = where(wavelength gt 700 and wavelength lt 1d4, ct)
     if ct ne 0 then result[good] = curve2[good]
  endif else begin
     readcol, '~/idl/data/ossenkopf_dust_opacity.tsv', $
              n, l1, k1, l2, k2, l3, k3, delim='|', comment='#', /silent
     case model of
        0 : kappa = k2
        1 : kappa = k1
        2 : kappa = k3
        else: message, 'model must be 0-3'
     endcase
     good = where(n eq 1d5)
     kappa = kappa[good] / 125.
     l = l1[good]
     result = interpol(kappa, l, wavelength)
  endelse
  return, result
end
