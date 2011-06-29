;+
; PURPOSE:
;  This class implements a maxheap data structure of variable size. It
;  uses the vector class to store the data. A maxheap is a complete
;  binary tree with the property that any node is greater than all of
;  its children. This implies that the root of the tree is the maximum
;  value in the data. 
;
;  Insertion and deletion are both O(log(n)) operations. Thus,
;  maxheaps are useful for implementing priority queues.
;
;  This class requires that the items added to the heap be
;  structures with a tag VALUE, containing the numeric value of the
;  item to insert. The heap sorting occurs according to this value
;  TAG. Such a convention allows someone to insert non-numeric data
;  into the heap (via other tags in the structure), as long as it has
;  an associated value.
;
; PUBLIC METHODS:
;  insert: insert a new value into the heap
;  delete: Delete and remove the root (i.e. maximum)
;  peek: Look at, but do not remove, the root
;  isEmpty: test whether the heap contains data
;  getSize: return the number of elements in the heap
;
; MODIFICATION HISTORY:
;  December 2010: Written by Chris Beaumont
;  June 2011: Added support for inserting multiple elements at once
;-

;+
; PURPOSE:
;  This is a private method to swap to values in the heap tree
;
; INPUTS:
;  i: The index of the first node to swap
;  j: The index of the second node to swap
; 
;-
pro maxheap::swap, i, j
  tmp = self.vector->getValues(i)
  self.vector->insertAt, self.vector->getValues(j), i
  self.vector->insertAt, tmp, j
end

;+
; PURPOSE:
;  Return but do not remove the root of the tree. The root is also the
;  maximum data value.
;
; OUTPUTS:
;  The root of the tree
;-
function maxheap::peek
  return, self.vector->getValues(0)
end

;+
; PURPOSE:
;  Returns the number of elements in the heap
; 
; OUTPUTS:
;  The number of elements in the heap
;-
function maxheap::getSize
  return, self.num
end

;+
; PURPOSE:
;  Insert a new value into the heap
;
; INPUTS:
;  value: The value to insert
;-
pro maxheap::insert, value
  if n_params() eq 0 || size(value, /type) ne 8 then begin
     print, 'calling sequence'
     print, 'heap->insert, value'
     print, 'value: a structure with a tag called VALUE'
     return
  endif
     
  if n_elements(value) gt 1 then begin
     for i = 0, n_elements(value) - 1, 1 do $
        self->insert, value[i]
     return
  endif

  v = self.vector

  ;- insert into bottom of tree. Swap with parent repeat up tree
  ;- until the max-heap property is satisfied

  v->insertAt, value, self.num++

  index = self.num-1
  parent = (index - 1) / 2
  while (v->getValues(index)).value gt (v->getValues(parent)).value do begin
     self->swap, index, parent
     index = parent
     parent = (index - 1)/2
  endwhile
end

;+
; PURPOSE:
;  Test whether the heap is empty
;
; OUTPUTS:
;  1 if the heap is empty, 0 otherwise
;-
function maxheap::isEmpty
  return, self.num eq 0
end

;+
; PURPOSE:
;  Remove and return the top of the heap
;
; OUTPUTS:
;  The top of the heap, which is the maximum data value in the heap.
;-
function maxheap::delete
  if self.num eq 0 then $
     message, 'heap is empty'
  result = self.vector->getValues(0)
  self->swap, 0, self.num-1
  self.num--
  self->maxHeapify, 0
  return, result
end

;+
; PURPOSE:
;  An internal, recursive method to restore the heap property of a
;  sub-tree rooted at node i. This works assuming that both children
;  of i are valid heap trees. 
;
; INPUTS:
;  i: The node to reheap
;-
pro maxheap::maxHeapify, i
  v = self.vector
  left = 2L * i + 1
  right = 2L * i + 2
  largest = i
  if largest ge self.num then return
  if left lt self.num && $
     (v->getValues(left)).value  gt $
     (v->getValues(largest)).value then largest = left
  if right lt self.num && $
     (v->getValues(right)).value gt $
     (v->getValues(largest)).value then largest =  right
  if largest ne i then begin
     self->swap, i, largest
     self->maxHeapify, largest
  endif
end

;+
; PURPOSE:
;  Create a new maxheap
;
; INPUTS:
;  values: An optional array of values to be inserted into the
;  heap. If not provided, the an empty heap is created. Each element
;  must be a structure, which contains a VALUE tag. The heap is sorted
;  according to this value.
;
; OUTPUTS:
;  1 for success.
;
; BEHAVIOR:
;  If values are present, an arbitrary binary tree is created. Then,
;  starting one level above the leaves, each sub-tree is re-heaped to
;  extablish the property that each node is greater than both its
;  children (the leaves satisfy this trivially). This is faster than
;  inserting each element individualy.
;-
function maxheap::init, values
  if n_elements(values) ne 0 && size(values, /type) ne 8 then $
     message, 'Input values must be structures, with a VALUE tag'

  self.vector = obj_new('vector')
  if n_elements(values) eq 0 then return, 1

  self.vector->insertAt, values, 0
  self.num = n_elements(values)
  for i = self.num/2-1, 0, -1 do self->maxHeapify, i

  return, 1
end

;+
; PURPOSE:
;  Deletes the variable and frees memory
;-
pro maxheap::cleanup
  obj_destroy, self.vector
end


pro maxheap__define
  ;- num is the index of the first empty slot in vector.
  data = {maxheap, vector:obj_new(), num:0L}
end


pro test
  sz = 20
  vals = randomu(seed, sz) * 20
  st = replicate({value:0.}, sz)
  st.value = vals

  sorted =  reverse(vals[sort(vals)])
  h = obj_new('maxheap', st)
  assert, ~h->isEmpty()
  for i = 0, sz-1, 1 do begin
     v = h->delete()
     assert, v.value eq sorted[i]
  endfor
  assert, h->isEmpty()

  for i = 0, 19, 1 do h->insert, st[i]
  assert, ~h->isEmpty()
  for i = 0, sz-1, 1 do assert, (h->delete()).value eq sorted[i]
  assert, h->isEmpty()
  obj_destroy, h


  ;- make sure deleting an empty heap generates an error
  e = 0
  catch, emptyDeletionError
  if emptyDeletionError ne 0 then begin
     catch, /cancel
     e = 1
     goto, finally
  endif
  x = h->delete()
  
  finally:
  assert, e eq 1
  print, 'all tests passed'
end
