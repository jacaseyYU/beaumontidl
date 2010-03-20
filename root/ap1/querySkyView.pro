pro querySkyView,l,b,sz
;-limited tool to query sky view images in galactic coordinates
front='http://skyview.gsfc.nasa.gov/cgi-bin/images?'
position='Position='+strtrim(string(l),2)+','+strtrim(string(b),2)
coordinates='&Coordinates=Galactic'
survey='&Survey=CO2D'
Size=
