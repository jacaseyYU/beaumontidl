pro imlapdiff, im, x, y, d1, d2

  ind = border_indices(im, 2)
  x = (shift(im, 2) - 8 * shift(im, 1) + $
       8 * shift(im, -1) - shift(im, -2)) / 12D
  y = -(shift(im, 0,2) - 8 * shift(im, 0, 1) + $
       8 * shift(im, 0, -1) - shift(im, 0, -2)) / 12D
  d1 = (shift(im, 2,2) - 8 * shift(im, 1, 1) + $
       8 * shift(im, -1, -1) - shift(im, -2, -2)) / (12D * sqrt(2))
  d2 = (shift(im, -2,2) - 8 * shift(im, -1, 1) + $
       8 * shift(im, 1, -1) - shift(im, 2, -2)) / (12D * sqrt(2))
  x[ind] = 0 & y[ind] = 0 & d1[ind] = 0 & d2[ind] = 0
end
