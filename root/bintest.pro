pro bintest

dir = '~/catdir.98'
path = '/n0000/0148'
;m = mrdfits(dir + '/n0000/0148.cpm',1,h)
t = mrdfits(dir + path+'.cpt',1,h)

nt = n_elements(t)
nm = t[nt-1].off_measure + t[nt - 1].nmeasure - 1

flags = intarr(nm) - 1
