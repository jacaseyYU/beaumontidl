pro mine_catalogs

  cats = file_search('/media/cave/catdir.[1-9]*/*/*good.sav', count = ct)
  ;outfile = '/home/beaumont/pmplots/'
  outfile = '/home/beaumont/parplots/'
  spawn, 'rm '+outfile+'*.p*'
  
  for i = 0, ct - 1, 1 do begin
     
     restore, cats[i]
     split = strsplit(cats[i], 'g', /extract)
     skymodel = split[0]+'skymodel'
     restore, skymodel

     hipm = sqrt(pm.ura^2 + pm.udec^2) gt 15 
     veryhipm = sqrt(pm.ura^2 + pm.udec^2) gt 150

     hipmsn = sqrt(pm.ura^2 + pm.udec^2) / sqrt(pm.covar[1,1] + pm.covar[3,3]) gt 20
     
     hipar = par.parallax gt 20
     hiparsn = par.parallax / sqrt(par.covar[4,4]) gt 7
     goodpar = par.chisq lt 2 * par.ndof
     goodpm = pm.chisq lt 2 * pm.ndof
     
     betterpm = pos.chisq - pm.chisq gt 5
     betterpar = pm.chisq - par.chisq gt .3 * par.ndof
     
     iffypar = par.chisq lt 20 * par.ndof
     parsn = par.parallax / sqrt(par.covar[4,4])
     
     
     good = where(par.parallax gt 20 and  $
                  parsn gt 5 and $
                  par.chisq lt 5 * par.ndof and $
                  betterpar, goodct)

     ;good = where(hipmsn and veryhipm and iffypar, goodct)
     if goodct eq 0 then continue
     
     ;- print them to the screen
     print, cats[i]
     print, 'CAT ID   | m_i    | pi   |  d_pi | chisq |   ndof  |' 
     print, transpose([[t[good].obj_id], [reform(mags[2,good])], [par[good].parallax], [sqrt(par[good].covar[4,4])], $
                       [par[good].chisq], [par[good].ndof]]), format='((i8.8, 3x, 5(f0.2, 3x)))'

     ;- make some figures
     for j = 0, goodct - 1, 1 do begin
        file = strsplit(cats[i], '\.good\.sav', /extract, /regex)
        file = file[0]
        read_object, file, t[good[j]].obj_id, m2, t2
        lo = t2.off_measure
        hi = lo + t2.nmeasure - 1
        psfx = xpsf[lo:hi]
        psfy = ypsf[lo:hi]
        xfloor = skymodel_x[0,lo:hi]
        xfudge = skymodel_x[1,lo:hi]
        yfloor = skymodel_y[0,lo:hi]
        yfudge = skymodel_y[1,lo:hi]
        file = strsplit(file, '/',/extract)
        file = file[n_elements(file) - 1]
        reduce_object, m2, t2, $
                       xfloor, psfx, xfudge, $
                       yfloor, psfy, yfudge, $
                       a, b, c, pos, pm, par, $
                       /parplot, /verbose, /pmplot, $
                       ps = outfile+file+'.'+strtrim(t[good[j]].obj_id,2), $
                       title = file+'.'+strtrim(t[good[j]].obj_id,2)
        reduce_object, m2, t2, $
                       xfloor, psfx, xfudge, $
                       yfloor, psfy, yfudge, $
                       a, b, c, pos, pm, par, $
                       /parplot, /verbose, /pmplot, /bin, $
                       ps = outfile+file+'.'+strtrim(t[good[j]].obj_id,2)+'.bin', $
                       title =  file+'.'+strtrim(t[good[j]].obj_id,2)
     endfor
  endfor
  spawn, outfile+'join'
end
