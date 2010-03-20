;+
; PURPOSE:
;  This procedure constructs synthetic luminosity functions via Monte
;  Carlo simulation. It does so by selecting according to an IMF and
;  star formation rate. It then calculates absolute magnitudes for
;  these stars according to evolutionary models (see details in the
;  function mass2mag), and creates an absolute magnitude histogram.
;
; CATEGORY:
;  Stellar evolution
;
; CALLING SEQUENCE:
;  lumfunc, [filter = filter, /noturn, maxage = maxage, 
;            minage = minage, nstars = nstars, output = output, 
;            /plot, /help, ps = ps]
;
; KEYWORD PARAMETERS:
;  filter: One of grizyjk to indicate which photometric band 
;          to calculate the luminosity function in. Default is 'i'.
;          Z and Y are interpolated from the values for i and j.
;
;  noturn: Set to force the imf to follow a m^-2.35 relation for all
;           masses, instead of turning over at low masses (see imf.pro
;           for details)
;
;  maxage: The maximum age, in Gyr, of the distribution from which
;           stars are drawn. Default is 10 Gyr
;
;  minage: The minimum age, in Gyr, of the distribution from which
;           stars are drawn. Default is .01 Gyr
;
;  nstars: The number of stars in the simulation. Default is 3M
;
;  output: The name of the output file into which the absolute
;           magnitude histogram is saved (via the SAVE
;           procedure). The procedure saves two variables into this 
;           file: mabs and phi. These are the x and y values for
;           the luminosity function histogram. 
;           Default is '~/lumfunc.[filter].sav'. 
;
;  plot: Set to plot the histogram.
;
;  help: Print the calling sequence and exit. 
;
;  ps: Output the file to a ps file (filename = value of keyword)
;
; SEE ALSO:
;  mass2mag, imf
;
; TODO:
;  -Allow for a more general star formation history
;  -Expand number of possible colors
;  -Expand mass range. For nstars < 3d6, there seem to be no stars
;  running up against the 10 solar mass wall. However, we may want
;  that at some point. This requires finding stellar evolution models
;  at this range.
;
; MODIFICATION HISTORY:
;  May 2009: Written by Chris Beaumont
;-
pro lumfunc, masses, ages, $
             filter = filter, $
             noturn = noturn, $
             maxage = maxage, $
             minage = minage, $
             nstars = nstars, $
             output = output, $
             plot = plot, $
             ps = ps, $
             help = help

compile_opt idl2
on_error, 2

  if keyword_set(help) then begin
     print, 'lumfunc calling sequence:'
     print, 'lumfunc, [filter = [v,r,or i], '
     print, '          /noturn, '
     print, '          minage = minage (Gyr), '
     print, '          maxage = maxage (Gyr),'
     print, '          nstars = nstars, output = output,'
     print, '          /plot, /help'
     return
  endif
  

 ;- run parameters
  if ~keyword_set(nstars) then nstars = 3d6
  if ~keyword_set(minage) then minage = .01
  if ~keyword_set(maxage) then maxage = 10
  if ~keyword_set(filter) then filter = 'i'
  case(filter) of 
     'v':
     'r':
     'i':
     'z':
     'y':
     'j':
     'k':
     else: message, 'filter must be one of v,r,i,z,y,j,k'
  endcase
  if ~keyword_set(output) then output='~/pro/lumfunc.'+filter+'.sav'

  ;-set up arrays
  masses = dblarr(nstars)
  ages = dblarr(nstars)

  ;-mass cdf
  masses = findgen(3d3) / 1d2 + 1d-2 ;- runs from .01 to 10 Msolar
  imf = imf(masses, noturn = noturn)
  mass_x = masses
  mass_cdf = total(imf, /cumul) / total(imf)
  
  ;- random number generation
  rand1 = randomu(seed, nstars)
  rand2 = randomu(seed, nstars)

  ages = minage + rand1 * (maxage - minage)
  masses = interpol(mass_x, mass_cdf, rand2)
  
  ;- calculate absolute magnitudes
  mag = mass2mag(masses, ages, filter=filter)

  ;-bin results and save
  phi = histogram(mag, loc = mabs, binsize = .5, /nan)
  phi = convol(1D * phi, [.1, .3, .8, .3, .1])

  phi /= total(phi)
  save, mabs, phi, file = output
  
  ;- look at results
  if keyword_set(ps) then begin
     set_plot, 'ps'
     device, file=ps, /color, /land, /encapsulated, yoff = 9.5, /in
     thick = 3
     thin = 1.5
     charsize = 1.5
  endif else begin
     thick = 2
     thin = 1
     charsize = 2
  endelse

  if keyword_set(plot) || keyword_set(ps) then begin
     plot, mabs, phi / max(phi), yra = [0,1.15], psym = 10, thick = thick, $
           title = 'Luminosity Function', xtit = textoidl('M_{abs}'), $
           ytit = textoidl('\Phi(M)'), charsize = charsize, xra = [-5, 30], $
           /xsty, /ysty, charthick = thick

     if filter ne 'r' then goto, finish
     xyouts, 15, 1, 'Model (this work)', charsize = charsize, charthick = thick
     xyouts, 15, .9, 'Empirical (Bochanski 2009)', color = fsc_color('crimson'), $
             charsize = charsize, charthick = thick
  ;-overplot bochanski empirical luminosity function
     val = [3, 2.1, 2, 2.1, 3, 3.5, 4, $
            5.2, 6.5, 7, 6.8, 5.8, $
            4.2, 3, 2.5, 2.8, 1.8, 1.5, $
            1, 1.8, .8, 1.5]
     val /= max(val)
     mag = findgen(n_elements(val)) / 2. + 6.5
     oplot, mag, val, color = fsc_color('crimson'), psym = 10, thick = thick

     finish:
     if keyword_set(ps) then begin
        device, /close
        set_plot, 'x'
     endif
  endif
end
