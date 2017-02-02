# require "tumblr/dl/version"
require 'net/http'
require 'json'

module TumblrDl

  module_function

  def get_html_with(username, start = 0)
    uri = URI.parse("http://#{username}.tumblr.com/api/read/json?start=#{start}&num=50")
    html_string = Net::HTTP.get uri
    ["./#{username}", "./#{username}/json"].each do |path|
      unless File.exist? path; begin; Dir.mkdir path; rescue; end; end
    end
    open("./#{username}/json/lists#{start}.json", 'wb') {|io| io.write html_string }
    html_string
  end

  def get_resource_url_with(html)
    video_list = []
    image_list = []
    data = JSON.parse html[22..-3]
    data['posts'].each do |post|
      if post['type'] == 'video'
        next if post['video-player-500'] == false
        if post['video-player-500'] =~ /src="(.*)" type/
          video_list << "#{$1}.mp4"
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
    end
    return video_list, image_list
  end

  def get_all_resource_url_with(html)
    puts 'get all resource url'
    video_list, image_list = get_resource_url_with html
    data = JSON.parse html[22..-3]
    start = data['posts-start'].to_i
    total = data['posts-total'].to_i
    username = data['tumblelog']['name']
    while start < total
      puts "#{start}-#{start+50}/#{total}"
      video_list, image_list = get_resource_url_with get_html_with username, start
      save_url [
        {username: username, type: 'video', data: video_list},
        {username: username, type: 'photo', data: image_list}
      ]
      start += 50
    end
    puts 'finish!'
  end

  def save_url(lists)
    print 'saving list...'
    lists.each do |list|
      next if list[:data].empty?
      path = "./#{list[:username]}/#{list[:type]}.txt"
      data = list[:data].join "\n"
      open(path, 'a') {|io| io.write "#{data}\n"}
    end
    puts 'saved!'
  end

  def wget_video(username)
    string = open("./#{username}/video.txt", 'rb') {|io| io.read }
    data = string.split("\n").uniq.sort
    data.each_with_index do |line, index|
      puts "#{index+1}/#{data.size}"
      next if line == ""
      filename = "./#{username}/#{index}_#{line.split("/")[-1]}"
      next if File.exist? filename
      system "wget -O #{filename} #{line}"
    end
  end

  def wget_image(username)
    string = open("./#{username}/photo.txt", 'rb') {|io| io.read }
    data = string.split("\n").uniq.sort
    data.each_with_index do |line, index|
      puts "#{index+1}/#{data.size}"
      next if line == ""
      next if File.exist? "./#{username}/photo/#{line.split("/")[-1]}"
      system "wget -P ./#{username}/photo/ #{line}"
    end
  end

  def start(argv)
    username = argv.shift
    unless argv.include? '-nc'
      get_all_resource_url_with get_html_with username
    end
    argv.each_with_index do |arg, index|
      case arg
      when '-d'
        case argv[index + 1]
        when 'video'
          wget_video username
        when 'image'
          wget_image username
        else
          wget_image username
          wget_video username
        end
      end
    end
  end

end
