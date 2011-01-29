function getMapDims
  naxis = sxpar(*self.header, 'NAXIS')
  return, naxis eq 2 ? [sxpar(*self.header, 'NAXIS1'), $
                       sxpar(*self.header, 'NAXIS2')] : $
     [sxpar(*self.header, 'NAXIS1'), $
      sxpar(*self.header, 'NAXIS2'), $
      sxpar(*self.header, 'NAXIS3')]
end

function mapParams::init, headerOrArray, xrange, yrange, zrange
  if n_params() eq 0 || n_params() gt 4 then begin
     print, 'calling sequence'
     print, "o = obj_new('mapParams', header)"
     print, 'or'
     print, "o = obj_new('mapParams', array, [xrange, yrange, zrange])"
     print, 'range of the form [min, max]'
     return, 0
  endif

  nx = n_elements(xrange)
  ny = n_elements(yrange)
  nz = n_elements(zrange)

  if (nx ne 0 && nx ne 2) || $
     (ny ne 0 && ny ne 2) || $
     (nz ne 0 && nz ne 2) then $
        message, 'xrange, yrange, zrange must be of form [min, max] '+$
                 'if provided'

  nd = size(headerOrArray, /ndim)
  sz = size(headerOrArray)

  if size(headerOrArray, /tname) eq 'STRING' then begin
     self.header = ptr_new(headerOrArray)
     return, 1
  endif 

  if (ndim ne 2 && ndim ne 3) then $
     message, 'input array must be 2- or 3-dimensional'
  
  mkhdr, head, headerOrArray
  sxaddpar, head, 'CRPIX1', 1
  sxaddpar, head, 'CRVAL1', nx eq 2 ? xrange[0] : 0
  sxaddpar, head, 'CDELT1', nx eq 2 ? 1. * range(xrange) / sz[1] : 1
  sxaddpar, head, 'CRPIX2', 1
  sxaddpar, head, 'CRVAL2', ny eq 2 ? yrange[0] : 0
  sxaddpar, head, 'CDELT2', ny eq 2 ? 1. * range(yrange) / sz[2] : 1
  
  if ndim eq 3 then begin
     sxaddpar, head, 'CRPIX3', 1
     sxaddpar, head, 'CRVAL3', nz eq 2 ? zrange[0] : 0
     sxaddpar, head, 'CDELT3', nz eq 2 ? 1. * range(zrange) / sz[3] : 1
  endif
  self.header = ptr_new(head)

  return, 1
end

pro mapParams::cleanup
  ptr_free, self.header
end

pro mapParams__define
  data = { mapParams, header:ptr_new() }
end
           
