;+
; NAME:
;  SOURCETAG
;
; PURPOSE:
;   This function tags sources with IR excess based on their colors
;   in Spitzer IRAC bands 1-4. The cut used comes from Megeath et al
;   2004, ApJS 154:367. Sources are tagged as source 0/I, II, or
;   III/main sequence  
;
; CALLING SEQUENCE:
;  result=SOURCETAG(i1,i2,i3,i4)
;
; INPUTS:
;  i1-i4: Vectors containing magnitudes or sources in Spitzer IRAC
;  bands 1-4.
;
; OUTPUT:
;  A vector of bytes the same length as i1-i4. The value at slot i is
;  1, 2, or 3 depending on whether the source at slot i has colors
;  like a class I, II or III/Main Sequence star. Only  sources marked
;  as 1 or 2 should be considered as candidate excess stars.
;
; MODIFICATION HISTORY:
;  Written by: Chris Beaumont, June 2008.
;-

FUNCTION  sourcetag, i1, i2, i3, i4


on_error,2

if n_params() ne 4 then message,'Calling Sequence: tag=sourcetag(i1,i2,i3,i4)'

nelem=n_elements(i1)
if (n_elements(i2) ne nelem) or (n_elements(i3) ne nelem) or (n_elements(i4) ne nelem) then $
  message, 'Error -- input irac vectors must be the same length.'


c1= ((i1-i2) ge .8) or  ((i3-i4) ge 1.1)

c2= ((i1-i2) gt 0) and  ((i1-i2) lt .8) and $
  ((i3-i4) gt .4) and  ((i3-i4) lt 1.1)

result=bytarr(nelem)+3B
hit1=where(c1,ct1)
hit2=where(c2,ct2)
if ct1 ne 0 then result[hit1]=1B
if ct2 ne 0 then result[hit2]=2B

print, 'Number of Class 0/1 Sources: ',ct1
print, 'Number of Class 2 Sources:   ',ct2
return,result

end
