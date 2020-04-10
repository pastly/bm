# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## Unreleased

### Changed

- Removed quotes around call to the ED in `internal/create` (such that it
  matches the behavior of `internal/edit`). This means that your $EDITOR or bm
$ED variable can be multiple words and they won't get treated as one word. For
example (and the motivating reason for this change): `gvim --nofork` now calls
`gvim` with the `--nofork` option, while before this change `internal/create`
would have tried calling an executable called "`gvim --nofork`".

## [v5.0.0] - 2020-03-04

### Changed

- bundled markdown parser to be `cmark-gfm` instead of `Markdown.pl`. This is a
  major breaking change because they do not render exactly the same way

### Fixed

- recipe for feed.rss doesn't need to delete the old one first, so remove `rm`
  call.
- link in default config file now points to the docs for config options instead
  of incorrectly pointing to the docs for per-post options.

## [v4.2.0] - 2019-06-09

### Added

- optional generation of RSS feed

### Fixed

- replaced links to my Gogs server (no longer available without Tor) with links
  to GitHub

## [v4.1.1] - 2019-01-02

### Changed

- limit make to 8 jobs

### Fixed

- allow static directory to be a symlink
- allow symlinks to themes in theme directory
- make the table of contents temporary file be a dependency for the final post
  html file, resolving a race condition where sometimes the TOC would be
missing.


## [v4.1.0] - 2018-07-09
### Added
- ability to copy files from a `static/` directory into
  `build/static/`. Now you can put your resume at `static/resume.pdf` and link
to it in your posts with `[resume](/static/resume.pdf)`!

## [v4.0.2] - 2017-02-27
### Added
- massive amounts of comments to the Makefile

### Changed
- `make clean` is much simplier now, using `find` instead some convoluted
  process involving checking for symlinks. We just leave behind `build/` and
  `meta/`. No big deal.

## [v4.0.1] - 2017-02-08
### Changed
- don't make /pubkey.gpg a 404 page if not signing pages. Delete it if it
  exists, and just don't generate it otherwise. (#97)
- move program variables and program sanity checks to a new file.

### Fixed
- when changing to not signing pages, signature files were left behind. Delete
  them.
- only require gpg when signing pages. (#102)

## [v4.0.0] - 2017-01-29
__Breaking changes__

__Themes have been added, style customization should be done through them__.
`include/*.{html,m4,css.in}` files were moved into theme directories in
`themes/`.

To change theme, use `./bm theme list` to list them, and use
`./bm theme set <index>` to set one.

To create your own theme, you can edit one of the existing ones in place, but it
would also be a good idea to copy one into a new directory before editing that.
See the [wiki page on theming](https://github.com/pastly/bm/blob/master/doc/Theming.md)
for more information.

__Configuration files have moved__. The example configuration file is in
`internal/` now. A newly created configuration file will be placed in `posts/`,
and BM will automatically create one there if it doesn't exist.

There's a new `./tools/convert_v3.0.3_v4.0.0.sh` script to help make the
transition in almost all cases.

### Added
- config option to include license in footer (#80)
- note in footer if pages are signed (#83)
- pubkey.gpg if pages are signed

### Changed
- stop generating per-post head/foot files. Foot is the same for every page, and
  head is the same expect the `<title>`. Should save build time. (#91)
- move confiruation files
   - bm.conf.example to internal/
   - bm.conf to posts/

### Fixed
- many theoretical makefile dependency issues that so far haven't come up due to
  luck.
- large images need to be limited in width in default theme, changed in terminal
  theme too. (#93)
- fixed unbound variable issue when building heading ids and multiple headings
  are the same

## [v3.0.3] - 2017-01-22
### Fixed
- blog generation when there's no pinned posts or tags

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

[v5.0.0]: https://github.com/pastly/bm/tree/v5.0.0
[v4.2.0]: https://github.com/pastly/bm/tree/v4.2.0
[v4.1.1]: https://github.com/pastly/bm/tree/v4.1.1
[v4.1.0]: https://github.com/pastly/bm/tree/v4.1.0
[v4.0.2]: https://github.com/pastly/bm/tree/v4.0.2
[v4.0.1]: https://github.com/pastly/bm/tree/v4.0.1
[v4.0.0]: https://github.com/pastly/bm/tree/v4.0.0
[v3.0.3]: https://github.com/pastly/bm/tree/v3.0.3
[v3.0.2]: https://github.com/pastly/bm/tree/v3.0.2
[v3.0.1]: https://github.com/pastly/bm/tree/v3.0.1
[v3.0.0]: https://github.com/pastly/bm/tree/v3.0.0
[v2.7.0]: https://github.com/pastly/bm/tree/v2.7.0
[v2.6.0]: https://github.com/pastly/bm/tree/v2.6.0
[v2.5.0]: https://github.com/pastly/bm/tree/v2.5.0
[v2.4.0]: https://github.com/pastly/bm/tree/v2.4.0
[v2.3.0]: https://github.com/pastly/bm/tree/v2.3.0
[v2.2.0]: https://github.com/pastly/bm/tree/v2.2.0
[v2.1.1]: https://github.com/pastly/bm/tree/v2.1.1
[v2.1.0]: https://github.com/pastly/bm/tree/v2.1.0
[v2.0.1]: https://github.com/pastly/bm/tree/v2.0.1
[v2.0.0]: https://github.com/pastly/bm/tree/v2.0.0
[v1.2.1]: https://github.com/pastly/bm/tree/v1.2.1
[v1.2.0]: https://github.com/pastly/bm/tree/v1.2.0
[v1.1.0]: https://github.com/pastly/bm/tree/v1.1.0
[v1.0.0]: https://github.com/pastly/bm/tree/v1.0.0
