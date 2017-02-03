require "tumblr/dl/version"
require 'net/http'
require 'json'
require 'tumblr/console'

module TumblrDl

  HELP =<<__HERE__
You should cache resources before downloading:

    $ tumblr_dl <username>

Then you will get the resource lists such as `video.txt` and `photo.txt`.
And you could download the resources by other tools what you like.
Of course, you can download by this tools too,
but you should make sure you've installed `wget` first.

When you have installed `wget`, you may cache and download as:

    $ tumblr_dl <username> -d         # download all
    $ tumblr_dl <username> -d video   # just download video resources
    $ tumblr_dl <username> -d image   # just download image resources

If you have cached and just want to download, use:

    $ tumblr_dl <username> -nc -d
    $ tumblr_dl <username> -nc -d video
    $ tumblr_dl <username> -nc -d image

__HERE__

  module_function

  def get_html_with(username, start = 0)
    uri = URI.parse "http://#{username}.tumblr.com/api/read/json?start=#{start}&num=50"
    html_string = Net::HTTP.get uri
    ["./#{username}", "./#{username}/json"].each do |path|
      unless File.exist? path; begin; Dir.mkdir path; rescue; end; end
    end
    if html_string.empty?
      res = Net::HTTP.get_response uri
      html_string = Net::HTTP.get URI.parse res['location']
    end
    open("./#{username}/json/lists#{start}.json", 'wb') {|io| io.write html_string }
    html_string
  end

  def get_resource_url_with(html)
    video_list = []
    image_list = []
    data = JSON.parse html[22..-3]
    Console.draw_process_bar 0, data['posts'].size
    data['posts'].each_with_index do |post, index|
      if post['type'] == 'video'
        next if post['video-player-500'] == false
        if post['video-player-500'] =~ /src="(.*)" type/
          res = Net::HTTP.get_response URI.parse "#{$1}.mp4"
          video_list << res['location'].scan(/http:.*mp4/)
        else
          video_list << post['video-player-500']
        end
      elsif post['type'] == 'photo'
        image_list << post['photo-url-1280']
        unless post['photos'].nil?
          post['photos'].each do |photo|
            image_list << photo['photo-url-1280']
          end
        end
      end
      Console.draw_process_bar index + 1, data['posts'].size
    end
    return video_list, image_list
  end

  def get_all_resource_url_with(html)
    puts 'Cache all resource url:'
    data = JSON.parse html[22..-3]
    start = data['posts-start'].to_i
    total = data['posts-total'].to_i
    username = data['tumblelog']['name']
    while start < total
      puts "Now: #{start}-#{start + 50 > total ? total : start + 50} Total: #{total}"
      video_list, image_list = get_resource_url_with get_html_with username, start
      save_url [
        {username: username, type: 'video', data: video_list},
        {username: username, type: 'photo', data: image_list}
      ]
      start += 50
    end
    puts 'Done!'
  end

  def save_url(lists)
    print 'Saving list...'
    lists.each do |list|
      next if list[:data].empty?
      path = "./#{list[:username]}/#{list[:type]}.txt"
      data = list[:data].join "\n"
      open(path, 'a') {|io| io.write "#{data}\n"}
    end
    puts 'Saved!'
  end

  def wget_resources(username, type)
    string = open("./#{username}/#{type}.txt", 'rb') {|io| io.read }
    data = string.split("\n").uniq.sort
    data.each_with_index do |line, index|
      puts "#{index+1}/#{data.size}"
      next if line == ""
      next if File.exist? "./#{username}/#{type}/#{line.split("/")[-1]}"
      system "wget -P ./#{username}/#{type}/ #{line}"
    end
  end

  def start(argv)
    $debug = (argv.include? '-debug') ? true : false
    return print HELP if argv.include? '-h'
    return puts VERSION if argv.include? '-v'
    username = argv.shift
    return print HELP if username.nil? || username.empty?
    unless argv.include? '-nc'
      get_all_resource_url_with get_html_with username
    end
    argv.each_with_index do |arg, index|
      case arg
      when '-d'
        case argv[index + 1]
        when 'video'
          wget_resources username, 'video'
        when 'image'
          wget_resources username, 'photo'
        else
          wget_resources username, 'photo'
          wget_resources username, 'video'
        end
      end
    end
  end

end
