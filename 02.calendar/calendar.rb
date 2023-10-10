require "date"
require "optparse"

#オプション
opt = OptionParser.new
option = {}
opt.on('-m [VAL]') {|v| option[:m] = v }
opt.on('-y [VAL]') {|v| option[:y] = v }
opt.parse(ARGV)

#オプションから月を指定
case
when option[:m] == nil && option[:y] == nil
  today = Date.today
when option[:m] != nil && option[:y] == nil
  today = Date.new(Date.today.year, option[:m].to_i, 1)
when option[:m] != nil && option[:y] != nil
  today = Date.new(option[:y].to_i, option[:m].to_i, 1)
end

selected_year = today.year
selected_month = today.month

week = ["Su","Mo","Tu","We","Th","Fr","Sa"]

#初日の曜日と月末の日にち
start_day_wday = Date.new(selected_year,selected_month,1).wday
last_day = Date.new(selected_year,selected_month, -1).day

puts today.strftime("%B %Y").center(20)
puts week.join(" ")
print "   " * start_day_wday
(1..last_day).each do |date|
  print date.to_s.rjust(2)
  print " "
  print "\n" if Date.new(selected_year, selected_month, date).cwday == 6
end
print "\n "
