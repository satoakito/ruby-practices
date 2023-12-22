# frozen_string_literal: true

require 'optparse'

def exec_wc(option)
  total_elements = { lines: 0, words: 0, bytes: 0, name: 'total' }
  ARGV.each_with_index do |file, i|
    str = File.read(file)
    counted_elements = { lines: count_lines(str), words: count_words(str), bytes: count_bytes(str), name: ARGV[i] }
    total_elements[:lines] += counted_elements[:lines]
    total_elements[:words] += counted_elements[:words]
    total_elements[:bytes] += counted_elements[:bytes]
    display_result(counted_elements, option)
  end
  display_result(total_elements, option) if ARGV.length > 1
end

def exec_wc_stdin(option)
  str = $stdin.read
  counted_elements = { lines: count_lines(str), words: count_words(str), bytes: count_bytes(str) }
  display_result_stdin(counted_elements, option)
end

def count_lines(str)
  str.scan(/\n/).size
end

def count_words(str)
  str.scan(/\S+/).size
end

def count_bytes(str)
  str.bytesize
end

def count_digits(int)
  int.values.map { |n| n.to_s.length }.max
end

#  indentはオプションが1つだけ指定された場合に出力が左寄せになるよう調整
def display_result(elements, option)
  indent = option.one? ? 0 : count_digits(elements.slice(:lines, :words, :bytes))
  print "#{elements[:lines].to_s.rjust(indent)} " if option[:l]
  print "#{elements[:words].to_s.rjust(indent)} " if option[:w]
  print "#{elements[:bytes].to_s.rjust(indent)} " if option[:c]
  puts elements[:name]
end

def display_result_stdin(elements, option)
  indent = count_digits(elements)
  indent = 7 if indent < 7
  indent = 0 if option.one?

  print "#{elements[:lines].to_s.rjust(indent)} " if option[:l]
  print "#{elements[:words].to_s.rjust(indent)} " if option[:w]
  print "#{elements[:bytes].to_s.rjust(indent)} " if option[:c]
  puts
end

opt = OptionParser.new
option = {}
opt.on('-l') { |v| option[:l] = v }
opt.on('-w') { |v| option[:w] = v }
opt.on('-c') { |v| option[:c] = v }
opt.parse!(ARGV)
option = { l: true, w: true, c: true } if option.none?

if ARGV.empty?
  exec_wc_stdin(option)
else
  exec_wc(option)
end
