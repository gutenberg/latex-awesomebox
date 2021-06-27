BASENAME = awesomebox
# System-wide directory is TEXMFDIST (/usr/share/texmf-dist)
#DESTDIR ?= $(shell kpsewhich -var-value=TEXMFHOME)
DESTDIR ?= /usr/share/texmf-dist
INSTALL_DIR = $(DESTDIR)/tex/xelatex/$(BASENAME)
EMACS = emacs -Q -nw --batch

all: build

build: $(BASENAME).pdf

ctan: all $(BASENAME)/README.md
	cp $(addprefix $(BASENAME), .pdf .tex .sty) LICENSE $(BASENAME)/
	zip -r $(BASENAME).zip $(BASENAME)

$(BASENAME):
	mkdir $@

$(BASENAME)/README.md: $(BASENAME) README.org
	$(EMACS) --eval "(require 'ox-md)" --eval "(find-file \"README.org\")" \
		-f org-md-export-to-markdown
	mv README.md $@

$(BASENAME).pdf: allfonts $(BASENAME).tex
	xelatex -interaction batchmode -halt-on-error -shell-escape $(word 2,$^)
	xelatex -interaction batchmode -halt-on-error -shell-escape $(word 2,$^)

OTF_FILES = fonts/Inconsolata.otf \
	fonts/LinBiolinum_R.otf fonts/LinBiolinum_RB.otf fonts/LinBiolinum_RI.otf \
	fonts/LinLibertine_R.otf fonts/LinLibertine_RB.otf fonts/LinLibertine_RI.otf \
	fonts/LinLibertine_RBI.otf

fonts:
	mkdir fonts

fonts/Inconsolata.otf:
	curl -s -o $@ https://www.levien.com/type/myfonts/Inconsolata.otf

fonts/LinLibertineOTF_5.3.0_2012_07_02.tgz:
	curl -sL -o $@ https://downloads.sourceforge.net/project/linuxlibertine/linuxlibertine/5.3.0/LinLibertineOTF_5.3.0_2012_07_02.tgz

fonts/Lin%.otf: fonts/LinLibertineOTF_5.3.0_2012_07_02.tgz
	tar -C fonts -xzf fonts/LinLibertineOTF_5.3.0_2012_07_02.tgz $(@F)

allfonts: fonts $(OTF_FILES)

clean:
	rm -rf _minted-$(BASENAME)
	rm -f $(addprefix $(BASENAME), .aux .log .out .zip) $(addprefix test, .aux .log .pdf)

cleanctan:
	rm -rf $(BASENAME)

cleanall: clean cleanctan
	rm -rf fonts
	rm -f $(BASENAME).pdf

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
