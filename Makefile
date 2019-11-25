all: build

GIT_BRANCH:=$(shell git branch | sed -n '/\* /s///p')
build: stack_build
	stack exec site -- $@
rebuild: stack_build
	stack exec site -- $@
watch: stack_build
	stack exec site -- $@
.PHONY: build rebuild watch

stack_build:
	stack build
.PHONY: stack_build

# To avoid problems with submodule, do not pull directly.
pull:
	git pull --recurse-submodules
.PHONY: pull

deploy: check-deploy-branch check-upstream rebuild
	git submodule update --remote --merge
	# cleanup everything in site/, and force a reset on origin/master
	cd site && git stash && git fetch && git checkout master && git reset --hard origin/master
	rsync -avr --delete --exclude='.git'  _site/ site/
	cd site \
	&& git add . \
	&& git commit --allow-empty -m 'Automatic commit in submodule site/ by dev. repo. Makefile.' \
	&& git push origin master
	git add site
	git commit -m 'Automatic commit of submodule site/ update.'
	git push --recurse-submodules=check origin deploy

# Only the branch monitored by 'check-branch.sh' can be used for site deploys.
check-deploy-branch:
	./bin/check-branch.sh
.PHONY: check-deploy-branch

check-upstream:
	# First, check that we are either up to date, or ahead of the
	# default upstream branch
	git fetch --recurse-submodules
	# MAYBE This is fragile!  Any better options for making sure
	# that we are up to date or ahead of upstream?
	LANG=C git status --untracked-files=no | grep -q -e 'ahead' -e 'up to date' || (echo "\n\nERROR.\nPlease integrate upstream changes first."; return 1)
.PHONY: check-upstream

commit-merge-and-push-both-branches:
ifneq ($(GIT_BRANCH),master)
	@echo "Target '$@' can be called only when in branch 'master', not in '$(GIT_BRANCH)'."
	@false
endif
	@git diff-index --quiet HEAD || ( echo "Please commit or stash modified files to clean the work tree." && false )
	git checkout deploy
	git merge --ff-only master
	make deploy
	git checkout master
	git merge --ff-only deploy
	git push origin deploy
	git push origin master
.PHONY: commit-merge-and-push-both-branches

##################### program
# le build doit être appelé depuis ce répertoire, parce que les chemis
booklet:
	$(MAKE) -C booklet
.PHONY: booklet

clean:
	rm -rf _site
	$(MAKE) -C booklet clean
.PHONY: clean
