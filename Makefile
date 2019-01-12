.PHONY: doc test update

PACKAGE = aioamqp

TEST_LAUNCHER ?= pytest
TEST_OPTIONS ?= -v -s --timeout=20
PYLINT_RC ?= .pylintrc

BUILD_DIR ?= build
INPUT_DIR ?= docs

# Sphinx options (are passed to build_docs, which passes them to sphinx-build)
#   -W       : turn warning into errors
#   -a       : write all files
#   -b html  : use html builder
#   -i [pat] : ignore pattern

SPHINXOPTS ?= -a -W -b html
AUTOSPHINXOPTS := -i *~ -i *.sw* -i Makefile*

SPHINXBUILDDIR ?= $(BUILD_DIR)/sphinx/html
ALLSPHINXOPTS ?= -d $(BUILD_DIR)/sphinx/doctrees $(SPHINXOPTS) docs

doc:
	sphinx-build -a $(INPUT_DIR) build

livehtml: docs
	sphinx-autobuild $(AUTOSPHINXOPTS) $(ALLSPHINXOPTS) $(SPHINXBUILDDIR)

test:
	$(TEST_LAUNCHER) $(TEST_OPTIONS) $(PACKAGE)


update:
	pip install -r requirements_dev.txt

pylint:
	pylint aioamqp


### semi-private targets used by polyconseil's CI (copy-pasted from blease) ###

.PHONY: reports jenkins-test jenkins-quality

reports:
	mkdir -p reports

jenkins-test: reports
	$(MAKE) test TEST_OPTIONS="--cov=$(PACKAGE) \
		--cov-report xml:reports/xmlcov.xml \
		--junitxml=reports/TEST-$(PACKAGE).xml \
		-v \
		$(TEST_OPTIONS)"

jenkins-quality: reports
	pylint --rcfile=$(PYLINT_RC) $(PACKAGE) > reports/pylint.report || true
