pro n_n_astrometry, x, y, dx, dy

rank = [1D3, 5D2, 1D2, 50, 30, 20, 15, 10]
nrank = n_elements(rank)
sz = n_elements(x)

points = transpose([[x],[y]])
for i = 0, nrank - 1, 1 do begin
   if rank[i] ge sz then continue

   ;-gather them all
   neighbors = nearestn(points, points, rank[i])

   ;-calculate the offset, decide whether its significant
