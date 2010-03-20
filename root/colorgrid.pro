pro colorgrid

masses = 10^(findgen(1d2)/99. * 3. - 2)
ages = 10^(findgen(1d2)/99. * 4 - 3)

masses = rebin(masses, 100, 100)
ages = rebin(1#ages, 100, 100)
masses = reform(masses, 10000)
ages = reform(ages, 10000)

v = mass2mag(masses, ages, filter='v')
r = mass2mag(masses, ages, filter='r')
i = mass2mag(masses, ages, filter='i')
z = mass2mag(masses, ages, filter='z')
y = mass2mag(masses, ages, filter='y')

save, v, r, i, z, y, masses, ages, file='colorgrid.sav'

stop

end
