# frozen_string_literal: true

require 'optparse'
require 'etc'

ROW_NUM = 3
FILE_TYPE_SYMBOL = {
  'fifo' => ['p'],
  'characterSpecial' => ['c'],
  'directory' => ['d'],
  'blockSpecial' => ['b'],
  'file' => ['-'],
  'link' => ['l'],
  'socket' => ['s']
}.freeze
PERMISSION_SYMBOL = {
  '7' => 'rwx',
  '6' => 'rw-',
  '5' => 'r-w',
  '4' => 'r--',
  '3' => '-wx',
  '2' => '-w-',
  '1' => '--x',
  '0' => '---'
}.freeze

def load_files(option_a)
  if ARGV == [] || FileTest.directory?(ARGV[0])
    Dir.glob('*', option_a ? File::FNM_DOTMATCH : 0, base: ARGV[0] || nil)
  elsif FileTest.file?(ARGV[0])
    ARGV
  end
end

def sort_files(files, option_r)
  sorted_files = files.sort_by { |s| [s.match(/[^_.]+/).to_s.downcase, s] }
  sorted_files = sorted_files.reverse if option_r
  sorted_files
end

def prepare_files(sorted_files)
  col_num = 1
  col_num = (sorted_files.length / ROW_NUM.to_f).ceil if sorted_files.length > ROW_NUM

  prepared_files = sorted_files.each_slice(col_num).to_a

  { col_num:, prepared_files:, col_width: calc_col_width(sorted_files) }
end

def prepare_files_l_option(sorted_files)
  prepared_files = []
  sorted_files.each do |file|
    file_stat = File.lstat(ARGV[0] ? "#{ARGV[0]}/#{file}" : file)
    file_elements = {
      blocks: file_stat.blocks / 2, # OS標準とstatの差を吸収するため2で割っている
      mode: convert_mode(file_stat),
      link: file_stat.nlink.to_s,
      owner: Etc.getpwuid(file_stat.uid).name,
      group: Etc.getgrgid(file_stat.gid).name,
      size: file_stat.size.to_s,
      mtime: file_stat.mtime.strftime('%b %e %H:%M'),
      file_name: file
    }
    prepared_files << file_elements
  end
  prepared_files
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

def calc_col_width_l_option(files, item)
  files.map { |file| file[item] }.max_by(&:size).length + 1
end

def convert_mode(file_stat)
  converted_mode = []
  converted_mode << FILE_TYPE_SYMBOL[file_stat.ftype]
  mode_octal = format('%06d', file_stat.mode.to_s(8))
  (3..5).each do |i|
    converted_mode << PERMISSION_SYMBOL[mode_octal[i]]
  end
  converted_mode.join
end

def display_files(col_num, files, col_width)
  col_num.times do |col|
    files.length.times do |row|
      break if !files[row][col]

      col_width_mb = calc_col_width_mb(col_width, files[row][col])
      print files[row][col].ljust(col_width_mb)
    end
    puts
  end
end

def display_files_l_option(files)
  puts "total #{files.map { |f| f[:blocks] }.sum}"
  files.each do |file|
    print file[:mode].ljust(calc_col_width_l_option(files, :mode))
    print file[:link].ljust(calc_col_width_l_option(files, :link))
    print file[:owner].ljust(calc_col_width_l_option(files, :owner))
    print file[:group].ljust(calc_col_width_l_option(files, :group))
    print "#{file[:size].rjust(calc_col_width_l_option(files, :size) - 1)} " # sizeのみ右寄せのためスペース調整
    print file[:mtime].ljust(calc_col_width_l_option(files, :mtime))
    print file[:file_name]
    print " -> #{File.readlink(File.expand_path("#{ARGV[0]}/#{file[:file_name]}"))}" if file[:mode][0] == 'l'
    puts
  end
end

opt = OptionParser.new
option = {}
opt.on('-a') { |v| option[:a] = v }
opt.on('-r') { |v| option[:r] = v }
opt.on('-l') { |v| option[:l] = v }
opt.parse!(ARGV)

sorted_files = sort_files(load_files(option[:a]), option[:r])

if option[:l]
  display_files_l_option(prepare_files_l_option(sorted_files))
else
  list = prepare_files(sorted_files)
  display_files(list[:col_num], list[:prepared_files], list[:col_width])
end
