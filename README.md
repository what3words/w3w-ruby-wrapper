# What3Words

Use the What3Words API in your Ruby app (see http://what3words.com/api/reference)

## Installation

Add this line to your application's Gemfile:

    gem "what3words"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install what3words

## Usage

Sign up for an API key at http://what3words.com/api/signup

See http://what3words.com/api/reference for all parameters that can be
passed to the API calls

Then:

    what3words = What3Words::API.new(:key => "<your-api-key>")

Convert 3 words or a OneWord into GPS coordinates

    what3words.words_to_position ["prom", "cape", "pump"]
    # => [51.484463, -0.195405]

Convert 3 words or a OneWord into GPS coordinates and return 3 words for the same position in a different language

    what3words.words_to_position ["prom", "cape", "pump"], :full_response => true, :lang => "fr"
    # => { :type => "3 words", :words => ["concevoir", "époque", "amasser"],
           :position => [51.484463, -0.195405], :language: "fr" }

Supported keyword params for `words_to_position` call:

* `full_response` (default false) - return the original response from the API
* `lang` (defaults to language of 3 words)  - optional language code (only use this if you want to return 3 words in a different language to the language submitted)
* `oneword_password` (default nil) - password for OneWord, if private
* `corners` (default false) - "true" or "false" to return the coordinates of the w3w square. Will return an array with the southwest coordinates of the square and then the northeast coordinate
* `email` - user email if required for private OneWord
* `password` - user password if required for private OneWord

TODO from below here

Converts public *OneWord to 
    what3words.oneword_to_position "*libertytech", :language => "en"
    # => TODO

    what3words.oneword_to_position "*libertytech", :oneword_password => "password",
      :language => "en", :email => "myemail@example.com",
      :password => "user-password"
    # => TODO

    # Convert position information to 3 words
    what3words.position_to_words [51.484463, -0.195405]
    # => { :words => ["prom", "cape", "pump"], :position => [51.484463, -0.195405],
           :language => "en" }

    # Get list of available 3 word languages
    what3words.languages
    # => [ { :code => "en", :name => "English" },
           { .. } ]



See http://what3words.com/api/reference for the rest of the API - the
gem's 3 API calls are available and any flags specified can usually be
passed through in an intuitive way

## Contributing

1. Fork it ( http://github.com/<my-github-username>/what3words and click "Fork" )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

# Testing

1. Unit specs require no set up. Look in `spec/what3words`
2. Integration specs that hit the API directly are in spec/integration, and need the file spec/config.yaml to be filled in (using spec/config.sample.yaml as a template) with valid details. It is only needed for testing private OneWord functionality
