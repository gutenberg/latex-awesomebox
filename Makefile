BASENAME=awesomebox

all: clean ctan

build: README.md $(BASENAME).pdf

ctan: build
	mkdir $(BASENAME)
	mv README.md $(BASENAME)/
	cp $(BASENAME).pdf $(BASENAME).tex $(BASENAME).sty LICENSE $(BASENAME)/
	zip -r $(BASENAME).zip $(BASENAME)

README.md: README.org
	pandoc -o README.md README.org

$(BASENAME).pdf:
	xelatex -halt-on-error "$(BASENAME).tex" &> /dev/null
	xelatex -halt-on-error "$(BASENAME).tex" &> /dev/null

clean:
	rm -rf $(BASENAME)
	rm $(BASENAME).pdf
	rm -f README.md $(BASENAME).zip $(BASENAME).aux $(BASENAME).log $(BASENAME).out
