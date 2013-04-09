#! ruby -EUTF-8
# -*- mode:ruby; coding:utf-8 -*-

#Load module
require 'find'

# Initialize
keywords = []

# Picking up keywords for localization
# Get Current Directory + /keywords/src
keyword_src_path = Dir::getwd + "/keywords/src"
# Find keyword_src_path file and put into path variable
Find.find(keyword_src_path) do |path|
  #is directory do next process
  #== next if File.directory?(path)
  next unless !File.directory?(path)
  #substring[data,number]
  #equals "list" step next process
  if path[path.length-"list".length, "list".length] === "list" then
    text_fetch_flag = false
    text_en = ""
    text_jp = ""
    #read File data
    source_file = IO.readlines path
    source_file.each do |data|
      #remove kaigyo
      data = data.chomp
      if data.length > 0 then
        if text_fetch_flag then
          text_jp = data
          text_fetch_flag = false
        else
	  #regrex ' " ? () * []
          text_en = data.gsub(/([\'\?"\(\)\*\[\]])/, "\\\\\\1")
          text_fetch_flag = true
        end
      else
        if text_jp != "" && text_en != "" then
	  #Create HashMap key en,jp value text_en,text_jp
          keywords << {
            :en => text_en,
            :jp => text_jp
          }
          text_en = ""
          text_jp = ""
          text_fetch_flag = false
        end
      end
    end
    if text_jp != "" && text_en != "" then
          keywords << {
            :en => text_en,
            :jp => text_jp
          }
    end
  end
end

# Replacing the keywords
text = File.read( Dir::getwd + "/learnGitBranching/build/bundle.js")
keywords.each do |data|
  if !text.gsub!(/#{data[:en]}/, data[:jp]) then
    # Keywords failed to replace will be informed
    puts data[:en]
    puts data[:jp]
  end
end

File.open(Dir::getwd + "/learnGitBranching/build/bundle-ja.js",'w'){|f|
  f.write text
}
