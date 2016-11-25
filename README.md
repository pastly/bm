# BM

Blog Maker - Build a blog with bash, make, and other GNU shell utilities. 

![example blog image](https://i.imgur.com/6chb1CG.png)

# Requirements

BM only requires programs commonly already found on GNU/Linux systems. While
many of the programs may be found on non-GNU/Linux systems (such as OS X), BM
assumes they are the GNU variety.

You also need a web server such as nginx to serve up the generated files.

# Features

- Uses Markdown to format post content.
- Creates tag pages to list all posts which contain a given tag.
- Generates post previews of dynamic length for the homepage.
- Automatically regenerates blog after every post edit.
- Optionally pin one or more posts to the top of the homepage.
- Optionally autocreate a table of contents for a post.
- Keeps track of post time, post modification time, and post author.

# Help

See [the Wiki] for more usage information. You may also enjoy the
[configuration] and [options] pages.

# Issues

Please report issues via the [issue tracker]

[the Wiki]: https://gogs.system33.pw/mello/bm/wiki
[configuration]: https://gogs.system33.pw/mello/bm/wiki/Configuration
[options]: https://gogs.system33.pw/mello/bm/wiki/Options
[issue tracker]: https://gogs.system33.pw/mello/bm/issues

# Branches

- Master should always be the same as the newest release.
- Each release has a branch, and each should also have a tag by the same name.
  Branches may get pruned eventually, but tags will always remain.
- Next is the active development branch. It's _probably_ stable enough to not
  delete all your posts, and sometimes it will actually do useful things with
  them. Don't count on it.
