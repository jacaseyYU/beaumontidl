pro s2_f2m, flux = flux, distance = distance, kappa = kappa, $
            temperature = temperature, um450 = um450, um850 = um850, $
            silent = silent, outmass = outmass, outcol = outcol, outav = outav

  compile_opt idl2
  on_error, 2

  if ~keyword_set(silent) then begin
     print, '***********************************'
     print, 'SCUBA 2 Flux to Mass converter'
     print, '***********************************'
  endif

  ;- set observing wavelength
  if ~keyword_set(um450) && ~keyword_set(um850) then begin
     print, 'Assuming 850 micron observations'
     um450 = 0
  endif else if keyword_set(um450) && keyword_set(um850) then $
     message, 'Cannot set both um450 and um850'

  ;- set temperature
  if ~keyword_set(temperature) then begin
     temperature = 20.
  endif else temperature = double(temperature)

  ;- set distance
  if ~keyword_set(distance) then begin
     distance = 1000.
  endif else distance = double(distance)

  ;- set opacity
  if ~keyword_set(kappa) then begin
     lambda = um450 ? 450. : 850.
     kappa = mass_opacity(lambda)
  endif else kappa = double(kappa)

  ;- set flux
  if ~keyword_set(flux) then begin
     flux = 1.
  endif else flux = double(flux)

  ;- get planck value
  h = apcon('h')
  k = apcon('k')
  c = apcon('c')
  T = temperature
  nu = c / (um450 ? 450d-4 : 850d-4)
  b = 2 * h * nu^3 / c^2 * 1 / (exp(h * nu / (k * T)) - 1)
  ;b = 2 * k * T * nu^2 / c^2

  ;- get beamsize
  beamsize = keyword_set(um450) ? 32D : 120D
  beamsize = beamsize * (distance / 206265D)^2

  ;- convert to mass in solar masses
  mass = flux * 1d-3 * apcon('jy') * (distance * apcon('pc'))^2 / (kappa * b)
  mass /= apcon('m_solar')

  outmass = mass
  surface_density = mass / beamsize ;- solar masses per square parsec
  mol_mass = 2.36
  h2_frac = 4.5 / 5.5
  ;- particle density in cm^-2
  outcol = surface_density  / apcon('pc')^2 * apcon('m_solar') / (mol_mass * apcon('m_proton'))
  ;- h2 density in cm^-2
  outh2 = outcol * h2_frac
  ;- convert from NH2 cm^-2 to Av
  outav = outh2 / 1.9d21

  if ~keyword_set(silent) then begin
     print, '***********************'
     print, ' Distance (pc)          :'+string(distance, format='(e0.1)')
     print, ' Flux (mJy)             :'+string(flux, format='(f0.2)')
     print, ' Kappa (cm^2/g)         :'+string(kappa, format='(f0.3)')
     print, ' Temp (K)               :'+string(T ,format='(f0.1)')
     print, ' Beamsize (pc^2 / beam) :'+string(beamsize, format='(e0.1)')
     print, ''
     print, ' MASS (Msol)   :'+string(mass, format='(e0.1)')
  endif
end


pro s2_itc, mapsize = mapsize, nefd = nefd, band = band, nbol = nbol, $
            um450 = um450, um850 = um850, am = am, sigma = sigma, $
            out_time = out_time, silent = silent
  
  compile_opt idl2
;  on_error, 2

  if ~keyword_set(silent) then begin
     print, '************************************'
     print, 'SCUBA 2 Integration Time Calculator'
     print, '************************************'
  endif

  ;- set observing wavelength
  if ~keyword_set(um450) && ~keyword_set(um850) then begin
     if ~keyword_set(silent) then print, 'Assuming 850 micron observations'
     um450 = 0
  endif else if keyword_set(um450) && keyword_set(um850) then $
     message, 'Cannot set both um450 and um850'
  
  ;- set AM
  if ~keyword_set(am) then begin
     if ~keyword_set(silent) then $
        print, 'AM not provided. Assuming Airmass = 1'
     am = 1.
  endif

  ;- set tau
  if ~keyword_set(tau) then begin
     if ~keyword_set(band) then begin
        if ~keyword_set(silent) then $
           print, 'No tau provided. Assuming grade 3 weather'
        band = 3
     endif
     case band of
        1: tcso = .040
        2: tcso = .065
        3: tcso = .100
        4: tcso = .150
        else: message, 'band must be 1-4'
     endcase
     tau = um450 ? 20 * (tcso - .01) : 4.02 * (tcso - .001)
  endif 

  ;- set nefd
  if ~keyword_set(nefd) then begin
     if ~keyword_set(band) then $
        message, 'Must supply NEFD (mJy root[s]) or band (1-4)'
     case band of
        ;- expected zenith NEFDs from 
        ;- http://www.jach.hawaii.edu/JCMT/continuum/scuba2_integration_time_calc.html
        1 : nefd = um450 ? 100. : 50.
        2 : nefd = um450 ? 220. : 55.
        3 : nefd = um450 ? 550. : 70.
        4 : nefd = um450 ? 5500. : 90.
        else: message, 'band must be 1-4'
     endcase
  endif
  nefd *= exp((am - 1) * tau)
  print, nefd

  ;- set mapsize
  if ~keyword_set(mapsize) then begin
     if ~keyword_set(silent) then $
        print, 'mapsize not provided. Assuming 10 square arcminutes'
     mapsize = 10.
  endif

  ;- set bolometer number
  if ~keyword_set(nbol) then $
     nbol = um450 ? 700. : 400.

  ;- set noise level
  if ~keyword_set(sigma) then begin
     if ~keyword_set(silent) then $
        print, 'map noise not provided. Assuming 10 mJy'
     sigma = 10.
  endif

  ;- set overhead
  overhead = 1.

  ;- set bolometer size
  bolsize = um450 ? 32. : 120. 
  bolsize /= 3600.


  tmap = (1 + overhead) * mapsize / (nbol * bolsize) * (nefd / sigma)^2
  out_time = tmap
  ;- print output
  if ~keyword_set(silent) then begin
     print, '********************************'
     print, ' Wavelength          :'+ (um450 ? '450 um' : '850 um')
     print, ' Mapsize (arcmin^2)  :'+ string(mapsize, format='(f0.2)')
     print, ' Tau                 :'+ string(tau, format='(f0.3)')
     print, ' Airmass             :'+ string(am, format='(f0.1)')
     print, ' Map Noise (mJy/beam):'+ string(sigma, format='(f0.1)')
     print, ' INTEGRATION TIME    :'+ time2string(tmap)
  endif
end

pro scuba2, silent = silent
  if ~keyword_set(silent) then begin
     print, 'available routines:'
     print, '   s2_itc (integration time calculator)'
     print, '   s2_f2m (flux to mass converter)'
  endif
end
