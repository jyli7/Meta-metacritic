require 'rubygems'
require 'json'
require 'open-uri'

#Return movie facts, based on user input
def search
  #For user input
  print "Movie title: "
  title = gets #take in movie title from command line
  title.chomp!.gsub!(' ', '+') # sub spaces for plus signs
  url = "http://api.rottentomatoes.com/api/public/v1.0/movies.json?apikey=hv4pzbs4n46nmv7s9w87nzwu&q=#{title}"
  buffer = open(url).read

  # convert JSON data into a hash
  result = JSON.parse(buffer)
  return result
end

movie_list = search

total_num = movie_list["total"]
puts "Which of these #{total_num} films did you mean?"

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

print "Enter the number of the film you want: "
num = gets.to_i

movie_sought = movie_list["movies"][num]

Id = movie_sought["id"]
### Pull up Movie Details ###

def get_movie
  url = "http://api.rottentomatoes.com/api/public/v1.0/movies/#{Id}.json?apikey=hv4pzbs4n46nmv7s9w87nzwu"
  buffer = open(url).read
  # convert JSON data into a hash
  result = JSON.parse(buffer)
  return result
end

movie_found = get_movie

print "Title: ", movie_found["title"], "\n"
print "Year: ", movie_found["year"], "\n"
print "Runtime: ", movie_found["runtime"], "\n"
movie_found["ratings"].each {|key, value| puts "#{key}: #{value}"}