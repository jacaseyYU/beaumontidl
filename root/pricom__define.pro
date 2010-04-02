function pricom::project, data, nterm = nterm
  if ~keyword_set(nterm) then nterm = self.nevec else $
     nterm = nterm < self.nevec
  
  sz = size(data)
  if sz[1] ne self.ndim then message, 'input data not the correct dimension'
  mean = rebin(*self.mean, sz[1], sz[2])
  norm = data - mean
  
  ;- dot the data into each eigenvector. Get coeffs
  coeffs = *self.evec ## transpose(norm) ;- N data cols by M evec rows
  
  if nterm lt self.nevec then coeffs[*, nterm:*] = 0
  result = norm * 0
  for i = 0, sz[2] - 1 do $
     result[*, i] = total(rebin(coeffs[i,*], self.ndim, self.nevec) * *self.evec, 2)
  
  return, result + mean
end

function pricom::get_pc
  return, *self.evec
end

function pricom::get_variance
  return, *self.var
end

function pricomm::get_mean
  return, *self.mean
end


function pricom::init, data

  sz = size(data)
  nobj = sz[2]
  ndim = sz[1]
  mean = total(data, 2) / nobj
  norm_data = data - rebin(mean, ndim, nobj)

  result = PCOMP(norm_data, coeff = coeff, $
                 eigenval = eval, var = var)

  ;- ok, the result has some instabilities when ndata < ndim
  ;- we know there are only min(ndata, ndim) distinct evecs
  ;- so truncate the output
  outsz = min(ndim, nobj)
  nevec = outsz
  ;- get the eigenvectors and normalize them
  evec = coeff / rebin(eval, ndim, ndim)
  evec /= sqrt(rebin(1#total(evec^2, 1), ndim, ndim))
  bad = where(~finite(evec), badct)
  if badct ne 0 then evec[bad] = 0

  evec = evec[*,0:outsz-1]
  eval = eval[0:outsz-1]
  var = var[0:outsz-1]
  ;- populate the object
  self.ndim = ndim
  self.nobj = nobj
  self.nevec = nevec
  self.data = ptr_new(norm_data)
  self.eval = ptr_new(eval)
  self.evec = ptr_new(evec)
  self.mean = ptr_new(mean)
  self.var = ptr_new(var)

  return, 1
end

pro pricom::cleanup
  ptr_free, self.eval
  ptr_free, self.evec
  ptr_free, self.data
  ptr_free, self.var
  ptr_free, self.mean
end

pro pricom__define
  data = {pricom, nobj : 0, ndim: 0, nevec: 0, data : ptr_new(), $
          eval : ptr_new(), evec : ptr_new(), var: ptr_new(), mean : ptr_new()}
end
