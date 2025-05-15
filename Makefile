$(shell [ -d .make ] || \
  (git clone -q https://github.com/makeplus/makes .make))

include .make/init.mk
include .make/python.mk

DEPS := \
  $(PYTHON-VENV) \

SITE-REMOTE := origin
SITE-BRANCH := site

TEMPLATES := \
  $(PYTHON-VENV)/lib/python3.12/site-packages/material/templates/partials/

build: site

site: $(DEPS)
	$(RM) -r $@
	git worktree add -f $@
	$(RM) -r $@/*
	$(VENV) && mkdocs build
	git -C $@ add -A

publish: site
	-git -C $< commit -m "Publish $$(date)"
	git -C $< push $(SITE-REMOTE) HEAD:$(SITE-BRANCH) --force

serve: $(DEPS)
	$(VENV) && mkdocs $@

template-list: $(DEPS)
	ls -1 $(TEMPLATES)

template-copy: $(DEPS)
ifndef template
	@echo Specify a template with 'template=name.html'
	exit 1
else
	mkdir -p theme/partials
	cp $(TEMPLATES)/$(template) theme/partials/
endif

clean::
	$(RM) -r site

distclean::
	$(RM) -r .make
