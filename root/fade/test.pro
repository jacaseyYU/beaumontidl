pro test

  im1 = bytscl(dist(512))
  im2 = shift(im1, 200, 100)

  win = obj_new('IDLgrWindow', retain = 2, $
                dimensions = [512, 512], title = 'Fade')
  view = obj_new('IDLgrView', $
                 VIEWPLANE_RECT = [0., 0., [512, 512]])
  model = obj_new('IDLgrModel')

  im1 = obj_new('IDLgrImage', im1, /greyscale)
  palette = obj_new('idlgrpalette')
  palette->loadct, 3

  im2 = obj_new('IDLgrIMage', im2, $
                blend_function=[3,4], $
                alpha = .5)
  model->add, im1
  model-> add, im2

  view->add, model
  win->draw, view

  obj_destroy, view
end
