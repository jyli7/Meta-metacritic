require 'rubygems'
require 'json'
require 'open-uri'
require 'nokogiri'
'''
Objects
  Movie
    Properties
      Title
      Date
      Overall Rating
      Reviews
    Methods
'''


# Method for converting fractions to decimals. Used below in "calculate_average" method.
def frac_to_float(str)
    numerator, denominator = str.split("/").map(&:to_f)
    denominator ||= 1
    numerator/denominator
end

### ROTTEN TOMATOES: Return movie facts, based on user input ###

#find_movie: search through RT
#user select

#Ask user to enter a title
print "Movie title: "
title = gets #take in movie title from command line
title.chomp!.gsub!(' ', '+') # sub spaces for plus signs

'''

def rt(title)
  
  def find_movie(title)
    def search(title)  
      url = "http://api.rottentomatoes.com/api/public/v1.0/movies.json?apikey=hv4pzbs4n46nmv7s9w87nzwu&q=#{title}&page_limit=20"
      buffer = open(url).read

      # convert JSON data into a hash
      result = JSON.parse(buffer)
    end
  
    movie_list = search(title) #List of movies that match the search
    
    total_num = movie_list["total"] #Total number of search results

    puts "Which of these #{total_num} films did you mean?" #Ask user to identify the film they want to examine

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
  
    search_output(movie_list)

    #Allow user to select a film from the search results
    def user_select(movie_list)
      print "Enter the number of the film you want: "
      num = gets.to_i
      movie_sought = movie_list["movies"][num]
      movie_sought["id"]
    end
  
    user_select(movie_list)
  end 

  id = find_movie(title)

  # Pull up Movie Details

  def show_movie_details(id)
  
    def get_movie(id)
      url = "http://api.rottentomatoes.com/api/public/v1.0/movies/#{id}.json?apikey=hv4pzbs4n46nmv7s9w87nzwu"
      buffer = open(url).read
      # convert JSON data into a hash
      result = JSON.parse(buffer)
      return result
    end

    movie_found = get_movie(id) #movie_found is a hash that has the basic movie info

    movie = movie_found["title"].gsub(" ", "+") # Movie title only. Used for finding the movie within IMDB and metacritic. Subtitute spaces for plus signs

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

    movie_critics = get_all_critics(id)
  
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

      print "Which critics to exclude? (use numbers above; put spaces between; type \"n\" if none):"
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
  
    filter_critics(movie_critics)
  
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
      printf("Average converted RT score: %.2f", "#{avg_converted_score}")
      print "\n"
      return avg_converted_score
    end 
    
    show_movie_details_score = display_final_stats(movie_critics)
    return show_movie_details_score
    
  end 
  
  rt_score = show_movie_details(id)
  return rt_score
end

rt_results = rt(title)

### IMDB ###

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
  print "Title: ", movie_found["Title"], "\n"
  print "Year: ", movie_found["Year"], "\n"
  print "Runtime: ", movie_found["Runtime"], "\n"
  print "IMDB Rating: ", movie_found["Rating"], "\n"

  return (movie_found["Rating"].to_f)*10
end

imdb_results = imdb(title)
'''
def metacritic(title)
  #insert metacritic scraping here
  title.gsub!('+', '-').downcase!
  puts title
  movie = Nokogiri::HTML(open("http://www.metacritic.com/movie/#{title}"))
  return movie.at_css(".score_value").text
end

mt_score = metacritic(title).to_i
puts mt_score
'''
meta_meta_score = (rt_results + imdb_results + mt_score)/2.0
print "\n"
print "Meta-metascore: ", meta_meta_score, "\n\n"
'''