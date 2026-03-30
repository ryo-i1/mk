# tex/core.mk

##################################################
# Defaults
##################################################

MAIN_DOC  ?=
SUB_DOCS  ?=
REQUIRE_V ?= 0

PLATEX    ?= platex
BIBTEX    ?= pbibtex
DVIPDFMX  ?= dvipdfmx
RM        ?= rm -f
OPEN      ?= open

TEX_FLAGS      ?= -interaction=nonstopmode -file-line-error
BIBTEX_FLAGS   ?=
DVIPDFMX_FLAGS ?=

# version build:
#   make v=1
v ?=

# special build:
#   make sp
SP := $(or $(SP),$(sp),0)


##################################################
# Main document detection
##################################################

tex_files := $(filter-out $(SUB_DOCS:%=%.tex),$(wildcard *.tex))

ifeq ($(strip $(MAIN_DOC)),)
ifeq ($(words $(tex_files)),1)
	MAIN_DOC := $(basename $(notdir $(firstword $(tex_files))))
endif
endif

ifeq ($(strip $(MAIN_DOC)),)
	$(error MAIN_DOC is not set. Please set MAIN_DOC in your project Makefile)
endif

ifeq ($(REQUIRE_V),1)
ifeq ($(strip $(v)),)
	$(error v is required because REQUIRE_V=1)
endif
endif

# require v when SP build
ifeq ($(SP),1)
ifeq ($(strip $(v)),)
	$(error v is required when SP=1)
endif
endif


##################################################
# Output names
##################################################

JOBBASE := $(MAIN_DOC)
SUFFIX  :=

ifeq ($(SP),1)
	SUFFIX := $(SUFFIX)_sp
endif

ifneq ($(strip $(v)),)
	SUFFIX := $(SUFFIX)_v$(v)
endif

JOBNAME := $(JOBBASE)$(SUFFIX)

DVI := $(JOBNAME).dvi
PDF := $(JOBNAME).pdf
AUX := $(JOBNAME).aux
LOG := $(JOBNAME).log
BLG := $(JOBNAME).blg
BBL := $(JOBNAME).bbl
TOC := $(JOBNAME).toc
OUT := $(JOBNAME).out


##################################################
# Open control
##################################################

ifdef SSH_CONNECTION
	DO_OPEN := 0
else
	DO_OPEN := 1
endif


##################################################
# Internal helpers
##################################################

define run_platex
$(PLATEX) $(TEX_FLAGS) -jobname=$(JOBNAME) $(if $(filter 1,$(SP)),"\def\SP{$(v)}\input{$(MAIN_DOC).tex}","$(MAIN_DOC).tex")
endef

define run_bibtex_if_needed
@if [ -f "$(AUX)" ] && grep -q '\\citation{' "$(AUX)"; then \
	$(BIBTEX) $(BIBTEX_FLAGS) $(JOBNAME); \
fi
endef


##################################################
# Targets
##################################################

.PHONY: all pdf dvi open clean distclean sp help check

all: open

open: $(PDF)
ifeq ($(DO_OPEN),1)
	$(OPEN) $(PDF)
else
	@printf '[INFO] skip open on remote shell\n'
endif

pdf: $(PDF)

dvi: $(DVI)

$(DVI): $(MAIN_DOC).tex $(SUB_DOCS:%=%.tex)
	$(call run_platex)
	$(call run_bibtex_if_needed)
	$(call run_platex)
	$(call run_platex)

$(PDF): $(DVI)
	$(DVIPDFMX) $(DVIPDFMX_FLAGS) -o $(PDF) $(DVI)

sp:
	$(MAKE) SP=1 open

clean:
	$(RM) *.aux *.bbl *.blg *.dvi *.log *.out *.toc *.lof *.lot *.fls *.fdb_latexmk *.synctex.gz

distclean: clean
	$(RM) *_v*.pdf *_v*.dvi *_v*.aux *_v*.bbl *_v*.blg *_v*.log *_v*.out *_v*.toc
	$(RM) *_sp*.pdf *_sp*.dvi *_sp*.aux *_sp*.bbl *_sp*.blg *_sp*.log *_sp*.out *_sp*.toc
	$(RM) *.pdf

check:
	@printf 'MAIN_DOC = %s\n' "$(MAIN_DOC)"
	@printf 'SUB_DOCS = %s\n' "$(SUB_DOCS)"
	@printf 'JOBBASE  = %s\n' "$(JOBBASE)"
	@printf 'SUFFIX   = %s\n' "$(SUFFIX)"
	@printf 'JOBNAME  = %s\n' "$(JOBNAME)"
	@printf 'SP       = %s\n' "$(SP)"
	@printf 'v        = %s\n' "$(v)"

help:
	@printf '%s\n' \
		'targets:' \
		'  make          : build pdf and open locally if possible' \
		'  make pdf      : build pdf' \
		'  make dvi      : build dvi' \
		'  make sp       : build with \def\SP{N} and open locally if possible' \
		'  make clean    : remove auxiliary files' \
		'  make distclean: remove auxiliary files and generated pdf' \
		'  make check    : show resolved variables' \
		'' \
		'variables:' \
		'  MAIN_DOC=<name>' \
		'  SUB_DOCS="sec1 sec2 ..."' \
		'  REQUIRE_V=0|1' \
		'  v=<number>'
