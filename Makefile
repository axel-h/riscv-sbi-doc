#
# Build usable documents
#

ASCIIDOCTOR = asciidoctor
ASCIIDOCTOR_PDF = $(ASCIIDOCTOR)-pdf
DITAA = ditaa
DEPS = src/contributors.adoc
DEPS += src/changelog.adoc
DEPS += src/intro.adoc
DEPS += src/terms.adoc
DEPS += src/binary-encoding.adoc
DEPS += src/ext-base.adoc
DEPS += src/ext-legacy.adoc
DEPS += src/ext-time.adoc
DEPS += src/ext-ipi.adoc
DEPS += src/ext-rfence.adoc
DEPS += src/ext-hsm.adoc
DEPS += src/ext-sys-reset.adoc
DEPS += src/ext-pmu.adoc
DEPS += src/ext-debug-console.adoc
DEPS += src/ext-sys-suspend.adoc
DEPS += src/ext-cppc.adoc
DEPS += src/ext-nested-acceleration.adoc
DEPS += src/ext-steal-time.adoc
DEPS += src/ext-experimental.adoc
DEPS += src/ext-vendor.adoc
DEPS += src/ext-firmware.adoc
DEPS += src/references.adoc
IMAGES = images/riscv-sbi-intro1.png
IMAGES += images/riscv-sbi-intro2.png
IMAGES += images/riscv-sbi-hsm.png
REVSNIP = $(SPEC)/autogenerated/revision.adoc-snippet
TARGETS = riscv-sbi.pdf
TARGETS += riscv-sbi.html
TARGETS += $(REVSNIP)
COMMITDATE=$(shell git show -s --format=%ci | cut -d ' ' -f 1)
GITVERSION=$(shell git describe --tag)
SPEC=$(shell pwd)

.PHONY: all
all: $(IMAGES) $(TARGETS)

images/%.png: src/%.ditaa
	rm -f $@
	$(DITAA) $< $@

%.html: %.adoc $(IMAGES) $(REVSNIP) $(DEPS)
	$(ASCIIDOCTOR) -d book -b html $<

%.pdf: %.adoc $(IMAGES) docs-resources/themes/riscv-pdf.yml $(REVSNIP) $(DEPS)
	$(ASCIIDOCTOR_PDF) \
	-a toc \
	-a compress \
	-a pdf-style=docs-resources/themes/riscv-pdf.yml \
	-a pdf-fontsdir=docs-resources/fonts \
	-o $@ $<

$(SPEC)/autogenerated:
	-mkdir $@

$(SPEC)/autogenerated/revision.adoc-snippet: Makefile $(SPEC)/autogenerated
	echo ":revdate: ${COMMITDATE}" > $@-tmp
	echo ":revnumber: ${GITVERSION}" >> $@-tmp
	(test -f $@ && diff $@ $@-tmp) || mv $@-tmp $@

.PHONY: clean
clean:
	rm -f $(TARGETS)
	rm -rf $(SPEC)/autogenerated

.PHONY: install-debs
install-debs:
	sudo apt-get install pandoc asciidoctor ditaa ruby-asciidoctor-pdf

.PHONY: install-rpms
install-rpms:
	sudo dnf install ditaa pandoc rubygem-asciidoctor rubygem-asciidoctor-pdf
