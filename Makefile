BASENAME = awesomebox
# System-wide directory is TEXMFDIST (/usr/share/texmf-dist)
#DESTDIR ?= $(shell kpsewhich -var-value=TEXMFHOME)
DESTDIR ?= /usr/share/texmf-dist
INSTALL_DIR = $(DESTDIR)/tex/xelatex/$(BASENAME)

all: distclean ctan

build: README.md $(BASENAME).pdf

ctan: build
	mkdir $(BASENAME)
	mv README.md $(BASENAME)/
	cp $(BASENAME).pdf $(BASENAME).tex $(BASENAME).sty LICENSE $(BASENAME)/
	zip -r $(BASENAME).zip $(BASENAME)

README.md: README.org
	pandoc -o README.md README.org

$(BASENAME).pdf:
	xelatex -halt-on-error -shell-escape "$(BASENAME).tex"
	xelatex -interaction batchmode -halt-on-error -shell-escape "$(BASENAME).tex"

clean:
	rm -rf $(BASENAME) _minted-$(BASENAME)
	rm -f README.md $(BASENAME).zip $(BASENAME).aux $(BASENAME).log $(BASENAME).out

distclean: clean
	rm $(BASENAME).pdf

install: $(BASENAME).pdf
	install -d -m 755 $(INSTALL_DIR)
	install -D -m 644 $(BASENAME).sty $(INSTALL_DIR)/$(BASENAME).sty
	install -D -m 644 $(BASENAME).tex $(INSTALL_DIR)/$(BASENAME).tex
	install -D -m 644 $(BASENAME).pdf $(INSTALL_DIR)/$(BASENAME).pdf
	install -D -m 644 LICENSE $(INSTALL_DIR)/LICENSE
	texhash

uninstall:
	rm -rf $(INSTALL_DIR)
	texhash
