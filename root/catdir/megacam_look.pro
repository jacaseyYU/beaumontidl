pro megacam_look, file, ccd, x, y, m = m, t = t
  im = mrdfits(file, ccd+1, h)
  sz = size(im)
  xsz = sz[1]
  ysz = sz[2]
  xwin = 600
  ywin = 600
  xstamp = 400
  ystamp = 400
  window, xsize = xwin, ysize = ywin
  xp = rebin(findgen(xstamp) - xstamp / 2., xstamp, ystamp)
  yp = rebin(1#(findgen(ystamp) - ystamp / 2.), xstamp, ystamp)
  
  X_OFF = 33
  Y_OFF = 1

  subx =  0 > (xp + x + X_OFF) < (xsz - 1)
  suby = 0 > (yp + y + Y_OFF) < (ysz - 1)
  stmp = im[subx, suby]
  
  stmp = congrid(stmp, xwin, ywin)
  sub = stmp[.4 * xwin : .6 * xwin, .4 * ywin : .6 * ywin]
  s = sort(sub)
  lo = sub[s[.02 * n_elements(sub)]]
  hi = sub[s[.98 * n_elements(sub)]]
;  lo = min(sub, max = hi)
  stmp = bytscl(lo > stmp < hi)
  stmp[.8 * xwin : *, *] = 0B

  tvscl, stmp
  tvcircle, 10, xwin / 2, ywin / 2, color = fsc_color('red'), thick = 3

  if keyword_set(m) then begin
     xs = m.x_ccd
     ys = m.y_ccd
     dx = (xs - x) * 1D * xwin / xstamp
     dy = (ys - y) * 1D * ywin / ystamp
     good = where(dx lt xwin / 2 and dy lt ywin / 2)
     dx = dx[good]
     dy = dy[good]
     xpos = xwin / 2+ dx
     ypos = ywin / 2 + dy
     for i = 0, n_elements(dx) - 1, 1 do begin
        tvcircle, 10, xpos[i], ypos[i], $
                  color = fsc_color('blue'), thick = 2
        if keyword_set(t) then begin
           entry = t[m[good[i]].ave_ref]
           text = string(entry.ra, entry.dec, format='(2(f0.5, 2x))')
           xyouts, xpos[i], ypos[i], $
                   text, $
                   charsize = 1.5, charthick = 4, $
                   /device, color = fsc_color('black')
           xyouts, xpos[i], ypos[i], $
                   text, $
                   charsize = 1.5, charthick = 2, $
                   /device, color = fsc_color('crimson')
           
        endif
     endfor

  endif
end
