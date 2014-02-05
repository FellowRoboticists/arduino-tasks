arduino-tasks
=============

This project provides Ruby Rake tasks to simplify the process of setting
up an ino project that has library dependencies.

Usage
=====

Most of the FellowRoboticist projects assume a directory structure like:

   + [some-directory]
           |
	   +- arduino-tasks
	   |
	   +- [cloned-library-1-dir]
	   |
	   +- [cloned-library-2-dir]
	   |
	   +- [ino-project-dir]
	           |
		   +- lib
		       |
		       +- [copy-of-cloned-library-1-dir]
		       |
		       +- [copy-of-cloned-library-2-dir]
	   
If you change your currenct directory to your 'ino-project-dir' and execute the 'rake'
command, it will attempt to clone the libraries and place a copy of the cloned libraries
into your ino project's lib directory.

I could have wrote this to place the cloned project directories directly into the ino
project's lib directory, but then every project that used that library would have to
perform a clone. My goal was to perform clone as few times as possible. Since I almost
always have multiple ino projects going at the same time, it is more efficient to do it
this way.

Besides, if I need to make a change to one of the libraries, it's a bit easier to make
the change in one place, then let the other projects pull in the changes. That would be
as simple as removing the library directory from the ino project's lib directory and 
re-running the 'rake' command.

It would be nice if the rake command could detect changes to the libraries, then it could
automatically update the ino project. This thing isn't that smart (yet).

Copyright
=========
Copyright (c) 2014 Dave Sieh

See LICENSE.txt for details.

