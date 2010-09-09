pro letter_values
  common letter_values, values
  values = intarr(256)

  alphabet = ['a', 'b', 'c', 'd', 'e', 'f', 'g', $
              'h', 'i', 'j', 'k', 'l', 'm', 'n', $
              'o', 'p', 'q', 'r', 's', 't', 'u', $
              'v', 'w', 'x', 'y', 'z']
  ;- words with friends scores
;  points = [1, 4, 4, 2, 1, 4, 3, 3, 1, 10, 5, $ ;- a-k
;            2, 4, 2, 1, 4, 10, 1, 1, 1, 2, 5, 4, 8, 3, 10]
  ;- traditional scores
  points = [1, 3, 3, 2, 1, 4, 2, 4, 1, 8, 5, $
            1, 3, 1, 1, 3, 10, 1, 1, 1, 1, 4, 4, 8, 4, 10]
  values[byte(alphabet)] = points
end
