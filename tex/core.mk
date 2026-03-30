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
$(PLATEX) $(TEX_FLAGS) -jobname=$(JOBNAME) $(if $(filter 1,$(SP)),"\def\SP{1}\input{$(MAIN_DOC).tex}","$(MAIN_DOC).tex")
endef


##################################################
# Targets
##################################################

.PHONY: all pdf dvi bib clean distclean open sp help check

all: pdf

pdf: $(PDF)

dvi: $(DVI)

$(DVI): $(MAIN_DOC).tex $(SUB_DOCS:%=%.tex)
	$(call run_platex)

$(BBL): $(AUX)
	$(BIBTEX) $(BIBTEX_FLAGS) $(JOBNAME)

$(PDF): $(DVI)
	$(DVIPDFMX) $(DVIPDFMX_FLAGS) -o $(PDF) $(DVI)

bib:
	$(call run_platex)
	@if [ -f "$(AUX)" ]; then \
		$(BIBTEX) $(BIBTEX_FLAGS) $(JOBNAME) || true; \
	fi
	$(call run_platex)
	$(call run_platex)
	$(DVIPDFMX) $(DVIPDFMX_FLAGS) -o $(PDF) $(DVI)

sp:
	$(MAKE) SP=1 pdf

open: $(PDF)
ifeq ($(DO_OPEN),1)
	$(OPEN) $(PDF)
else
	@printf '[INFO] skip open on remote shell\n'
endif

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
		'  make          : build pdf' \
		'  make pdf      : build pdf' \
		'  make dvi      : build dvi' \
		'  make bib      : build with bibliography' \
		'  make sp       : build with \def\SP{1}' \
		'  make open     : open pdf locally' \
		'  make clean    : remove auxiliary files' \
		'  make distclean: remove auxiliary files and generated pdf' \
		'  make check    : show resolved variables' \
		'' \
		'variables:' \
		'  MAIN_DOC=<name>' \
		'  SUB_DOCS="sec1 sec2 ..."' \
		'  REQUIRE_V=0|1' \
		'  v=<number>'
