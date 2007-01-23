SOFTWARE = polyparse
VERSION  = 1.00

CPP      = cpp -traditional
#CPP     = cpphs --text 	# useful e.g. on MacOS X

DIRS = Text Text/ParserCombinators

SRCS = \
	src/Text/ParserCombinators/HuttonMeijer.hs \
	src/Text/ParserCombinators/HuttonMeijerWallace.hs \
	src/Text/ParserCombinators/Poly.hs \
	src/Text/ParserCombinators/PolyState.hs \
	src/Text/ParserCombinators/PolyLazy.hs \
	src/Text/ParserCombinators/PolyStateLazy.hs \
	src/Text/Parse.hs

TOOLSRCS = \

AUX =	configure Makefile src/Makefile docs/* examples/* \
	README LICENCE* COPYRIGHT script/echo.c Build.bat \
	*.cabal Setup.hs
ALLFILES = $(SRCS) $(TOOLSRCS) $(AUX)

# These files in CVS are NOT included in the src distribution.
NOT =	Makefile.inc Makefile.nhc98 src/Makefile.inc src/Makefile.nhc98

.PHONY: all libs tools haddock install register

COMPILERS = $(shell cat obj/compilers)
LIBS  = $(patsubst %, libs-%, $(COMPILERS))
TOOLS = $(patsubst %, tools-%, $(COMPILERS))
INSTALL = $(patsubst %, install-%, $(COMPILERS))
FILESONLY = $(patsubst %, install-filesonly-%, $(COMPILERS))

all: $(LIBS) $(TOOLS)
libs: $(LIBS)
tools: $(TOOLS)
install: $(INSTALL)
install-filesonly: $(FILESONLY)
libs-ghc:
	cd obj/ghc; $(MAKE) HC=$(shell cat obj/ghccmd) libs
libs-nhc98:
	cd obj/nhc98; $(MAKE) HC=nhc98 libs
libs-hugs:
	@echo "No building required for Hugs version of $(SOFTWARE) libs."
tools-ghc:
	cd obj/ghc; $(MAKE) HC=$(shell cat obj/ghccmd) toolset
tools-nhc98:
	cd obj/nhc98; $(MAKE) HC=nhc98 toolset
tools-hugs:
	@echo "No building required for Hugs version of $(SOFTWARE) tools."
install-ghc:
	cd obj/ghc; $(MAKE) HC=$(shell cat obj/ghccmd) install-ghc
install-nhc98:
	cd obj/nhc98; $(MAKE) HC=nhc98 install-nhc98
install-hugs:
	hugs-package src
	cd obj/hugs; $(MAKE) install-tools-hugs
install-filesonly-ghc:
	cd obj/ghc; $(MAKE) HC=$(shell cat obj/ghccmd) install-filesonly-ghc
install-filesonly-nhc98:
	cd obj/nhc98; $(MAKE) HC=nhc98 install-filesonly-nhc98
install-filesonly-hugs: install-hugs
haddock:
	mkdir -p docs/$(SOFTWARE)
	for dir in $(DIRS); \
		do mkdir -p docs/$(SOFTWARE)/src/$$dir; \
		done
	for file in $(SRCS); \
		do $(CPP) -D__NHC__ $$file >$$file.uncpp; \
		   HsColour -anchorHTML $$file >docs/$(SOFTWARE)/`dirname $$file`/`basename $$file .hs`.html; \
		done
	haddock --html --title=$(SOFTWARE) --odir=docs/$(SOFTWARE) \
		--package=$(SOFTWARE) \
		--source-module="src/%{MODULE/.//}.html" \
		--source-entity="src/%{MODULE/.//}.html#%{NAME}" \
		$(patsubst %, %.uncpp, $(SRCS))
	rm -f $(patsubst %, %.uncpp, $(SRCS))

# packaging a distribution

srcDist: $(ALLFILES) haddock
	rm -f $(SOFTWARE)-$(VERSION).tar $(SOFTWARE)-$(VERSION).tar.gz
	mkdir $(SOFTWARE)-$(VERSION)
	tar cf - $(ALLFILES) | ( cd $(SOFTWARE)-$(VERSION); tar xf - )
	tar cf $(SOFTWARE)-$(VERSION).tar $(SOFTWARE)-$(VERSION)
	rm -rf $(SOFTWARE)-$(VERSION)
	gzip $(SOFTWARE)-$(VERSION).tar

zipDist: $(ALLFILES) haddock
	rm -f $(SOFTWARE)-$(VERSION).zip
	mkdir $(SOFTWARE)-$(VERSION)
	tar cf - $(ALLFILES) | ( cd $(SOFTWARE)-$(VERSION); tar xf - )
	zip -r $(SOFTWARE)-$(VERSION).zip $(SOFTWARE)-$(VERSION)
	rm -rf $(SOFTWARE)-$(VERSION)


# clear up rubbish
clean:
	rm -rf obj/ghc obj/nhc98 obj/hugs
	cd examples;    rm -f *.hi *.o
realclean: clean

