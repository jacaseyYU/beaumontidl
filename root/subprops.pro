function subprops, ptr, virial
  nan = !values.f_nan
  rec = {area:nan, $
         height:nan, $
         maxheight:nan, $
         height_rank:nan, $
         area_times_dv:nan, $
         neighbor_area_ratio:nan, $
         neighbor_height_ratio:nan, $
         nsub:nan, $
         shoulder_height:nan, $
         shoulder_height_rank:nan, $
         gradient:nan}
  nst = n_elements(virial)

  data = replicate(rec, nst)
  data.area = !pi * virial.sig_maj * virial.sig_min
  data.height = (*ptr).height[0:nst - 1]

  s = sort(data.height)
  r = indgen(nst) & rank = r
  rank[s] = r
  data.height_rank = rank
  data.area_times_dv = data.area * virial.sig_v

  for i = 0, nst - 1, 1 do begin
     l = leafward_mergers(i, (*ptr).clusters)
     data[i].nsub = n_elements(l)
     data[i].maxheight = max(data[l].height)
  endfor


  for i = 0, nst - 1, 1 do begin
     p = merger_partner(i, (*ptr).clusters, merge = m)
     if m eq -1 || p eq -1 then continue
     data[i].shoulder_height = data[i].height - data[m].height
     data[i].neighbor_height_ratio = data[i].maxheight / data[p].maxheight
     data[i].neighbor_area_ratio = data[i].area / data[p].area
     data[i].gradient = (data[i].height - data[m].height) / $
                        (sqrt(data[m].area) - sqrt(data[i].area))
  endfor

  r = indgen(nst) & rank = r
  s = sort(data.shoulder_height)
  rank[s] = r
  data.shoulder_height_rank = rank

  return, data
end
     
         
