function roiwin::event, event
  widget_control, event.id, get_uvalue = uval
  super = self->interwin::event(event)
  if n_elements(uval) ne 0 && uval eq 'ROI' then self->setButton, /roi
  
  if size(super, /tname) eq 'STRUCT' && $
     super.LEFT_CLICK && self.doRoi then begin
     self->add_roi_point, super.x, super.y
     result = create_struct(super, name='ROI_EVENT')
     return, result
  endif
  return, super
end

pro roiwin::keyboard_event, event
  self->interwin::keyboard_event, event
  if ~event.release then return
  case strupcase(event.ch) of 
     'R':self->setButton, /roi
     'X': self->reset_roi
     else:
  endcase
end

pro roiwin::add_roi_point, x, y
  self.roi->appendData, x, y
  self.roi->getProperty, data = d
  dx = [reform(d[0,*]), d[0,0]]
  dy = [reform(d[1,*]), d[1,0]]
  self.roiplot->setProperty, datax = dx, datay=dy
  self->request_redraw
end

pro roiwin::reset_roi
  self.roi->getProperty, data = data
  if n_elements(data) eq 0 then return
  ndat = n_elements(data[0,*])
  self.roi->removeData, count = ndat
  self.roiplot->setProperty, datax=[!values.f_nan], datay=[!values.f_nan]
  self->request_redraw
end


pro roiwin::setButton, translate = translate, $
                            rotate = rotate, $
                            resize = resize, roi = roi
  self->interwin::setButton, translate = translate, $
                             rotate = rotate, resize = resize
  if keyword_set(roi) then begin
     if self.doRoi then begin
        self->reset_roi
        return
     endif
     self.doRoi = 1
     widget_control, self.roiButton, set_value = self.bmp_roi_select
     widget_control, self.translateButton, set_value = self.bmp_translate_deselect
     widget_control, self.rotateButton, set_value = self.bmp_rotate_deselect
     widget_control, self.resizeButton, set_value = self.bmp_resize_deselect
  endif else begin
     self.doRoi = 0
     widget_control, self.roiButton, set_value = self.bmp_roi_deselect
  endelse
end
     

function roiwin::init, model, $
                       _extra = extra
  super = self->interwin::init(model, rotate = 0, _extra = extra)
  file = file_which('roi.bmp')
  if ~file_test(file) then message, 'cannot find roi.bmp'
  roi_im = read_image(file)
  roi_im = transpose(congrid(roi_im, 3, 20, 20), [1,2,0])
  help, roi_im
  select = roi_im & select[*,*,0] = 255B
  self.bmp_roi_select = select
  self.bmp_roi_deselect = roi_im
  self.roiButton = widget_button(self.buttonbase, value=self.bmp_roi_deselect, /bitmap, $
                                 uvalue='ROI')
  self.roiplot = obj_new('idlgrplot', [!values.f_nan], [!values.f_nan], $
                         color=[255, 128,0], thick = 2)
  model->add, self.roiplot
  self.roi = obj_new('IDLanroi')
  return, 1
end

pro roiwin::cleanup
  self->interwin::cleanup
  obj_destroy, [self.roiplot, self.roi]
end

pro roiwin__define
  data = {roiwin, $
          inherits interwin, $
          roiplot:obj_new(), $
          roi:obj_new(), $
          
          bmp_roi_select: bytarr(20,20,3), $
          bmp_roi_deselect: bytarr(20,20,3), $
          roiButton:0L, $
          doRoi:0B $
         }
end
          
pro test

  plot =obj_new('idlgrplot', findgen(30), sin(findgen(30)))
  m = obj_new('idlgrmodel')
  m->add, plot
  o = obj_new('roiwin', m)
  o->run
end
