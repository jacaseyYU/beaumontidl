function slice3binary::event, event
  
  result = self->slice3::event(event, draw_event = de)
  if event.id eq self.save then begin
     self->io, /save
     return, 0
  endif else if event.id eq self.open then begin
     self->io, /open
     return, 0
  endif
  
  ;- shift-clicking means no marking
  if tag_names(event, /struct) ne 'PZWIN_EVENT' || $
     (event.modifiers and 1) ne 0 then return, result

  ;-control-clicking means erase
  erase = (event.modifiers and 2) ne 0

  coords = self.mask_obj->convert_coords(de.x, de.y, de.z, valid = valid)
  
  if valid && (de.LEFT_CLICK || de.LEFT_DRAG) then begin
     (*self.mask)[coords[0], coords[1], coords[2]] = erase ? 0 : 1
  endif

  if valid && (de.RIGHT_CLICK || de.RIGHT_DRAG) then $
     (*self.mask)[coords[0], coords[1], coords[2]] = erase ? 0 : 2

  self->update_images
  return, result
end

pro slice3binary::io, save = save, open = open
  file = dialog_pickfile(default_extension='.mask', $
                         filter='*.mask', read = keyword_set(open), $
                         write = keyword_set(save), $
                         overwrite_prompt = keyword_set(save))
  if keyword_set(save) then begin
     mask = *self.mask
     save, mask, file=file
  endif else if keyword_set(open) then begin
     old_sz = size(*self.mask)
     restore, file

     ;- make sure the new mask is the right size
     sz = size(mask)
     nd = size(mask, /n_dim)
     if nd ne 3 || sz[1] ne old_sz[1] || $
        sz[2] ne old_sz[2] || $
        sz[3] ne old_sz[3] then begin
        msg = dialog_message(/info, 'Mask size is not compatible with current data')
        return
     endif

     ;- update mask, and redraw
     *self.mask = mask
     self->redraw
  endif
end

function slice3binary::init, cube, slice = slice, $
                    group_leader = group_leader, $
                    widget_listener = widget_listener, $
                    _extra = extra

  ;- Initialize superclass
  junk = self->slice3::init(cube, slice = slice, $
                      group_leader = group_leader, $
                      widget_listener = widget_listener, $
                      _extra = extra)

  ;- I/O buttons
  button_base = widget_base(self.base, row = 1)
  self.save = widget_button(button_base, value='Save')
  self.open = widget_button(button_base, value='Open')

  ;- set up blank mask of data
  isPtr = size(cube, /type) eq 10
  if isPtr then mask = byte(*cube * 0) else $
     mask = byte(cube * 0)

  self.mask = ptr_new(mask, /no_copy)
  self.mask_obj = obj_new('CNBgrMask', self.mask, $
                          color=[[0,255,0],[255,0,0]], alpha=.9, blend=[3,4])
  self.model->add, self.mask_obj
  widget_control, self.base, set_uvalue = self

  self.win->set_event_filter, /shift
  return, 1
end



pro slice3binary__define
  date={slice3binary, inherits slice3, $
        mask:ptr_new(), $
        mask_obj:obj_new(), $
        save:0L, $
        open:0L}
end

pro test
  data = randomn(seed, 64, 64, 64)
  s = obj_new('slice3binary', data)
  s->run
end
