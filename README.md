Amazon Wishlist Monitor
-----------------------

This is a Ruby script I use to monitor my own Amazon wishlist. It alerts me when things I want to buy are reduced in price

Installation
------------

The code should run with Ruby 2 or higher. You'll need to install a few gems:

	bundle install

Create the following file:

	~/.wishlist-monitor/config.yaml

The contents should be:

```yaml
  wishlist: ID_GOES_HERE
  amazon_domain: DOMAIN_OF_LOCAL_AMAZON_SITE (www.amazon.com, www.amazon.co.uk, etc)
```

Where `ID_GOES_HERE` is the unique identifier for your wishlist. You can find it in the URL of your wishlist:

	https://www.amazon.co.uk/hz/wishlist/genericItemsPage/ID_GOES_HERE

You can then add a `crontab` entry to run the script as often as you like. Here's how I run mine:

35 * * * * eval "export $(egrep -z DBUS_SESSION_BUS_ADDRESS /proc/$(pgrep -u $LOGNAME gnome-session)/environ)"; /bin/bash -l -c 'cd /home/ldodds/workspaces/current/wishlist-monitor && bundle exec ruby monitor.rb' >> /tmp/wishlist 2>&1


The big crazy eval statement is to get Ubuntu to display the notifications in the main notifications panel. (No, I don't know)

The first time it runs it'll tell you the items it is now tracking, and will also alert you when a new item is now being tracked.

The ongoing data it collects is kept in:

	~/.wishlist-monitor/history.json

The JSON document contains the ASIN, title, currency and price for each item.

Potential Improvements
----------------------

There are lots of potential improvements:

* The notifications are done using the `notify-send` command-line tool. I had some issues with Ruby/gem/library dependencies when trying to use a proper Ruby interface to notify, so ended up just shelling out. You might want to improve that
* The notifications could be better formatted. In principle `notify` supports many more options, but the Ubuntu developers, in their wisdom, have decided not to support them. You could easily add better formatting, improve timeouts, or add product images and direct links
* It reports on all price changes. Would be better to set thresholds
* It could track more price history, e.g. to summarise notifications
* It could track a variety of prices, e.g. second-hand as well as new
* There's a bug with some unavailable items being marked as dropping to zero price.
* ...etc

Some Observations
-----------------

The dumb implementation reports on every price change. No matter how small.

This means that over the last few months of using the script I've been noticing some interesting behaviour, mainly marketplace vendors continually tweaking prices, often by only a few pence in order to stay at the top of the rankings. I only run the script on an hourly basis, so I'm not sure how often the changes really occur. But for some things on my list, e.g. board games and DVDs, there are often several daily price changes.

It's made me wonder what kinds of tools Amazon provides to marketplace vendors to monitor prices. Or whether there are third-party tools. Or whether vendors are just carefully tracking their own inventory.

Its also educational to watch how rapidly video game or DVD prices drop over the course of a few months. Nothing we don't know already, but makes you think about rushing out and buying the next exciting thing when you know it'll be much, much cheaper in a few months.
