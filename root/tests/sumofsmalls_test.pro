pro sumofsmalls_test

tol = 1d-6

;- an array
x = randomu(seed, 100,/double)
logx = alog(x)
sum = exp(sumofsmalls(logx))
assert, abs(sum - total(x)) lt tol
print, 'Test 1 passed'

;- vectorized
x = randomu(seed, 100, 200,/double)
logx = alog(x)
sum = exp(sumofsmalls(logx))
assert, max(abs(sum - total(x, 1))) lt tol
print, 'Test 2 passed'


end
