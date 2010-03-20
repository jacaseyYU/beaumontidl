pro summarize_reduction, file

restore, file

nt = n_elements(obj_flags)

noskip   = total((obj_flags and '10'xl) ne 0)
nofail   = total((obj_flags and '20'xl) ne 0)
npmskip  = total((obj_flags and '40'xl) ne 0)
npmfail  = total((obj_flags and '80'xl) ne 0)
nparskip = total((obj_flags and '100'xl) ne 0)
nparfail = total((obj_flags and '200'xl) ne 0)
npargood = total((obj_flags and '400'xl) ne 0)

print, 'Data reduction summary for '+file
ng = nt - noskip
print, nt,                             format="('Total objects       : ', i)"
print, noskip,     format="('Objects skipped     : ', i)"
print, nofail, 100D * nofail / ng,     format="('Failed positions    : ', i, ' (', i2,'%)')"
print, npmfail, 100D * npmfail / ng,   format="('Failed pm fits      : ', i, ' (', i2,'%)')"
print, nparfail, 100D * nparfail / ng, format="('Failed par fits     : ', i, ' (', i2,'%)')"
print, npargood, 100D * npargood / ng,format="('Successful par fits : ', i, ' (', i2,'%)')"
assert, (npargood + nparfail + npmfail + nofail + noskip) $
        eq nt
end
