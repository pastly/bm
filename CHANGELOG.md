# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) 
and this project adheres to [Semantic Versioning](http://semver.org/).

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

[v2.1.1]: https://gogs.system33.pw/mello/bm/src/v2.1.1
[v2.1.0]: https://gogs.system33.pw/mello/bm/src/v2.1.0
[v2.0.1]: https://gogs.system33.pw/mello/bm/src/v2.0.1
[v2.0.0]: https://gogs.system33.pw/mello/bm/src/v2.0.0
[v1.2.1]: https://gogs.system33.pw/mello/bm/src/v1.2.1
[v1.2.0]: https://gogs.system33.pw/mello/bm/src/v1.2.0
[v1.1.0]: https://gogs.system33.pw/mello/bm/src/v1.1.0
[v1.0.0]: https://gogs.system33.pw/mello/bm/src/v1.0.0
[Unreleased]: https://gogs.system33.pw/mello/bm
