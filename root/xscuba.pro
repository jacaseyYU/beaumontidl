pro xscuba_event, event

  widget_control, event.top, get_uvalue = infoptr
  widget_control, event.id, get_uvalue = id
  info = *infoptr

  if id eq 'wav' then begin
     info.wavelength_val = event.index
  endif

  widget_control, info.weather, get_value  = weather
  widget_control, info.speed, get_value = speed
  widget_control, info.noise, get_value = noise
  widget_control, info.airmass, get_value = airmass
  widget_control, info.distance, get_value = distance

     
  s2_itc, mapsize = 1., band = weather, um450 = (info.wavelength_val eq 0), am = airmass/10., $
          sigma = noise, out_time = time, /silent

  ;- special case: change the rate, want the noise
  if id eq 'spe' then begin
     new_rate = 3600 / time
     new_noise = noise * (float(speed) / new_rate)^.5
     print, new_rate, new_noise
     widget_control, info.noise, set_value = string(new_noise, format='(e0.1)')
     noise = new_noise
  endif else begin
     widget_control, info.speed, set_value = string(3600/time, format='(e0.2)')
  endelse

  s2_f2m, flux = noise, distance = distance, temperature = 20, $
          um450 = (info.wavelength_val eq 0), $
          outmass = mass, outcol = col, outav = av
  nl = string(10B)
  output  =string(mass, format='(e0.1)')+ ' M_solar / beam' + NL
  output +=string(col, format='(e0.1)')+' H2 / cm^2'+NL
  output +=string(av, format='(f0.1)')+' Av'
  widget_control, info.sensitivity, set_value=output

  widget_control, event.top, set_uvalue = ptr_new(info)
end


pro xscuba

tlb = widget_base(column = 1, title = 'SCUBA-2 Integration Time Calculator', $
                 xsize = 400, ysize = 340)

row1 = widget_base(tlb, row = 1)
row2 = widget_base(tlb, row = 1)
row3 = widget_base(tlb, row = 1)
row4 = widget_base(tlb, row = 1)
row5 = widget_base(tlb, row = 1)
row6 = widget_base(tlb, row = 1)
row7 = widget_base(tlb, row = 1)

wid = 120
height = 5
wavelength_label = widget_label(row1, value='Wavelength', xsize = wid, /align_right)
airmass_label = widget_label(row2, value = 'Airmass', xsize = wid, /align_right)
weather_label = widget_label(row3, value='Weather Band', xsize = wid, /align_right)
noise_label = widget_label(row4, value='Noise (mJy)', xsize = wid, /align_right)
speed_label = widget_label(row5, value='Speed (arcmin/hr)', xsize=wid, /align_r)
distance_label = widget_label(row6, value = 'Distance (pc)', xsize = wid, /align_r)
sensitivity_label = widget_label(row7, value='1-sigma Sensitivity', xsize = wid, /align_r)

wavelength_value = widget_droplist(row1, value=['450','850'], uvalue='wav')
airmass_value = widget_slider(row2, minimum = 10, maximum = 50, uval='air')
weather_value = widget_slider(row3, min = 1, max = 4, uval='wea')
noise_value = widget_text(row4, value = '10', /edit, uval='noi')
speed_value = widget_text(row5, value = '', /edit, uval='spe')
distance_value = widget_text(row6, value='100', /edit, uval = 'dis')
sensitivity_info = widget_label(row7, value='', uval = 'sen', ysize = .5 * wid, $
                              xsize = 1.5 * wid, /align_l)

widget_control, tlb, /realize

info = {wavelength: wavelength_value, airmass: airmass_value, $
        weather: weather_value, noise: noise_value, speed:speed_value, $
        distance:distance_value, sensitivity:sensitivity_info, $
        wavelength_val : 0}
widget_control, tlb, set_uvalue = ptr_new(info, /no_copy)

scuba2, /silent
xmanager, 'xscuba', tlb, event = 'xscuba_event'
end
