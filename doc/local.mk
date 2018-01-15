# GNU Guix --- Functional package management for GNU
# Copyright © 2016 Eric Bavier <bavier@member.fsf.org>
# Copyright © 2012, 2013, 2014, 2015, 2016, 2017 Ludovic Courtès <ludo@gnu.org>
# Copyright © 2013 Andreas Enge <andreas@enge.fr>
# Copyright © 2016 Taylan Ulrich Bayırlı/Kammer <taylanbayirli@gmail.com>
# Copyright © 2016, 2018 Mathieu Lirzin <mthl@gnu.org>
#
# This file is part of GNU Guix.
#
# GNU Guix is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or (at
# your option) any later version.
#
# GNU Guix is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with GNU Guix.  If not, see <http://www.gnu.org/licenses/>.

info_TEXINFOS = %D%/guix.texi

%C%_guix_TEXINFOS = \
  %D%/contributing.texi \
  %D%/fdl-1.3.texi

DOT_FILES =					\
  %D%/images/bootstrap-graph.dot		\
  %D%/images/bootstrap-packages.dot		\
  %D%/images/coreutils-graph.dot		\
  %D%/images/coreutils-bag-graph.dot		\
  %D%/images/service-graph.dot			\
  %D%/images/shepherd-graph.dot

DOT_VECTOR_GRAPHICS =				\
  $(DOT_FILES:%.dot=%.eps)			\
  $(DOT_FILES:%.dot=%.pdf)

EXTRA_DIST +=					\
  %D%/htmlxref.cnf				\
  $(DOT_FILES)					\
  $(DOT_VECTOR_GRAPHICS)			\
  %D%/images/coreutils-size-map.eps		\
  %D%/environment-gdb.scm			\
  %D%/package-hello.scm

OS_CONFIG_EXAMPLES_TEXI =			\
  %D%/os-config-bare-bones.texi			\
  %D%/os-config-desktop.texi			\
  %D%/os-config-lightweight-desktop.texi

# Bundle this file so that makeinfo finds it in out-of-source-tree builds.
BUILT_SOURCES        += $(OS_CONFIG_EXAMPLES_TEXI)
EXTRA_DIST           += $(OS_CONFIG_EXAMPLES_TEXI)
MAINTAINERCLEANFILES  = $(OS_CONFIG_EXAMPLES_TEXI)

%D%/os-config-%.texi: gnu/system/examples/%.tmpl
	$(AM_V_GEN)$(MKDIR_P) "`dirname $@`";	\
	cp "$<" "$@"

infoimagedir = $(infodir)/images
dist_infoimage_DATA =				\
  $(DOT_FILES:%.dot=%.png)			\
  %D%/images/coreutils-size-map.png

# Try hard to obtain an image size and aspect that's reasonable for inclusion
# in an Info or PDF document.
DOT_OPTIONS =					\
  -Gratio=.9 -Gnodesep=.005 -Granksep=.00005	\
  -Nfontsize=9 -Nheight=.1 -Nwidth=.1

.dot.png:
	$(AM_V_DOT)$(DOT) -Tpng $(DOT_OPTIONS) < "$<" > "$(srcdir)/$@.tmp"; \
	mv "$(srcdir)/$@.tmp" "$(srcdir)/$@"

.dot.pdf:
	$(AM_V_DOT)$(DOT) -Tpdf $(DOT_OPTIONS) < "$<" > "$(srcdir)/$@.tmp"; \
	mv "$(srcdir)/$@.tmp" "$(srcdir)/$@"

.dot.eps:
	$(AM_V_DOT)$(DOT) -Teps $(DOT_OPTIONS) < "$<" > "$(srcdir)/$@.tmp"; \
	mv "$(srcdir)/$@.tmp" "$(srcdir)/$@"

.png.eps:
	$(AM_V_GEN)convert "$<" "$@-tmp.eps"; \
	mv "$@-tmp.eps" "$@"

# We cannot add new dependencies to `%D%/guix.pdf' & co. (info "(automake)
# Extending").  Using the `-local' rules is imperfect, because they may be
# triggered after the main rule.  Oh, well.
pdf-local: $(DOT_FILES=%.dot=$(top_srcdir)/%.pdf)
info-local: $(DOT_FILES=%.dot=$(top_srcdir)/%.png)
ps-local: $(DOT_FILES=%.dot=$(top_srcdir)/%.eps)		\
	  $(top_srcdir)/%D%/images/coreutils-size-map.eps
dvi-local: ps-local

## ----------- ##
##  Man pages. ##
## ----------- ##

# The man pages are generated using GNU Help2man.  In makefiles rules they
# depend not on the binary, but on the source files.  This usage allows a
# manual page to be generated by the maintainer and included in the
# distribution without requiring the end-user to have 'help2man' installed.
# They are built in $(srcdir) like info manuals.

sub_commands_mans =				\
  $(srcdir)/%D%/guix-archive.1			\
  $(srcdir)/%D%/guix-build.1			\
  $(srcdir)/%D%/guix-challenge.1		\
  $(srcdir)/%D%/guix-download.1			\
  $(srcdir)/%D%/guix-edit.1			\
  $(srcdir)/%D%/guix-environment.1		\
  $(srcdir)/%D%/guix-gc.1			\
  $(srcdir)/%D%/guix-hash.1			\
  $(srcdir)/%D%/guix-import.1			\
  $(srcdir)/%D%/guix-lint.1			\
  $(srcdir)/%D%/guix-package.1			\
  $(srcdir)/%D%/guix-publish.1			\
  $(srcdir)/%D%/guix-pull.1			\
  $(srcdir)/%D%/guix-refresh.1			\
  $(srcdir)/%D%/guix-size.1			\
  $(srcdir)/%D%/guix-system.1

dist_man1_MANS =				\
  $(srcdir)/%D%/guix.1				\
  $(sub_commands_mans)

gen_man =						\
  LANGUAGE= $(top_builddir)/pre-inst-env $(HELP2MAN)	\
  $(HELP2MANFLAGS)

HELP2MANFLAGS = --source=GNU --info-page=$(PACKAGE_TARNAME)

$(srcdir)/%D%/guix.1: scripts/guix.in $(sub_commands_mans)
	-$(AM_V_HELP2MAN)$(gen_man) --output="$@" `basename "$@" .1`

# The 'case' ensures the man pages are only generated if the corresponding
# source script (the first prerequisite) has been changed.  The $(GOBJECTS)
# prerequisite is solely meant to force these docs to be made only after all
# Guile modules have been compiled.
$(srcdir)/%D%/guix-%.1: guix/scripts/%.scm $(GOBJECTS)
	-@case '$?' in \
	  *$<*) $(AM_V_P) && set -x || echo "  HELP2MAN $@"; \
	        $(gen_man) --output="$@" "guix $*";; \
	  *)    : ;; \
	esac

if BUILD_DAEMON

dist_man1_MANS += $(srcdir)/%D%/guix-daemon.1

$(srcdir)/%D%/guix-daemon.1: nix/nix-daemon/guix-daemon.cc
	-$(AM_V_HELP2MAN)$(gen_man) --output="$@" `basename "$@" .1`

endif
