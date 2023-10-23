# frozen_string_literal: true

# 必要な要素を設定
def ls(row_num)
  if ARGV == []
    # 引数がない場合はCDのリストを取得
    files = Dir.glob('*')
  else
    # 引数がディレクトリだった場合はそこを起点にリスト取得
    files = Dir.glob('*', base: ARGV[0]) if FileTest.directory?(ARGV[0])
    # 引数がファイル名だった場合はそのまま返す
    files = ARGV if FileTest.file?(ARGV[0])
  end

  # 行数・列数
  if files.length > row_num
    col_num = (files.length / row_num.to_f).ceil
  else
    col_num = 1
    row_num = files.length
  end

  # 行・列・列数をもとに分割したリスト・インデントの数を返す
  { row_num:, col_num:, processed_array: files.each_slice(col_num).to_a, item_width: calc_item_width(files) }
end

# 表示幅の設定
def calc_item_width(files)
  files.collect do |file|
    file_name_length = 0
    file.each_char do |char|
      file_name_length += 1 if char.bytesize == 1
      file_name_length += 2 unless char.bytesize == 1
    end
    file_name_length + 2
  end.max
end

# 出力
def display_files(row_num, col_num, processed_array, item_width)
  col_num.times do |col|
    row_num.times do |row|
      break if !processed_array[row][col]

      mb_count = 0
      processed_array[row][col].each_char { |file| mb_count += 1 unless file.bytesize == 1 }
      print processed_array[row][col].to_s.ljust(item_width - mb_count)
    end
    puts
  end
end

ls_elements = ls(3)
display_files(ls_elements[:row_num], ls_elements[:col_num], ls_elements[:processed_array], ls_elements[:item_width])
