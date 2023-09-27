require "tilt/erubis"
require "sinatra"
require "sinatra/reloader"

before do
  @contents = File.readlines("./data/toc.txt")
end

get "/" do
  @title = "Table of Contents"

  erb :home
end

get "/chapters/:number" do
  @ch_number = params[:number]
  @title = "Chapter #{@ch_number}: #{@contents[@ch_number.to_i - 1]}"
  redirect "/" unless (1..@contents.size).cover?(@ch_number.to_i)
  @chapter = split_into_paragraphs!(File.read("./data/chp#{@ch_number}.txt"))

  erb :chapter
end

get "/search" do
  @search_result = find_search_word(@contents, params[:query])

  erb :search
end

helpers do
  def split_into_paragraphs!(text)
    text = text.split("\n\n")
    text.map!.with_index do |para, idx|
      "<p id=paragraph#{idx}>#{para}</p>"
    end.join
  end

  def find_search_word(contents, query)
    result = []

    return result unless query

    contents.each_with_index do |chapter_name, idx|
      idx += 1
      paragraphs = get_paragraphs("./data/chp#{idx}.txt")
      matches = {}

      paragraphs.each_with_index do |para, idx|
        matches[idx] = para if para.include?(query)
      end

      result << {number: idx, chapter: chapter_name, paragraphs: matches} if matches.any?
    end

    result
  end

  def get_paragraphs(text)
    paragraphs = File.read(text).split("\n\n")
  end

  def highlight_matched_text(text, query)
    text.gsub(query, %(<strong>#{query}</strong>))
  end
end

not_found do
  "404: Page was not found."
end
