function get_score, letters, letter_bonus, word_bonus
  alphabet = ['a', 'b', 'c', 'd', 'e', 'f', 'g', $
              'h', 'i', 'j', 'k', 'l', 'm', 'n', $
              'o', 'p', 'q', 'r', 's', 't', 'u', $
              'v', 'w', 'x', 'y', 'z']
  points = [1, 4, 4, 2, 1, 4, 3, 3, 1, 10, 5, $ ;- a-k
            2, 4, 2, 1, 4, 10, 1, 1, 1, 2, 5, 4, 8, 3, 10]

  score = points[value_locate(alphabet, letters)] * letter_bonus
  score *= product(word_bonus)
  return, total(score)
end
            
pro test
  assert, get_score(['a','p','p','l','e'], [1,1,1,1,1], [1,1,1,1,1]) eq 12
  assert, get_score(['a','p','p','l','e'], [2,1,1,1,1], [1,1,1,1,1]) eq 13
  assert, get_score(['a','p','p','l','e'], [1,1,1,1,1], [2,1,1,1,1]) eq 24
  assert, get_score(['a','p','p','l','e'], [1,1,1,1,1], [2,2,1,1,1]) eq 48

end
