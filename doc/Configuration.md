# How to

Copy `internal/bm.conf.example` to `posts/bm.conf` and edit the latter. This may
likely have happened automatically for you if you've already run BM once.

# Variables

## Basic global strings

All these variables are rather global, general, and simple to understand.

### `BLOG_SUBTITLE`

Subtitle of the website. Shows up at the top of every page under the title.
It should probably be longer than the title. Consider a witty quote or
something philosophical.

- default: "Where super awesome things happen"
- recommendation: change it

### `BLOG_TITLE`

Title of the website. Shows up at the top of every page and the HTML `<title>`
tag. This should be "short," for whatever is short to you.

- default: "My Super Awesome Blog"
- recommendation: change it

### `DEFAULT_AUTHOR`

Default author for new posts. This gets put in the metadata section of new posts
and can be changed there too.

- default: "$(whoami)" (username of current user)
- recommendation: change it unless your username is sufficient

### `LICENSE_TEXT`

If you would like to release the contents of your site under some license, you
can use this variable to state as such. For example, you might set it to

    The content of this blog is licensed under the Creative Commons Attribution
    4.0 International License

You can put HTML in this variable and it will be rendered. For example, you
could link to the full license text.

- default: ""
- recommendation: personal preference

### `ROOT_URL`

First part of the URL that every blog page should have. For example, if your
blog homepage should be at "http://example.com/", then set this to "". If it
should be at "http://example.com/blog/", then set this to "/blog".

__NEVER__ include a trailing slash.

- default: ""
- recommendation: change as needed

## Format strings

All these variables store printf-like format strings. Not necessarily actually
printf (like '%d' for an int), but just printf-like.

`man 1 date` for the date format sequences.

### `DATE_FRMT`

The go-to default date format. It is used for post dates currently. It's
probably best that it has the month, day, and year.

- default: "%d %b %Y"
- recommendation: personal preference

### `LONG_DATE_FRMT`

The date format used for post modification dates. It might makes sense to
include the hours, minutes, and seconds in it as well.

- default: "%d %b %Y at %l:%M %P"
- recommendation: personal preference

### `MONTHLY_INDEX_DATE_FRMT`

Date format to use when dividing posts/tags up by month. Should not have
anything more specific than a month.

- default: "%b %Y"
- recommendation: leave alone

### `YEARLY_INDEX_DATE_FRMT`

Date format to use when dividing posts/tags up by year. Should not have anything
more specific than a year.

- default: "%Y"
- recommendation: leave alone

## Indexing

### `DEFAULT_INDEX_BY`

Default timespan for grouping posts on aggregate pages such as
`posts/index.html` and `tags/index.html`.

`POST_INDEX_BY` and `TAG_INDEX_BY` default to this if unset.

Valid values are "month", "year", "none"

- default: "none"
- recommendation: "month" or personal preference

### `TAG_INDEX_BY`

Default timespan for grouping posts on the `tags/index.html` page.

Valid values are "month", "year", "none"

- default: `$DEFAULT_INDEX_BY`
- recommendation: "none" or personal preference

### `POST_INDEX_BY`

Default timespan for grouping posts on the `posts/index.html` page.

Valid values are "month", "year", "none"

- default: `$DEFAULT_INDEX_BY`
- recommendation: personal preference

## External Programs

When BM can't do it all, what should BM call on for help?

### `ED`

Desired editor for creating and modifying posts. The text editor should be able
to take one option: the name of a file to edit.

- default: $EDITOR environment variable
- recommendation: personal preference

### `HASH_PROGRAM`

This variable stores the name of a program that can take input on stdin and
produce something unique to that input on stdout.

BM has a list of many commonly-installed hashing programs. If yours isn't on the
list, please open a ticket. Even if it isn't, the last autodected program is
`cat`, which is a huge dependency for BM. There's no conceivable sane case where
this option needs overwriting.

- default: first found of `sha1sum`, `sha1`, `sha256sum`, `sha256`, `md5sum`,
  `md5`, `cat`
- recommendation: never change

## Homepage

Options that change the look of the homepage.

### `POSTS_ON_HOMEPAGE`

The number of non-pinned posts to include on the main `index.html` homepage.
Posts are chosen by creation date, with the most recent `POSTS_ON_HOMEPAGE`
being picked.

With 10 total posts, 2 pinned posts, and `POSTS_ON_HOMEPAGE` set to 5, 7 posts
with be on the homepage: The 2 pinned posts at the top regardless of age
followed by the next 5 newest.

- default: 5
- recommendation: personal preference

### `PREVIEW_MAX_WORDS`

_Approximate_ maximum number of words from a post to be included in the post
preview on the homepage. If a post consists of fewer than this number of words,
then its entire body will be the preview. If a post has more than this number of
words, then it will be cut off and a link appended to the individual post page
for viewing the entire post.

This value is only approximate as lines from the source Markdown file are read
until one pushes the word count over the limit.

