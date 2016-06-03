# ![what3words](https://map.what3words.com/images/map/marker-border.png)what3words Ruby wrapper

Use the what3words API in your Ruby app (see http://developer.what3words.com/api)

## Installation

Add this line to your application's Gemfile:

    gem 'what3words', '~> 2.0'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install what3words

## Usage

Sign up for an API key at http://developer.what3words.com

See https://docs.what3words.com/api/v2/ for all parameters that can be
passed to the API calls

If not using Bundler, require it:

    require "what3words"

Then:

    what3words = What3Words::API.new(:key => "YOURAPIKEY")

Forward Geocode : convert a 3 word address into GPS coordinates (WGS-84)

    what3words.forward "prom.cape.pump"
    # => {:crs=>{:properties=>{:type=>"ogcwkt", :href=>"http://spatialreference.org/ref/epsg/4326/ogcwkt/"}, :type=>"link"}, :bounds=>{:southwest=>{:lng=>-0.195426, :lat=>51.484449}, :northeast=>{:lng=>-0.195383, :lat=>51.484476}}, :words=>"prom.cape.pump", :map=>"http://w3w.co/prom.cape.pump", :language=>"en", :geometry=>{:lng=>-0.195405, :lat=>51.484463}, :status=>{:status=>200, :reason=>"OK"}, :thanks=>"Thanks from all of us at index.home.raft for using a what3words API"}

## API
### Forward Geocoding
Convert a 3 word address into GPS coordinates and return 3 words for the same position in a different language

    what3words.forward "prom.cape.pump", :lang => "fr"
    # => {:crs=>{:properties=>{:type=>"ogcwkt", :href=>"http://spatialreference.org/ref/epsg/4326/ogcwkt/"}, :type=>"link"}, :bounds=>{:southwest=>{:lng=>-0.195426, :lat=>51.484449}, :northeast=>{:lng=>-0.195383, :lat=>51.484476}}, :words=>"concevoir.époque.amasser", :map=>"http://w3w.co/concevoir.époque.amasser", :language=>"fr", :geometry=>{:lng=>-0.195405, :lat=>51.484463}, :status=>{:status=>200, :reason=>"OK"}, :thanks=>"Thanks from all of us at index.home.raft for using a what3words API"}

Supported keyword params for `forward` call:

* `lang` (defaults to language of 3 words)  - optional language code (only use this if you want to return 3 words in a different language to the language submitted)
* `format` Return data format type; can be one of json (the default), geojson or xml
* `display` Return display type; can be one of full (the default) or terse

### Reverse Geocoding
Reverse Geocode : Convert position(latitude) information to a 3 word address

    what3words.reverse [51.484463, -0.195405]
    # => {:crs=>{:properties=>{:type=>"ogcwkt", :href=>"http://spatialreference.org/ref/epsg/4326/ogcwkt/"}, :type=>"link"}, :bounds=>{:southwest=>{:lng=>-0.195426, :lat=>51.484449}, :northeast=>{:lng=>-0.195383, :lat=>51.484476}}, :words=>"prom.cape.pump", :map=>"http://w3w.co/prom.cape.pump", :language=>"en", :geometry=>{:lng=>-0.195405, :lat=>51.484463}, :status=>{:status=>200, :reason=>"OK"}, :thanks=>"Thanks from all of us at index.home.raft for using a what3words API"}

Convert position information to a 3 word address in a specific language

    what3words.reverse [51.484463, -0.195405], :lang => :fr
    # => {:crs=>{:properties=>{:type=>"ogcwkt", :href=>"http://spatialreference.org/ref/epsg/4326/ogcwkt/"}, :type=>"link"}, :bounds=>{:southwest=>{:lng=>-0.195426, :lat=>51.484449}, :northeast=>{:lng=>-0.195383, :lat=>51.484476}}, :words=>"concevoir.époque.amasser", :map=>"http://w3w.co/concevoir.époque.amasser", :language=>"fr", :geometry=>{:lng=>-0.195405, :lat=>51.484463}, :status=>{:status=>200, :reason=>"OK"}, :thanks=>"Thanks from all of us at index.home.raft for using a what3words API"}

Supported keyword params for `reverse` call:

* `lang` (defaults to en)  - optional language code
* `format` Return data format type; can be one of json (the default), geojson or xml
* `display` Return display type; can be one of full (the default) or terse

### Get Languages
Get list of available 3 word languages

    what3words.languages
    # => {:languages=>[{:name=>"German", :native_name=>"Deutsch  (beta)", :code=>"de"}, {:name=>"Italian", :native_name=>"Italiano  (beta)", :code=>"it"}, {:name=>"Turkish", :native_name=>"Türkçe  (beta)", :code=>"tr"}, {:name=>"Portuguese", :native_name=>"Português  (beta)", :code=>"pt"}, {:name=>"French", :native_name=>"français, langue française  (beta)", :code=>"fr"}, {:name=>"Swedish", :native_name=>"svenska  (beta)", :code=>"sv"}, {:name=>"English", :native_name=>"English", :code=>"en"}, {:name=>"Russian", :native_name=>"русский язык  (beta)", :code=>"ru"}, {:name=>"Spanish; Castilian", :native_name=>"español, castellano  (beta)", :code=>"es"}, {:name=>"Swahili", :native_name=>"Kiswahili  (beta)", :code=>"sw"}], :status=>{:status=>200, :reason=>"OK"}, :thanks=>"Thanks from all of us at index.home.raft for using a what3words API"}

See http://developer.what3words.com for the original API call documentation

## Contributing

1. Fork it ( http://github.com/what3words/w3w-ruby-wrapper and click "Fork" )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### Testing/

 Prerequisite : we are using [bundler](https://rubygems.org/gems/bundler)
    `$ gem install bundler`

1. `$ cd w3w-ruby-wrapper`
1. `$ bundle update`
1. `$ rake spec`
1. Mock Unit specs require no set up. Look in `spec/mock/`
1. Integration specs that hit the API directly are in `spec/what3words`, and need the file `spec/config.yaml` to be filled in (using `spec/config.sample.yaml` as a template) with valid details.
