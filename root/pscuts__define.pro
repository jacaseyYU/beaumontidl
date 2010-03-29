function pscuts::getdata
  return, self.data
end
function pscuts::getpsdata
  return, self.psdata
end

function pscuts::randomRealization, ind = ind
  common pscut, seed
  if keyword_set(ind) then begin
     result = (*self.psdata)[ind]
  endif else result=*self.psdata
  n = n_elements(result)
  result.pi += randomn(seed, n) * result.sigma_pi
  result.mux += randomn(seed, n) * result.sigma_mu
  result.muy += randomn(seed, n) * result.sigma_mu
  return, result
end

function pscuts::filter, data, filter
  result = (data.pi gt filter.pi) and $
           (data.mux^2 + data.muy^2) gt filter.pm^2 and $
           (data.pi / data.sigma_pi gt filter.pisnr) and $
           (data.mux^2 + data.muy^2 / data.sigma_mu^2 gt filter.pmsnr^2)
  return, result
end

function pscuts::interloperCount, filter, $
                                  rel_noise = rel_noise, $
                                  abs_noise = abs_noise, $
                                  verbose = verbose, status = status, $
                                  s_prob = s_prob, $
                                  number = number
  common pscut, seed
  number = n_elements(*self.psdata)
  picut = filter.pi
  pmcut = filter.pm
  pisnrcut = filter.pisnr
  pmsnrcut = filter.pmsnr
  d_in = filter.d_in
  d_out = filter.d_out

  pi = (*self.psdata).pi
  spi = (*self.psdata).sigma_pi
  mu = (*self.psdata).mu
  mux = (*self.psdata).mux
  muy = (*self.psdata).muy
  smu = (*self.psdata).sigma_mu
  
  if ~keyword_set(rel_noise) then rel_noise = 0.01
  if ~keyword_set(abs_noise) then abs_noise = 0

  ninterloper = 0
  nround = 1
  ;- collect the nearby objects
  nearby = (*self.data).dist lt d_in
  far = (*self.data).dist gt d_out

  
  ;- try out new analytic tools
  lambda = (mux / smu)^2 + (muy / smu)^2
  prob = (1 - gauss_pdf((picut - pi) / spi)) * $
         (1 - gauss_pdf(pisnrcut - pi / spi)) * $
         c2noncen_mc((pmcut / smu)^2, lambda, s1) * $
         c2noncen_mc(replicate(pmsnrcut^2, n_elements(lambda)), lambda, s2)
;         (1 - c2noncen_cdf((pmcut / smu)^2, 2, lambda)) * $
;         (1 - c2noncen_cdf((mu / smu + pmsnrcut)^2, 2, lambda))
  prob *= far
;  near = where(prob gt .01)
;  edf, 1/pi[near], x, y, /plot
;  stop
  status = s1 > s2
  s_prob = dblarr(5)
  for i = 0, 4, 1 do begin
     bad = where(status eq i, ct)
     if ct ne 0 then s_prob[i] = total(prob[bad], /nan)
  endfor
  assert, s_prob[2] eq 0
  return, total(prob, /nan)




  ;- analytically compute interloper probability
  ;- for objects displaying zero pm signal
  nosig = where( (*self.psdata).mu / (*self.psdata).sigma_mu lt .05, $
                 noct, complement = sig, ncomp = sigct)
  int1 = (1 - gauss_pdf((picut - pi) / spi)) * $
         (1 - gauss_pdf(pisnrcut)) * $
         (1 - chisqr_pdf(pmcut^2 / smu^2,2)) * $
         (1 - chisqr_pdf(pmsnrcut^2,2))

  if sigct eq 0 then return, total(int1[nosig])
  
  while 1 do begin
     verbiage, string(nround, ninterloper, sqrt(ninterloper > 1)/nround, $
                      format='("round nint err:", i0, 5x, i0, 5x, e0.3)'), $
               3, verbose
     noisy = self->randomRealization(ind = sig)
     classified = self->filter(noisy, filter)
     ninterloper += total(classified and far)
     rn = 1 / sqrt(ninterloper > 1) / nround
     an = sqrt(ninterloper > 1) / nround
     rn *= (1D * sigct / (sigct + noct))
     an *= (1D * sigct / (sigct + noct))
     if an lt abs_noise || $
        rn lt rel_noise then break
     nround++
  endwhile
  return, 1D * ninterloper / nround * (1D * sigct / (sigct + noct)) + $
          total(int1[nosit])
end

function pscuts::init, file, sav = sav, doav = doav, old_noise = old_noise
  if keyword_set(sav) then begin
     restore, sav
     self.psdata = ptr_new(besancon2psdata(data, /cut, $
                                           /optimistic, $
                                           av = keyword_set(doav), $
                                          old_noise = keyword_set(old_noise))$
                           , /no_copy)
     self.data = ptr_new(data,/no_copy)
  endif else begin
     self.file = file
     if ~file_test(file) then begin
        print, 'FILE DNE: '+file
        return, 0
     endif
     data = read_besancon(file)
     self.psdata = ptr_new(besancon2psdata(data, /cut, /optimistic, $
                                           av = keyword_set(doav), $
                                           old_noise = keyword_set(old_noise))$
                           , /no_copy)
     self.data = ptr_new(data, /no_copy)
     self.doav = keyword_set(doav)
  endelse
  return, 1
end

pro pscuts::cleanup
  ptr_free, self.data
  ptr_free, self.psdata
end

pro pscuts__define
  data = {pscuts, file:'', data:ptr_new(), psdata:ptr_new(), doav:0}
end

pro test
  cut = obj_new('pscuts', 'l15b90_far.txt')
  filter = {pi :  1 / 200., pisnr : 0, pm : 0D, pmsnr : 200D, d_in : .100, d_out : .200}
  print, cut->interloperCount(filter, verbose = 5, rel_noise = .01, abs_noise = .01)
  obj_destroy, cut
end
