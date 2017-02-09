.PHONY: all clean
SHELL := /bin/bash
.SHELLFLAGS := -u -c

################################################################################
## The following variables store source files. These files are not changed by BM
## and they do not depend on anything. Think of these as "incoming" files that
## when combined put together the final product.
################################################################################
POST_FILES := $(shell find $(POST_DIR) -name '*.bm')
CSS_THEME_FILES := $(shell find $(THEME_SYMLINK)/ -name '*.css.in') \
	$(THEME_SYMLINK)/css.m4
HTML_THEME_FILES := $(shell find $(THEME_SYMLINK)/ -name '*.html.in') \
	$(THEME_SYMLINK)/html.m4
THEME_FILES := $(CSS_THEME_FILES) $(HTML_THEME_FILES)
USER_CONF_FILE := $(POST_DIR)/bm.conf
CONF_FILES := $(USER_CONF_FILE) internal/bm.conf.example
################################################################################
################################################################################

################################################################################
## This section is for building up the list of output files based on what input
## files we have and what the configuration says (which is also an input file!).
################################################################################

# A long post is always built and looks like build/posts/the-title-abcd1234.html
BUILT_POSTS := $(foreach p,$(POST_FILES),\
	$(BUILT_POST_DIR)/$(shell get_title $(p) | title_to_post_url)$(TITLE_SEPARATOR_CHAR)$(shell get_id $(p)).html)

# We always have to have a list of short posts, even if the MAKE_SHORT_POSTS
# option is false. This is because the post building process outputs to short
# files (as it is easier), and then the short file are either copied or moved
# to the long files based on MAKE_SHORT_POSTS. A short post looks like
# build/p/abcd1234.html
BUILT_SHORT_POSTS := $(foreach p,$(POST_FILES),\
	$(BUILT_SHORT_POST_DIR)/$(shell get_id $(p)).html)

# If the user wants to copy the source files to the build directory, then build
# the list of (short) post source files based on the list of (short) post files.
# They look like build/posts/the-title-abcd1234.bm and build/p/abcd1234.bm
# BUILT_SHORT_SRC_FILES will always be set if CP_SRC_FILES_TO_BUILD is true even
# if MAKE_SHORT_POSTS isn't for the same reasoning as why BUILT_SHORT_POSTS
# can't be empty.
ifeq ($(CP_SRC_FILES_TO_BUILD),yes)
BUILT_SRC_FILES := $(BUILT_POSTS:.html=.bm)
BUILT_SHORT_SRC_FILES := $(BUILT_SHORT_POSTS:.html=.bm)
else
BUILT_SRC_FILES :=
BUILT_SHORT_SRC_FILES :=
endif

# Here is a convoluted process of getting path/to/style.css.in turned into
# $(BUILT_STATIC_DIR)/style.css. Any other files that should go in
# BUILT_STATIC_DIR should get added here as well, but at the time of writing,
# CSS files are the only ones.
BUILT_STATICS := $(filter %.css.in, $(CSS_THEME_FILES))
BUILT_STATICS := $(BUILT_STATICS:.css.in=.css)
BUILT_STATICS := $(notdir $(BUILT_STATICS))
BUILT_STATICS := $(addprefix $(BUILT_STATIC_DIR)/,$(BUILT_STATICS))

# These are _not_ the files in METADATA_DIR. These files are output files that
# contain information about other output files (or, honestly, don't really fit
# anywhere else...).
BUILT_META_FILES := \
	$(BUILD_DIR)/index.html \
	$(BUILT_POST_DIR)/index.html \
	$(BUILT_TAG_DIR)/index.html \
	$(BUILD_DIR)/404.html \

# If the user has turned on automatic output page signing, then generate the
# lists of signature files based on the lists of all other output files. If we
# aren't doing page signing, then the lists are empty. No surprise there.
ifeq ($(GPG_SIGN_PAGES),yes)
BUILT_META_FILES := $(BUILT_META_FILES) $(BUILD_DIR)/pubkey.gpg
BUILT_SIG_PAGES := \
	$(addsuffix .asc,$(BUILT_POSTS)) \
	$(addsuffix .asc,$(BUILT_SRC_FILES))
BUILT_SHORT_SIG_PAGES := \
	$(addsuffix .asc,$(BUILT_SHORT_POSTS)) \
	$(addsuffix .asc,$(BUILT_SHORT_SRC_FILES))
BUILT_SIG_STATICS := \
	$(addsuffix .asc,$(BUILT_STATICS))
BUILT_META_SIG_PAGES := \
	$(addsuffix .asc,$(BUILT_META_FILES))
