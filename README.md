# <img src="https://what3words.com/assets/images/w3w_square_red.png" width="32" height="32" alt="what3words">&nbsp;what3words Ruby wrapper

[![Build Status](https://travis-ci.org/what3words/w3w-ruby-wrapper.svg?branch=master)](https://travis-ci.org/what3words/w3w-ruby-wrapper)

The Ruby wrapper is useful for Ruby developers who wish to seamlessly integrate the [what3words Public API](https://developer.what3words.com/public-api) into their Ruby applications, without the hassle of having to manage the low level API calls themselves.

The what3words API is a fast, simple interface which allows you to convert 3 word addresses such as `///index.home.raft` to latitude and longitude coordinates such as `-0.203586, 51.521251` and vice versa. It features a powerful autosuggest function, which can validate and autocorrect user input and limit it to certain geographic areas (this powers the search box on our map site). It allows you to request a section of the what3words grid (which can be requested as GeoJSON for easy display on online maps), and to request the list of all languages supported by what3words. For advanced users, autosuggest can be used to post-process voice output.

All coordinates are latitude,longitude pairs in standard `WGS-84` (as commonly used worldwide in GPS systems). All latitudes must be in the range of `-90 to 90 (inclusive)`.

## Installation

The library is available through [RubyGems](https://rubygems.org/gems/what3words).

You can simply add this line to your application's Gemfile:

```
    gem 'what3words', '~> 3.0'
```

And then execute:

```shell
    $ bundle
```

Or install it yourself as:

```shell
    $ gem install what3words
```

## Usage

Sign up for an API key at [https://developer.what3words.com](https://developer.what3words.com)

See [https://developer.what3words.com/public-api/docs](https://developer.what3words.com/public-api/docs) for all parameters that can be passed to the API calls.

If not using Bundler, require it:

```ruby
    require 'what3words'
```

Then:

```ruby
    what3words = What3Words::API.new(:key => "YOURAPIKEY")
```

Convert to Coordinates: convert a 3 word address into GPS coordinates (WGS84)

```ruby
    what3words.convert_to_coordinates 'prom.cape.pump'
    # => {:country=>"GB", :square=>{:southwest=>{:lng=>-0.195426, :lat=>51.484449}, :northeast=>{:lng=>-0.195383, :lat=>51.484476}}, :nearestPlace=>"Kensington, London", :coordinates=>{:lng=>-0.195405, :lat=>51.484463}, :words=>"prom.cape.pump", :language=>"en", :map=>"https://w3w.co/prom.cape.pump"}
```

## API
### Convert to Coordinates
Convert a 3 word address into GPS coordinates and return 3 words for the same position.

```ruby
    what3words.convert_to_coordinates "prom.cape.pump"
    # => {:country=>"GB", :square=>{:southwest=>{:lng=>-0.195426, :lat=>51.484449}, :northeast=>{:lng=>-0.195383, :lat=>51.484476}}, :nearestPlace=>"Kensington, London", :coordinates=>{:lng=>-0.195405, :lat=>51.484463}, :words=>"prom.cape.pump", :language=>"en", :map=>"https://w3w.co/prom.cape.pump"}
```
Supported keyword params for `convert_to_coordinates` call:

* `words` A 3 word address as a string
* `format`  Return data format type. It can be one of json (the default) or geojson


### Convert to 3WA
Convert position information, latitude and longitude coordinates, into a 3 word address.

```ruby
    what3words.convert_to_3wa [29.567041, 106.587875]
    # => {:country=>"CN", :square=>{:southwest=>{:lng=>106.58786, :lat=>29.567028}, :northeast=>{:lng=>106.587891, :lat=>29.567055}}, :nearestPlace=>"Chongqing", :coordinates=>{:lng=>106.587875, :lat=>29.567041}, :words=>"disclose.strain.redefined", :language=>"en", :map=>"https://w3w.co/disclose.strain.redefined"}
```

Convert position information to a 3 word address in a specific language

```ruby
    what3words.convert_to_3wa [29.567041, 106.587875], language: 'fr'
    # => :country=>"CN", :square=>{:southwest=>{:lng=>106.58786, :lat=>29.567028}, :northeast=>{:lng=>106.587891, :lat=>29.567055}}, :nearestPlace=>"Chongqing", :coordinates=>{:lng=>106.587875, :lat=>29.567041}, :words=>"courgette.rabotons.infrason", :language=>"fr", :map=>"https://w3w.co/courgette.rabotons.infrason"}
```

Supported keyword params for `convert_to_3wa` call:

* `coordinates` The coordinates of the location to convert to 3 word address
* `language` (defaults to en) - A supported 3 word address language as an ISO 639-1 2 letter code
* `format` Return data format type. It can be one of json (the default) or geojson

### Autosuggest
Returns a list of 3 word addresses based on user input and other parameters.

This resource provides corrections for the following types of input error:
- typing errors
- spelling errors
- misremembered words (e.g. singular vs. plural)
- words in the wrong order

The autosuggest resource determines possible corrections to the supplied 3 word address string based on the probability of the input errors listed above and returns a ranked list of suggestions. This resource can also take into consideration the geographic proximity of possible corrections to a given location to further improve the suggestions returned.

See [https://developer.what3words.com/public-api/docs#autosuggest](https://developer.what3words.com/public-api/docs#autosuggest) for detailed information

Gets suggestions in french for this address:

```ruby
    what3words.autosuggest 'trop.caler.perdre', language: 'fr'
    # => {:suggestions=>[{:country=>"FR", :nearestPlace=>"Saint-Lary-Soulan, Hautes-Pyrénées", :words=>"trier.caler.perdre", :rank=>1, :language=>"fr"}, {:country=>"ET", :nearestPlace=>"Asbe Teferi, Oromiya", :words=>"trôler.caler.perdre", :rank=>2, :language=>"fr"}, {:country=>"CN", :nearestPlace=>"Ulanhot, Inner Mongolia", :words=>"froc.caler.perdre", :rank=>3, :language=>"fr"}]}
```

Gets suggestions for a different number of suggestions, i.e. 10 for this address:

```ruby
    what3words.autosuggest 'disclose.strain.redefin', language: 'en', 'n-results': 10
    # => {:suggestions=>[{:country=>"SO", :nearestPlace=>"Jamaame, Lower Juba", :words=>"disclose.strain.redefine", :rank=>1, :language=>"en"}, {:country=>"ZW", :nearestPlace=>"Mutoko, Mashonaland East", :words=>"discloses.strain.redefine", :rank=>2, :language=>"en"}, {:country=>"MM", :nearestPlace=>"Mogok, Mandalay", :words=>"disclose.strains.redefine", :rank=>3, :language=>"en"}, {:country=>"CN", :nearestPlace=>"Chongqing", :words=>"disclose.strain.redefined", :rank=>4, :language=>"en"}, {:country=>"ZM", :nearestPlace=>"Binga, Matabeleland North", :words=>"disclosing.strain.redefine", :rank=>5, :language=>"en"}, {:country=>"XH", :nearestPlace=>"Leh, Ladakh", :words=>"disclose.straining.redefine", :rank=>6, :language=>"en"}, {:country=>"US", :nearestPlace=>"Kamas, Utah", :words=>"disclose.strain.redefining", :rank=>7, :language=>"en"}, {:country=>"GN", :nearestPlace=>"Boké", :words=>"disclose.strained.redefine", :rank=>8, :language=>"en"}, {:country=>"BO", :nearestPlace=>"Pailón, Santa Cruz", :words=>"discloses.strains.redefine", :rank=>9, :language=>"en"}, {:country=>"US", :nearestPlace=>"McGrath, Alaska", :words=>"discloses.strain.redefined", :rank=>10, :language=>"en"}]}
```

Gets suggestions when the coordinates for focus has been provided for this address:

```ruby
    what3words.autosuggest 'filled.count.soap', focus: [51.4243877,-0.34745]
    # => {:suggestions=>[{:country=>"US", :nearestPlace=>"Homer, Alaska", :words=>"fund.with.code", :rank=>1, :language=>"en"}, {:country=>"AU", :nearestPlace=>"Kumpupintil, Western Australia", :words=>"funk.with.code", :rank=>2, :language=>"en"}, {:country=>"US", :nearestPlace=>"Charleston, West Virginia", :words=>"fund.with.cove", :rank=>3, :language=>"en"}]}
```

Gets suggestions for a different number of focus results for this address:

```ruby
    what3words.autosuggest 'disclose.strain.redefin', language: 'en', 'n-focus-results': 3
    # => {:suggestions=>[{:country=>"SO", :nearestPlace=>"Jamaame, Lower Juba", :words=>"disclose.strain.redefine", :rank=>1, :language=>"en"}, {:country=>"ZW", :nearestPlace=>"Mutoko, Mashonaland East", :words=>"discloses.strain.redefine", :rank=>2, :language=>"en"}, {:country=>"MM", :nearestPlace=>"Mogok, Mandalay", :words=>"disclose.strains.redefine", :rank=>3, :language=>"en"}]}
```

Gets suggestions for a voice input type mode, i.e. generic-voice, for this address:

```ruby
    what3words.autosuggest 'fun with code', 'input-type': 'generic-voice', language: 'en'
    # => {:suggestions=>[{:country=>"US", :nearestPlace=>"Homer, Alaska", :words=>"fund.with.code", :rank=>1, :language=>"en"}, {:country=>"AU", :nearestPlace=>"Kumpupintil, Western Australia", :words=>"funk.with.code", :rank=>2, :language=>"en"}, {:country=>"US", :nearestPlace=>"Charleston, West Virginia", :words=>"fund.with.cove", :rank=>3, :language=>"en"}]}
```

Gets suggestions for a restricted area by clipping to country for this address:

```ruby
    what3words.autosuggest 'disclose.strain.redefin', 'clip-to-country': 'GB,BE'
    # => {:suggestions=>[{:country=>"GB", :nearestPlace=>"Nether Stowey, Somerset", :words=>"disclose.retrain.redefined", :rank=>1, :language=>"en"}, {:country=>"BE", :nearestPlace=>"Zemst, Flanders", :words=>"disclose.strain.reckon", :rank=>2, :language=>"en"}, {:country=>"GB", :nearestPlace=>"Waddington, Lincolnshire", :words=>"discloses.trains.redefined", :rank=>3, :language=>"en"}]}
```

Gets suggestions for a restricted area by clipping to a bounding-box for this address:

```ruby
    what3words.autosuggest 'disclose.strain.redefin', 'clip-to-bounding-box': [51.521, -0.343, 52.6, 2.3324]
    # => {:suggestions=>[{:country=>"GB", :nearestPlace=>"Saxmundham, Suffolk", :words=>"discloses.strain.reddish", :rank=>1, :language=>"en"}]}
```


Gets suggestions for a restricted area by clipping to a circle in km for this address:

```ruby
    what3words.autosuggest 'disclose.strain.redefin', 'clip-to-circle': [51.521, -0.343, 142]
    # => {:suggestions=>[{:country=>"GB", :nearestPlace=>"Market Harborough, Leicestershire", :words=>"discloses.strain.reduce", :rank=>1, :language=>"en"}]}
```

Gets suggestions for a restricted area by clipping to a polygon for this address:

```ruby
    what3words.autosuggest 'disclose.strain.redefin', 'clip-to-polygon': [51.521, -0.343, 52.6, 2.3324, 54.234, 8.343, 51.521, -0.343]
    # => {:suggestions=>[{:country=>"GB", :nearestPlace=>"Saxmundham, Suffolk", :words=>"discloses.strain.reddish", :rank=>1, :language=>"en"}]}
```

Gets suggestions for a restricted area by clipping to a polygon for this address:

```ruby
    what3words.w3w.autosuggest 'disclose.strain.redefin', 'prefer-land': false, 'n-results': 10
    # => {:suggestions=>[{:country=>"SO", :nearestPlace=>"Jamaame, Lower Juba", :words=>"disclose.strain.redefine", :rank=>1, :language=>"en"}, {:country=>"ZW", :nearestPlace=>"Mutoko, Mashonaland East", :words=>"discloses.strain.redefine", :rank=>2, :language=>"en"}, {:country=>"MM", :nearestPlace=>"Mogok, Mandalay", :words=>"disclose.strains.redefine", :rank=>3, :language=>"en"}, {:country=>"CN", :nearestPlace=>"Chongqing", :words=>"disclose.strain.redefined", :rank=>4, :language=>"en"}, {:country=>"ZM", :nearestPlace=>"Binga, Matabeleland North", :words=>"disclosing.strain.redefine", :rank=>5, :language=>"en"}, {:country=>"XH", :nearestPlace=>"Leh, Ladakh", :words=>"disclose.straining.redefine", :rank=>6, :language=>"en"}, {:country=>"US", :nearestPlace=>"Kamas, Utah", :words=>"disclose.strain.redefining", :rank=>7, :language=>"en"}, {:country=>"GN", :nearestPlace=>"Boké", :words=>"disclose.strained.redefine", :rank=>8, :language=>"en"}, {:country=>"BO", :nearestPlace=>"Pailón, Santa Cruz", :words=>"discloses.strains.redefine", :rank=>9, :language=>"en"}, {:country=>"US", :nearestPlace=>"McGrath, Alaska", :words=>"discloses.strain.redefined", :rank=>10, :language=>"en"}]}
```

Supported keyword params for `autosuggest` call:
  * `input` The full or partial 3 word address to obtain suggestions for. At minimum this must be the first two complete words plus at least one character from the third word.
  * `language` A supported 3 word address language as an ISO 639-1 2 letter code. This setting is on by default. Use false to disable this setting and receive more suggestions in the sea.
  * `n_results` The number of AutoSuggest results to return. A maximum of 100 results can be specified, if a number greater than this is requested, this will be truncated to the maximum. The default is 3.
  * `n_focus_results` Specifies the number of results (must be <= n_results) within the results set which will have a focus. Defaults to n_results. This allows you to run autosuggest with a mix of focussed and unfocussed results, to give you a "blend" of the two.
  * `clip-to-country` Restricts autosuggest to only return results inside the countries specified by comma-separated list of uppercase ISO 3166-1 alpha-2 country codes (for example, to restrict to Belgium and the UK, use clip_to_country="GB,BE").
  * `clip-to-bounding-box` Restrict autosuggest results to a bounding box, specified by coordinates.
  * `clip-to-circle` Restrict autosuggest results to a circle, specified by the center of the circle, latitude and longitude, and a distance in kilometres which represents the radius. For convenience, longitude is allowed to wrap around 180 degrees. For example 181 is equivalent to -179.
  * `clip-to-polygon` Restrict autosuggest results to a polygon, specified by a list of coordinates. The polygon should be closed, i.e. the first element should be repeated as the last element; also the list should contain at least 4 entries. The API is currently limited to accepting up to 25 pairs.
  * `input-type` For power users, used to specify voice input mode. Can be text (default), vocon-hybrid, nmdp-asr or generic-voice.
  * `prefer-land` Makes autosuggest prefer results on land to those in the sea.

### Grid
Returns a section of the 3m x 3m what3words grid for a given area.

See [https://developer.what3words.com/public-api/docs#grid-section](https://developer.what3words.com/public-api/docs#grid-section) for detailed information.

Gets grid for these bounding box northeast 52.208867,0.117540,52.207988,0.116126.

```ruby
    what3words.grid_section '52.208867,0.117540,52.207988,0.116126'
    # => {:lines=>[{:start=>{:lng=>0.116126, :lat=>52.20801}, :end=>{:lng=>0.11754, :lat=>52.20801}}, {:start=>{:lng=>0.116126, :lat=>52.208037}, :end=>{:lng=>0.11754, :lat=>52.208037}}, {:start=>{:lng=>0.116126, :lat=>52.208064}, :end=>{:lng=>0.11754, :lat=>52.208064}}, ___...___ ]}
```

Supported keyword params for `grid_section` call:
  * `bounding-box` The bounding box is specified by the northeast and southwest corner coordinates, for which the grid should be returned
  * `format` Return data format type. It can be one of json (the default) or geojson

### Get Languages
Retrieve a list of available 3 word languages.

```ruby
    what3words.available_languages
    # => {:languages=>[{:nativeName=>"Deutsch", :code=>"de", :name=>"German"}, {:nativeName=>"हिन्दी", :code=>"hi", :name=>"Hindi"}, {:nativeName=>"Português", :code=>"pt", :name=>"Portuguese"}, {:nativeName=>"Magyar", :code=>"hu", :name=>"Hungarian"}, {:nativeName=>"Українська", :code=>"uk", :name=>"Ukrainian"}, {:nativeName=>"Bahasa Indonesia", :code=>"id", :name=>"Bahasa Indonesia"}, {:nativeName=>"اردو", :code=>"ur", :name=>"Urdu"}, ___...___]}
```

See [https://developer.what3words.com/public-api/docs#available-languages](https://developer.what3words.com/public-api/docs#available-languages) for the original API call documentation.

## Testing

* Prerequisite : we are using [bundler](https://rubygems.org/gems/bundler) `$ gem install bundler`

* W3W-API-KEY: For safe storage of your API key on your computer, you can define that API key using your system’s environment variables.
```bash
$ export W3W_API_KEY=<Secret API Key>
```

* on your cloned folder
1. `$ cd w3w-ruby-wrapper`
1. `$ bundle update`
1. `$ rake rubocop spec`

To run the tests, type on your terminal:
```bash
$ bundle exec rspec
```

## Issues

Find a bug or want to request a new feature? Please let us know by submitting an issue.

## Contributing
Anyone and everyone is welcome to contribute.

1. Fork it (http://github.com/what3words/w3w-ruby-wrapper and click "Fork")
1. Create your feature branch (`git checkout -b my-new-feature`)
1. Commit your changes (`git commit -am 'Add some feature'`)
1. Don't forget to update README and bump [version](./lib/what3words/version.rb) using [semver](https://semver.org/)
1. Push to the branch (`git push origin my-new-feature`)
1. Create new Pull Request

# Revision History

* `v3.0.0`  12/05/22 - Update endpoints and tests to API v3, added HTTP headers
* `v2.2.0`  03/01/18 - Enforce Ruby 2.4 Support - Thanks to PR from Dimitrios Zorbas [@Zorbash](https://github.com/zorbash)
* `v2.1.1`  22/05/17 - Update gemspec to use rubocop 0.48.1, and fixes spec accordingly
* `v2.1.0`  28/03/17 - Added multilingual version of `autosuggest` and `standardblend`
* `v2.0.4`  27/03/17 - Updated README with `languages` method result updated from live result
* `v2.0.3`  24/10/16 - Fixed `display` in `assemble_common_request_params`
* `v2.0.2`  10/06/16 - Added travis-ci builds
* `v2.0.0`  10/06/16 - Updated wrapper to use what3words API v2

## Licensing

The MIT License (MIT)

A copy of the license is available in the repository's [license](LICENSE.txt) file.
