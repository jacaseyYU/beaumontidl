;+
; PURPOSE:
;  bestlist is a class to store the n highest-scoring data
;  points. A 'data point' can be any variable with an associated
;  score. 
;
; METHODS:
;  add: Add a new element to the list
;  fetch_best: return the best score + data
;  fetch: return a given score + data by rank index
;
; MODIFICATION HISTORY:
;  July 2010: Written by Chris Beaumont
;-

;+
; PURPOSE:
;  add a new datum to the list
; 
; INPUTS:
;  score: A scalar specifying the priority/score of the datum
;  data: (optional) the data itself. Any variable (scalar or vector)
;  will do. 
;-
pro bestlist::add, score, data
  lo = min(*self.scores, loc)
  if score gt lo then begin
     
     ;- do not include duplicate data points
     hit = where((*self.scores) eq score, ct)
     for i = 0, ct - 1 do begin
        d = (*self.data)[hit[i]]
        if ptr_valid(d) && min( *d eq data) then return
     endfor

     ;- replace lowest scoring element with this data
     (*self.scores)[loc] = score
     ptr_free, (*self.data)[loc]
     if n_elements(data) ne 0 then (*self.data)[loc] = ptr_new(data)
  endif
end
  

;+
; PURPOSE:
;  Return the best data point, with its score
;
; KEYWORD PARAMETERS:
;  score: Variable to hold the score
;
; OUTPUTS:
;  The best-scoring data point
;-
function bestlist::fetch_best, score = score
  return, self->fetch(0, score = score)
end


;+
; PURPOSE:
;  Fetch the n-th best data point
;
; INPUTS:
;  index; The rank of the data point to return
;
; KEYWORD PARAMETERS:
;  score: A variable to hold the score
;
; OUTPUTS:
;  The index-th best data point
;-
function bestlist::fetch, index, score = score
  if index ge self.capacity || index lt 0 then $
     message, 'requested index must be in the range [0, capacity-1]'

  s = reverse(sort(*self.scores))
  score = (*self.scores)[s[index]]
  result = (*self.data)[s[index]]
  if ptr_valid(result) then return, *result $
  else return, !values.f_nan
end

;+
; PURPOSE:
;  Defines the bestlist object
;
; INPUTS:
;  capacity: Integer giving the number of unique data points to keep
;  track of. The lowest ranking excess data points will be discarded
;  to limit the size of the object
;-
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
