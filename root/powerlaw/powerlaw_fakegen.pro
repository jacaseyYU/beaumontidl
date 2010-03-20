function powerlaw_fakegen, alpha = alpha, xmin = xmin, ntrial = ntrial

if ~keyword_set(alpha) then alpha = 2.5
if ~keyword_set(xmin) then xmin = 5.2
if ~keyword_set(ntrial) then n = 100000 else n = ntrial

a = (1D/xmin)/2.
data = randomu(seed, n)
data = xmin * data^(1D / (1D - alpha))

return, data

end
