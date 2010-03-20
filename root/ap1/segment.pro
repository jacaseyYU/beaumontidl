;+
; NAME:
;  SEGMENT
;
; PURPOSE:
;  This function creates a data cube mask whose non-zero values index
;  the group of voxels connected to a seed voxel. The group boundaries
;  are defined as the 3 sigma isosurface that bounds the seed.
;
; CALLING SEQUENCE:
;  result=SEGMENT(cube,seed)
;
; INPUTS:
;  cube: A data cube
;  seed: The index of a voxel which defines the interior of the masked
;  region. Seed may either be a scalar or a 3 element vector
;
; OUTPUT:
;  A cube of the same dimensions as the input. The output cube has a
;  value of 1 within the region described above, and zero elsewhere.
;
; MODIFICATION HISTORY:
;  June 23, 2008: Written by Chris Beaumont
;-

FUNCTION SEGMENT,cube,seed

;-CHECK PARAMETERS
if n_params() ne 2 then message,'Calling Sequence: mask=segment(cube,seed)'
sz=size(cube)
if sz[0] ne 3 then message,'Error-- Input cube must be 3 dimensional'
case n_elements(seed) of
    1: seed=array_indices([sz[0],sz[1],sz[2]],seed,/dimensions)
    3: 
    else: message,'Error- Seed must be a scalar or triplet'
endcase 



result=cube ge 3*sqrt(variance(cube,/nan))
result=label_region(result,/all_neighbors)
stop
index=result[seed[0],seed[1],seed[2]]
if index eq 0 then message,'Error--Seed voxel below threshold'

result=(result eq index)
stop
;-step through, display the mask
for i=0, sz[3]-1,5 do begin
    tv,255*result[*,*,i]
    wait,.1
endfor

stop
return,result

end
