pro bestlist::add, score, data
  lo = min(*self.scores, loc)
  if score gt lo then begin
     ;- replace lowest scoring element with this data
     (*self.scores)[loc] = score
     ptr_free, (*self.data)[loc]
     if n_elements(data) ne 0 then (*self.data)[loc] = ptr_new(data)
  endif
end
  
function bestlist::fetch_best, score = score
  return, self->fetch(0, score = score)
end

function bestlist::fetch, index, score = score
  if index ge self.capacity || index lt 0 then $
     message, 'requested index must be in the range [0, capacity-1]'

  s = reverse(sort(*self.scores))
  score = (*self.scores)[s[index]]
  result = (*self.data)[s[index]]
  if ptr_valid(result) then return, *result $
  else return, !values.f_nan
end

function bestlist::init, capacity
  self.capacity = capacity
  self.scores = ptr_new(fltarr(capacity))
  self.data = ptr_new(ptrarr(capacity))
  return, 1
end

pro bestlist::cleanup
  ptr_free, self.scores
  for i = 0, n_elements(*self.data) -1 do ptr_free, (*self.data)[i]
  ptr_free, self.data
end

pro bestlist__define
  data = {bestlist, scores:ptr_new(), data:ptr_new(), capacity:0}
end


pro test

  list = obj_new('bestlist', 20)
  for i = 0, 50 do list->add, i, i
  print, list->fetch_best(score = s) & print, s
;  for i = 0, 19 do print, list->fetch(i)

  for i = 70, 90 do list->add, i
  for i = 0, 19 do print, list->fetch(i)
  obj_destroy, list
  
end
