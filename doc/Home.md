Welcome to the BM wiki.

BM is a simple set of scripts that help you create, update, and manage a set of
blog posts, notes, and more.

BM depends on GNU features of system utilities such as `grep` and `sed`. If you
are on a non-GNU system, you will probably have a bad time.

You, the human, format your posts using Markdown. BM takes Markdown and converts
it to HTML (with some additional parsing features). The HTML files are organized
in an output directory completely ready for a web server such as nginx or
apache. The simplest way to make a website out of BM's output directory is to
point your web server of choice at the output directory. Your website will then
be automatically updated every time you make a change.

# Configuration

BM ships with an example config located at `include/bm.conf.example`. It is
sourced before anything else. It should not be edited. Instead, copy it to
`include/bm.conf` and edit it there. For an exaplanation for every config
option, see [Configuration](Configuration.md).

For advanced setup and configuration, such as how to best configure your
webserver, see the [advanced configuration page](AdvancedConfiguration.md).
# Options

In additional to global configuration options, BM offers some per-post options
that may be specified in the header of the post file. For more information, see
[Options](Options.md).

# Installation

BM runs entirely within it's own directory. Simply clone the source and situate
yourself in the new directory.

    git clone https://github.com/pastly/bm.git
    cd bm

## `cmark-gfm` issue?

You might want to verify that the bundled copy works on your machine,
especially if "Linux amd64" doesn't sound like a good description of your
computer.

One way to do this would be to try parsing the `README.md` into HTML:

    <README.md ./internal/cmark-gfm | head

You should get HTML and no errors.

If you get errors, maybe it's because the binary won't work on your computer.
There is a script in the `tools` directory to help you download and compile
`cmark-gfm`. Please be familiar with compiling software from source and
discovering/fetching dependencies before attempting this.

    ./tools/get-and-build-cmark.sh

# Usage

All BM commands are run through the `./bm` script interface.

## Post creation

To create your first post, run

    ./bm create [post title]

You may optionally specify no post title, and the new post with have a terrible
default name of "My Newest Post".

If your `EDITOR` environment variable is set, it will be respected. If it
behaves rationally (AKA how I want it to), then it should expect a single file
name as an argument and open that file for editing. You may also specify an
editor in the configuration file. See [Configuration](Configuration.md).

In the new post, the first 7 lines are special and must come before anything
else. The first three are creation date, modification date, and post id.
The fourth line is for any per-post options you would like to set. See
[Options](Options.md).

The fifth line is reserved for future use. If it isn't blank, then this
documentation needs updating.

The sixth line is the post author. It defaults to the username of the current
user, but feel free to change this line at any time. Again, see
[Configuration](Configuration.md) if you would like to make the default
author something else.

The seventh line is the post title. Feel free to change this line at any time.

All remaining lines that do not begin with `///` are considered the body of the
post. `///` indicates comments, which you may add if you like, but they will be
completely ignored by BM.

### Additional features

Any word preceeded by `@@` will be considered a tag. The `@@` will be removed
and a link added to a tag page showing all posts with that given tag.

Post previews on the homepage default to about 300 words. If you would like to
manually specify a place to stop the preview (before _or_ after the 300 word
default), then place `{preview_stop}` once somewhere. It behaves best when on a
line by itself, but doesn't have to be.

BM can optionally generate a table of contents for a post. Include the `{toc}`
macro in a post where you would like it to go. The table of contents is
automatically populated based on the headings you use.

### Saving the post

When you're done creating the post, tell your editor to save the temporary file
it opened. Then close the editor. BM will prompt you if you would like to save
the post.

## Post editing

`./bm edit` is your gateway into editing posts you've made previously.

    ./bm edit <search term>

You may search by post id or by post title. Searching by post id is __case
sensitive__, but searching by post title is __case insensitive__.

If the search term is a single word, BM will first try to find a _single_ post
id. If that fails or more than one word was given, it will then search post
titles. By default, it must also find a single post by title, but this can be
[configured](Configuration.md).

When you're done editing, tell your editor to save the temporary file. Then
close your editor. BM will take care of the rest by default.

If no search term is given, `./bm list` is called. It is also called if BM can't
tell which post you would like to edit.

## Post listing

    ./bm list [search term]

With no search term, this will list all posts you've ever made. Given one or
more words as a search term, BM behaves exactly the same as it does in
`./bm edit`, only it merely lists posts instead of hopefully opening one for
editing.

## Post removal

    ./bm remove <search term>

If you've decided you want to permanently delete a post, this is the command for
you. BM takes the search term and behaves exactly the same as it does in `./bm
edit`, only it will prompt you whether or not you would like to delete the post
it finds.

Running this command is not destructive until it prompts you and you tell it
yes.

## Post building

    ./bm build [all|clean|rebuild]

If you've set your `REBUILD_POLCIY` to manual, then BM will no longer
automatically update the generated files. This command will also help if your
output directory manages to get out of date compared to the source files. No
matter your reason for wanting to use this script, it will make the `make`
calls needed to do what you ask it.

- `./bm build all` and `./bm build` run `make` to update the output
- `./bm build clean` runs `make clean` to delete all output
- `./bm build rebuild` runs `make clean` followed by `make`

## Theme selection

    ./bm theme list
    ./bm theme set <index>
    ./bm theme info <index>

Version 4.0.0 of BM added the concept of themes. Themes allow you to quickly and
easily change the look and feel of the built site. A theme is self-contained in
its own directory under `themes/`, and a symbolic link is automatically made to
the currently selected theme. A theme directory can be copy/pasted and edited if
it isn't quite right for you.

BM comes with a default theme that will be marked as selected if nothing else
is. It also comes with a terminal theme that is sterotypical green text on a
black background and a "nothing" theme that contains the bare minimum
requirements.

For more information about theming, see [theming](Theming.md).
