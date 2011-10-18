require 'rubygems'
require 'json'
require 'open-uri'

### ROTTEN TOMATOES: Return movie facts, based on user input ###
def search
  #For user input
  print "Movie title: "
  title = gets #take in movie title from command line
  title.chomp!.gsub!(' ', '+') # sub spaces for plus signs
  url = "http://api.rottentomatoes.com/api/public/v1.0/movies.json?apikey=hv4pzbs4n46nmv7s9w87nzwu&q=#{title}&page_limit=20"
  buffer = open(url).read

  # convert JSON data into a hash
  result = JSON.parse(buffer)
  return result
end

movie_list = search #List of movies that match the search

total_num = movie_list["total"] #Total number of search results
puts "Which of these #{total_num} films did you mean?"

#This section is purely for formatting the search output
count = 0
movie_list["movies"].each do |h| 
  print "#{count}) "
   if count <10
     print " "
   end
  print "Title: #{h["title"]}"
   if h["title"].length < 70
     print " "*(70-h["title"].length)
   end
  print "Year: #{h["year"]}"
  print "\n"
  count += 1
end

#Allow user to select a film from the search results
print "Enter the number of the film you want: "
num = gets.to_i

movie_sought = movie_list["movies"][num]

Id = movie_sought["id"]

# Pull up Movie Details

def get_movie
  url = "http://api.rottentomatoes.com/api/public/v1.0/movies/#{Id}.json?apikey=hv4pzbs4n46nmv7s9w87nzwu"
  buffer = open(url).read
  # convert JSON data into a hash
  result = JSON.parse(buffer)
  return result
end

movie_found = get_movie #movie_found is a hash that has the basic movie info

Movie = movie_found["title"].gsub(' ', '+') # Movie title only. Used for finding the movie within IMDB and metacritic. Subtitute spaces for plus signs

# Pull up reviewer's list

def get_critics
  url = "http://api.rottentomatoes.com/api/public/v1.0/movies/#{Id}/reviews.json?review_type=all&page_limit=20&page=1&country=us&apikey=hv4pzbs4n46nmv7s9w87nzwu"
  buffer = open(url).read
  # convert JSON data into a hash
  result = JSON.parse(buffer)
  return result
end   

# Method for converting fractions to decimals. Used immediately below
class String
  def to_frac
    numerator, denominator = split('/').map(&:to_f)
    denominator ||= 1
    numerator/denominator
  end
end

#Converts critic ratings, e.g. "A", "5/5", "78/100", to a 100 point scale
def score_convert(n) 
  score = 0
  if n.length <= 2 #if the score is in "A", "A+", "C-" form

    case n[0] #to account for the first letter
    when "A"
      score = 95
    when "B"
      score = 85
    when "C"
      score = 75
    when "D"
      score = 65
    else
      score = 50
    end
    
    case n[1] #to account for + and -
    when "+"
      score += 5
    when "-"
      score -=5
    end
  end 
  
  if n.include? "/"  #if the score is in X/Y form
    score = (n.to_frac*100).to_i
  end
  score
end

### IMDB ###

def imdb_search #returns the movie that the user selected, based on the Movie constant
  url = "http://www.imdbapi.com/?i=&t=#{Movie}"
  buffer = open(url).read

  # convert JSON data into a hash
  result = JSON.parse(buffer)
  return result
end

imdb_results = imdb_search

#Print out basic info (not individual critics' reviews)
print "Title: ", movie_found["title"], "\n"
print "Year: ", movie_found["year"], "\n"
print "Runtime: ", movie_found["runtime"], "\n"
print "RT Summary: ", movie_found["ratings"]["critics_rating"], "\n"
print "RT Critics Rating: ", movie_found["ratings"]["critics_score"], "\n"
print "IMDB Rating: ", imdb_results["Rating"], "\n"

#Print out individual critics' reviews
movie_critics = get_critics 

movie_critics["reviews"].each do |a| 
  if a["original_score"]
    puts "Critic: #{a["critic"]}"
    puts "Original Score: #{a["original_score"]}"
    converted_score = score_convert(a["original_score"])
    puts "Converted Score: #{converted_score}"
    puts "Quote: #{a["quote"]}"
    print "\n"
  end 
end
