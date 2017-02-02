# tumblr-dl

Tumblr-dl is a command-line tool for downloading Tumblr resources by username.

## Installation

Install it yourself as:

    $ gem install tumblr-dl

## Usage

Cache recouces:

    $ tumblr_dl username

Cache and download:

    $ tumblr_dl username -d
    $ tumblr_dl username -d video
    $ tumblr_dl username -d image

if you have cached and just download, use:

    $ tumblr_dl username -nc -d
    $ tumblr_dl username -nc -d video
    $ tumblr_dl username -nc -d image

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Shy07/tumblr-dl. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
