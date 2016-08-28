# BM

Blog Maker - Build a blog with bash, make, and other GNU shell utilities. 

# Requirements

BM only requires programs commonly already found on GNU/Linux systems. While
many of the programs may be found on non-GNU/Linux systems (such as OS X), BM
assumes they are the GNU variety.

You also need a web server such as nginx to serve up the generated files.

# Usage

Clone the repository and `cd` into the repo directory.

run `./bm create Your Title Here` to begin written your first post. If you have
your `EDITOR` environment variable set, it will be respected.

Read the comments in the new text file for help. Most notably, you should
format your post using Markdown.

When you are done writing your post, exit your editor cleanly and BM will ask
if you would like to save this post. 

To edit a post, run `./bm edit Title`. "Title" must be enough to uniquely
identify the post's file name.

If you would like to list all your posts and their file names, run `./bm list`.

You may delete a post with `./bm remove Title`, where "title" uniquely
identifies a single post's file name.

# Features

* Keeps track of post time, post modification time, and post author.
* Uses Markdown to format post content.
* Creates tag pages to list all posts which contain a given tag.
* Generates post previews of dynamic length for the homepage.
* Automatically regenerates blog after every post edit.
