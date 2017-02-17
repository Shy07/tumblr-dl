require "tumblr/dl/version"
require 'net/http'
require 'json'
require 'tumblr/console'

module TumblrDl

  HELP =<<__HERE__
Usage:
  tumblr_dl -h                      print this help info
  tumblr_dl -v                      print version number
  tumblr_dl <username> [options]
    options:
      -d [resource type]            cache and download resources
                                    e.g.  tumblr_dl alice -d video
                                          tumblr_dl bob -d image
      -nc                           do not cache
                                    e.g. tumblr_dl carol -nc -d video

Tips:
  <username> means the `xxx` of `xxx.tumblr.com`.
  When you using `-d` to download resources, you should make sure you've installed `wget` first.

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
    audio_list = []
    data = JSON.parse html[22..-3]
    start = data['posts-start'].to_i
    total = data['posts-total'].to_i
    Console.draw_process_bar start, total
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
      elsif post['type'] == 'audio'
        audio_list << post#['audio-player']
      end
      Console.draw_process_bar start + index + 1, total
    end
    return video_list, image_list, audio_list
  end

  def get_all_resource_url_with(html)
    data = JSON.parse html[22..-3]
    start = data['posts-start'].to_i
    total = data['posts-total'].to_i
    username = data['tumblelog']['name']
    return puts 'No post!' if total.zero?
    puts "Find and cache resources from all #{total} post[s]:"
    while start < total
      video_list, image_list, audio_list = get_resource_url_with get_html_with username, start
      save_url [
        {username: username, type: 'video', data: video_list},
        {username: username, type: 'photo', data: image_list},
        {username: username, type: 'audio', data: audio_list}
      ]
      start += 50
    end
    puts 'Done!'
  end

  def save_url(lists)
    lists.each do |list|
      next if list[:data].empty?
      path = "./#{list[:username]}/#{list[:type]}.txt"
      data = list[:data].join "\n"
      open(path, 'a') {|io| io.write "#{data}\n"}
    end
  end

  def wget_resources(username, type)
    filename = "./#{username}/#{type}.txt"
    return unless File.exist? filename
    string = open(filename, 'rb') {|io| io.read }
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
