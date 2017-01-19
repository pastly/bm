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
- on [the release page][gogs-releases] or the [github release
  page][gh-releases]
- under the BM tag on [my blog][blog-bm-tag] (which doubles as an example BM
  website!)

Active development for this project happens at
<https://gogs.system33.pw/mello/bm>. Github is a manually updated mirror.

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
- Keeps track of post time, post modification time, and post author.

# Branches

- __master__ should always be the same as the newest release, with possible
  minor documentation-related fixups due to brainfarts.
- __next__ is the active development branch. It's _probably_ stable enough to
  not delete all your posts, and sometimes it will actually do useful things
  with them. Don't count on it.
- Each release has a tag, and recent ones will have a branch by the same name.
  Branches will get pruned eventually so only the most recent ones remain, but
  tags are eternal.

# Help and Documentation

See [the Wiki][wiki] for more usage information. You may also enjoy the
[configuration][conf], [options][opts], and [advanced configuration][advconf]
pages.

# Issues

Please report issues via the [issue tracker]

[wiki]: https://gogs.system33.pw/mello/bm/wiki
[conf]: https://gogs.system33.pw/mello/bm/wiki/Configuration
[advconf]: https://gogs.system33.pw/mello/bm/wiki/AdvancedConfiguration
[opts]: https://gogs.system33.pw/mello/bm/wiki/Options
[issue tracker]: https://gogs.system33.pw/mello/bm/issues
[gogs-releases]: https://gogs.system33.pw/mello/bm/releases
[gh-releases]: https://github.com/pastly/bm/releases
[blog-bm-tag]: https://matt.traudt.xyz/tags/bm.html
