m4_changequote(`[[',`]]')
m4_define(BLOG_SUBTITLE,[[m4_esyscmd(echo -n "[[${BLOG_SUBTITLE}]]")]])
m4_define(BLOG_TITLE,[[m4_esyscmd(echo -n "[[${BLOG_TITLE}]]")]])
m4_define(MAKE_RSS_FEED,[[m4_esyscmd(echo -n "[[${MAKE_RSS_FEED}]]")]])
m4_define(GPG_SIGN_PAGES,m4_esyscmd(echo -n "${GPG_SIGN_PAGES}"))
m4_define(GPG_FINGERPRINT,m4_esyscmd(echo -n "${GPG_FINGERPRINT}"))
m4_define(LICENSE_TEXT,[[m4_esyscmd(echo -n "[[${LICENSE_TEXT}]]")]])
m4_define(ROOT_URL,m4_esyscmd(echo -n "${ROOT_URL}"))
m4_define(VERSION,m4_esyscmd(echo -n "${VERSION}"))
m4_define(DIR,themes/selected)

m4_define(START_HTML,
m4_include(DIR/start-html.html.in)
)
m4_define(END_HTML,
m4_include(DIR/end-html.html.in)
)

m4_define(PAGE_HEADER,[[
<div id='headerholder'>
<div id='header'>
m4_include(DIR/header.html.in)
</div> <!-- header -->
</div> <!-- headerholder -->
]])
m4_define(PAGE_FOOTER,[[
<div id='footerholder'>
<div id='footer'>
m4_include(DIR/footer.html.in)
</div> <!-- footer -->
</div> <!-- footerholder -->
]])

m4_define(START_CONTENT,
m4_include(DIR/start-content.html.in)
)
m4_define(END_CONTENT,
m4_include(DIR/end-content.html.in)
)

m4_define(POST_HEADER,[[
m4_define([[TITLE]],[[$1]])
m4_define([[AUTHOR]],[[$2]])
m4_define([[DATE]],[[$3]])
m4_define([[MOD_DATE]],[[$4]])
m4_define([[PERMALINK]],[[$5]])
m4_define([[IS_PINNED]],[[$6]])
<div>
m4_include(DIR/post-header.html.in)
</div>
]])
