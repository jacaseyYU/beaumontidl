pro grsfetch

for i=32, 56, 2 do begin
str="curl http://grunt.bu.edu/grs-stitch/source/grs-"+strtrim(string(i),2)+"-cube.fits > /users/cnb/glimpse/grs/mosaic/"+strtrim(string(i),2)+".fits"

spawn,str

endfor

end
