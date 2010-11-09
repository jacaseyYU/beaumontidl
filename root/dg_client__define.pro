pro dg_client::set_alpha, index, alpha
  self.alpha[index] = alpha
end

pro dg_client::set_color, index, color, alpha = alpha
  self.colors[*,index] = color
  if n_elements(alpha) ne 0 then self.alpha[index] = alpha
end
  
pro dg_client::set_current, id
  self.current = id
end

pro dg_client::set_substruct, force = force
  message, 'cannot call this method directly'
end

function dg_client::calc_substruct, event
  return, event.substruct
end

function dg_client::get_substruct, id
  if n_elements(id) ne 1 then $
     message, 'must profide an index'
  return, *self.substructs[id]
end

pro dg_client::cleanup
  ptr_free, self.substructs
end

function dg_client::init, ptr, listener, colors = colors, alpha = alpha
  self.ptr = ptr
  for i = 0, 7 do self.substructs[i] = ptr_new(-10)

  if ~keyword_set(colors) then $
     colors = transpose(fsc_color(['crimson', 'royalblue', 'orange', 'purple', $
                                  'yellow', 'teal', 'brown', 'green'], /triple))
  if n_elements(alpha) eq 0 then alpha = replicate(.8, 8)
  self.colors = colors
  self.alpha = alpha
  self.listener = n_elements(listener) gt 0 ? $
                  listener : -1
  return, 1
end

pro dg_client::cleanup
  ptr_Free, self.substructs
end

pro dg_client__define
  data = {dg_client, $
          ptr:ptr_new(), $
          ;- mask properties
          colors:bytarr(3, 8), $
          alpha:fltarr(8), $
          substructs:ptrarr(8), $
          current:0, $ ;- current mask
          listener:0L $
         }
end
