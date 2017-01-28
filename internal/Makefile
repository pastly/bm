.PHONY: all clean
SHELL := /bin/bash
.SHELLFLAGS := -u -c

# These are the files that always exist
# AKA source files
POST_FILES := $(shell find $(POST_DIR) -name '*.bm')
CSS_THEME_FILES := $(shell find $(THEME_SYMLINK)/ -name '*.css.in') $(THEME_SYMLINK)/css.m4
HTML_THEME_FILES := $(shell find $(THEME_SYMLINK)/ -name '*.html.in') $(THEME_SYMLINK)/html.m4
THEME_FILES := $(CSS_THEME_FILES) $(HTML_THEME_FILES)
USER_CONF_FILE := $(POST_DIR)/bm.conf
CONF_FILES := $(USER_CONF_FILE) internal/bm.conf.example

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
BUILT_STATICS := $(filter %.css.in, $(CSS_THEME_FILES))
BUILT_STATICS := $(BUILT_STATICS:.css.in=.css)
BUILT_STATICS := $(notdir $(BUILT_STATICS))
BUILT_STATICS := $(addprefix $(BUILT_STATIC_DIR)/,$(BUILT_STATICS))
BUILT_META_FILES := \
	$(BUILD_DIR)/index.html \
	$(BUILT_POST_DIR)/index.html \
	$(BUILT_TAG_DIR)/index.html \
	$(BUILD_DIR)/404.html \
	$(BUILD_DIR)/pubkey.gpg \

ifeq ($(GPG_SIGN_PAGES),yes)
BUILT_SIG_PAGES := $(addsuffix .asc,$(BUILT_POSTS)) $(addsuffix .asc,$(BUILT_SRC_FILES))
BUILT_SHORT_SIG_PAGES := $(addsuffix .asc,$(BUILT_SHORT_POSTS)) $(addsuffix .asc,$(BUILT_SHORT_SRC_FILES))
BUILT_META_SIG_PAGES := $(addsuffix .asc,$(BUILT_META_FILES))
BUILT_SIG_STATICS := $(addsuffix .asc,$(BUILT_STATICS))
else
BUILT_SIG_PAGES :=
BUILT_SHORT_SIG_PAGES :=
BUILT_META_SIG_PAGES :=
BUILT_SIG_STATICS :=
endif

METADATA_FILES := \
	$(METADATA_DIR)/pagefoot \
	$(METADATA_DIR)/pagehead \
	$(METADATA_DIR)/postsbydate \
	$(METADATA_DIR)/tags \

