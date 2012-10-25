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

I read a lot of Kindle books but reluctant to the same price as a paper; often the prices are more equivalent to hardback prices. I'm also reluctant to pay full price when I notice that sometimes Kindle editions can be heavily discounted. Sometimes just for a day (e.g. the Daily Deal) sometimes for slightly longer periods. I wanted to automate the bargain hunting.

Having noticed that there are predictable URLs for wishlists and that the "compact" view is easily scrapeable, I wrote a quick script that regularly scans the items on my list and then compares them to their last known price. The script generates a desktop notification if it sees a discount. 

At one point I was interested in building a service to do this, but the Amazon Product API has very prescriptive terms for storing and using data. The economics of Amazon marketplace prices would be interesting to watch.

And actually, because my script is so dumb, that's what I've been doing. More on that below.

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

I've been wondering recently about setting up a wishlist with a selection of top rank video games, major film releases, etc and charting out how they change over a few months. I may still do that. Now you have the basic script, maybe you will too.

Most importantly though the script works for me. Today I bought a Kindle book for 99p, it was nearly £7 when I added it to my wishlist. I'm now finding that I'm wishlisting a lot more books and then buying them cheaper.
