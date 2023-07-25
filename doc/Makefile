# Minimal makefile for Sphinx documentation
#

# You can set these variables from the command line, and also
# from the environment for the first two.
SPHINXOPTS    ?=
SPHINXBUILD   ?= sphinx-build
SOURCEDIR     = .
BUILDDIR      = _build

vpath %.nix ../lib

all: html

help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: help Makefile

lib/%.md: %.nix
	@./build_md.py ../lib/$*.nix lib/$*.md

lib: lib/pypa.md lib/pep427.md lib/pep440.md lib/pep508.md lib/pep518.md lib/pep599.md lib/pep600.md lib/pep621.md

html: lib Makefile
	@$(SPHINXBUILD) -M html "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS)

clean: Makefile
	@rm -rf lib
	@$(SPHINXBUILD) -M clean "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS)