POST_METADATA_FILES := $(foreach file,$(POST_FILES),$(METADATA_DIR)/$(shell get_id $(file)))
POST_METADATA_FILES := $(foreach dir,$(POST_METADATA_FILES),\
	$(dir)/headers \
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
	$(BUILT_SHORT_SIG_PAGES) \
	$(BUILT_STATICS) \
	$(BUILT_SIG_STATICS) \
	$(BUILT_META_FILES) \
	$(BUILT_META_SIG_PAGES) \

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

# Target for content that appears on the homepage. Just Markdown, no processing
$(METADATA_DIR)/%/previewcontent: $(METADATA_DIR)/%/content $(METADATA_DIR)/%/options
	@echo $@
	get_preview_content $(@D)/content $(@D)/options > $@

# Target for short posts
$(BUILT_SHORT_POST_DIR)/%.html: $(METADATA_DIR)/%/headers $(METADATA_DIR)/pagehead $(METADATA_DIR)/%/content $(METADATA_DIR)/pagefoot $(CONF_FILES) $(BUILD_DIR)/404.html $(HTML_THEME_FILES)
	@echo $@
ifeq ($(MAKE_SHORT_POSTS),yes)
	$(eval OUT_FILE := $@)
else
	$(eval OUT_FILE := $(filter %-$*.html,$(BUILT_POSTS)))
endif
	$(eval TITLE := $(shell get_title $(METADATA_DIR)/$*/headers))
	{ start_html "$(TITLE) - $(BLOG_TITLE)"; \
	cat "$(METADATA_DIR)/pagehead"; \
	echo "START_CONTENT"; \
	build_content_header $* ""; \
	< $(METADATA_DIR)/$*/content \
		pre_markdown $* |\
		$(MARKDOWN) |\
		post_markdown $*; \
	echo "END_CONTENT"; \
	cat "$(METADATA_DIR)/pagefoot"; \
	end_html; } | $(M4) $(M4_FLAGS) > $(OUT_FILE)
ifeq ($(MAKE_SHORT_POSTS),yes)
	cp $@ $(filter %-$*.html,$(BUILT_POSTS))
else
	cp $(BUILD_DIR)/404.html $@
endif

# Target for short source files
$(BUILT_SHORT_POST_DIR)/%.bm: $(POST_DIR)/*/*/*-%.bm $(CONF_FILES) $(BUILD_DIR)/404.html
	@echo $@
ifeq ($(MAKE_SHORT_POSTS),yes)
	cp $< $@
	cp $< $(filter %-$*.bm,$(BUILT_SRC_FILES))
	chmod +r $@ $(filter %-$*.bm,$(BUILT_SRC_FILES))
else
	cp $< $(filter %-$*.bm,$(BUILT_SRC_FILES))
	chmod +r $(filter %-$*.bm,$(BUILT_SRC_FILES))
	cp $(BUILD_DIR)/404.html $@
endif

# Target for gpg signature pages for posts, if enabled
$(BUILT_SHORT_POST_DIR)/%.asc: $(BUILT_SHORT_POST_DIR)/% $(BUILD_DIR)/404.html $(CONF_FILES)
	</dev/null $(GPG) $(GPG_SIGN_FLAGS) $<
ifeq ($(MAKE_SHORT_POSTS),yes)
	cp $@ $(filter %-$*.asc,$(BUILT_SIG_PAGES))
else
	mv $@ $(filter %-$*.asc,$(BUILT_SIG_PAGES))
	cp $(BUILD_DIR)/404.html $@
endif

# Target for the footer for all pages, m4 formatted
$(METADATA_DIR)/pagefoot: $(CONF_FILES) $(HTML_THEME_FILES) | $(OUT_DIRS)
	@echo $@
	build_page_foot > $@

# Target for the head for all pages, m4 formatted
$(METADATA_DIR)/pagehead: $(CONF_FILES) $(HTML_THEME_FILES) | $(OUT_DIRS)
	@echo $@
	build_page_head > $@

# Target for all other gpg signature pages, if enabled
%.asc: %
	</dev/null $(GPG) $(GPG_SIGN_FLAGS) $<

# Target for homepage
$(BUILD_DIR)/index.html: $(METADATA_DIR)/postsbydate $(CONF_FILES) $(BUILT_SHORT_POSTS) $(HTML_THEME_FILES) $(METADATA_DIR)/pagehead $(METADATA_DIR)/pagefoot | $(OUT_DIRS)
	@echo $@
	{ start_html "$(BLOG_TITLE)"; \
	cat $(METADATA_DIR)/pagehead; \
	build_index $<; \
	cat $(METADATA_DIR)/pagefoot; \
	end_html; } | $(M4) $(M4_FLAGS) > $@

# Target for posts index
$(BUILT_POST_DIR)/index.html: $(filter $(METADATA_DIR)/%/headers,$(POST_METADATA_FILES)) $(CONF_FILES) $(HTML_THEME_FILES) $(METADATA_DIR)/pagehead $(METADATA_DIR)/pagefoot | $(OUT_DIRS)
	@echo $@
	{ start_html "Posts - $(BLOG_TITLE)"; \
	cat $(METADATA_DIR)/pagehead; \
	build_postindex; \
	cat $(METADATA_DIR)/pagefoot; \
	end_html; } | $(M4) $(M4_FLAGS) > $@

# Target for tags index
$(BUILT_TAG_DIR)/index.html: $(METADATA_DIR)/tags $(filter $(METADATA_DIR)/%/headers,$(POST_METADATA_FILES)) $(CONF_FILES) $(HTML_THEME_FILES) $(METADATA_DIR)/pagehead $(METADATA_DIR)/pagefoot | $(OUT_DIRS)
	@echo $@
	{ start_html "Tags - $(BLOG_TITLE)"; \
	cat $(METADATA_DIR)/pagehead; \
	build_tagindex; \
	cat $(METADATA_DIR)/pagefoot; \
	end_html; } | $(M4) $(M4_FLAGS) > $@

# Target for all CSS
$(BUILT_STATIC_DIR)/%.css: $(CSS_THEME_FILES) | $(OUT_DIRS)
	@echo $@
	$(M4) $(M4_FLAGS) $< > $@

# Target to build 404 page
$(BUILD_DIR)/404.html: $(METADATA_DIR)/pagehead $(METADATA_DIR)/pagefoot | $(OUT_DIRS)
	@echo $@
	{ start_html "404 - $(BLOG_TITLE)"; \
	cat $(METADATA_DIR)/pagehead; \
	build_404; \
	cat $(METADATA_DIR)/pagefoot; \
	end_html; } | $(M4) $(M4_FLAGS) > $@

# Target for fingerprint
$(BUILD_DIR)/pubkey.gpg: $(CONF_FILES) $(BUILD_DIR)/404.html | $(OUT_DIRS)
	@echo $@
ifeq ($(GPG_SIGN_PAGES),yes)
	</dev/null $(GPG) $(GPG_EXPORT_FLAGS) > $@
else
	cp $(BUILD_DIR)/404.html $@
endif

# Target to automatically make the config file if necessary
$(USER_CONF_FILE): internal/bm.conf.example
	[ ! -f $@ ] && grep -vE '^#' $< > $@ || touch $@

clean:
	$(RM) $(RM_FLAGS) -- $(BUILD_DIR)/* $(METADATA_DIR)/*
	[ -d $(BUILD_DIR) ] && [ ! -L $(BUILD_DIR) ] && rmdir $(BUILD_DIR) || exit 0
	[ -d $(METADATA_DIR) ] && [ ! -L $(METADATA_DIR) ] && rmdir $(METADATA_DIR) || exit 0
