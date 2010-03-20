pro lf_figs

;- the imf
set_plot, 'ps'
device, file = 'imf.ps',/land, /bold
masses = findgen(3d3) / 1d2 + 1d-8
imf = imf(masses)
imf /= max(imf)
sun = sunsymbol()
plot, masses, imf, /xlog, /ylog, xra = [5d-3, 3d1], $
      yra = [1d-6, 2], xtit = textoidl('M / M'+sun), $
      ytit = textoidl('\xi(M) = dN/dM'), charsize = 1.5, $
      title = 'IMF'
oplot, [.07, .07], [1d-8, imf(.07)], linestyle = 2
oplot, [.5, .5], [1d-8, imf(.5)], linestyle = 2
xyouts, .1, 1d-4, textoidl('\xi \propto M^{-1.05}'), charsize = 1
xyouts, 5d-3, 1d-4, textoidl('\xi \propto M^0'), charsize = 1
xyouts, .8, 1d-4, textoidl('\xi \propto M^{-2.35}'), charsize = 1
xyouts, .5, 1.1, '0.5 M'+sunsymbol(), align = .5, charsize = 1
xyouts, .07, 1.1, '0.07 M'+sunsymbol(), align = .5, charsize = 1
print, minmax(imf)
print, minmax(masses)


;- the luminosity function
mv = mass2magv(masses, masses * 0 + .5)
good = where(mv lt 40)
plot, masses[good], mv[good], /xlog, xra = [1d-2, 30], $
      xtit = 'M / M'+sun, ytit = textoidl('M_V'), charsize = 1.5, $
      tit = 'Mass-Luminosity Relation'

oplot, .7 * [1,1], [-100, mass2magv(.7, .5)], linestyle = 2
oplot, .1 * [1,1], [-100, mass2magv(.1, .5)], linestyle = 2

xyouts, 1., -5, 'Malkov 2007'
xyouts, .12, -5, 'Malkov et al. 1997'
xyouts, .012, -5, 'Chabrier et al. 2000'

device, /close
set_plot,'X'

end
