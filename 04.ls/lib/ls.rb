def ls(row_num)
  files = Dir.glob("*") # ファイルリストを取得
  col_num = (files.length / row_num.to_f).ceil   # ファイル数から行数を計算
  row_file_arrays = files.each_slice(col_num).to_a   # 行数をもとにリストを分割
  indent_size = files.map {|file| file.length}.max + 2   # 一番長いファイル名＋2文字分のスペースを計算

  display_files(row_num, col_num, row_file_arrays, indent_size)
end

def display_files(row_num, col_num, row_file_arrays, indent_size)
  col_num.times do |col|
    row_num.times do |row|
      print row_file_arrays[row][col].to_s.ljust(indent_size)
    end
    puts
  end
end

ls(3)
