function venn, a, b, clusters

  lo = min([a,b], max=hi)
  ah = histogram([a], min=lo, max = hi, loc = l )
  bh = histogram([b], min=lo, max = hi)

  ah <= 1 & bh <= 1

  anotb = where(ah and ~bh, ct1)
  anotb = ct1 eq 0 ? -1 : l[anotb]

  bnota = where(bh and ~ah, ct2)
  bnota = ct2 eq 0 ? -1 : l[bnota]

  ab = where(ah and bh, ct3)
  ab = ct3 eq 0 ? -1 : l[ab]
  return, {anotb: anotb, anotbct: ct1, $
           bnota: bnota, bnotact: ct2, $
           ab:ab, abct: ct3}
end
