In addition to all the standard Markdown formatting syntax, BM supports some
additional formatting macros. They should be placed in the body of the post,
usually only up to one time each.

# `{preview-stop}`

When parsing a post for inclusion on the homepage, including everything in the
post up until this macro. This overrides both the global `PREVIEW_MAX_WORDS`
configuration and the per-post `preview_max_words` option.

# `{toc}`

This macro places a table of contents in the body of the post. The table of
contents is automatically generated based on the headings used. This macro
implies the `heading_ids` option, so it should either be left unset (the
default) or set to true.
