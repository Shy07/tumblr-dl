# tumblr-dl

Tumblr-dl is a command-line tool for downloading Tumblr resources by username.

## Installation

Install as:

    $ gem install tumblr-dl

## Usage

You should cache resources before downloading:

    $ tumblr_dl <username>            # username means xxx of xxx.tumblr.com

Then you will get the resource lists such as `video.txt` and `photo.txt`.
And you could download the resources by other tools what you like.  
Of course, you can download by this tools too,
but you should make sure you've installed `wget` first.

If you have installed `wget`, you may cache and download as:

    $ tumblr_dl <username> -d         # download all resources
    $ tumblr_dl <username> -d video   # download video resources only
    $ tumblr_dl <username> -d image   # download image resources only

If you have cached and just want to download, use:

    $ tumblr_dl <username> -nc -d
    $ tumblr_dl <username> -nc -d video
    $ tumblr_dl <username> -nc -d image

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Shy07/tumblr-dl.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
