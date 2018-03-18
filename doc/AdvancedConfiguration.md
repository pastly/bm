# Webserver Configuration

BM can do a lot, but it can't do everything. With some simple modifications to
your webserver's configuration, you can get even more out of BM.

## Error pages

Starting with v3.0.0, BM will generate a styled 404 page. After a successful
build, you can find it at `/404.html`. BM uses it automatically sometimes\*, but
it can't possibly detect real 404s.

To configure nginx to use the 404 page requires only one line.

    error_page 404 = /404.html

Every Linux distro seems to come with a different default nginx confiruation.
For Gentoo, I had __already__ added a `server {}` block in the `http {}` block
in `/etc/nginx/nginx.conf` in order to make nginx work for me, so within that
`server {}` block I added the above line. Debian and Ubuntu normally have a
`server {}` block in `/etc/nginx/sites-enabled/default` in their basic default
configuration.


In apache, the following line is probably the one you'll want to add somewhere,
likely in a VirtualHost block. I haven't tested this.

     ErrorDocument 404 /404.html

\* BM uses the 404 when `MAKE_SHORT_POSTS` is unset. Instead of `/p/<id>.html`
being the post, it returns 404 the 404 page. This is due to a limitation in the
current build process.

## MIME type tweaks

Starting with v3.0.0, BM can optionally copy the source post files (the files in
the `posts/` subdirectory that end with `.bm`), into the `build/` subdirectory
so that they can get served up by your webserver. BM will only do this if
`CP_SRC_FILES_TO_BUILD` is set.

Unfortunately, webservers by default may not detect these `.bm` files are just
plain text, and thus won't display them in the browser, and the browser will
just offer to download them. If you'd like to have them displayed in the browser
for your users, you need to tell your webserver that files ending in `.bm` are
plain text.

Gentoo makes this easy by default in nginx. I just needed to add the following
line to `/etc/nginx/mime.types` inside the `types {}` block.

    text/plain bm;

If your webserver is apache, this should also be possible. Many Linux distros
have a `/etc/mime.types` file, and apparently apache will read it. You should be
able to add the following line to this file. I haven't tested this.

    text/plain bm
