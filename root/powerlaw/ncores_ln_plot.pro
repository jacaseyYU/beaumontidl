pro ncores_ln_plot, ps = ps

restore, 'ncores_ln.sav'

!p.multi = [0,2,3]

if keyword_set(ps) then begin
   set_plot, 'ps'
   device, /encap, /color, /land, yoff = 9.5, /in, $
           file='ln_fits.eps'
   oldsz = !p.charsize
   oldth = !p.thick
   oldct = !p.charthick
   !p.charsize = 2
   !p.thick = 2
   !p.charthick = 2
endif

for i = 0, 4, 1 do begin
   h1 = histogram(pl_dfrac[i,*], loc = l1, nbin = 1d4)
   h2 = histogram(ln_dfrac[i,*], loc = l2, nbin = 1d4)
   plot, [0,1],[0,1], xtit = 'Dfrac', ytit = 'cdf', $
         tit = 'Ncores: '+strtrim(ncores[i]), $
         charsize = 2
   oplot, l1, total(h1, /cumul) / total(h1), color = fsc_color('crimson')
   oplot, l2, total(h2, /cumul) / total(h2), color = fsc_color('forestgreen')
   xyouts, .6, .4, 'LN Data', color = fsc_color('forestgreen')
   xyouts, .6, .2, 'PL Data', color = fsc_color('crimson')
endfor

if keyword_set(ps) then begin
   device, /close
   !p.charsize = oldsz
   !p.thick = oldth
   !p.charthick = oldct
endif


!p.multi = 0
end
