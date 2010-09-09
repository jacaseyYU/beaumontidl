pro animate

  m = mrdfits('mosaic.fits', 0, h)
  nanswap, m, 0
  m = bytscl(sigrange(m))

  restore, 'emission_class.sav' ;-mask

  sz = size(m)
  hit = where(mask eq 1)
  ind =array_indices(m, hit)
  lo = min(ind[2,*], max = hi)
  window, xsize = 2 * sz[1], ysize = sz[2]
  movie = mpeg_open([2 * sz[1], sz[2]])
  frame = 0
  for i = hi, lo, -1 do begin
     left = reform(m[*,*,i])
     left = rebin(reform(left, 1, sz[1], sz[2]), 3, sz[1], sz[2])
     right = left
     hit = where(mask[*,*,i] eq 1, ct)
     if ct ne 0 then begin
        plane = reform(right[1, *, *])
        r= plane & g = plane & b = plane
        g[hit] = (g[hit] + 100)/2
        r[hit] = (r[hit] + 0)/2
        b[hit] = (g[hit] + 0)/2
        right[0,*,*] = r & right[1, *, *] = g & right[2, *, *] = b
     endif
     
     tvimage, left, /true, /keep, pos = [0, 0, .5, 1]
     tvimage, right, /true, /keep, pos = [.5, 0, 1, 1]
     mpeg_put, movie, image = tvrd(/true, /order), frame = frame++
  endfor
  mpeg_save, movie, file='anim.mpg'
end
