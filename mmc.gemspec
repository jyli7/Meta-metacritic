Gem::Specification.new do |s|
  s.name        = 'mmc'
  s.version     = '0.0.1'
  s.date        = '2011-10-22'
  s.summary     = "Meta metacritic"
  s.description = "Calculates a 'meta metascore' for a given movie by averaging its scores from rotten tomatoes, metacritic, and imdb."
  s.authors     = ["Jimmy Li"]
  s.email       = 'jyl702@gmail.com'
  s.files       = `git ls-files`.split("\n")
  s.executables = ['mmc']
  s.homepage    =
    'http://rubygems.org/gems/mmc'
end