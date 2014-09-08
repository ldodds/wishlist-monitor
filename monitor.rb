#!/usr/bin/ruby
require 'rubygems'
require 'json'
require 'hpricot'
require 'yaml'
require 'open-uri'

# Method to check if notify-send exists in a cross-platform way.
# The code is graciously borrowed from:
# http://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby
def which(cmd)
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each { |ext|
      exe = File.join(path, "#{cmd}#{ext}")
      return exe if File.executable?(exe) && !File.directory?(exe)
    }
  end
  return nil
end

# Config and history filenames are variables
# so we can leverage them in multiple palaces later
config_file = "#{ENV['HOME']}/.wishlist-monitor/config.yaml"
history_file = "#{ENV['HOME']}/.wishlist-monitor/history.json"

#Check for required config file
if !File.readable?(config_file)
  puts "Configuration file is missing"
  puts "Create a file called ~/.wishlist-monitor/config.yaml"
  puts "Then add the following configuration options:"
  puts "wishlist: ID_GOES_HERE"
  exit(1)
end

#Load config
config = YAML.load_file(config_file)
wishlist = config["wishlist"]
amazon_domain = config['amazon_domain']

#Load history    
if File.readable?(history_file)
  history = JSON.parse(File.read(history_file))
else
  history = {"items"=> {}}
end

url = "http://#{amazon_domain}/registry/wishlist/#{wishlist}?layout=compact"
doc = open(url) {|f| Hpricot(f.read.encode("UTF-8")) }

current_items = {}

doc.search(".g-compact-items tr")[1..-1].each do |item|
  title = item.at(".g-title a").inner_text.strip!
  asin = item.at(".g-title a")["href"].split("/")[2].split("?")[0]

  currency = "unknown"
  price = item.at(".g-price span").inner_text.strip!
  currency = price[0]
  price = price[1..-1]

  current_items[asin] = {
    "asin"=>asin,
    "title"=>title,
    "currency"=>currency,
    "price"=>price.to_f
  }
end

unless which('notify-send').nil?
  current_items.each do |asin, obj|
    if history["items"][asin] == nil
    #Generate notification
      system "notify-send -i /usr/share/pixmaps/gnome-irc.png \"Now Tracking\" \"#{obj["title"]}\""    
    end
  end

  history["items"].merge!(current_items) do |asin, old, new|
    if new["price"] != old["price"] && old["currency"] == null
    #Generate notification
      system "notify-send -i /usr/share/pixmaps/gnome-irc.png \"Now Available\" \"#{new["title"]} for #{new["price"]}\""
    end  
    if new["price"] == old["price"]
      #$stderr.puts "#{old["title"]} is still same price"
    end   
    if new["price"] < old["price"]
    #Generate notification
      system "notify-send -i /usr/share/pixmaps/gnome-irc.png \"Price Reduction\" \"#{new["title"]} is now #{new["price"]}\""
    end    
    new
  end
end

history["items"].delete_if do |asin,obj|
  #Removed  
  current_items[asin] == nil
end

#Save our history
File.open(history_file, "w") do |f|
  JSON.dump(history, f)
end
