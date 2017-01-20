# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## [v3.0.2] - 2017-01-20

### Fixed

- actually fix `build/*/*.bm` files not being world readable (#88)

## [v3.0.1] - 2017-01-18

### Added

- config option to cryptographically sign all output files (#84)

### Changed

- remove `--output-sync` option to `make` as it is unecessary with how it is
  currently configured. Having it makes it confusing what step is taking a
  while.
- only create temporary tag file once in `build_tagindex`

### Fixed

- 404 page sometimes getting scheduled for building before output dirs
- `build/*/*.bm` files not being world readable (#88)

## [v3.0.0] - 2017-01-16

__Breaking changes__

__Long post URLs are now limited__. Before, a post titled "My New Post On
My New Blog" would have the post URL of
`/posts/my-new-post-on-my-new-blog-12345678.html`, but starting with this
version, it will be truncated to the first three words:
`/posts/my-new-post-12345678.html`. __All existing links to posts with titles
longer than three words will break__. From this version on, use the new
shortlinks for permanent links.

__The user can no longer call `make` themselves__. `make` now expects to have a
bunch of variables and functions defined in the environment. The new (as of
v2.7.0) `./bm build` script is what should be used.

### Added
- config option to make permalinks/shortlinks (#66)
- config option to prefer permalinks/shortlinks
- config option to copy post source files to the build directory for serving up
  by the webserver (#67)
- `version` command as `--version` prints too much for scripts (#70)
- add branch descriptions to readme
- a sad face
- 404 page, must be configured to be used by your web server

### Changed
- move many Makefile variables definitions to globals.sh
- moved generic option functions to options.sh
- move a ton of logic into the Makefile (#65)
- limit long post URLs to the first three words and the ID instead of all words
  (#73)

### Fixed
- force full rebuild if post title changes (#68)
- #section-links now stay on the same post page instead of going to the long
  post URL (#69)
- #section-links on the homepage go to the prefered post type (short/long) (#69)
- Heading ids with special chars somehow fixed with new table of contents
  generating functions (#61)

### Removed
- `-v` and `--version` options from `bm` script

## [v2.7.0] - 2016-10-22
### Added
- `./bm build` script as a wrapper to `make` (#60)
- `{toc}` macro (#40)
- `heading_ids` option

### Changed
- Modify README with better links, especially towards the wiki
- all internal scripts use `./bm build` instead of `$MAKE` calls

## [v2.6.0] - 2016-10-16
### Added
- pinning posts to homepage via new `pinned` option

### Changed
- `POST_HEADER_MOD_DATE_HTML` m4 macro no longer recursively calls
  `POST_HEADER_HTML`

## [v2.5.0] - 2016-10-16
### Added
- generic option parsing code
- per-post options on 4th line of post file
- `preview_max_words` option

### Fixed
- `make` hanging if no more posts

## [v2.4.0] - 2016-10-15
### Added
- `cat` to end of the list of hash programs
- `make` target for nonexistant `bm.conf`
- short commit hash to version output if git is available
- a bunch of "help me!" options to the `bm` script

### Changed
- moved id alphabet to a variable in `globals.sh`

### Removed
- comments in `bm.conf.example`

## [v2.3.0] - 2016-10-15
### Added
- option to make automatic rebuilds optional (#52)

### Changed
- standardize `make` calls with $MAKE vars

### Removed
- redundant check for `Markdown.pl`

## [v2.2.0] - 2016-10-08
### Added
- option for shortening/removing help comments in new posts (#22)

### Fixed
- harmless errors when `bm.conf` or `posts/` doesn't eixst (#57)

## [v2.1.1] - 2016-09-17
### Fixed
- bash number comparisons

## [v2.1.0] - 2016-09-17
### Added
- `SIGNIFICANT_MOD_AFTER` option: only display mod time after this number of
  seconds

## [v2.0.1] - 2016-09-17
### Added
- more comments in makefile

### Changed
- only call `build-post.sh` for changed post. Introduces backwards incompatable
  change. See #45. Closes #45.
- minor markdown changes in old changelog entries

### Fixed
- make CSS files dependencies for everything

### Removed
- uneeded `.SUFFIXES` in makefile

## [v2.0.0] - 2016-09-11
### Added
- post indexing by month/year on post/tag index.html pages (#49)
- global post search function that searches titles/ids instead of filenames
- post format conversion script in `tools/`

### Changed
- `make clean` only removes build/ if not a symlink.
- minor quoting fix in `bm.conf.example`
- IDs from 16 to 8 chars (backwards compatable because IDs unused so far)
- end of filename from $RANDOM to post id
- pretty print post list format is now `date (id=foobarr): Post Title`
- `edit`, `list`, and `remove` now use the new global search function
- make `make` less noisy when run from inside our scripts
- `edit` with no args calls `list`

### Fixed
- `make clean` harmless error message if build/ did not exist
- filename changes when title/id changes (#3)

### Removed
- "Tags" h1 at the top of `tags/index.html`

## [v1.2.1] - 2016-09-02
### Changed
- remove some unecessary line-based looping

### Fixed
- leading spaces stripped from markdown code (#44)

## [v1.2.0] - 2016-09-02
### Added
- `HASH_PROGRAM` option which should be left blank

### Fixed
- rebuilding when edit made no changes

### Changed
- allow '-' in tag names

## [v1.1.0] - 2016-08-31
### Added
- `MULTI_MATCH_STRAT` for determining what to do in case of ambiguous search
  term in edit and remove (#46)
- root url config option so blog doesn't have to reside at root of website

### Changed
- remove '/' from .gitignore build and post lines
- refactored out post listing to global function `pretty_print_post_info`
- minor grammar changes in edit/list/remove output
- output actual search terms instead of what they were converted to in edit
  and remove


## [v1.0.0] - 2016-08-28
### Added
- post generation
- tag pages generation
- homepage generation
- markdown formatting
- author, date, mod date metadata
- post id (unused)

[v3.0.2]: https://gogs.system33.pw/mello/bm/src/v3.0.2
[v3.0.1]: https://gogs.system33.pw/mello/bm/src/v3.0.1
[v3.0.0]: https://gogs.system33.pw/mello/bm/src/v3.0.0
[v2.7.0]: https://gogs.system33.pw/mello/bm/src/v2.7.0
[v2.6.0]: https://gogs.system33.pw/mello/bm/src/v2.6.0
[v2.5.0]: https://gogs.system33.pw/mello/bm/src/v2.5.0
[v2.4.0]: https://gogs.system33.pw/mello/bm/src/v2.4.0
[v2.3.0]: https://gogs.system33.pw/mello/bm/src/v2.3.0
[v2.2.0]: https://gogs.system33.pw/mello/bm/src/v2.2.0
[v2.1.1]: https://gogs.system33.pw/mello/bm/src/v2.1.1
[v2.1.0]: https://gogs.system33.pw/mello/bm/src/v2.1.0
[v2.0.1]: https://gogs.system33.pw/mello/bm/src/v2.0.1
[v2.0.0]: https://gogs.system33.pw/mello/bm/src/v2.0.0
[v1.2.1]: https://gogs.system33.pw/mello/bm/src/v1.2.1
[v1.2.0]: https://gogs.system33.pw/mello/bm/src/v1.2.0
[v1.1.0]: https://gogs.system33.pw/mello/bm/src/v1.1.0
[v1.0.0]: https://gogs.system33.pw/mello/bm/src/v1.0.0
[Unreleased]: https://gogs.system33.pw/mello/bm/src/next
