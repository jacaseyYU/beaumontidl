;- JS CODE
pro av_var,C,meanvec,path=path,file=file

;;; Procedure to calculate directly the covariance matrix of the intrinsic color
;;; variations of a control sample of stars

  if not keyword_set(path) then path = '/users/cnb/glimpse/pro/'
  if not keyword_set(file) then file = 'control.dat'
  readcol,path+file,format='f,f,f,f,f,f,f,f', $
          ra,dec,j,je,h,he,k,ke,/silent
  
  c1 = j-h
  c1mean = mean(c1)
  c2 = h-k
  c2mean = mean(c2)
  meanvec = [c1mean,c2mean]

  ; calculate covariance matrix directly
  C = fltarr(2,2)
  C[0,0] = variance(c1)
  C[1,1] = variance(c2)
  C[0,1] = total((c1-mean(c1))*(c2-mean(c2)))/float(n_elements(c1))
  C[1,0] = total((c2-mean(c2))*(c1-mean(c1)))/float(n_elements(c1))

  return
end
