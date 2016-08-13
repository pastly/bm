M4=m4
M4FLAGS=--prefix-builtins

MARKDOWN=Markdown.pl
MARKDOWNFLAGS=

.SUFFIXES: .html.in .html \
	.md.in .md

FINAL_HTML_FILES := \
	build/index.html

FINAL_MD_FILES := \
	build/mdtest.html

FINAL_FILES := \
	${FINAL_HTML_FILES} \
	${FINAL_MD_FILES}

all: ${FINAL_FILES} tags

clean:
	rm -r ${FINAL_FILES}

tags: mdtest.md.in
	echo "YES"

build/%.html: %.html.in
	${M4} ${M4FLAGS} $< > build/$*.html

build/%.html: %.md.in
	${MARKDOWN} ${MARKDOWNFLAGS} $< | ${M4} ${M4FLAGS} > build/$*.html
