# frozen_string_literal: true
#!/usr/bin/env

require 'what3words'
require 'json'

api_key = ENV['W3W_API_KEY']

what3words = What3Words::API.new(:key => api_key, :format => 'json')

# ## convert_to_coordinates #########
res = what3words.convert_to_coordinates 'prom.cape.pump'
puts '######### convert_to_coordinate #########'
puts res

# ## convert_to_3wa #########
res = what3words.convert_to_3wa [29.567041, 106.587875]
puts '######### convert_to_3wa #########'
puts res

# ## grid_section #########
res = what3words.grid_section '52.208867,0.117540,52.207988,0.116126'
puts '######### grid_section #########'
puts res

# ## available_languages #########
res = what3words.available_languages
puts '######### available_languages #########'
puts res


# ## Vanilla autosuggest, limiting the number of results to three #########
res = what3words.autosuggest 'disclose.strain.redefin', language: 'en', 'n-results': 10
puts '######### autosuggest n-results #########'
puts res

# ## autosuggest demonstrating clipping to polygon, circle, bounding box, and country #########
res_polygon = what3words.autosuggest 'disclose.strain.redefin', 'clip-to-polygon': [51.521, -0.343, 52.6, 2.3324, 54.234, 8.343, 51.521, -0.343]
res_circle = what3words.autosuggest 'disclose.strain.redefin', 'clip-to-circle': [51.521, -0.343, 142]
res_bbox = what3words.autosuggest 'disclose.strain.redefin', 'clip-to-bounding-box': [51.521, -0.343, 52.6, 2.3324]
res_country = what3words.autosuggest 'disclose.strain.redefin', 'clip-to-country': 'GB,BE'
puts '######### autosuggest clipping options #########'
puts res_polygon
puts res_circle
puts res_bbox
puts res_country

# ## autosuggest with a focus, with that focus only applied to the first result #########
res = what3words.autosuggest 'filled.count.soap', focus: [51.4243877, -0.34745], 'n-focus-results': 3,  'n-results': 10
puts '######### autosuggest with a focus ######### '
puts res

# ## autosuggest with an input type of Generic Voice #########
res =  what3words.autosuggest 'fun with code', 'input-type': 'generic-voice', language: 'en'
puts '######### autosuggest with Generic Voice as input type ######### '
puts res

# ## isPossible3wa #########
addresses = ["filled.count.soap", "not a 3wa", "not.3wa address"]
addresses.each do |address|
  is_possible = what3words.isPossible3wa(address)
  puts "Is '#{address}' a possible what3words address? #{is_possible}"
end

# ## findPossible3wa #########
texts = [
  "Please leave by my porch at filled.count.soap",
  "Please leave by my porch at filled.count.soap or deed.tulip.judge",
  "Please leave by my porch at"
]
texts.each do |text|
  possible_addresses = what3words.findPossible3wa(text)
  puts "Possible what3words addresses in '#{text}': #{possible_addresses}"
end

# ## didYouMean #########
addresses = ["filled-count-soap", "filled count soap", "invalid#address!example", "this is not a w3w address"]
addresses.each do |address|
  suggestion = what3words.didYouMean(address)
  puts "Did you mean '#{address}'? #{suggestion}"
end

# ## isValid3wa #########
addresses = ["filled.count.soap", "filled.count.", "coding.is.cool"]
addresses.each do |address|
  is_valid = what3words.isValid3wa(address)
  puts "Is '#{address}' a valid what3words address? #{is_valid}"
end

