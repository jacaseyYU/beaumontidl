function const, value, print = print, cgs = cgs, mks = mks

value = strlowcase(value)

switch value of
   'g' :begin
   if keyword_set(mks) then return, 6.673d-11
   return, 6.673d-8
   end
   'c' : begin
      if keyword_set(mks) then return, 299792458D
      return, 299792458D * 1d2
   end
   'k' : begin
      if keyword_set(mks) then return, 1.3806503d-23
      return, 1.3806503d-16
   end
   'sigma': begin
      if keyword_set(mks) then return, 5.6704d-8
      return, 5.6704d-5
   end
   'au' : begin
      if keyword_set(mks) then return, 149598000d3
      return, 149598000d5
   end
   'pc' : begin
      if keyword_set(mks) then return, 3.08568025d16
      return, 3.08568025d18
   end
   'mass_sun' : begin
      if keyword_set(mks) then return, 1.98892d30
      return, 1.98892d33
   end
   'radius_sun': begin
      if keyword_set(mks) then return, 6.955d8
      return, 6.955d10
   end
endswitch
end
   
