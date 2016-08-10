require 'terminal-table'
require 'date'
require 'json'

# require 'base64'
# require 'aescrypt'
# require 'dotenv'
# require 'awesome_print'
# encrypted_data = AESCrypt.encrypt(message, password)
# crypted_data = AESCrypt.decrypt(encrypted_data, password)
# a = Dotenv.load

def get_files 
  
  files = Dir.entries("info")
  files.keep_if { |a| a.end_with? ".json" }
  for i in (0..files.count-1)
    files[i] = files[i].gsub(".json","")
  end

  return files

end

def pre_process
  unless Dir.exists? "info"
    Dir.mkdir("info")
    #system "sudo chown root info/"
    #system "sudo chmod +700 info/"
  end
  unless File.exists? "Data"
    autocomplete() 
  end
end

def autocomplete

  files = get_files()
  
  autocomplete = "_Data() \n { \n local cur prev opts \n   COMPREPLY=() \n  cur=\"${COMP_WORDS[COMP_CWORD]}\" \n   prev=\"${COMP_WORDS[COMP_CWORD-1]}\" \n   opts=\"New Existing Delete\" \n   case \"$prev\" in
      New) \n  COMPREPLY=() \n  return 0 \n        ;; \n     Delete) \n         COMPREPLY=( $(compgen -W \"#{files.join(" ")}\" -- $cur) ) \n         return 0 \n         ;; \n     Existing) \n COMPREPLY=( $(compgen -W \"#{files.join(" ")}\" -- $cur) ) \n       return 0 \n       ;; \n     *) \n         local prev2=\"${COMP_WORDS[COMP_CWORD-2]}\" \n         if [ \"$prev2\" == \"New\" ];then \n             return 0 \n         fi \n         if [ \"$prev2\" == \"Existing\" ];then \n          opts2=\"Data_Add Data_Edit Data_Delete Data_Show Column_Add Column_Edit Column_Delete Column_Show\" \n           COMPREPLY=( $(compgen -W \"$opts2\" -- $cur) ) \n           return 0 \n         fi \n         ;; \n 
      esac  \n COMPREPLY=( $(compgen -W \"$opts\" -- $cur) ) \n   return 0 \n } \n complete -F _Data Data"

  File.delete("Data") if File.exists? "Data"
  File.open("Data", 'a') { |f| f.write(autocomplete) }


end

def add file
  if get_files().include? file
    puts "#{file} already exists. Use keyword Existing, instead of New."
  else
    info = []
    info[0] , info[1] = {} , []
    puts "How many columns to store data?"    
    info[0]["nColumns"] , info[0]["Columns"] = gets.chomp.to_i , []
    for i in (0..info[0]["nColumns"]-1)
      puts "Enter title for Column ##{i+1} : "
      col = gets.chomp
      info[0]["Columns"].push(col)
    end 
    Dir.chdir("info")
    File.open("#{file}.json", "a") { |f| f.write(JSON.generate(info)) }
    Dir.chdir("..")
    autocomplete()
    puts "Successfully created #{file}."
  end
end

def delete file
  if get_files().include? file
    choice  = ""
    while !(["Y","N"].include? choice)
      puts "Are you sure you want to delete #{file}? (Y/N) : "
      choice = gets.chomp.upcase
      if choice == "Y"
        Dir.chdir("info")
        File.delete("#{file}.json")
        Dir.chdir("..") 
        autocomplete()
        puts "Succesfully deleted #{file}."
      elsif choice == "N"
        puts "Successfully cancelled deletion of #{file}."
      else
        puts "Couldn't recognise choice given for Y/N."
      end
    end
  else
    puts "#{file} doesn't exist."
  end
end

def existing_add file

  if get_files().include? file
    Dir.chdir("info")
    info , data = JSON.parse(File.read("#{file}.json")) , {}
    data = {}
    data["ID"] = info[1].count == 0 ? 1 : (info[1].last["ID"] + 1)
    data["Date"] = Date.today.strftime("%d/%m/%y")
    for i in (0..info[0]["nColumns"]-1)
      puts "Input the data for #{info[0]["Columns"][i]} : "
      data["#{info[0]["Columns"][i]}"] = gets.chomp
    end
    info[1].push(data)
    File.delete("#{file}.json")
    File.open("#{file}.json", "a") { |f| f.write(JSON.generate(info)) }
    Dir.chdir("..")
    puts "Succesfully added data."
  else
    puts "File doesn't exist with name #{file}."
  end

end

def existing_edit file
  
  if get_files().include? file
    Dir.chdir("info")
    info = JSON.parse(File.read("#{file}.json"))
    puts "Enter ID of data to edit : "
    id = gets.chomp.to_i
    index = info[1].find_index { |row| row["ID"] == id }
    if index.nil? 
      puts "Data with such an ID doesn't exist."
    else
      info[1][index]["Date"] = Date.today.strftime("%d/%m/%y")
      for i in (0..info[0]["nColumns"]-1)
        col = info[0]["Columns"][i]
        puts "Edit the data for #{col} from #{info[1][index][col]} to : "
        get = gets.chomp
        if get.length == 0
          puts "No edit made - data (#{info[1][index][col]}) remains unchanged. "
        else
          info[1][index][col] = get
        end
      end
      File.delete("#{file}.json")
      File.open("#{file}.json", "a") { |f| f.write(JSON.generate(info)) }
      puts "Succesfully edited data."
    end
    Dir.chdir("..")  
  else
    puts "File doesn't exist with name #{file}."
  end

end

def existing_delete file

  if get_files().include? file
    Dir.chdir("info")
    info = JSON.parse(File.read("#{file}.json"))
    puts "Enter ID of data to delete : "
    id = gets.chomp.to_i
    index = info[1].find_index { |row| row["ID"] == id }
    if index.nil? 
      puts "Data with such an ID doesn't exist."
    else
      choice  = ""
      while !(["Y","N"].include? choice)
        puts "Are you sure you want to delete data with ID ##{id}? (Y/N) : "
        choice = gets.chomp.upcase
        if choice == "Y"
          data = info[1][index]
          info[1].delete(data)
          File.delete("#{file}.json")
          File.open("#{file}.json", "a") { |f| f.write(JSON.generate(info)) }
          puts "Succesfully deleted data with ID ##{id}."
        elsif choice == "N"
          puts "Successfully cancelled deletion of data with ID ##{id}."
        else
          puts "Couldn't recognise choice given for Y/N."
        end
      end
    end
    Dir.chdir("..")  
  else
    puts "File doesn't exist with name #{file}."
  end

end

def existing_show file

  if get_files().include? file
    Dir.chdir("info")
    info = JSON.parse(File.read("#{file}.json"))
    Dir.chdir("..")
    heading_list , row_list = ['ID' , 'DATE'] , []
    info[0]["Columns"].each do |head|
      heading_list.push(head)
    end
    info[1].each do |data|
      row_list.push(data.values)
    end 
    table = Terminal::Table.new :title => "#{file.upcase} - Found #{info[1].count} objects", :headings => heading_list, :rows => row_list, :style => { :alignment => :center, :border_x => "=", :border_i => "="}
    puts table     
  else
    puts "File doesn't exist with name #{file}."
  end

end

def existing_column_add file

  if get_files().include? file
    Dir.chdir("info")
    info = JSON.parse(File.read("#{file}.json"))
    puts "How many columns to add to store data?"    
    nColumns = gets.chomp.to_i 
    info[0]["nColumns"] = info[0]["nColumns"] + nColumns
    for i in (0..nColumns-1)
      puts "Enter title for new Column ##{i+1} : "
      col = gets.chomp
      puts "Enter default value for Column #{col} : "
      default = gets.chomp
      info[0]["Columns"].push(col)
      for j in (0..info[1].count-1)
        info[1][j][col] = default
      end
    end 
    File.delete("#{file}.json")
    File.open("#{file}.json", "a") { |f| f.write(JSON.generate(info)) }
    Dir.chdir("..")
    puts "Successfully created #{file}."
  else
    puts "#{file} already exists. Use keyword Existing, instead of New."
  end

end

def existing_column_edit file

  if get_files().include? file
    Dir.chdir("info")
    info = JSON.parse(File.read("#{file}.json"))
    puts "Enter ID of column to edit : "
    id = gets.chomp.to_i
    if ((id <= info[0]["nColumns"]) && (id >= 1)) 
      puts "Edit the column #{info[0]["Columns"][id-1]} to : "
      info[0]["Columns"][id-1] = gets.chomp.to_s      
      File.delete("#{file}.json")
      File.open("#{file}.json", "a") { |f| f.write(JSON.generate(info)) }
      puts "Succesfully edited column ##{id} to #{info[0]["Columns"][id-1]}."
    else
      puts "Data with such an ID doesn't exist."      
    end
    Dir.chdir("..")  
  else
    puts "File doesn't exist with name #{file}."
  end  

end

def existing_column_delete file

  if get_files().include? file
    Dir.chdir("info")
    info = JSON.parse(File.read("#{file}.json"))
    puts "Enter ID of column to delete : "
    id = gets.chomp.to_i
    if ((id <= info[0]["nColumns"]) && (id >= 1)) 
      choice  = ""
      while !(["Y","N"].include? choice)
        puts "Are you sure you want to delete the column \"#{info[0]["Columns"][id-1]}\" with ID ##{id}? (Y/N) : "
        choice = gets.chomp.upcase
        if choice == "Y"
          info[0]["nColumns"] = info[0]["nColumns"] - 1
          info[1].each { |row| row.delete info[0]["Columns"][id-1] }
          info[0]["Columns"].delete_at(id-1)
          File.delete("#{file}.json")
          File.open("#{file}.json", "a") { |f| f.write(JSON.generate(info)) }
          puts "Succesfully deleted column with ID ##{id}."
        elsif choice == "N"
          puts "Successfully cancelled deletion of column with ID ##{id}."
        else
          puts "Couldn't recognise choice given for Y/N."
        end
      end
    Dir.chdir("..")
    else
      puts "Data with such an ID doesn't exist."      
    end      
  else
    puts "File doesn't exist with name #{file}."
  end

end

def existing_column_show file

  if get_files().include? file
    Dir.chdir("info")
    info = JSON.parse(File.read("#{file}.json"))
    Dir.chdir("..")
    heading_list , row_list = ['ID' , 'COLUMN'] , []
    for i in (0..info[0]["nColumns"]-1)
      row_list.push([i+1,info[0]["Columns"][i]])
    end 
    table = Terminal::Table.new :title => "#{file.upcase} - Found #{info[0]["nColumns"]} columns", :headings => heading_list, :rows => row_list, :style => { :alignment => :center, :border_x => "=", :border_i => "="}
    puts table     
  else
    puts "File doesn't exist with name #{file}."
  end

end

def existing file , func 

  puts ""
  if func == "Data_Add"
    existing_add(file)
  elsif func == "Data_Edit"
    existing_edit(file)
  elsif func == "Data_Delete"
    existing_delete(file)
  elsif func == "Data_Show"
    existing_show(file)  
  elsif func == "Column_Add"
    existing_column_add(file)
  elsif func == "Column_Edit"
    existing_column_edit(file)
  elsif func == "Column_Delete"
    existing_column_delete(file)
  elsif func == "Column_Show"
    existing_column_show(file)
  else
    puts "Couldn't recognise the functionality type."
  end
  puts ""

end

def process mode , file , func

  pre_process()
  if mode == "New"
    add(file)
  elsif mode == "Delete"
    delete(file)
  elsif mode == "Existing"
    existing(file,func)
  else
    puts "Sorry, can't recognize this command."
  end
   
end

mode , file , func = ARGV[0] , ARGV[1] , ARGV[2]
ARGV.clear
process(mode,file,func)
