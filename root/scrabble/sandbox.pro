pro sandbox_event, ev
end
pro sandbox
  tlb = widget_base()
  board = scrabble(tlb)
  widget_control, tlb, /realize
  xmanager, 'sandbox', tlb, /no_block
end
