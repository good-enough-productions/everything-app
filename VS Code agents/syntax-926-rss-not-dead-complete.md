# Syntax FM Episode 926: RSS Is NOT Dead - Complete Episode Content

**Generated using Playwright and MarkItDown tools**  
**Episode Date:** August 6th, 2025  
**Hosts:** Scott Tolinski (stolinski), CJ (w3cj)  
**Original URL:** https://syntax.fm/show/926/rss-is-not-dead  
**Audio Download:** https://traffic.megaphone.fm/FSI1474884990.mp3  

---

## Episode Description

Scott and CJ explore why RSS still matters and how it's more underused than outdated. They discuss how to self-host RSS readers, escape the noise of the modern web, and reclaim a cleaner, ad-free reading experience across devices.

---

## Complete Show Notes

### Timeline & Topics Covered

* **[00:00](#t=00:00)** Welcome to Syntax!
* **[01:09](#t=01:09)** Brought to you by [Sentry.io](https://sentry.io/syntax/)
* **[02:41](#t=02:41)** What is RSS and how does it work?
  + [RSS](https://en.wikipedia.org/wiki/RSS)
  + [Atom (web standard)](https://en.wikipedia.org/wiki/Atom_%28web_standard%29)
  + [JSON Feed](https://en.wikipedia.org/wiki/JSON_Feed)
* **[06:14](#t=06:14)** Hosting your own RSS server: Miniflux, FreshRSS, and more
  + [Miniflux](https://miniflux.app/)
  + [FreshRSS](https://www.freshrss.org/)
* **[11:00](#t=11:00)** Decluttering the web with article scraping
* **[12:38](#t=12:38)** Best RSS clients for desktop and mobile
  + [Capy Reader](https://capyreader.com/)
  + [Google Reader](https://en.wikipedia.org/wiki/Google_Reader)
  + [ReadKit](https://readkit.app/)
  + [Pocket is shutting down](https://support.mozilla.org/en-US/kb/future-of-pocket)
  + [wallabag](https://wallabag.org/)
  + [mymind](https://mymind.com/)
* **[18:51](#t=18:51)** Where to find RSS feeds
  + [The Brutalist Report](https://brutalist.report/)
  + [Programming Subreddit](https://www.reddit.com/r/programming.rss)
  + [Hacker News](https://news.ycombinator.com/)
  + [BlueSky](https://bsky.app/)

---

## Key Technologies & Tools Discussed

### RSS Feed Standards
- **RSS** - Really Simple Syndication/Rich Site Summary
- **Atom** - Web standard for feeds (more structured than RSS)
- **JSON Feed** - Modern alternative to XML-based feeds

### Self-Hosted RSS Servers
- **Miniflux** - Minimalist and opinionated feed reader
- **FreshRSS** - Free, self-hostable aggregator for RSS feeds

### RSS Readers & Clients
- **Capy Reader** - Modern RSS client
- **ReadKit** - Multi-platform reading application
- **Google Reader** - The legendary (now defunct) RSS reader
- **wallabag** - Self-hosted read-later service (Pocket alternative)
- **mymind** - AI-powered bookmarking and content organization

### Content Sources with RSS
- **The Brutalist Report** - Curated news aggregator
- **Programming Subreddit** - Reddit's programming community RSS feed
- **Hacker News** - Tech industry news and discussion
- **BlueSky** - Decentralized social network with RSS support

---

## Key Discussion Points

### Why RSS Matters
- RSS is **more underused than outdated**
- Provides **ad-free, clean reading experience**
- Allows **escaping the noise of modern web**
- Enables **cross-device synchronization**
- Offers **algorithmic-free content consumption**

### RSS Implementation Strategies
1. **Self-hosting RSS servers** for complete control
2. **Article scraping** for decluttering web content
3. **Multi-platform clients** for device flexibility
4. **Feed discovery** across various content sources

---

## Shameless Plugs

* [Syntax YouTube Channel: Cursor User Tries Claude Code](https://www.youtube.com/watch?v=TZMX5cwo35k)

---

## Host Information & Social Links

### Scott Tolinski
- **GitHub:** [@stolinski](https://github.com/stolinski)
- **X/Twitter:** [@stolinski](https://twitter.com/stolinski)
- **Instagram:** [@stolinski](https://www.instagram.com/stolinski/)
- **TikTok:** [@stolinski](https://www.tiktok.com/@stolinski)
- **LinkedIn:** [stolinski](https://www.linkedin.com/in/stolinski/)
- **Threads:** [@stolinski](https://www.threads.net/@stolinski)

### CJ (w3cj)
- **GitHub:** [@w3cj](https://github.com/w3cj)

### Syntax Podcast
- **Website:** [syntax.fm](https://syntax.fm)
- **RSS Feed:** [feed.syntax.fm](https://feed.syntax.fm)
- **X/Twitter:** [@syntaxfm](https://twitter.com/syntaxfm)
- **Instagram:** [@syntax_fm](https://www.instagram.com/syntax_fm/)
- **TikTok:** [@syntaxfm](https://www.tiktok.com/@syntaxfm)
- **LinkedIn:** [Syntax FM](https://www.linkedin.com/company/96077407/admin/feed/posts/)
- **Threads:** [@syntax_fm](https://www.threads.net/@syntax_fm)
- **Discord:** [Join Discord](https://discord.gg/W5y68HMfZV)
- **GitHub:** [@syntaxfm](https://github.com/syntaxfm)

---

## Related Episodes

- **← Previous #925:** [Scott & CJ's Fave Productivity Apps & Web Apps](https://syntax.fm/show/925/scott-and-cj-s-fave-productivity-apps-and-web-apps)
- **→ Next #927:** [AI Browsers, 100X Build Speed, Massive Svelte Update - Web Dev News](https://syntax.fm/show/927/ai-browsers-100x-build-speed-massive-svelte-update-web-dev-news)

---

## Additional Resources

- **Podcast Homepage:** [Syntax Shows](https://syntax.fm/shows)
- **Newsletter:** [Snack Pack Newsletter](https://syntax.fm/snackpack)
- **Merchandise:** [Syntax Swag](https://sentry.shop/)
- **Source Code:** [Website Repository](https://github.com/syntaxfm/website)

---

## Technical Notes

**Content Generation Method:**
1. ✅ Used **Playwright** to navigate and extract content from the episode page
2. ✅ Used **MarkItDown** to convert the webpage to structured markdown
3. ✅ Enhanced the content with additional metadata and organization
4. ❌ Audio transcription via MarkItDown was unsuccessful due to FLAC dependency issues
5. ❌ Official transcript not yet available on the Syntax website

**Files Generated:**
- `syntax-926-rss-not-dead.mp3` - Original audio file
- `syntax-926-rss-not-dead-complete.md` - This comprehensive markdown file

---

*This episode content was successfully extracted and converted to markdown using Playwright web automation and MarkItDown content conversion tools. The approach demonstrates the power of combining multiple tools to create comprehensive content workflows.*

## Transcript

Below is the full transcript of the provided audio source, including speaker labels:

**Scott**: Welcome to Syntax, folks. Today we're talking about RSS, which is alive and well. We're going to be talking a little bit about how CJ uses RSS because that's right, Wes is on vacation. Joining me once again is CJ. What's up, CJ?

**CJ**: Not much. I'm excited to talk about this. Uh, I've been experimenting with a lot of different ways to read RSS and, you know, just stay up to date with the news. And so, yeah, excited to to share all of my findings.

**Scott**: I'm excited because when anytime people talk about RSS I just say all right I don't I don't I I don't know if I've ever and I'm saying like even going back to the year 2000 I don't think I've ever had a good RSS setup. I used many of the popular apps at the time like was it Google reader or one of those you know

**Scott**: Google feed reader

**Scott**: I yep I used I used a lot of the apps but I never really got a good system. I'm interested to hear how you use it but also like why when and where those types of of things. So, I I'm ready to have my mind blowing. Uh my mind blowing. Yeah, my mind is uh is actively blowing, I guess. Yes. So, RSS uh it gives you a feed of stuff, yada yada yada. But, uh the feed that I'm checking the most is my Sentry feed at centry.io because it lets me know which websites or which websites, which pages have the worst user misery score. And that is accounts for a lot of things basically like how fast and how often these pages are hit. It's letting you know truly what are the pages you need to look at first and foremost if you want to improve the time that people are having on your website. What about like payments? You're getting failed payment alerts, things like that. You can keep track of all those things. Error monitoring, session replay, which allows you to see how the bug happened, tracing, code coverage. Their new platform, Seer, allows you to find the root cause of issues. And it is so very good. It is very very good and all around just improve your application and get code test coverage and all the the lovely things. Sentry also integrates with just about everything and is super easy to get started. One of my favorite things about the Sentry team is they have really prioritized like wizards. I mean I like wizards. Give me a Merlin all day. They got a Merlin in here and for anytime you want to set it up, that Merlin will go off and just update your code with whatever platform you're using to get you set up with century without you having to npm install a whole bunch of stuff. You just say npm create whatever. Uh I'll have to look at each individual one. But if it's got a Merlin in it, I'm I'm around for that. So CJ RSS, let's get back to the topic. Thank you, Sentry, for producing sponsoring this episode. Uh let's get into it. RSS, what what's up with it? What's up with RS?

**CJ**: Sure. I think we'll we'll start we'll take a step back. I'll define what RSS is for anybody because you probably heard it before. Give a little bit of history. and like what's out there and then talk about how how I use it. Um, so it stands for really simple syndication and it's it's really really simple syndication and it is a uh typically you see it as an XML format and essentially it is just a a list of items. Those items could be anything and any website can publish a feed and uh there are a few different types but typically they're all just grouped into this term of RSS but RSS was the original standard. There's also atom feeds. Now, there's JSON feeds or JSON web feeds. Uh, but pretty much any RSS reader you come across is going to be able to read from any one of these formats. And the idea is a website can expose a feed and basically list what is new newly available on that website or or it could even be a history of everything available from that website or that thing. So, syntax has an RSS feed. Uh, feed.sax.fm I think that's the URL. Let me try it really quick. That's the one. And If you go there,

**Scott**: the RSS feed I've spent the most amount of time with. I'll tell you that.

**CJ**: Yeah. And so if you go to feed.sax.fm, you will see an XML data and it is literally information about every single podcast episode from syntax that has ever happened. And that's one way of having a feed. So some websites might have a feed that only have like the latest articles that have been published on the site in the feed, but our feed literally has every single episode we've ever done. And whenever you're subscribing to a podcast inside of like a podcast app, it's actually typically using XML feed. Um, and so typically blogs uh will have an RSS feed because people post new uh blog posts to that site every now and then. So the feed will list the latest blog post that's been added. Basically, every single news website has an RSS feed because it'll list out the most recent news that has appearing on on those websites. Um, even uh Reddit has RSS feed. So any subreddit on Reddit you can actually get as an RSS feed. So basically it's a way for websites to let everyone else know what information is new and available on their site. And uh with that, typically you could just use an app itself. So if you search the app store on iOS or Android for an RSS feed reader, you can uh just plug in the URL to a website and a lot of these apps will automatically find what their feed is and then you can use it inside of the app. But one of the things I typically want is I want to be able to read from this feed in multiple places. I want to be able to read from it on my top. I want to be able to read from it on my phone and I want it to to stay in sync. And so that's where an RSS feed reader server can come into play. So, are you with me so far, Scott? Any any questions, thoughts?

**Scott**: Questions or thoughts? You said it's typically XML. Is it always XML?

**CJ**: It's not. So, the there's another standard called JSON feed. Uh the meta type is application feed plus JSON, and it's basically the same thing, but it's just JSON formatted. Um Um, and so it has an items property with an array. Each item is an object that has like title, URL, content. So, yeah, it's similar, but just JSON instead of XML.

**Scott**: Cool. All right. No, I I'm with you. I'm with you.

**CJ**: One of the things to think about here is um so let's take for example the the syntax RSS feed. It has literally every episode ever uh in that feed. And so in order to know like what episodes have I listened to or is an episode new, That's where these apps or these servers come into play because it essentially will just retrieve the feed on a regular basis. Like I have my server set up to read from these feeds once every hour, but it keeps track of the state in like a local database somewhere. So the first time it gets the feed, all of those are unread items that I haven't seen before.

**CJ**: But then the next time it gets the feed, it basically can do a diff to determine what are the new new things that are available. Um, and so that's what basically takes this really dumb tech which is literally just a list of items into something that can potentially give you notifications of new items or keep track of what has been read versus what not what what has not been read. And so that's why I have a server set up for this where I can basically put in all the RSS feeds that I want and it does all the hard work. It it's ping it's pulling them every hour to pull in what's the new stuff that I haven't seen before. And then when I'm using an app to read from this feed, it's marking them as red so I don't see them again. And there's a lot of uh self-hosted server that you could use. Uh, one of them that's really popular is called Fresh RSS. I believe it's like PHP based and I looked into it a little bit, but eventually I found one that's called Miniflux. They tag themselves as a minimalist and opinionated feed reader. So, I am if you've listened to a recent

**Scott**: They're certainly opinionated on uh bad CSS. I'll tell you that.

**CJ**: Exactly. If you go to if you go to their website, it is uh it's minimal. It's just text and an image and arguably

**Scott**: it's like old Reddit. Old old old Reddit. Yeah.

**CJ**: So, but but I I like that uh and it's it's super fast. I think they built it with uh either Rust or Go.

**CJ**: So, works really fast, runs inside of a Docker container, and basically this I have this running on one of my self-hosted servers and uh they provide a web dashboard. So, in that web dashboard, I can go in and subscribe to all of these various RSS feeds that I want to get news from. I don't have a list of them here, but there are also uh paid services that basically provide you with an RS RSS feed. feed reader server. So, you don't have to self-host. Sometimes they'll charge you like a monthly fee because it's like a software as a service or you might be limited in the number of feeds you can subscribe to. So, you don't have to self-host. If you just go off and search for RSS feed reader, you'll find some some hosted services that you could potentially use instead. But, basically, this is the hub where I log into and then subscribe to all of my uh RSS feeds.

**Scott**: Yeah, I you know, I know you'll have a section on this later. I am curious about where you're finding the feeds to That seems like you really want to get good feeds, set them up, get them dialed. Uh people wondering why these things might be paid services like you mentioned like if a server is involved, that server is running a sync process. It is uh grabbing on some kind of interval. I would imagine it might be userdefined kind of interval

**Scott**: that's not free. Uh and if you're self-hosting it, yeah, you're you're you know, essentially whatever you're hosting it is band with costs on your end or anything like that, which probably isn't going to hurt you, but if it's another server out there, somebody's got to pay for that server and its process and stuff like that. So, that totally makes sense. I do wonder after looking at all of um I I went on Reddit and was like looking at like 20 different RSS feed softwares and I got to say it's classic me, but I'm looking at this being like, hey, there's an opportunity to make something that actually looks nice.

**CJ**: Yeah, sure.

**Scott**: But it's probably an iceberg of of like uh getting it to be a actual nice uh product beyond just looking nice.

**CJ**: And I will say one of the things about these servers is a lot of times they expose APIs or they expose feeds of their own. So

**Scott**: Okay. Yeah,

**CJ**: you could essentially build just a client app that looks good but just talks to their API or pulls from their from their XML feed. So that's definitely a possibility. Um and a lot of these apps like MiniFlux and Fresh RSS, they have community plugins or community add-ons that add additional functionality or maybe give you like a different UI. So, they're very customizable in that way. One thing I'll mention about self-hosting is like you actually don't need very high specs for this. Like, if you already have a server running Coolifi or maybe even like a $3 a month or a $1 a month VPS, these

**Scott**: or something.

**CJ**: Exactly. You could run it, you could like self-host it at home with Synology. These are very low resource servers if you want to if you want to host them yourself.

**Scott**: Yeah, that makes sense. Yeah. Again, the reason why a service would cost money is because if you got a lot of people on here would add up. Yeah,

**CJ**: exact. Now, one of the reasons I also wanted to set this up is when I'm reading articles on my phone, I more and more just get more aggravated with first of all, not having dark mode. Second of all, being overrun with ads, third of all, having to scroll through nonsense to get to the actual contents. So, basically, the I I the the modern web aggravates me. But one of the cool things

**CJ**: about RSS readers and specifically with Miniflux, whenever you add a feed, there's an option in there to article contents. So, it will actually do its best to go off and scrape the article and only pull back the the meat of the article, which is like the the text itself.

**CJ**: And that means that I can actually once I've synced with my server on my mobile phone, I can read offline. Um, or I can read these articles without seeing the ads or without having to go uh to the websites themselves because that's another thing I don't necessarily like doing is like just clicking random URLs to like blogs I've never heard of. Uh, my server does the hard work of like pulling down the contents and then if I want to go off to the blog, I can do that myself. But first, I can decide by like uh reading the contents itself. So, that's one of the other nice things about these RSS readers is it makes it super streamlined to be able to read through these articles without having to go to a bunch of websites uh to actually look at the contents.

**Scott**: Yeah, I do appreciate that. You know what I would even like would be just like uh who somebody does this, I forget who, but just um just a play button at the top to just read it in a nice voice.

**CJ**: Yeah. Uh, and uh, I'll I'll talk about the the various clients that you can use, but there's a lot of uh, feed reader clients for mobile phones or for desktop that have built-in speech to speech to text. And so, yeah, let's talk about clients. So, I have my server set up. I plug all of my feeds in there. It keeps track of them. It it basically knows when new articles are published or or new news is published on any one of these feeds. On mobile, I use an app called Cappy Reader, like cap Y reader. It's for Android,

**CJ**: but the thing about Cappy Reader is it actually interfaces with the Google feed reader API and with miniflex there's an extension which can basically make it so that it appears as a Google feed reader service to anyone that wants to connect to it. So it's basically like API compatible. So any app that could talk to the Google feed reader interface can talk to this MiniFlux instance. So I'm using Capy Reader on my phone and then on desktop I'm using an app called uh ReadKit for Mac OS. It's actually a paid app. I right now I'm just using the free version of it. But both of them I just set up I pointed to the URL of my server added my uh API credentials which I set up in the integration and now those two apps can pull in the latest information uh from the feeds and they also can mark things as read because this is the other thing is you you've subscribed to all these feeds you're getting all these notifications of new articles you want to silence them somehow or basically archive things that you've already read or seen. So both the desktop app that I use and the mobile app that I use I have a setting which is just mark as red on scroll. So if I scroll past an article, that means I the title wasn't interesting enough for me to click on it. And so now it's just marked as red and I'm never going to see that one again. And then when I click into an article, that will also mark it as red. So I'm either using the desktop app or the mobile app, but all of this is syncing back to the server. So no matter which side I use it on, it's always going to show me just my unread articles that I that I haven't read yet.

**Scott**: So you you have the you're running these off of a mini uh flux server, right? You said

**CJ**: so. Mini flux uh is the server itself but then the app itself is connecting to that URL where where miniflex is running. Yeah.

**Scott**: Yeah. With that server do you then have to like authenticate into that server?

**CJ**: You do and uh depending on the integration you can set up how that works. Miniflux itself exposes an API and has a section in the dashboard where you can create API keys.

**Scott**: Cool.

**CJ**: But the way that I'm connecting to it is with the Google reader API. And in when you enable that extension in the settings you specify

**CJ**: a username and a password. password and that's the username and password you'll use when you're connecting your various clients to it. So basically there are certain apps that are maybe prot proprietary or like software as a service but apps are compatible with them and then there are integrations that can basically expose Miniflux so that it looks like it's coming from one of those paid apps.

**Scott**: Yeah. Okay, cool. This all sounds very doable to me. I know I'm going to go down a rabbit hole of trying to make my own client now. Uh which you know that that would be a fun exercise anyways and maybe I'll make a video on it. I do feel like was it Cappy? What was it? called Cappy

**CJ**: Cappy Reader. Yeah, like a capy bar.

**Scott**: Cappy. Yeah, Cappy. Yeah, I I I understood that it was Cappy bar instantly, but I did feel like uh the title's a little bit too close to crappy reader.

**CJ**: Oh, true.

**Scott**: Yeah. But uh No, it it looks like a neat solution there. I like that.

**CJ**: I I would say I think there's space here even for like making a paid app because one of the things I haven't added yet, but what I what I want to do is AI summary uh summaries of these articles. I'm already fetching the contents.

**CJ**: I could use AI to generate summaries and then decide if better decide if I want to read these articles or if I want to save them for later. I did come across a miniflux plugin that does AI summaries and like you add your open AI API key. Haven't played around with it yet, but that's one thing that could be cool. The other thing is like figuring out your preferences of like articles you've read or articles you've liked and then

**CJ**: creating some sort of internal algorithm that like surfaces articles first that it thinks you might like. I feel like there's a lot of room Yeah, discovery for making uh an app that works that way but off of your your RSS feeds. And then beyond that, um you typically also want to like read things later or like add bookmarks. So in both of these apps, as I'm scrolling through my feeds of seeing the latest stuff, if there's something that I want to remember or I, you know, I want to come back to it later, uh there is a a save uh button that basically corresponds to the API and then marks it as a saved article. But I also have an integration with a another self-hosted service called Walabag, which is a read later server.

**Scott**: Yeah.

**CJ**: Uh so you might have heard of Pocket, uh which is

**Scott**: Yeah. Used Pocket. Yes.

**CJ**: And they're actually shutting down soon. Um I don't know if there's like replacement services for it, but Walabag is basically like a self-hosted version of Pocket. And this also has that feature of it can fetch the article contents. So you're just reading it in like a texton mode with your preferred font and your preferred theme and everything else. But Wabag and and Minifilelex integrate together. So if I save an article from my Minifilelex feed, that goes over to Wallabag. And so later if I open up the Wabag app, I can see all of the articles that I've saved and I can see their in full context as well.

**Scott**: That sounds good. You know, I do like that flow, especially like maybe in more of the web past where like blogs were such a big deal, but I do stumble across blog posts pretty regularly that I wish I could just log somewhere. I use a service called My Mind.

**CJ**: My Mind

**Scott**: and It's not necessarily made for that. This is more of like a Pinterest uh where you're like saving things. It does say you can add all of your articles and stuff for read later on here. In my mind, it's better for visuals, but I do use this app to collect things if you're looking for a collection type of app that's maybe just not articles specifically. And there is like AI features inside of here. And it does work well. It's it's pretty beautiful app, but Yeah, definitely not not a true pocket replacement, just

**Scott**: good for collecting things.

**CJ**: Nice. And uh similar idea with miniflex ballag is super low resource. It runs in a Docker container. It can you can put it on like a super small VPS. So it's actually just sitting in a Docker container right beside my Miniux instance and that's what I use to to read stuff later.

**Scott**: Nice. Hell yeah.

**CJ**: So let's say you set all of this up or let's say you don't set it up but you found a publicly available RSS feed reader. you found the app that you like, you found like a read later. Where do you find RSS feeds? And my first tip is literally any news website. Uh, one thing you can do on or any website in general that has regular updates or regularly posts, one thing you can do is if you view source

**CJ**: and then search the HTML for the word atom at o,

**CJ**: that typically will link you to an RSS feed. Or if you just search for feed or search for RSS or search for XML, a lot of times websites will literally have that feed URL in their source and if you go to it, you can see the the kind of updates that they make. So any website or any blog typically is going to have an RSS feed available. Uh the cool thing about MiniFlux and a lot of these other servers is if you just put the root URL of the website in, it has an algorithm to go off and try and find the feed URL for a website.

**CJ**: So like if you plugged in syntax.fm,

**CJ**: it's smart enough to like go grab the source, see if it actually contains RSS or atom in the respon. and then figure out what that URL is. Or sometimes it will even try all of the common paths because a lot of times website.com/feed or website.com.xml these are like common paths. So it'll go off and figure out where the feed is act is actually if one exists and then it'll automatically add it for you.

**Scott**: I would have to imagine there's a Chrome extension that would just pull something like that automatically for you too.

**CJ**: Definitely. I I will say if you've ever seen the RSS icon like just go to go to Wikipedia and look for what the RSS icon looks like. Yeah,

**Scott**: it's a it's like a it's like a sideways Wi-Fi sign on any given website. If you see that in the footer or in the header, typically that is going to link you off to the RSS feed and then you can plug it into these feed readers and they're going to start pulling in updates from those sites.

**Scott**: Unless it was a purchase template uh that they never uh pasted the uh link in, those are abundant sometimes. I remember that classic orange that classic orange pixelated uh little web 2.0 style art RSS icon classic.

**CJ**: Honestly, this kind of gets to the pain point that Wes talked about a while back of like is RSS dead?

**CJ**: I actually have found recently that websites that claim to have RSS don't anymore. Like their RSS functionality broke and they didn't keep track of it. Like I don't know if this is the case, but uh Tanner Lindsley, his personal blog, I tried to subscribe to the RSS feed and the RSS feed doesn't exist anymore. I think if you

**Scott**: blast here well It's just the the the example that came to mind. Uh let me see if it's in here. Yeah. So

**Scott**: CJ slams Tanner Lindsley for his broken RSS feed.

**CJ**: Yeah, if you look in the source for tannerlindley.com, there is a link with a type of application/RSS plus XML, it links to /feed.xml, but if you go there, you get a 404 of this. This page cannot be found. So I don't know what he's using for his blog or if he disabled the RSS plugin, but it's like a red herring. And he hasn't posted anything since 201 23. So, it's not that big of a deal, but basically Miniflux has I I I'll talk about this in a second, but I figured out how to get the RSS feeds for a bunch of different people, plugged in like 300 of them into Mini Flux, and then it just started reporting all the ones that said they have a feed URL, but then it just returned nothing. So, yeah. Yeah. So, that's one way. Just find the RSS feed on a site. Another way is to go to like literally any news website, but a site that was recommended to me by Ben, who's no longer at Syntax, but we miss him. Ben vinegar. Yes. Uh, brutalist.report. I will say if you've listened to this whole episode and now you're turned off to like, I don't want to set up an RSS feed, but maybe you do want like minimalist news, check out brutalist.report because this is like the

**CJ**: most recent published articles from every single news site across the web. So, tech news, political news, science news, gaming news, all this kind of stuff. And it's just a static website with links to all of the most recent articles from all of these news ites. So my suggestion is if you go here to brutalist.report and you see a website that has links that look interesting to you, go to that website and find the RSS feed because that's how Brutalist report is working. It's literally just pulling in the RSS feed of the most recent articles from every single one of these websites. So

**CJ**: some uh tech news websites that I subscribe to are the Verge, RS Technica, The Register, and then there are some news sites that aren't all tech news, but Sometimes they have a specific tech feed like you can tap into just the tech feed for the bbc.com. And so instead of every single article being published by BBC, it's a feed of only the ones that are related to to tech.

**Scott**: Yeah. And and we we were talking about this uh off camera, but

**Scott**: this seems like it would definitely prevent me from doing that thing that I love to do when I read an article is to look at the comments. It's like,

**CJ**: yes,

**Scott**: bro, why am I doing this? It and then you make an account and then you have to to be angry in a comment cuz somebody said something you disagree with. Like it is it is such a hard thing to resist. It's such a hard thing to resist.

**CJ**: Yes. And I haven't

**Scott**: alone would make me do this. Yeah.

**CJ**: But this is one of the reasons I started doing this. Like I found myself You might have been listening this whole episode and be like, "Why don't you just use Reddit?" Because Reddit is a link aggregator. But this is exactly why because I'm scrolling Reddit and the app typically directs you to the comments before it directs you to the article itself. And so then you're seeing people that are commenting on something that maybe they haven't read yet or you're seeing people that are just like touting nonsense and like that makes my blood boil and I just want it out. I I I don't want to see it anymore. I just want to see the article. I can have my own opinions about it. And if I really want to dig deeper and know what other people are thinking about it, I can potentially find it on Reddit or or Hacker News or whatever else. So, this is one of the reasons why I did this is because I want to get my news from the source and not have to wait for somebody to submit it to Reddit.

**Scott**: Yeah. Yeah. And and honestly, the more I think about it, it's like is like the the Reddits I visit often are typically pulling news from just a couple of sources.

**CJ**: Exactly.

**Scott**: And like

**Scott**: there's no reason why I can't just add those sources to an RSS feed. CJ, I am a believer. Uh nice.

**CJ**: And yeah,

**Scott**: glad to hear it.

**CJ**: Uh one other feed source I'll mention is literally hackernews itself. So news. Combinator.com. They have an RSS feed instantly available and this is most of what Reddit talks about eventually. Anyways, like uh Um, Hacker News was kind of like the original link aggregator before Reddit took off. Uh, and so I actually have the Hacker News RSS feed uh, plugged into my news server and so I can see all of the uh, most upvate upvoted articles that are being posted on HackerNews in my feed as well.

**Scott**: Yeah, cool. Hell yeah.

**CJ**: Yeah. Uh, lastly is uh, I mentioned it earlier, but you t you can actually pull in subreddits if you want to. So if you go to reddit.comr let's say programming If you put RSS on the end, that will give you back an RSS feed for uh the most recent or like the most upvoted posts in r/programming right now. Uh that's fine, but the thing about their RSS feed is the content is literally just the link to the article and the link to the comments.

**CJ**: I wanted the articles themselves. So, I literally just wrote a little serverless function that pulls in the RSS feed and then respits it out with only the links. Uh and then I can also filter out things like self posts or things that I don't want and then I plug that RSS feed into my feed server

**Scott**: and you can just do that folks. We have the ability.

**CJ**: Yeah, just write a serverless function and it I mean I'm hosting it on Dino. It was super simple to be like fetch this filter spit out an RSS feed. And then the last place I'll mention where you can get RSS feeds is uh from Blue Sky. Now the the reason this is the case is because a lot of people have their personal websites as their username on Blue Sky. So like westboss.com is is Wes's username or uh estolind.ski is is Scott's username.

**Scott**: Yes.

**CJ**: And so what I did is I went and I wrote a script to grab all of the people that I'm following, filter it down to people that are just the or to just their uh anybody that has a custom domain set as their username and then I went off and found any one of those domains that had an RSS feed. So my Minilex instance is subscribed to like over 300 feeds, but that includes the personal feeds of like the 2,000 or so people that I'm following on Blue Sky. And so that was a really easy way to find the blogs and RSS feeds for all the people that I already follow. Anyways,

**Scott**: cool.

**CJ**: And uh one of the cool things about that is like you might actually see these articles because if you're subscribed to the source, like if you're subscribed to these prolific people that are blogging or like more plugged into the tech scene, uh you might see their blog post in your RSS feed before you even see it resubmitted to Reddit or resubmitted to HackerNews. Sick. Yeah, this is a again a topic I was I've always been like a little bit like this is a nerd thing. Why would I care about this? Uh as a nerd myself, it is like very, you know, sometimes when you like don't get it, you can just like look at it and be like, not for me. Uh no, you've done a great job of really explaining the benefits here and why I might care. It feels ridiculous that I am just about 40 years old and I'm now like, huh, maybe I should give RS us a try. But uh that's that's just how it works sometimes, I suppose.

**CJ**: Glad to hear it. Yeah.

**Scott**: Cool. Well, thank you so much for this again. Uh really eye opening and I loved all these tools. I I can't wait to spend time creating my own client and um abandoning it two months later, but that's how it goes. Uh folks, if if you are out there and you are listening to this episode, join us on YouTube. We're doing all kinds of cool stuff. CJ just released a video on Claude Code that is really super good. We're doing fun CSS battles. We made annoying captas. We're doing videos that you cannot get in the podcast show feed. Uh we also do video episodes of every single one of these podcasts if you care to see any of us annunciating or uh showing our our screen on on camera every once in a while and all that stuff. Check us out youtube.com/sintaxfm and you can find us there. CJ, anything else to say before we get out of here?

**CJ**: That's all I got, but break yourself from the chains of Reddit and make your own RSS. server. So, yeah,

**Scott**: I'm I'm ready.

**CJ**: I'm ready.

**Scott**: All right, cool. We'll catch you guys later. Peace.

**CJ**: Peace.