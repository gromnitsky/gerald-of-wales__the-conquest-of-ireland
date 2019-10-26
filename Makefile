out := _out/wales,gerald
web := $(out)/web
book.name := wales,gerald__conquest-of-ireland,the
pandoc := pandoc

all: html epub

src.all := $(shell find src -type f)
dest.css := $(patsubst src/%, $(web)/%, $(filter %.css, $(src.all)))

html: $(web)/index.html $(dest.css)
epub: $(out)/$(book.name).epub

$(out)/$(book.name).epub: $(src.all)
	$(mkdir)
	$(pandoc) -p --toc -c src/common.css -c src/epub.css src/meta.yaml src/main.md -o $@

$(web)/index.html: $(src.all)
	$(mkdir)
	$(pandoc) -s -p --toc -c common.css -c web.css src/meta.yaml src/main.md -o $@

$(dest.css): $(web)/%: src/%
	$(copy)

mkdir = @mkdir -p $(dir $@)
define copy =
$(mkdir)
cp $< $@
endef
