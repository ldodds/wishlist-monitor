Amazon Wishlist Monitor
-----------------------

This is a Ruby script I use to monitor my own Amazon wishlist. It alerts me when things I want to buy are reduced in price

Installation
------------

The code should run with Ruby 1.8.7 or higher. You'll need to install a few gems:

	sudo gem install hpricot json

Create the following file:

	~/.wishlist-monitor/config.yaml

The contents should be:

	wishlist: ID_GOES_HERE

Where `ID_GOES_HERE` is the unique identifier for your wishlist. You can find it in the URL of your wishlist:

	http://www.amazon.co.uk/registry/wishlist/ID_GOES_HERE

You can then add a `crontab` entry to run the script as often as you like. Here's how I run mine:

	35 * * * * env DISPLAY=:0.0 /home/ldodds/workspace/current/wishlist-monitor/monitor.rb

So the script executes at 35 minutes past every hour. The `env` setting ensures that notifications are displayed properly.

The first time it runs it'll tell you the items it is now tracking, and will also alert you when a new item is now being tracked.

The ongoing data it collects is kept in:

	~/.wishlist-monitor/history.json

The JSON document contains the ASIN, title, currency and price for each item.

Background
----------

Potential Improvements
----------------------

Some Observations
-----------------


