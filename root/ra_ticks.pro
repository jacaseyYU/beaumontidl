pro ra_ticks, ra, ticknumber, ticknames, tickval, number = number

  steps = [1., 2, 5, 10, 20, 30, $
           1 * 60, 2 * 60, 5 * 60, 10 * 60, 20 * 60, 30 * 60, $
           1 * 3600, 2 * 3600, 5 * 3600, 10 * 3600, 20 * 3600, $
           30 * 3600]

  if not keyword_set(number) then number = 5
  nums = range(ra) / (steps / 3600.)
  best = min(abs(number - nums), loc)
  
  delta = steps[loc]
  ind = arrgen(0., 24., delta / 3600.)
  hit = where(ind gt min(ra) and ind lt max(ra), ct)
  ticknumber = ct - 1
  tickval = ind[hit]

  ticknames = replicate('', ct)
  hms_old = [-1,-1,-1]
  for i = ct-1, 0, -1 do begin
     hms = sixty(tickval[i])
     if delta lt 60 then $
        s = string(hms[2],format='(i2.2)')+'^s' $
     else s = ''
     if delta lt 3600 then $
        m = string(hms[1], format='(i2.2)')+'^m' $
     else m = ''
     h = string(hms[0], format='(i2.2)')+'^h'
     
     if hms_old[0] ne hms[0] then $
        ticknames[i] = h + m + s $
     else if hms_old[1] ne hms[1] then $
        ticknames[i] = m + s $
     else ticknames[i] = s
     hms_old = hms
  endfor

end
