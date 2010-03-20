pro vector_test

v = obj_new('vector')
print, v->toArray()

print, 'adding 12345'
v->append, [1,2,3,4,5]
print, v->toArray()

print, 'adding 6'
v->append, 6
print, v->toArray()

print, 'adding 78'
v->insertAt, [7,8], 6
print, v->toArray()

print, 'zeroing 23'
v->insertAt, [0,0], 1
print, v->toArray()

print, 'filling first 3 elements with -1'
v->fill, -1, 0, 2
print, v->toArray()

print, 'filling first 3 elements with -2'
v->fill, -2, lastInd = 2
print, v->toArray()

print, 'filling all but first element with -3'
v->fill, -3, firstInd = 1
print, v->toArray()

print, 'deleting'
v->delete
print, v->toArray()

print, 'creating 5 element array by using fill'
v->fill, 1, 3, 4
print, v->toArray()


print, 'destroying'
obj_destroy,v
help, /heap

end
