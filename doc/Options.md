# How to

Starting in BM version 2.5.0, per-post options may be specified on line four of
the post header. The post header is the first 7 lines of a post and looks
something like this on a new post.

    1476647494
    1476647494
    3xo84suM
    
    
    matt
    My Newest Post

The previously unused 4th line now can contain arbitrary combinations of the
options listed in this document. Multiple options must be space separated.

## Setting values

Given the option `foo`, which is an option that should be understood as an
integer, use the following to set `foo` to 123.

    foo=123

## Setting flags

Given the option `foo`, which is an option that should be understood as either
true or false, all of the following set `foo` to true.

    foo
    foo=1
    no_foo=0

All of the following set `foo` to false.

    foo=0
    no_foo
    no_foo=1

## Example

Given `foo` (a flag) and `bar` (an integer value), the following post header
sets `foo` to true and `bar` to 123

    1476647494
    1476647494
    3xo84suM
    foo bar=123
    
    matt
    My Newest Post

# All Options

## `preview_max_words`

Integer value

Override the global configuration option `PREVIEW_MAX_WORDS` with this value for
this post.

## `pinned`

Integer value

If greater than 0, pin this post. Multiple posts can be pinned if they have
different values. Pinned posts are sorted in ascending value order, meaning the
post with the smallest value will be first at the top of the page.

If two posts have the same value, only one will be pinned. The
determination of which one is picked should be considered unreliable.

## `heading_ids`

Boolean value

If set to true, all `<h1>`, `<h2>`, etc. HTML tags will have auto-generated IDs
added to them. This is useful if you would like to be able to link to individual
sections of a post.

This option must be true or unset (AKA: anything other than explicitly set to
false) if the table of contents macro `{toc}` is used in the post.
