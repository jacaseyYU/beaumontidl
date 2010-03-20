function r, lambda, v, n, md
mu0 = 4 * !pi * 1d-7 ;- N A^-2
mp = 1.67d-27 ;- kg

return, (mu0 * md^2D / (32D * !pi^2 * mp * v^2D * n) * $
        (1D + 3D * sin(lambda * !dtor)^2.))^(1D/6D)

end
pro magnetosphere

print, 'earth'
print, r(12., 5d5, 1d-5, 8d22) / 6378.D3
print,'jupiter'
print, r(10., 5d5, 3.7d-7, 1.6d27) / 71492.D3
end
