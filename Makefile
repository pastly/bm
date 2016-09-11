CMD_BUILD_POST=./internal/build-post.sh
CMD_BUILD_POSTS_INDEX=./internal/build-posts-index.sh
CMD_BUILD_INDEX=./internal/build-index.sh
CMD_BUILD_TAGS=./internal/build-tags.sh

M4=m4
M4_FLAGS=--prefix-builtins

MKDIR=mkdir
MKDIR_FLAGS=-p

RM=rm
RM_FLAGS=-fr

.SUFFIXES:

.PHONY: all clean

POST_DIR=posts
BUILD_DIR=build
INCLUDE_DIR=include
BUILT_POST_DIR=$(BUILD_DIR)/posts
BUILT_TAG_DIR=$(BUILD_DIR)/tags
BUILT_STATIC_DIR=$(BUILD_DIR)/static

# These are the files that always exist
# AKA source files
POST_FILES := $(shell find $(POST_DIR) -name '*.bm')
CSS_FILES := $(shell find $(INCLUDE_DIR) -name '*.css.in')
INCLUDE_FILES := $(shell find $(INCLUDE_DIR) -name '*.html' -or -name '*.m4' -or -name '*.conf*')

# These are the targets. These files don't exist
# until after a successful build
BUILT_POSTS := $(POST_FILES:.bm=.html) # posts/year/month/post-title-123.{bm,html}
BUILT_POSTS := $(notdir $(BUILT_POSTS)) # post-title-123.html
BUILT_POSTS := $(addprefix $(BUILT_POST_DIR)/,$(BUILT_POSTS)) # build/posts/post-title-123.html
BUILT_STATICS := $(CSS_FILES:.css.in=.css)
BUILT_STATICS := $(notdir $(BUILT_STATICS))
BUILT_STATICS := $(addprefix $(BUILT_STATIC_DIR)/,$(BUILT_STATICS))
BUILT_META_FILES := \
	$(BUILD_DIR)/index.html \
	$(BUILT_POST_DIR)/index.html \
	$(BUILT_TAG_DIR)/index.html

all: $(BUILT_POSTS) $(BUILT_STATICS) $(BUILT_META_FILES)

$(BUILT_POSTS): $(POST_FILES) $(INCLUDE_FILES)
	@echo $@
	$(CMD_BUILD_POST) $@ $(POST_FILES)

$(BUILD_DIR)/index.html: $(POST_FILES) $(INCLUDE_FILES)
	@echo $@
	$(CMD_BUILD_INDEX) $@ $(POST_FILES)

$(BUILT_POST_DIR)/index.html: $(POST_FILES) $(INCLUDE_FILES)
	@echo $@
	$(CMD_BUILD_POSTS_INDEX) $@ $(POST_FILES)

$(BUILT_TAG_DIR)/index.html: $(POST_FILES) $(INCLUDE_FILES)
	@echo $@
	$(CMD_BUILD_TAGS) $@ $(POST_FILES)

$(BUILT_STATIC_DIR)/%.css: $(INCLUDE_DIR)/%.css.in $(INCLUDE_FILES)
	@echo $@
	$(MKDIR) $(MKDIR_FLAGS) $(BUILT_STATIC_DIR)
	$(M4) $(M4_FLAGS) $< > $@

clean:
	$(RM) $(RM_FLAGS) -- $(BUILD_DIR)/*
	[ -d $(BUILD_DIR) ] && [ ! -L $(BUILD_DIR) ] && rmdir $(BUILD_DIR) || exit 0
