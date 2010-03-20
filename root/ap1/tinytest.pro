pro tinytest

file='/users/cnb/glimpse/glimic/test.tbl'

openr,lun,file,/get_lun

fmt='(A26,A17,I10)'
record={a:' ',b:' ',c:0L}
readf,lun,record,format=fmt

print,record.a
print,record.b
print,record.c

free_lun,lun
end
