pro kinErrors

d_par = [4.59, 5.88, 3.19, 2.19, $
         3.27, 5.13, 2.16, 0.70, $
         2.65, 2.13, 2.82, 1.95, $
         5.99, 2.10, 5.29, 0.41, $
         1.68, 1.14]

d_k = [4.72, 5.30, 4.77, 1.98, $
       2.78, 5.46, 3.45, 0.58, $
       4.65, 3.10, 2.01, 3.43, $
       6.94, 3.28, 3.28, 0.90, $
       1.43, 1.15]
plot, d_par, d_par - d_k, psym = 4
stop
err = abs(d_par - d_k) / (d_par) * 100
print, mean(err), median(err), stdev(err)
h = histogram(err, binsize = 10, loc = loc)
plot, loc, h, psym = 10, yra=minmax(h) + [0,1]

end
