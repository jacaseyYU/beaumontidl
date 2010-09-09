pro svm_cleanup
  spawn, 'rm /tmp/model.*', stdout, stderr
  spawn, 'rm /tmp/feature.*', stdout, stderr
  spawn, 'rm /tmp/predict', stdout, stderr
end
