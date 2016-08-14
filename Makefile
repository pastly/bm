CMD_BUILD_POST=./internal/build-post.sh
CMD_BUILD_INDEX=./internal/build-index.sh

RM=rm
RM_FLAGS=-r

.SUFFIXES:
.SUFFIXES: .html .bbg

.PHONY: all clean

POST_DIR=posts
BUILD_DIR=build
INCLUDE_DIR=include
BUILT_POST_DIR=$(BUILD_DIR)/posts
BUILT_TAG_DIR=$(BUILD_DIR)/tags

# These are the files that always exist
# AKA source files
POST_FILES := $(shell find $(POST_DIR) -name '*.bbg')
INCLUDE_FILES := $(shell find $(INCLUDE_DIR) -name '*.html' -or -name '*.m4')

# These are the targets. These files don't exist
# until after a successful build
BUILT_POSTS := $(POST_FILES:.bbg=.html) # posts/year/month/post-title-123.{bbg,html}
BUILT_POSTS := $(notdir $(BUILT_POSTS)) # post-title-123.html
BUILT_POSTS := $(addprefix $(BUILT_POST_DIR)/,$(BUILT_POSTS)) # build/posts/post-title-123.html
BUILT_META_FILES := $(BUILD_DIR)/index.html

all: $(BUILT_POSTS) $(BUILT_META_FILES)

$(BUILT_POSTS): $(POST_FILES) $(INCLUDE_FILES)
	$(CMD_BUILD_POST) $@ $(POST_FILES)

$(BUILD_DIR)/index.html: $(POST_FILES) $(INCLUDE_FILES)
	$(CMD_BUILD_INDEX) $@ $(POST_FILES)

clean:
	$(RM) $(RM_FLAGS) -- $(BUILD_DIR)
