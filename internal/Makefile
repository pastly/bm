.PHONY: all clean
SHELL := /bin/bash
.SHELLFLAGS := -u -c

# These are the files that always exist
# AKA source files
POST_FILES := $(shell find $(POST_DIR) -name '*.bm')
CSS_FILES := $(shell find $(INCLUDE_DIR) -name '*.css.in')
USER_CONF_FILE := $(INCLUDE_DIR)/bm.conf
INCLUDE_FILES := $(shell find $(INCLUDE_DIR) -name '*.html' -or -name '*.m4' -or -name '*.conf.example') \
	$(USER_CONF_FILE)

# These are the targets. These files don't exist until after a successful build
BUILT_POSTS := $(foreach p,$(POST_FILES),$(BUILT_POST_DIR)/$(shell get_title $(p) | title_to_post_url)$(TITLE_SEPARATOR_CHAR)$(shell get_id $(p)).html)
BUILT_SHORT_POSTS := $(foreach p,$(POST_FILES),$(BUILT_SHORT_POST_DIR)/$(shell get_id $(p)).html)
ifeq ($(CP_SRC_FILES_TO_BUILD),yes)
BUILT_SRC_FILES := $(BUILT_POSTS:.html=.bm)
BUILT_SHORT_SRC_FILES := $(BUILT_SHORT_POSTS:.html=.bm)
else
BUILT_SRC_FILES :=
BUILT_SHORT_SRC_FILES :=
endif
BUILT_STATICS := $(CSS_FILES:.css.in=.css)
BUILT_STATICS := $(notdir $(BUILT_STATICS))
BUILT_STATICS := $(addprefix $(BUILT_STATIC_DIR)/,$(BUILT_STATICS))
BUILT_META_FILES := \
	$(BUILD_DIR)/index.html \
	$(BUILT_POST_DIR)/index.html \
	$(BUILT_TAG_DIR)/index.html \
	$(BUILD_DIR)/404.html

METADATA_FILES := \
	$(METADATA_DIR)/postsbydate \
	$(METADATA_DIR)/tags \

POST_METADATA_FILES := $(foreach file,$(POST_FILES),$(METADATA_DIR)/$(shell get_id $(file)))
POST_METADATA_FILES := $(foreach dir,$(POST_METADATA_FILES),\
	$(dir)/headers \
	$(dir)/head \
	$(dir)/body \
	$(dir)/foot \
	$(dir)/tags \
	$(dir)/options \
	$(dir)/toc \
	$(dir)/content \
	$(dir)/previewcontent)

# These are output dirs that need to exist before files start getting dropped in them
OUT_DIRS := $(METADATA_DIR) \
	$(dir $(filter $(METADATA_DIR)/%/headers,$(POST_METADATA_FILES))) \
	$(BUILT_POST_DIR) \
	$(BUILT_STATIC_DIR) \
	$(BUILT_TAG_DIR) \
	$(BUILT_SHORT_POST_DIR)


all: $(OUT_DIRS) \
	$(METADATA_FILES) \
	$(POST_METADATA_FILES) \
	$(BUILT_SHORT_POSTS) \
	$(BUILT_SHORT_SRC_FILES) \
	$(BUILT_STATICS) \
	$(BUILT_META_FILES)

$(OUT_DIRS):
	$(MKDIR) $(MKDIR_FLAGS) $@

$(METADATA_DIR)/postsbydate: $(filter $(METADATA_DIR)/%/headers,$(POST_METADATA_FILES)) | $(OUT_DIRS)
	for POST in `sort_by_date $^`; do get_id $$POST; done > $@

$(METADATA_DIR)/tags: $(filter $(METADATA_DIR)/%/tags,$(POST_METADATA_FILES)) | $(OUT_DIRS)
	cat $^ | sort | uniq > $@

# Target for per-post headers
# headers are the first handful of lines in a post file
$(METADATA_DIR)/%/headers: $(POST_DIR)/*/*/*-%.bm | $(OUT_DIRS)
	@echo $@
	get_headers $< > $@

# Target for per-post tags, deduplicated and one per line
$(METADATA_DIR)/%/tags: $(METADATA_DIR)/%/content
	@echo $@
	get_tags $< > $@

# Target for per-post options file, fully validated
$(METADATA_DIR)/%/options: $(POST_DIR)/*/*/*-%.bm | $(OUT_DIRS)
	parse_options $< > $@
	validate_options $< $@

# Target for per-post table of contents, or empty of no toc needed
$(METADATA_DIR)/%/toc: $(METADATA_DIR)/%/content
	@echo $@
	get_toc $< > $@

