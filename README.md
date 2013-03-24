threaddl
========

Archive complete threads with images with a truncated 4chanX injected and
more features for more comfortable browsing of the threads.

Dependencies
------------

* Basic GNU tools
* sed
* wget
* Linux, Windows with cygwin (not tested on Mac)

Warning
--------

4chan has some nasty and/or illegal images. All images in a thread will
be downloaded! Images from ads are not downloaded. Author(s) shall not be
liable for any legal action result from use of this software. If you are
unsure if a thread will contain illegal images, use tmpfs. Keep that stuff
off your computer.

Copying
-------

Whatever

Archiving
---------

    ./threaddl.sh [4chan thread URL] <time value and/or return target>

4chan thread URL: something like
https://boards.4chan.org/vg/res/30100764#p30100764

time value:
* 1 -> Download once
* 10 - 999 -> Interval in seconds between fetches

return target: a valid HTML path to a document you want to return

Archive Layout
--------------

    <number of OP post>.html: the thread
    <board name>_<number of OP post>: contains full resolution images
    --misc/: contains thumbnails, css, logo image, gallery, misc stuff
