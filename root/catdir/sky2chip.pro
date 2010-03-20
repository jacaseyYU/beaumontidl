pro sky2chip, ain, din, xin, yin, a, d, x, y
  
  ;- assuming that (a,d) aligned to (x,y) - reasonable for 
  ;- megacam
  xfit = linfit(ain, xin)
  yfit = linfit(din, yin)
  x = xfit[0] + xfit[1] * a
  y = yfit[0] + yfit[1] * d

  return
end
  
