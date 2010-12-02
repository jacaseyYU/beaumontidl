function guess_system, header

  if n_params() eq 0 then begin
     print, 'calling sequence'
     print, 'sys = guess_system(header)'
     return, -1
  endif

  sys = sxpar(header, 'SYSTEM')
  if size(sys, /tname) eq 'STRING' then begin
     case 1 of
        strmatch(sys, '*J200*', /fold): return, 'EQ'
        strmatch(sys, '*FK5*', /fold): return, 'EQ'
        strmatch(sys, '*GAL*', /fold): return, 'GAL'
        else: return, ''
     endcase
  endif
  ctyp = sxpar(header, 'CTYPE1')
  if size(ctyp, /TNAME) eq 'STRING' then begin
     case 1 of
        strmatch(ctyp, '*RA*', /fold): return, 'EQ'
        strmatch(ctyp, '*LAT*', /fold): return, 'GAL'
        strmatch(ctyp, '*GAL*', /fold): return, 'GAL'
        else: return, ''
     endcase
  endif
  return, ''
        
end

