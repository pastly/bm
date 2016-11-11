CMD_BUILD_POST=./internal/build-post.sh
CMD_BUILD_POSTS_INDEX=./internal/build-posts-index.sh
CMD_BUILD_INDEX=./internal/build-index.sh
CMD_BUILD_TAGS=./internal/build-tags.sh

.PHONY: all clean

# These are the files that always exist
# AKA source files
POST_FILES := $(shell find $(POST_DIR) -name '*.bm')
CSS_FILES := $(shell find $(INCLUDE_DIR) -name '*.css.in')
USER_CONF_FILE := $(INCLUDE_DIR)/bm.conf
INCLUDE_FILES := $(shell find $(INCLUDE_DIR) -name '*.html' -or -name '*.m4' -or -name '*.conf.example') \
	$(USER_CONF_FILE)


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

# Target for posts
# ** If directory structure of POST_DIR every changes, this will need updating
# ** as it is not generalized anymore
$(BUILT_POST_DIR)/%.html: $(POST_DIR)/*/*/%.bm $(INCLUDE_FILES) $(CSS_FILES)
	@echo $@
	$(CMD_BUILD_POST) $@ $<

# Target for homepage
$(BUILD_DIR)/index.html: $(POST_FILES) $(INCLUDE_FILES) $(CSS_FILES)
	@echo $@
	$(CMD_BUILD_INDEX) $@ $(POST_FILES)

# Target for posts index
$(BUILT_POST_DIR)/index.html: $(POST_FILES) $(INCLUDE_FILES) $(CSS_FILES)
	@echo $@
	$(CMD_BUILD_POSTS_INDEX) $@ $(POST_FILES)

# Target for tags index
$(BUILT_TAG_DIR)/index.html: $(POST_FILES) $(INCLUDE_FILES) $(CSS_FILES)
	@echo $@
	$(CMD_BUILD_TAGS) $@ $(POST_FILES)

# Target for all CSS
$(BUILT_STATIC_DIR)/%.css: $(INCLUDE_DIR)/%.css.in $(INCLUDE_FILES)
	@echo $@
	$(MKDIR) $(MKDIR_FLAGS) $(BUILT_STATIC_DIR)
	$(M4) $(M4_FLAGS) $< > $@

# Target to automake the config file if necessary
$(USER_CONF_FILE): $(INCLUDE_DIR)/bm.conf.example
	[ ! -f $@ ] && grep -vE '^#' $< > $@ || touch $@

clean:
	$(RM) $(RM_FLAGS) -- $(BUILD_DIR)/*
	[ -d $(BUILD_DIR) ] && [ ! -L $(BUILD_DIR) ] && rmdir $(BUILD_DIR) || exit 0
