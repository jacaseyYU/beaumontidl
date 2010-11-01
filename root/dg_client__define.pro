pro dg_client::set_substruct, id, substruct, status
  status = 0
  if self.substructs[id] eq substruct then return
  self.substructs[id] = substruct
  status = 1
end

function dg_client::get_substruct, id, all = all
  if keyword_set(all) then return, self.substructs
  if n_elements(id) ne 1 then $
     message, 'must profide an index or set /all'
  return, self.substructs[id]
end

function dg_client::init, ptr, listener, colors = colors
  self.ptr = ptr
  self.substructs = replicate(-2, 8)

  if ~keyword_set(colors) then $
     colors = transpose(fsc_color(['crimson', 'royalblue', 'orange', 'purple', $
                                  'yellow', 'teal', 'brown', 'green'], /triple))
  self.colors = colors
  self.listener = n_elements(listener) gt 0 ? $
                  listener : -1
  self.alpha[*] = .5
  return, 1
end

pro dg_client__define
  data = {dg_client, $
          ptr:ptr_new(), $
          colors:bytarr(3, 8), $
          alpha:fltarr(8), $
          substructs:intarr(8), $
          listener:0}
end
