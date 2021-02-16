#!/usr/bin/ruby
require 'rubygems'
require 'json'
require 'hpricot'
require 'yaml'
require 'open-uri'

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

SILENT=false

def notify(type, obj)
  case type
  when :tracking
    msg = "\"Now Tracking\" \"#{obj["title"]}\""
  when :available
    msg = "\"#{obj["title"]} for #{obj["price"]}\""
  when :changed
    msg = "\"#{obj["title"]} is now #{obj["price"]}\""
  else
    msg = nil
    #$stderr.puts "#{old["title"]} is still same price"
  end
  $stderr.puts "#{type}: #{msg}" if SILENT==true && msg != nil
  system "notify-send --icon=/usr/share/pixmaps/evolution-data-server/category_gifts_16.png \"#{type.capitalize.to_s}\" #{msg}" unless (msg == nil || SILENT==true)
end

def parse_items(amazon_domain, wishlist)
  url = "http://#{amazon_domain}/hz/wishlist/printview/#{wishlist}"
  doc = URI.open(url) {|f| Hpricot(f.read.encode("UTF-8")) }

  current_items = {}

  doc.search(".g-print-items .g-print-view-row")[1..-1].each do |item|
    title = item.search("td.a-align-center span")[0].inner_text
    asin = item["id"].split("tableRow_")[1]

    currency = "unknown"
    price = item.search("td")[3].inner_text
    currency = price[0]
    price = price[1..-1]
    currency = nil if currency == " "
    price = currency.nil? ? nil : price

    current_items[asin] = {
      "asin"=>asin,
      "title"=>title,
      "currency"=>currency,
      "price"=>price.to_f
    }
  end
  return current_items
end


#Load history
if File.readable?(history_file)
  history = JSON.parse(File.read(history_file))
else
  history = {"items"=> {}}
end

current_items = parse_items(amazon_domain, wishlist)

alerts = 0

unless which('notify-send').nil?

  current_items.each do |asin, obj|
    if history["items"][asin] == nil
      alerts = alerts + 1
      notify(:tracking, obj)
    end
  end

  history["items"].merge!(current_items) do |asin, old, new|
    if old != nil
      if new["price"] != old["price"] && old["currency"] == nil
        alerts = alerts + 1
        notify(:available, new)
      end
      if new["price"] == old["price"]
        #notify(nil, new)
      end
      if new["price"] < old["price"]
        alerts = alerts + 1
        notify(:changed, new)
      end
    end
    new
  end

  if alerts == 0
    system "notify-send --icon=/usr/share/pixmaps/evolution-data-server/category_gifts_16.png \"Wishlist monitor\" \"No price changes\"" unless SILENT==true
  end

end

history["items"].delete_if do |asin,obj|
  current_items[asin] == nil
end

#Save our history
File.open(history_file, "w") do |f|
  JSON.dump(history, f)
end

$stderr.puts "Wishlist monitor completed. Send #{alerts} alerts"
