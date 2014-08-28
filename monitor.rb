#!/usr/bin/ruby
require 'rubygems'
require 'json'
require 'hpricot'
require 'yaml'
require 'open-uri'

#Check for required config file
if !File.exist?(ENV["HOME"] + "/.wishlist-monitor/config.yaml")
  puts "Configuration file is missing"
  puts "Create a file called ~/.wishlist-monitor/config.yaml"
  puts "Then add the following configuration options:"
  puts "wishlist: ID_GOES_HERE"
  exit(1)
end

#Load config
config = YAML.load_file(ENV["HOME"] + "/.wishlist-monitor/config.yaml")
wishlist = config["wishlist"]

#Load history    
if File.exist?(ENV["HOME"] + "/.wishlist-monitor/history.json")
  history = JSON.parse(File.read("#{ENV["HOME"]}/.wishlist-monitor/history.json"))
else
  history = {"items"=> {}}
end

url = "http://www.amazon.co.uk/registry/wishlist/#{wishlist}?layout=compact"
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

history["items"].delete_if do |asin,obj|
  #Removed  
  current_items[asin] == nil
end

#Save our history
File.open("#{ENV["HOME"]}/.wishlist-monitor/history.json", "w") do |f|
  JSON.dump(history, f)
end
