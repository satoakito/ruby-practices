# frozen_string_literal: true

require 'optparse'

def prepare_files
  opt = OptionParser.new
  option = {}
  opt.on('-a') { |v| option[:a] = v }
  opt.on('-r') { |v| option[:r] = v }
  opt.parse!(ARGV)

  files = load_files(option[:a])
  col_num = 1
  col_num = (files.length / ROW_NUM.to_f).ceil if files.length > ROW_NUM

  divided_files = files.sort_by { |s| [s.match(/[^.]+/).to_s.downcase, s] }
  divided_files = divided_files.reverse if option[:r]
  divided_files = divided_files.each_slice(col_num).to_a

  { col_num:, divided_files:, col_width: calc_col_width(files) }
end

def load_files(option_a)
  if ARGV == [] || FileTest.directory?(ARGV[0])
    Dir.glob('*', option_a ? File::FNM_DOTMATCH : 0, base: ARGV[0] || nil)
  elsif FileTest.file?(ARGV[0])
    ARGV
  end
end

def calc_col_width(files)
  files.collect do |file|
    col_width = 0
    file.each_char do |char|
      col_width += 1
      col_width += 1 unless char.bytesize == 1
    end
    col_width += 2
  end.max
end

def calc_col_width_mb(col_width, file)
  mb_count = 0
  file.each_char { |char| mb_count += 1 unless char.bytesize == 1 }
  col_width - mb_count
end

def display_files(col_num, divided_files, col_width)
  col_num.times do |col|
    divided_files.length.times do |row|
      break if !divided_files[row][col]

      col_width_mb = calc_col_width_mb(col_width, divided_files[row][col])
      print divided_files[row][col].ljust(col_width_mb)
    end
    puts
  end
end

ROW_NUM = 3
list = prepare_files
display_files(list[:col_num], list[:divided_files], list[:col_width])
