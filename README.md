threaddl
========

Archive complete threads with images with a truncated 4chanX injected and
more features for more comfortable browsing of the threads.

Notes
-----

* Works on Android with the proper GNU tools (use Google to find these).
    ** Please edit ** the interpreter in the first line before using it on Android!
* The script saves the thread to the current location of the console
* HTTPS protocol is ignored, HTTP is used for everything
* The thread's HTML is cleaned up of everything not necessary, which
    results in a very small filesize
* The gallery works only if the it's accessed online, because of
    XMLHttpRequest
* Deleted posts aren't prereserved, but if you started archiving the
    thread before the deletion of the post/image, the image will most
    likely be saved (if you find a way to preserve posts as well,
    post an issue or pull request to contact me)

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
https://boards.4chan.org/vg/thread/30100764#p30100764
or
http://boards.4chan.org/c/thread/2012645


time value:
* 1 -> Download once
* 10 - 999 -> Interval in seconds between fetches

return target: a valid HTML path to a document you want to return to
by clicking [Return]

Archive Layout
--------------

    <number of OP post>.html: the thread
    <board name>_<number of OP post>/: contains full resolution images
    --misc/: contains thumbnails, css, logo image, gallery, misc stuff
