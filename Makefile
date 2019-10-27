out := _out/wales,gerald
web := $(out)/web
book.name := wales,gerald__conquest-of-ireland,the
cache := _out/.cache
pandoc := pandoc

all: html epub

src.all := $(filter-out %.yaml, $(wildcard src/*))
dest.static := $(patsubst src/%, $(web)/%, $(filter-out %.md, $(src.all)))

html: $(web)/index.html $(dest.static)
epub: $(out)/$(book.name).epub
mobi: $(out)/$(book.name).mobi

deps := $(src.all) $(cache)/meta.yaml

$(out)/$(book.name).epub: $(deps)
	$(mkdir)
	$(pandoc) -p --toc --resource-path=src -c src/common.css -c src/epub.css $(cache)/meta.yaml src/main.md -o $@

$(out)/$(book.name).mobi: $(out)/$(book.name).epub
	cd $(dir $<) && kindlegen $(notdir $<) -o $(notdir $@); :

$(web)/index.html: $(deps)
	$(mkdir)
	$(pandoc) -s -p --toc -c common.css -c web.css $(cache)/meta.yaml src/main.md -o $@

$(dest.static): $(web)/%: src/%
	$(copy)

$(cache)/meta.yaml: src/meta.yaml
	$(mkdir)
	erb -r date $< > $@

mkdir = @mkdir -p $(dir $@)
define copy =
$(mkdir)
cp $< $@
endef
.DELETE_ON_ERROR: