$(shell [ -d .make ] || \
  (git clone -q https://github.com/makeplus/makes .make))

include .make/init.mk
include .make/python.mk

DEPS := \
  $(PYTHON-VENV) \

SITE-REMOTE := origin
SITE-BRANCH := site


build: site

site: $(DIRS) $(DEPS)
	$(RM) -r $@
	git worktree add -f $@
	$(RM) -r $@/*
	$(VENV) && mkdocs build
	git -C $@ add -A

publish: site
	-git -C $< commit -m "Publish $$(date)"
	git -C $< push $(SITE-REMOTE) HEAD:$(SITE-BRANCH) --force

serve: $(DIRS) $(DEPS)
	$(VENV) && mkdocs $@

clean::
	$(RM) -r site

distclean::
	$(RM) -r .make
