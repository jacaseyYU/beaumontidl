;+
; PURPOSE:
;  This procedure generates an estimate of the apriori distance
;  distribution of sources constrained to have a certain apparent
;  magnitude - i.e., P(d | mapp). It calculates this distribution 
;  using a synthetic luminosity function (calculated by lumfunc.pro), 
;  and includes the effect of the malmquist bias.
;
; CATEGORY:
;  population synthesis
;
; CALLING SEQUENCE:
;  apriori_distance, mapp, filter, [dist, prob, distcutoff = distcutoff, 
;                    lumfile = lumfile]
;
; INPUTS:
;  mapp: The apparent magnitude for which to calculate the apriori
;  distance distribution. 
;
;  filter: A single character naming the filter to use. Choices
;  include 'vrizyjk'
;
; KEYWORD PARAMETERS:
;  distcutoff: Set to a distance (in pc) beyond which stars are
;  assumed not to exist. Interior to this distance, stars are assumed
;  to be distributed uniformly in space.
;
;  lumfile: By default, the procedure restores the file
;  '~/pro/lumfunc.[filter].sav' to determine the luminosity
;  function. Set this keyword to manually specify the file. The file
;  is created by lumfunc.pro
;
; OUTPUTS:
;  dist: A variable into which the distances of the sampled apriori
;  distribution are stored. Note that the distribution is linear in
;  distance, but the returned values are spaced logarithmically. 
;
;  prob: A variable into which the probabilities of the sampled
;  apriori distribution are stored.
;
; SEE ALSO:
;  lumfunc
;
; MODIFICATION HISTORY:
;  May 2009: Written by Chris Beaumont
;  May 11 2009: Fixed a fundamental error in the probability calculation
;-                                                              
pro apriori_distance, mapp, filter, dist, prob, $
                           distcutoff = distcutoff, $
                           lumfile = lumfile, noplot = noplot

;- check arguments
if n_params() lt 2 then begin
   print, 'apriori_distance calling sequence:'
   print, ' apriori_distance, mapp, filter, [dist, prob '
   print, '                   distcutoff = distcutoff'
   print, '                   lumfunc = lumfunc]'
   return
endif

;- get luminosity function
if ~keyword_set(lumfile) then lumfile = '~/pro/lumfunc.'+filter+'.sav'
if ~file_test(lumfile) then message, 'Cannot find luminsoity function file: '+lumfile
print, lumfile
restore, lumfile ;- restores mabs, phi

;- extraploate phi for very bright objects to account for simulation
;  granularity
good = where(phi gt 0 and mabs gt -5 and mabs lt 0)
f = linfit(mabs[good], alog10(phi[good]))
;- add 10 bins to the left of the distribution
minabs = mabs[0]
step = mabs[1] - mabs[0]
new = minabs - (findgen(10)+1) * step
new = reverse(new)
mabs = [new, mabs]
phi = [new * 0, phi]
bad = where(mabs lt 0 and phi eq 0)
phi[bad] = 10^(f[0] + f[1] * mabs[bad])

if ~keyword_set(distcutoff) then distcutoff = 1d3 ;-pc
;- transform absolute magnitudes into distances
dist = 10^((mapp - mabs)/5) * 10
;- The transformation is VERY subtle, and assumes a constant stellar
;  density:
;  P(M) * n = d2N / dMdV
;  P(M) * n * dM/dD = d2N / dDdV
;                   ~ d2N / (dD * D^2 dD)
;  P(M) * n * D     ~ d2N / dD2
;  P(M) * n * D^2   ~ dN  / dD = P(D | mapp)
prob = phi * dist^2 * (dist lt distcutoff)

;- compute the 3 terms of the probability independentlyl
;- multipy by distance to plot on a Log-prob graph
p1 = phi * (dist lt distcutoff) * dist
p2 = dist^2 * (dist lt distcutoff) * dist
p3 = prob * (dist lt distcutoff) * dist

if keyword_set(noplot) then goto, skipplot

color1 = fsc_color('red')
color2 = fsc_color('blue')
color3 = fsc_color('purple')

plot, dist, p1 / max(p1), /xlog, charsize = 2, $
      xtit = 'Distance (pc)', psym = 10, $
      xra = [1d-2, 1d5 > distcutoff], /nodata, yra = [0, 1.1], /xsty , /ysty, $
      ytit = textoidl('Distance \times P(distance)')
oplot, dist, p1 / max(p1), color = color1, psym = 10
oplot, dist, p2 / max(p2), color = color2
oplot, dist, p3 / max(p3), psym = 10, color = color3, $
       thick = 3

xyouts, 3d-2, 1, 'Absolute Magnitude Bias', color = color1, charsize = 1.5
xyouts, 3d-2, .9, 'Malmquist Bias', color = color2, charsize = 1.5
xyouts, 3d-2, .8, 'Combined pdf', color = color3, charsize = 1.5
xyouts, 3d-2, .7, 'Filter: '+filter, charsize = 1.5
xyouts, 3d-2, .6, 'Apparent Magnitude: '+strtrim(mapp,2), charsize = 1.5

skipplot:
;- print some info about detectability
prob = p3 / total(p3)
precision = [100, 20, 10, 5, 2, 1, 5d-2, 1d-2]
dlim =   1 / (precision / 1d3)

print,      'Precision (mas)     F(objects)'
print,      '------------------------------'
for i = 0, n_elements(precision) - 1, 1 do begin
   frac = total(prob[where(dist lt dlim[i])])
   print,  string(precision[i], format='(e8.2)') +$
           '                   '+string(frac,format='(e8.2)')
endfor

;- explicitly set the output variables
dist = dist
prob = phi * dist^2 * (dist lt distcutoff)

return
end
