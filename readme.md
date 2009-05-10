Twitterified Client
=============================================================
This is the complete source code for the Twitterified client, as described at [Twitterified](http://twitterified.com)

What is this then?
-------------------------------------------------------------
When I started the Twitterified client, it was a "week-end project." Not something that was going to evolve into a full-fledged multimedia Twitter client.
Now, it has features such as supporting multiple accounts simultaneously, multiple providers, embedding video, images, long messages, mouse gestures...not to mention code, not activated yet, to archive favourite Tweets in an outliner, a drawer, change skins, etc.
It also has some glaring shortcomings such as having to restart the client after adding a new account.

And, to top it off, my goal with this project was to teach myself Flex.

As a result, we have a fairly large code base that remains readable but could certainly use some major reorganization. I used classes but not always! Yes, that's what happens when you think "Hey, no-one will ever have to see this. It's just a fun week-end thing."

Good to know
-------------------------------------------------------------
* I tried to keep most of the model itself in main.as while actual visual updates are found in com/voilaweb/tfd/notclasses/main_ui.as

* Multiple accounts management happens through a proxy class: MultiTwitter

* All configuration information is persisted in a local SQLite database.

* The certificate and air packaging script are not included because this would allow anyone to impersonate the official Twitterified build. I think current users would not be too happy about that.

* I need to create more documentation. Tons of documentation, really. In the meantime feel free to ask.

Community
-------------------------------------------------------------
[Get Satisfaction Community](http://getsatisfaction.com/voilaweb/products/voilaweb_twitterified_client_open_source)

CC License
-------------------------------------------------------------
[Creative Commons Attribution 3.0 United States License](http://creativecommons.org/licenses/by/3.0/us/)

Credits
-------------------------------------------------------------
For third-party contributions, see credits.txt as well as individual license files.