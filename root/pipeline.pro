pro pipeline

dir = '/media/cave/'

files = file_search(dir+'catdir*/*/*.cpm', count = nfile)

for i = 0, nfile - 1, 1 do begin
   split = strsplit(files[i], '/', /extract)
   ;- skip the directories that aren't in n0000 or s0000
   if strmid(split[3], 1, 4) ne 0 then continue

   dir = '/'+split[0]+'/'+split[1]+'/'+split[2]
   path = '/'+split[3]+'/'+strmid(split[4], 0, 4)
   reduce, dir = dir, path = path, cv = 4
endfor

end
