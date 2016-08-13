M4=m4
M4FLAGS=--prefix-builtins

MARKDOWN=Markdown.pl
MARKDOWNFLAGS=

.SUFFIXES:
.SUFFIXES: .html .bbg

.PHONY: all clean index

POST_DIR=posts
BUILD_DIR=build
BUILT_POST_DIR=$(BUILD_DIR)/posts
BUILT_TAG_DIR=$(BUILD_DIR)/tags

POST_FILES := $(shell find $(POST_DIR) -name '*.bbg')
BUILT_POSTS := $(POST_FILES:.bbg=.html)
BUILT_POSTS := $(notdir $(BUILT_POSTS))
BUILT_POSTS := $(addprefix $(BUILT_POST_DIR)/,$(BUILT_POSTS))

#$(BUILTPOSTDIR)/*.html: $(BUILTPOSTDIR)/%.html: $(POSTDIR)/*/*/%.bbg
#
#$(POSTDIR)/*/*/%.bbg:
#	./build-posts.sh $(BUILTPOSTDIR) $@

all: $(BUILT_POSTS) $(BUILD_DIR)/index.html

$(BUILT_POSTS): $(POST_FILES)
	./build-post.sh $@ $(POST_FILES)

$(BUILD_DIR)/index.html: $(POST_FILES)
	./build-index.sh $@ $(POST_FILES)

clean:
	rm -r $(BUILD_DIR)

#build/%.html: $(POST_FILES)

#build/%.html: %.html.in
#	${M4} ${M4FLAGS} $< > build/$*.html
#
#build/%.html: %.md.in
#	${MARKDOWN} ${MARKDOWNFLAGS} $< | ${M4} ${M4FLAGS} > build/$*.html