# Target for content that appears an per-post page. Just Markdown, no processing
$(METADATA_DIR)/%/content: $(POST_DIR)/*/*/*-%.bm | $(OUT_DIRS)
	@echo $@
	get_content $< > $@

# Target for content that appears on the homepage. Just Markdown
$(METADATA_DIR)/%/previewcontent: $(METADATA_DIR)/%/content $(METADATA_DIR)/%/options
	@echo $@
	get_preview_content $(@D)/content $(@D)/options > $@

# Target for per-post header. Completely HTML formatted
$(METADATA_DIR)/%/head: $(METADATA_DIR)/%/headers $(CSS_FILES) $(INCLUDE_FILES)
	@echo $@
	build_content_header $< | $(M4) $(M4_FLAGS) > $@

# Target for per-post footer. Completely HTML formatted
$(METADATA_DIR)/%/foot: $(CSS_FILES) $(INCLUDE_FILES) | $(OUT_DIRS)
	@echo $@
	build_content_footer | $(M4) $(M4_FLAGS) > $@

# Target for per-post body. Completely HTML formatted.
$(METADATA_DIR)/%/body: $(METADATA_DIR)/%/headers $(METADATA_DIR)/%/content $(METADATA_DIR)/%/toc $(METADATA_DIR)/%/options
	@echo $@
	$(eval METADATA := $(METADATA_DIR)/$(shell get_id $<))
	< $(METADATA)/content \
	pre_markdown $(shell get_id $<) |\
	$(MARKDOWN) |\
	post_markdown $(shell get_id $<) > $@

# Target for short posts
$(BUILT_SHORT_POST_DIR)/%.html: $(METADATA_DIR)/%/head $(METADATA_DIR)/%/body $(METADATA_DIR)/%/foot | $(BUILD_DIR)/404.html
	@echo $@
	cat $^ > $@
ifeq ($(MAKE_SHORT_POSTS),yes)
	cp $@ $(filter %-$*.html,$(BUILT_POSTS))
else
	mv $@ $(filter %-$*.html,$(BUILT_POSTS))
	ln --symbolic $(realpath $(BUILD_DIR)/404.html) $@
endif

# Target for short source files
$(BUILT_SHORT_POST_DIR)/%.bm: $(POST_DIR)/*/*/*-%.bm | $(BUILD_DIR)/404.html
	@echo $@
	cp $^ $@
ifeq ($(MAKE_SHORT_POSTS),yes)
	cp $@ $(filter %-$*.bm,$(BUILT_SRC_FILES))
else
	mv $@ $(filter %-$*.bm,$(BUILT_SRC_FILES))
	ln --symbolic $(realpath $(BUILD_DIR)/404.html) $@
endif

# Target for homepage
$(BUILD_DIR)/index.html: $(METADATA_DIR)/postsbydate $(CSS_FILES) $(INCLUDE_FILES) $(BUILT_SHORT_POSTS)
	@echo $@
	build_index $< | $(M4) $(M4_FLAGS) > $@

# Target for posts index
$(BUILT_POST_DIR)/index.html: $(filter $(METADATA_DIR)/%/headers,$(POST_METADATA_FILES)) $(CSS_FILES) $(INCLUDE_FILES) | $(OUT_DIRS)
	@echo $@
	build_postindex | $(M4) $(M4_FLAGS) > $@

# Target for tags index
$(BUILT_TAG_DIR)/index.html: $(METADATA_DIR)/tags $(filter $(METADATA_DIR)/%/headers,$(POST_METADATA_FILES)) $(CSS_FILES) $(INCLUDE_FILES) | $(OUT_DIRS)
	@echo $@
	build_tagindex | $(M4) $(M4_FLAGS) > $@

# Target for all CSS
$(BUILT_STATIC_DIR)/%.css: $(INCLUDE_DIR)/%.css.in $(INCLUDE_FILES) | $(OUT_DIRS)
	@echo $@
	$(M4) $(M4_FLAGS) $< > $@

# Target to build 404 page
$(BUILD_DIR)/404.html:
	@echo $@
	build_404 | $(M4) $(M4_FLAGS) > $@

# Target to automatically make the config file if necessary
$(USER_CONF_FILE): $(INCLUDE_DIR)/bm.conf.example
	[ ! -f $@ ] && grep -vE '^#' $< > $@ || touch $@

clean:
	$(RM) $(RM_FLAGS) -- $(BUILD_DIR)/* $(METADATA_DIR)/*
	[ -d $(BUILD_DIR) ] && [ ! -L $(BUILD_DIR) ] && rmdir $(BUILD_DIR) || exit 0
	[ -d $(METADATA_DIR) ] && [ ! -L $(METADATA_DIR) ] && rmdir $(METADATA_DIR) || exit 0
