function draw_tiles, num

  lb = obj_new('letterbag')
  result = lb->draw(num)
  obj_destroy, lb
  return, result
end
