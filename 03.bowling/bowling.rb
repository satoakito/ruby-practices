# frozen_string_literal: true

scores = ARGV[0].split(',')
shots = []
scores.each do |score|
  if score == 'X' # strikeの場合は[10,0]
    shots << 10
    shots << 0
  else
    shots << score.to_i # その他の場合はそのまま
  end
end

# 1フレームごとの配列にまとめる
frames = []
shots.each_slice(2) do |s|
  s.pop if s[0] == 10 # ストライクの場合の0を消す
  frames << s
end

# 合計点を計算
total = 0
frames.each.with_index(1) do |frame, i|
  total += frame.sum
  if i == 10 && frame.sum == 10 # 10フレーム目でストライクかスペアの場合
    next
  elsif frame[0] == 10 && i <= 10 # 10フレーム未満でストライクの場合
    total += frames[i].sum
    total += frames[i + 1][0] if frames[i].size == 1
  elsif frame.sum == 10 && i <= 10 # 10フレーム未満でスペアの場合
    total += frames[i][0]
  end
end
puts total
