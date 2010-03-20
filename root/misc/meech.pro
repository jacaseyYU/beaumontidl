function m, sz

return, -26.73 + 2.5 * alog10(4.5^2 * 3.5^2 / (.04 * sz^2) * (1.5d11)^2)

end

pro test

print, .45, m(450.)
print, .71, m(710.)
print, .9, m(900.)
print, 1.1, m(1100.)

end
