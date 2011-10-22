#!/usr/bin/env ruby

require 'rubygems'
require 'json'
require 'open-uri'
require 'nokogiri'

# Method for converting fractions to decimals. Used below in "calculate_average" method.
def frac_to_float(str)
    numerator, denominator = str.split("/").map(&:to_f)
    denominator ||= 1
    numerator/denominator
end

def identify_movie(title) 
  def search(title)  
    url = "http://api.rottentomatoes.com/api/public/v1.0/movies.json?apikey=hv4pzbs4n46nmv7s9w87nzwu&q=#{title}&page_limit=20"
    buffer = open(url).read

    # convert JSON data into a hash
    result = JSON.parse(buffer)
  end

  #Format and produce the search output
  def search_output(movie_list)
    count = 0
    movie_list["movies"].each do |h| 
      print "#{count}) "
       if count <10
         print " " #Ensure that first column is 2 spaces wide
       end
      print "Title: #{h["title"]}"
       if h["title"].length < 70
         print " "*(70-h["title"].length) #Ensure that first column is 70 spaces wide
       end
      print "Year: #{h["year"]}"
      print "\n"
      count += 1
    end
  end

  #Allow user to select a film from the search results
  def user_select(movie_list)
    print "Enter the number of the film you want: "
    num = gets.to_i
    movie_sought = movie_list["movies"][num]
  end
  
  # RUN FUNCTIONS IN IDENTIFY_MOVIE #
  movie_list = search(title) #List of movies that match the search
  total_num = movie_list["total"] #Total number of search results
  puts "Which of these #{total_num} films did you mean?" #Ask user to identify the film they want to examine
  search_output(movie_list)
  user_select(movie_list)
end 

def rt(id)

  def get_movie(id)
    url = "http://api.rottentomatoes.com/api/public/v1.0/movies/#{id}.json?apikey=hv4pzbs4n46nmv7s9w87nzwu"
    buffer = open(url).read
    # convert JSON data into a hash
    result = JSON.parse(buffer)
    return result
  end

  # Pull up reviewers list

  def get_all_critics(id)
    print "All critics, or just top critics? (all/top): "
    type = gets.chomp!
    if type == "top"
      url = "http://api.rottentomatoes.com/api/public/v1.0/movies/#{id}/reviews.json?review_type=top_critic&country=us&apikey=hv4pzbs4n46nmv7s9w87nzwu"
    elsif
      url = "http://api.rottentomatoes.com/api/public/v1.0/movies/#{id}/reviews.json?review_type=all&page_limit=30&page=1&country=us&apikey=hv4pzbs4n46nmv7s9w87nzwu"
    end
    buffer = open(url).read
    # convert JSON data into a hash
    result = JSON.parse(buffer)
    return result
  end 

  #Form the list of critics, let users exclude critics
  def filter_critics(movie_critics)

    #Print out list of critics that have numerical reviews
    count = 0 
    movie_critics["reviews"].each do |a| 
      if a["original_score"]
        puts "#{count}) Critic: #{a["critic"]}"
      end
      count += 1
    end

    print "Which critics to exclude? (identify critic by number; put spaces between numbers; type \"n\" if none):"
    temp = gets
    unless temp == "n\n"
      critic_num_to_exclude = temp.split(' ')
      critic_num_to_exclude.collect!{|i| i.to_i } #convert array values to numbers

      critic_to_exclude = []

      critic_num_to_exclude.each do |n| #form an array of excluded critics reviews
        critic_to_exclude << movie_critics["reviews"][n] 
      end  

      critic_to_exclude.each do |c| #delete excluded critics reviews from main array of review
        movie_critics["reviews"].delete(c)
      end 

      critics_list = critic_to_exclude.collect {|c| c["critic"]}
      print "Excluded critics: #{critics_list} \n" 
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
        score += 3
      when "-"
        score -=3
      end
    end 
    if n.include? "/"  #if the score is in X/Y form
      score = (frac_to_float(n)*100).to_i
    end
    score
  end

  def display_final_stats(movie_critics)
    sum = 0
    count = 0
    movie_critics["reviews"].each_with_index do |a, index| 
      if a["original_score"] 
        puts "#{index}) "
        puts "Critic: #{a["critic"]}"
        puts "Original Score: #{a["original_score"]}"

        converted_score = score_convert(a["original_score"])
        puts "Converted Score: #{converted_score}"
        sum += converted_score 
      
        puts "Quote: #{a["quote"]}"
        print "\n"
        count += 1
      end
    end
    #Calculates average converted score, for all RT critics
    avg_converted_score = ((sum.to_f)/count)
    printf("Rotten tomatoes: %.2f", "#{avg_converted_score}")
    print "\n"
    return avg_converted_score
  end 
  
  # RUN FUNCTIONS #
  movie_found = get_movie(id) #movie_found is a hash that has the basic movie info
  movie_critics = get_all_critics(id) 
  filter_critics(movie_critics)
  show_movie_details_score = display_final_stats(movie_critics) 
