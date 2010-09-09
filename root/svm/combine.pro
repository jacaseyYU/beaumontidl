pro combine
  restore, 'train_x_cloud.sav' & m = mask
  restore, 'train_y_cloud.sav' & mask = mask or m
  save, mask, file='train_cloud.sav'

  restore, 'train_x_notcloud.sav' & m = mask
  restore, 'train_y_notcloud.sav' & mask or= m
  save, mask, file='train_notcloud.sav'
  return

  restore, 'train_x172_cloud.sav' & m = mask
  restore, 'train_x232_cloud.sav' & mask  = mask or m
  save, mask, file='train_x_cloud.sav'

  restore, 'train_y142_cloud.sav' & m = mask
  restore, 'train_y190_cloud.sav' & mask = mask or m
  save, mask, file='train_y_cloud.sav'
  return

  restore, 'train_x172_snr.sav' & m = mask
  restore, 'train_x172_bg.sav' & mask = mask or m
  save, mask, file='train_x172_notcloud.sav'
  m172 = mask
  restore, 'train_x232_snr.sav' & m = mask
  restore, 'train_x232_bg.sav' & mask = mask or m
  save, mask, file='train_x232_notcloud.sav'
  mask = mask or m172
  maskx = mask
  save, mask, file='train_x_notcloud.sav'


  restore, 'train_y142_snr.sav' & m = mask
  restore, 'train_y142_bg.sav' & mask = mask or m
  save, mask, file='train_y142_notcloud.sav'
  m142 = mask
  restore, 'train_y190_snr.sav' & m = mask
  restore, 'train_y190_bg.sav' & mask = mask or m
  save, mask, file='train_y190_notcloud.sav'
  mask = mask or m142
  masky = mask
  save, mask, file='train_y_notcloud.sav'
  mask = masky or maskx
  save, mask, file='train_notcloud.sav'
  return


  restore, 'train_x172_snr.sav' & m = mask
  restore, 'train_x232_snr.sav' & mask = mask or m
  save, mask, file='train_x_snr.sav'
  mask_snr_x = mask
  return

  restore, 'train_y142_snr.sav' & m = mask
  restore, 'train_y190_snr.sav' & mask = mask or m
  save, mask, file='train_y_snr.sav'
  mask = mask or mask_snr_x
  save, mask, file='train_all_snr.sav'

  restore, 'train_x172_notsnr.sav' & m = mask
  restore, 'train_x232_notsnr.sav' & mask = mask or m
  save, mask, file='train_x_notsnr.sav'
  mask_notsnr_x = mask

  restore, 'train_y142_bg.sav' & m = mask
  restore, 'train_y142_cloud.sav' & mask = mask or m
  save, mask, file='train_y142_notsnr.sav'
  y142 = mask

  restore, 'train_y190_bg.sav' & m = mask
  restore, 'train_y190_cloud.sav' & mask = mask or m
  save, mask, file='train_y190_notsnr.sav'
  mask = mask or y142
  save, mask, file='train_y_notsnr.sav'
  mask = mask or mask_notsnr_x
  save, mask, file='train_all_notsnr.sav'
  return


  restore, 'train_x172_bg.sav' & m = mask
  restore, 'train_x172_cloud.sav'
  mask = mask or m
  save, mask, file='train_x172_notsnr.sav'


  restore, 'train_x232_bg.sav' & m = mask
  restore, 'train_x232_cloud.sav'
  mask = mask or m
  save, mask, file='train_x232_notsnr.sav'

  restore, 'train_y142_bg.sav' & m = mask
  restore, 'train_y142_cloud.sav'
  mask = mask or m
  save, mask, file='train_y142_notsnr.sav'


  restore, 'train_y190_bg.sav' & m = mask
  restore, 'train_y190_cloud.sav'
  mask = mask or m
  save, mask, file='train_y190_notsnr.sav'


end
