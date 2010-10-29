pro dg_slice::set_substruct, index, substruct
end

function dg_slice::event, event
return, 0
end


pro dg_slice::cleanup
  self->slice3::cleanup
end

function dg_slice::init, ptr

end
pro dg_slice__define
  data = {dg_slice, $
          inherits slice3, $
          ptr:ptr_new(), $
          dg_has_listen:0B, $
          dg_listen:0L}
end
