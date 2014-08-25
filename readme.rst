A notifier for latest submited post on Hacker News. It's a menubar item app for Mac OS X 10.9 written in Swift. Mac OS X 10.10 is not tested yet.

Motivation
================

I'm a big fan of Hacker News site, as I feel like it has the biggest density of
posts with high quality on the internet. Every minute, people all over the
world submit different posts covering different topics there, and a lot of them
never shows up on front page simply because they were not posted at right time
or they focus on a niche(yet interesting) topic.

I used to only check the HN front page as well, and sometimes only find that
most top 10 or 20 posts are not that interesting to me. I want to have a easy
way to checkout the NEW post whenever I have time, and it will only take my
minimal time to see the whole picture, without doing too many mouse/keyboard
operations.

So here you go, a menubar app to read what's the latest submitted posts on
Hacker News, for Mac OS.

Usage
===========

It periodically fetch the latest posts on Hacker News. The icon will be in grey
color if there is no new post since your last reading, and the icon turns to
colorful if there are new ones.

When you see icon turns to be colorful(orange), you can simply click on the
icon to see what are the latest posts.

.. image:: https://cloud.githubusercontent.com/assets/534284/4026469/1a1aaa40-2c1a-11e4-91b1-4045f6a2af8a.png

If you happened to find one looks interesting, you can click on it, and the
`"new" section of HN <https://news.ycombinator.com/newest>`_
will be openned in your browser automatically. You can then either upvote it or
leave comment.

Click your mouse again anywhere will make the post dialog disappear and the
icon goes back to grey status.

Configuration
=================

By default, hn-notifier sync with HN every 1 minute and grab at most 20 latest
post. You can update both value by selecting *option* item in menu.

.. image:: https://cloud.githubusercontent.com/assets/534284/4026475/436f7506-2c1a-11e4-92e8-4f82ac6a5fff.png

Install
===========

There will be binary release for each version. Simply go to
`Release page <https://github.com/cnbuff410/hn-notifier/releases>`_
to grab the zip file and unzip it, then drag the app file into your **Application** folder.

