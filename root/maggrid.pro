pro maggrid

  masses = 10^(findgen(300)/100 - 2)
  ages = 10^(findgen(400)/100 - 2) 
  
  masses = reform(rebin(masses, 300, 400), 12d4)
  ages = reform(rebin(1#ages, 300, 400), 12d4)
  
  g = mass2mag(masses, ages, filter='v')
  r = mass2mag(masses, ages, filter='r')
  i = mass2mag(masses, ages, filter='i')
  z = mass2mag(masses, ages, filter='z')
  y = mass2mag(masses, ages, filter='y')

  plot, g - r, -r, psym = 3
  stop
end
