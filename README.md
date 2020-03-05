# BM

Blog Maker - Build a blog with bash, make, and other GNU shell utilities.

![example blog image](https://i.imgur.com/6chb1CG.png)

BM generates static sites. Thus they will be _blazing fast_
even when hosted on cheap hardware (think raspberry pi) or on slow connections
(think Tor onion services). This is due to their underlying simplicity and tiny
size, therefore browsers are able to aggressively cache the pages. BM still
comes with some great features. See below.

# Important

This project follows [semantic versioning](http://semver.org/) and thus every
major version has the potential for breaking changes. You can find information
about what those are at the following places.

- in `CHANGELOG.md` (the same place you can find _all_ changes)
- on the [github release page][gh-releases]
- under the BM tag on [my blog][blog-bm-tag] (which doubles as an example BM
  website!)

Development on this project has mostly stalled. What little remains can be
found [on GitHub][bm-repo].

# Requirements

BM only requires programs commonly already found on GNU/Linux systems. While
many of the programs may be found on non-GNU/Linux systems (such as OS X), BM
assumes they are the GNU variety.

You also need a web server such as nginx to serve up the generated files.

# Features

Non-exhaustive list.

- Uses Markdown to format post content.
- Creates tag pages to list all posts which contain a given tag.
- Generates post previews of dynamic length for the homepage.
- Automatically regenerates blog after every post edit.
- Optionally automatically sign all output files with a pgp key.
- Optionally pin one or more posts to the top of the homepage.
- Optionally autocreate a table of contents for a post.
- Optionally generate an RSS feed.
- Keeps track of post time, post modification time, and post author.
- Quickly change the style of your website with themes

For more information, see [the wiki][wiki].

# Branches

__master__ is the bleeding edge release and may not be the same as the latest
tagged release. Realistically, it will probably be very close.  If you would
like to work on BM, it would most likely be best to branch off of the latest
master.

Each release has a tag. They used to have branches by the same name, then the
branches got pruned over time, and after v4.0.0 there will be no new
release branches. Releases will only have tags.

# Help and Documentation

See [the wiki][wiki] for more usage information. You may also enjoy the
[configuration][conf], [options][opts], and [advanced configuration][advconf]
pages.

# Issues

Please report issues via the [issue tracker]

[wiki]: https://github.com/pastly/bm/tree/master/doc
[conf]: https://github.com/pastly/bm/blob/master/doc/Configuration.md
[advconf]: https://github.com/pastly/bm/blob/master/doc/AdvancedConfiguration.md
[opts]: https://github.com/pastly/bm/blob/master/doc/Options.md
[issue tracker]: https://github.com/pastly/bm/issues
[gh-releases]: https://github.com/pastly/bm/releases
[blog-bm-tag]: https://matt.traudt.xyz/tags/bm.html
[bm-repo]: https://github.com/pastly/bm
