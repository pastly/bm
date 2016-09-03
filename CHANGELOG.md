# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) 
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
### Added
- `HASH_PROGRAM` option which should be left blank

### Fixed
- rebuilding when edit made no changes

## [v1.1.0] - 2016-08-31
### Added
- MULTI_MATCH_STRAT for determining what to do in case of ambiguous search
  term in edit and remove (#46)
- root url config option so blog doesn't have to reside at root of website

### Changed
- remove '/' from .gitignore build and post lines
- refactored out post listing to global function pretty_print_post_info
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

[v1.1.0]: https://gogs.system33.pw/mello/bm/src/v1.1.0
[v1.0.0]: https://gogs.system33.pw/mello/bm/src/v1.0.0