else
BUILT_SIG_PAGES :=
BUILT_SHORT_SIG_PAGES :=
BUILT_SIG_STATICS :=
BUILT_META_SIG_PAGES :=
endif

# Finally, let's collect _most of_ the above lists of output files into one big
# list so it can be given to the all recipe easily. We do not include the long
# form of short files: the BUILT_SHORT POSTS recipe takes care of BUILT_POSTS,
# BUILT_SHORT_SIG_PAGES takes care of BUILT_SIG_PAGES, and BUILT_SHORT_SRC_FILES
# takes care of BUILT_SRC_FILES
ALL_BUILT_FILES := \
	$(BUILT_SHORT_POSTS) \
	$(BUILT_SHORT_SIG_PAGES) \
	$(BUILT_SHORT_SRC_FILES) \
	$(BUILT_STATICS) \
	$(BUILT_SIG_STATICS) \
	$(BUILT_META_FILES) \
	$(BUILT_META_SIG_PAGES) \
################################################################################
################################################################################

################################################################################
## This section is for 'metadata' files, which are an intermediate step between
## the input files and the output files. As much as possible, the output files
## should depends on these instead of the input files.
################################################################################

# These are 'global' metadata files. They impact all (or most) output files or
# are impacted by all (or most) input files. For example, pagehead is the
# visible page header (liking containing the website title and subtitle) for all
# output pages, and tags contains a list of all tags used in any post.
METADATA_FILES := \
	$(METADATA_DIR)/pagefoot \
	$(METADATA_DIR)/pagehead \
	$(METADATA_DIR)/postsbydate \
	$(METADATA_DIR)/tags \
	$(METADATA_DIR)/.lastconfchange

# These are per-post metadata files. They each only depend on one specfic post
# file. First we get a per-post metadata directory based on the list of all
# posts so POST_METADATA_FILES is
# "$(METADATA_DIR)/abcd1234 $(METADATA_DIR)/5678abcd", and then we explode that
# into a list of all the given files in each per-post metadata directory.
POST_METADATA_FILES := $(foreach f,$(POST_FILES),\
	$(METADATA_DIR)/$(shell get_id $(f)))
POST_METADATA_FILES := $(foreach d,$(POST_METADATA_FILES),\
	$(d)/headers \
	$(d)/tags \
	$(d)/options \
	$(d)/toc \
	$(d)/content \
	$(d)/previewcontent)

# As with the output files, let's collect all the metadata files into a single
# variable for easy handing off to the all recipe
ALL_METADATA_FILES := \
	$(METADATA_FILES) \
	$(POST_METADATA_FILES) \
################################################################################
################################################################################

################################################################################
## This short section just builds up a list of directories that have to exist
## before metadata or output files start getting generated. Many recipes depend
## on these directories as a order-only prerequisite.
################################################################################

# In order to get a list of per-post metadata directories, we pick an arbitrary
# per-post metadata file, and then take only its parent directory. Example:
# meta/abcd1234/headers --> meta/abcd1234
OUT_DIRS := $(METADATA_DIR) \
	$(dir $(filter $(METADATA_DIR)/%/headers,$(POST_METADATA_FILES))) \
	$(BUILT_POST_DIR) \
	$(BUILT_STATIC_DIR) \
	$(BUILT_TAG_DIR) \
	$(BUILT_SHORT_POST_DIR)
################################################################################
################################################################################


all: $(OUT_DIRS) \
	$(ALL_METADATA_FILES) \
	$(ALL_BUILT_FILES) \

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
	</dev/null $(GPG) $(GPG_EXPORT_FLAGS) > $@

# Target to automatically make the config file if necessary
$(USER_CONF_FILE): internal/bm.conf.example
	[ ! -f $@ ] && grep -vE '^#' $< > $@ || touch $@

# Target for simple actions that should happen if a configuration file changes.
# Most likely should only be used for cleanup. For example, the intial reason
# for adding this is to cleanup signature files when GPG_SIGN_PAGES has just
# been turned off. Since BUILT_SIG_PAGES (and the like) are empty now, there's
# nothing else to clean those up in build/
$(METADATA_DIR)/.lastconfchange: $(CONF_FILES)
ifneq ($(GPG_SIGN_PAGES),yes)
	@echo cleaning up old gpg-related files
	[ -f $(BUILD_DIR)/pubkey.gpg ] && rm $(BUILD_DIR)/pubkey.gpg || true
	find $(BUILD_DIR)/ -type f -name "*.asc" -delete
endif
	touch $@

clean:
	find $(BUILD_DIR) $(METADATA_DIR) -mindepth 1 -delete
