function transmission, lambda, transmission, freq = freq, filter = filter, profile = profile

  if n_elements(lambda) eq 0 and ~keyword_set(profile) then $
     message, 'must provide a set of wavelengths, or set the /profile keyword'
  
  if ~keyword_set(filter) then filter='v'
  switch filter of 
     'u':
     'b':
     'v':
     'r':
     'i':
     'j':
     'h':
     'k':
     'l':
     'm': begin
        readcol, '~/idl/data/transmission_curves/jhklm.txt', jl, j,, hl, h, kl, k, ll, l, ml, m, $
           comment='#', /silent
     end
     'psg':
     'psr':
     'psy':
     'psz':
     'psy':
     default: message, $
        'filter must be one of u,b,v,r,i,j,h,k,l,m,psg,psr,psy,psz,psy'
  endcase

  
