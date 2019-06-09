Starting in BM v4.0.0, the look of the built site can be easily changed using
themes. A theme is a subdirectory in `themes/`, and can be selected using the
`./bm theme set <index>` command. `./bm theme list` will list available themes
with the currently selected one marked.

Customizing a theme can be done by copy/pasting and then editing the new copy. A
theme can do just about anything to change the look of the website, but some
requirements must be met in order to make it actually work.

# Requirements

## Metadata

Each theme must have a metadata file in a particular format with at least these
three values.

- description: a short description of the theme (truncates to 50 characters)
- author: your name or handle
- works_with: the last version of BM that you tested your theme against

The format looks like

    <key><TAB><value><NEWLINE>

Which is the way the `options.sh` functions work. An example theme metadata
file:

    description<TAB>My Newest Theme<NEWLINE>
    author<TAB>John Doe<NEWLINE>
    works_with<TAB>v4.0.0<NEWLINE>

You may use `options.sh` to help you write your metadata file. Say
you've just created an empty theme directory at `themes/mytheme`, then do:

    $ source internal/options.sh
    $ touch themes/mytheme/metadata
    $ op_set themes/mytheme/metadata description "My Newest Theme"
    $ op_set themes/mytheme/metadata author "John Doe"
    $ op_set themes/mytheme/metadata works_with "v4.0.0"

And the metadata file will have been created correctly. Values can be changed
with the same `op_set` command.

## m4 files

All m4 built-in functions must be prefixed by `m4_`.

Each theme needs at least an `html.m4` file and a `css.m4` file. Any others will
be ignored by BM with respect to rebuilding the site, but your theme could still
use them somehow.

`css.m4` is very basic in the officially supported themes: only used for color
variables. It doesn't really have any strict requirements.

`html.m4` on the other hand has some important macros that the rest of BM expect
to exist and to take certain arguments. You may define additional macros as you
wish, but the following ones shouldn't significantly change or else the theme
may malfunction.

In addition, the definitions at the top of the default `html.m4` should be left
alone in your theme, as you most likely need them and they'll need to be used.

**`START_HTML`** should generate the absolute first HTML in each page: the
DOCTYPE tag, the entire `<head>`, etc. It expects one argument: the contents
`<title>` tag.

**`END_HTML`** should generate the absoulte last HTML. It can't take any
arguments.

**`PAGE_HEADER`** should gneerate the visible page header. It would make sense
to put the `BLOG_TITLE` and the `BLOG_SUBTITLE` in here. It cant't take any
arguments. You may like to put links to other page indexes here.

**`PAGE_FOOTER`** should generate the visible page footer. It would make sense
to put `LICENSE_TEXT` in here (if set) and GPG signature information (if
enabled). Please respect the attribution part of the GPL and include a link to
BM's source at <https://github.com/pastly/bm> and state it's current
version. An easy way to do this is with the following line.

    <span style='font-size:smaller'>Made with <a href='https://github.com/pastly/bm'>bm</a> VERSION</span><br />

It can't take any arguments.

**`START_CONTENT`** should generate HTML that precedes a section of content on
the page. On most pages it is called once, but it is called multiple times on
the index page: once for each post preview. It can't take any arguments.

**`END_CONTENT`** should generate HTML that comes after a section of content on
the page. On most pages it is called once, but it is called multiple times on
the index page: once for each post preview. It can't take any arguments.

**`POST_HEADER`** should generate the HTML that precedes the body of a post. It
would make sense to put post metadata in it such as the `TITLE`, `AUTHOR`,
`DATE`, etc. It takes the following arguments in this order

1. `TITLE`
2. `AUTHOR`
3. `DATE`
4. `MOD_DATE`
5. `PERMALINK`
6. `IS_PINNED`

The first three will always be set. `MOD_DATE` will be a non-empty string if the
post has been modified (while respecting the `SIGNIFICANT_MOD_AFTER`).
`PERMALINK` will be a non-empty string if a permalink has been generated and
should be included. `IS_PINNED` is a non-empty string if the post is pinned and
that fact should be included.

# Explanations

So now that all the required macros have been described, here's a "visual" of
the basic order their contents show up.

    START_HTML
    PAGE_HEADER
    START_CONTENT
    [ ... content ... ]
    END_CONTENT
    PAGE_FOOTER
    END_HTML

On the homepage, `START_CONTENT` and `END_CONTENT` will be repeated for each
post preview.

If the content is a post preview or post page, then `POST_HEADER` will show up
in the content section too.

    START_HTML
    PAGE_HEADER
    START_CONTENT           < repeated 0 or more times for each post if
    POST_HEADER             < this is the homepage
    [ ... post body ... ]   <
    END_CONTENT             <
    PAGE_FOOTER
    END_HTML

# Conventions

While everything could be done in just the `html.m4` file, the convention is to
move most or all of the HTML to `.html.in` files in the theme directory. This
keeps the m4 file cleaner.

The officially supported themes change m4's quotes to `[[` and `]]`.
