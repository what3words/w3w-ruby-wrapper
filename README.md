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

    # Convert 3 words to position information - only required parameters supplied
    what3words.words_to_position ["prom", "cape", "pump"]
    # => { :type => "3 words", :words => ["prom", "cape", "pump"],
           :position => [51.484463, -0.195405], :language => "en" }

    # Convert 3 words to position information in a different language with
    # corner coordinates - all parameters supplied
    what3words.words_to_position ["prom", "cape", "pump"], :language => "fr",
      :corners => true
    # TODO CORRECT ME => { :type => "3 words", :words => ["oui", "non", "moi"],
           :position => [51.484463, -0.195405], :language => "fr" }

    # Converts public *OneWord to position information in a different
    # language with corner coordinates
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
