# frozen_string_literal: true

def prepare_files
  if ARGV == []
    files = Dir.glob('*')
  else
    files = Dir.glob('*', base: ARGV[0]) if FileTest.directory?(ARGV[0])
    files = ARGV if FileTest.file?(ARGV[0])
  end

  col_num = 1
  col_num = (files.length / ROW_NUM.to_f).ceil if files.length > ROW_NUM

  split_list = files.sort_by { |s| [s.downcase, s] }.each_slice(col_num).to_a

  { col_num:, split_list:, item_width: calc_item_width(files) }
end

def calc_item_width(files)
  files.collect do |file|
    file_name_length = 0
    file.each_char do |char|
      file_name_length += 1
      file_name_length += 1 unless char.bytesize == 1
    end
    file_name_length += 2
  end.max
end

def display_files(col_num, split_list, item_width)
  col_num.times do |col|
    split_list.length.times do |row|
      break if !split_list[row][col]

      mb_count = 0
      split_list[row][col].each_char { |file| mb_count += 1 unless file.bytesize == 1 }
      print split_list[row][col].ljust(item_width - mb_count)
    end
    puts
  end
end

ROW_NUM = 3
list = prepare_files
display_files(list[:col_num], list[:split_list], list[:item_width])
