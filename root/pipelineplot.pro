pro pipelineplot
set_plot, 'ps'
files = file_search('/media/cave/catdir.[1-9]*/*/*good.sav', count = nfile)
;files = file_search('/media/data/astrom/*good.sav', count = nfile)

!p.charthick = 2
!p.charsize = 1.5
!p.multi = [0,2,3]
device, /land, yoff = 9.5, /in, /color, file='~/pipeline2.eps', /encap

;sz = 1d6
;pars = replicate({parfit}, sz)
;pms = replicate({pmfit}, sz)
;poss = replicate({posfit},sz)
;magss = fltarr(4,sz)
;ids = lonarr(4,sz)
;cats = strarr(sz)
;sz = 0
for i = 0, nfile-1, 1 do begin
   file = files[i]
   restore, file
;   nelem = n_elements(pm)
;   pars[sz:sz + nelem-1] = par
;   pms[sz:sz + nelem-1] = pm
;   poss[sz:sz + nelem-1] = pos
;   magss[*, sz:sz + nelem-1] = mags
;   ids[sz:sz+nelem-1] = cat_id
;   cats[sz:sz+nelem-1] = files[i]
   file = strmid(file, 0, strlen(file)-4)
   reduceplots, path = file
;   sz += nelem
endfor

;sz = n_elements(pars)
;par = pars[1:sz-1]
;pm = pms[1:sz-1]
;pos = poss[1:sz-1]
;mags = magss[*,1:sz-1]
;id = ids[1:sz-1]
;cat = cats[1:sz-1]
;save, par, pm, pos, mags, id, cat, file='~/reduce.sav'
device,/close
set_plot,'x'

end