end 

def imdb(title) #returns the movie that the user selected

  def get_movie(title)
    url = "http://www.imdbapi.com/?i=&t=#{title}"
    buffer = open(url).read

    # convert JSON data into a hash
    result = JSON.parse(buffer)
    return result
  end

  movie_found = get_movie(title) #movie_found is a hash that has the basic movie info
  
  #Print out basic info (not individual critics reviews)
  print "IMDB Rating: ", movie_found["Rating"], "\n\n"
  print "Title: ", movie_found["Title"], "\n"
  print "Year: ", movie_found["Year"], "\n"
  print "Runtime: ", movie_found["Runtime"], "\n"
  print "\n"
  return (movie_found["Rating"].to_f)*10
end

def metacritic(title)
  #insert metacritic scraping here
  movie = Nokogiri::HTML(open("http://www.metacritic.com/movie/#{title}"))
  rating = movie.at_css(".score_value").text
  print "Metacritic: ", rating, "\n"
  return rating
end


def in_theaters
  url = "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/in_theaters.json?page_limit=25&page=1&country=us&apikey=hv4pzbs4n46nmv7s9w87nzwu"
  buffer = open(url).read

  # convert JSON data into a hash
  result = JSON.parse(buffer)
  movies = result["movies"]
  movies.sort! {|x, y| x["ratings"]["critics_score"] <=> y["ratings"]["critics_score"]}
  movies.reverse!
  
  puts "Current Releases"
  
  print "Score", " "*2, "Title", "\n"
  movies.each do |h|
    score = h["ratings"]["critics_score"]
    print score
    if score.to_s.length == 1
      print " "*6
    else
      print " "*5
    end 
    puts h["title"]
  end
end 
  
temp = in_theaters  

#Ask user to enter a title
print "Movie title (search entire Rotten Tomatoes database): "
title = gets #take in movie title from command line
title.chomp!.gsub!(' ', '+') # sub spaces for plus signs

#Find the movie, based on the user's input
movie = identify_movie(title)

#Reformat the title, so IMDB and MC will recognize it
title_for_imdb = movie["title"].downcase.gsub(" ", "+")
title_for_mc = movie["title"].downcase.gsub(" ", "-")

#Use ID to find the movie in RT
id = movie["id"]

#Run the 3 main functions for RT, IMDB, and MC
rt_score = rt(id) 
mc_score = metacritic(title_for_mc).to_i
imdb_score = imdb(title_for_imdb) 

#Let users define weights
print "Want a meta-metascore? How much weight to Rotten Tomatoes? (0-1): "
rt_weight = gets.to_f
printf("How much weight to metacritic? (0 - %.2f): ", (1-rt_weight))
mc_weight = gets.to_f
imdb_weight = 1-(rt_weight+mc_weight)
printf("Weight to imdb is %.2f", imdb_weight)
print "\n"

#Calculate and display the meta-metascore
meta_meta_score = rt_score*rt_weight + imdb_score*imdb_weight + mc_score*mc_weight
print "\n"
printf("Meta-metascore: %.2f", meta_meta_score)
print "\n\n"
