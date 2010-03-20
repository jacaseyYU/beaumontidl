pro contrastfig

;-make figure of I(r) for report

restore, '029_shellcontrast.sav'
norm = interpol(data, loc, [1.0])
data /= norm[0]
b29loc = loc
b29dat = data


restore, '050_shellcontrast.sav'
norm = interpol(data, loc, [1.0])
data /= norm[0]
b50loc = loc
b50dat = data

restore, '022_shellcontrast.sav'
norm = interpol(data, loc, [1.0])
data /= norm[0]
b22loc = loc
b22dat = data

;restore, 'simcontrast.sav'
;norm = interpol(data, loc, [1.0])
;data /= norm[0]
;simloc = loc
;simdat = data

;-optically thin approx

othloc = findgen(121)/100.
len = sqrt(1.2^2 - othloc^2)
hit = where(othloc le 1)
len[hit] -= sqrt(1 - othloc[hit]^2)
len /= (sqrt(1.2^2-1))


; set up colors - see www.dfanning.com


set_plot,'ps',/interpolate

!p.font=0
device,filename='~/paper/figs/contrast.ps',/color, bits = 8, $
  xsize = 9, ysize = 7, /inches, /helvetica, /isolatin1, /land

thk=5.

plot, [0],[0], color = black, /nodata, xra=[0,1.5], yra=[0,1.1], /xsty, /ysty, $
  charsize = 1.5, xtit='Normalized Radius', ytit='Normalized Intensity'

red = fsc_color('crimson')
green = fsc_color('forest green')
blue = fsc_color('blue')


oplot, b29loc, b29dat, thi = thk, color = red
oplot, b29loc, b29dat, color=red, psym = 6
xyouts, .1, 0.9, 'N29', /data, charsize = 2, color=red

oplot, b50loc, b50dat, color=green, thick=thk
oplot, b50loc, b50dat, color=green, psym=6
xyouts, .1, 0.8, 'N50', /data, charsize=2, color=green

oplot, b22loc, b22dat, color=blue, thick=thk
oplot, b22loc, b22dat, color=blue, psym=6
xyouts, .1, 1.0, 'N22', /data, charsize=2, color=blue

oplot, othloc, len, color=black, thick=thk
xyouts, .1, .7, 'Optically Thin Profile', /data, charsize=2

device,/close
set_plot,'X'
end
