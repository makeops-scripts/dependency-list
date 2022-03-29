PROJECT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
include $(abspath $(PROJECT_DIR)/scripts/makeops/dependency-list/init.mk)

# ==============================================================================
# Public targets

dependency-list: ### Find all the dependencies - mandatory: IMAGE=[image name]; optional TECH=[technology to search for]
	make _copy-system-detect-utility
	source ./scripts/makeops/dependency-list/dependency-list.sh
	dependency-list $(IMAGE) $(TECH)

test: ### Run the test suite
	make _build-examples
	./scripts/makeops/dependency-list/dependency-list.test.sh

clean: ### Clean up
	( cd ./scripts/makeops/dependency-list/images/example-python-app; make clean )
	( source ./scripts/makeops/dependency-list/dependency-list.sh; dependency-list-clean )

# ==============================================================================
# Private targets

_copy-system-detect-utility:
	cp -f \
		./scripts/makeops/system-detect/system-detect.sh \
		./scripts/makeops/dependency-list/images/wrapper/assets/lib

_build-examples:
	( cd ./scripts/makeops/dependency-list/images/example-python-app; make build )

# ==============================================================================
# Supporting targets

update-system-detect-utility: ### Update the MakeOps System Detect Utility
	curl -L bit.ly/makeops-system-detect | \
		INSTALL_DIR=$(PROJECT_DIR)/scripts SCRIPTS_ONLY=true bash

# ==============================================================================

.SILENT: \
	_copy-system-detect-utility \
	build-examples \
	clean \
	dependency-list \
	test \
	update-system-detect-utility