- default: 300
- recommendation: personal preference

## Additional output files

### `CP_SRC_FILES_TO_BUILD`

If set, copy the `.bm` source post files into the build directory adjacent to
the corresponding built `.html` files. This is useful if you want to share the
source files with your readers.

Valid values are "yes", "no".

- default: "no"
- recommendation: personal preference

### `GPG_FINGERPRINT`

If `GPG_SIGN_PAGES` is set, this is required to be set to a string that gpg
understands to be a user id. See the _HOW TO SPECIFY A USER ID_ section in the
gpg manpage.

Basically: set it to the fingerprint of your key. Other things may be possible,
but this is easiest.

- default: ""
- recommendation: the fingerprint of your key if you want to sign pages

### `GPG_SIGN_PAGES`

If this is set, then `GPG_FINGERPRINT` is required. When set, BM will generate
a signature for every output file in the build/ directory. All HTML pages, all
static files (like CSS), all `.bm` source files (if enabled), __everything__.

Given the public key of the key pair used to sign these output files, anyone can
verify the integrity and authorship of the output files.

Valid values are "yes", "no".

- default: "no"
- recommendation: personal preference
## RSS

Options related to the generation and format of `/feed.rss`, if enabled.

### `MAKE_RSS_FEED`

Whether or not to generate an RSS feed located at `/feed.rss`. The RSS feed
will contain all posts, sorted by posting date, with the newest first.

Note for people super hardcore concerned about their privacy/anonymity: if you
haven't already made your computer use UTC when displaying the time to you,
this will leak your configured timezone in the RSS feed. If you are in a
high-risk situation, you probably should have already changed your system
timezone to UTC; nonetheless, let this be a warning that `bm` will leak to the
world the timzone given to you when you run the `date` command in a Linux/macOS
terminal, which in many situations is your real one.

Valid values are "yes", "no".

- default: "no"
- recommendation: personal preference

### `RSS_HOST`

The host at which your blog is located **including a trailing slash**. Include
the http/https part, the domain part, and the trailing slash. That's it. If
your blog isn't located at the root of your webserver, use `ROOT_URL` to
configure that.

- default: `https://example.com/`
- recommendation: change it

### `RSS_TITLE`

The title of your overall RSS feed.

- default: the value of `BLOG_TITLE`
- recommendation: personal preference

### `RSS_DESCRIPTION`

The description of your overall RSS feed.

- default: the value of `BLOG_SUBTITLE`
- recommendation: personal preference

## Other

Stuff that didn't seem to fit anywhere else or I haven't gotten to categorizing
yet.

### `CREATE_HELP_VERBOSITY`

How many helpful comments should be included in a new post. Comments are for the
author only and do not show up in the final HTML post.

Valid values are "long", "short", "none".

- default: "long"
- recommendation: chose more terse values as you get more familiar with BM

### `MAKE_SHORT_POSTS`

Whether or not to make short post URLs in addition to the normal long ones. A
short URL should be considered a permalink, and looks like `/p/12345678.html`
for while the corresponding long post URL looks like
`/posts/my-post-12345678.html`.

This will add a "permalink" link under every post title to `/p/12345678.html`.

Valid values are "yes", "no".

- default: "yes"
- recommendation: don't change, they're really useful

### `MULTI_MATCH_STRAT`

The strategy to use when a given search term given to `edit`, or
`remove` matches more than one post.

Valid values are "simple", "newest", "oldest"

"simple" will refuse to do anything unless the search term is specific enough to
return one post.

"newest" will return the newest post (by post date) of those that match the
search term.

"oldest" is the same as "newest", but returns the oldest.

- default: "simple"
- recommendation: "simple" for most. You'll know if you want to change this

### `PREFER_SHORT_POSTS`

`MAKE_SHORT_POSTS` must be enabled if this is enabled.

If enabled, every link to a post will be a short "perma" link.

If disabled, but `MAKE_SHORT_POSTS` is enabled, every link to a post will be a
normal full link except for the little "permalink" links under post titles.

If diabled, and `MAKE_SHORT_POSTS` is also disabled, every link to a post will
be a normal full link.

Valid values are "yes", "no".

- default: "no"
- recommendation: personal preference. easy-to-read URLs vs robustness is the
  tradeoff.

### `REBUILD_POLICY`

This options determines when BM should remake the build automatically, if at
all.

Valid values are "asap", "manual"

"manual" is useful for experienced users with large blogs that take a long time
to rebuild.

- default: "asap"
- recommendation: personal preference

### `SIGNIFICANT_MOD_AFTER`

Period of time (in seconds) after which a modification to a post is considered
significant. When a change is made after this period of time, the modification
time will be displayed in the final post output along with the original creation
date.

This value can have basic arithmatic in it.

- default: "1" (1 second, (almost) any modification is considered significant)
- recommendation: "60\*60" (1 hour), "60\*60\*24" (1 day)

