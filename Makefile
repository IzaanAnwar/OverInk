SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help

APP_NAME := OverInk
APP_BUNDLE := $(CURDIR)/dist/$(APP_NAME).app
BUILD_ROOT := $(CURDIR)/.build
DEVELOPER_ROOT := $(shell xcode-select -p)
VERSION := $(shell cat VERSION)
ARCHS ?= $(shell uname -m)

SWIFT_ARGS := --disable-sandbox --cache-path $(BUILD_ROOT)/cache
TEST_ARGS :=

ifneq ($(findstring /CommandLineTools,$(DEVELOPER_ROOT)),)
SWIFT_ARGS += --build-system native
TEST_ARGS += -Xswiftc -F -Xswiftc $(DEVELOPER_ROOT)/Library/Developer/Frameworks
TEST_ARGS += -Xswiftc -plugin-path -Xswiftc $(DEVELOPER_ROOT)/usr/lib/swift/host/plugins/testing
TEST_ARGS += -Xlinker -rpath -Xlinker $(DEVELOPER_ROOT)/Library/Developer/Frameworks
endif

export CLANG_MODULE_CACHE_PATH := $(BUILD_ROOT)/clang-cache
export SWIFTPM_MODULECACHE_OVERRIDE := $(BUILD_ROOT)/module-cache

.PHONY: help validate build test dev-app run app universal package release clean

help:
	@printf '%s\n' \
	  'OverInk development commands' \
	  '' \
	  '  make run        Build and launch a local development app' \
	  '  make test       Run the Swift test suite with coverage' \
	  '  make app        Build an app for the current architecture' \
	  '  make universal  Build an arm64 + x86_64 app' \
	  '  make package    Package the existing app as a verified DMG' \
	  '  make release    Run the complete local release pipeline' \
	  '  make clean      Remove generated build and distribution files'

validate:
	bash -n scripts/*.sh
	plutil -lint Resources/Info.plist
	git diff --check

build:
	swift build $(SWIFT_ARGS)

test:
	swift test $(SWIFT_ARGS) $(TEST_ARGS) --enable-code-coverage

dev-app: build
	pkill -x $(APP_NAME) >/dev/null 2>&1 || true
	rm -rf "$(APP_BUNDLE)"
	mkdir -p "$(APP_BUNDLE)/Contents/MacOS"
	cp "$$(swift build $(SWIFT_ARGS) --show-bin-path)/$(APP_NAME)" "$(APP_BUNDLE)/Contents/MacOS/$(APP_NAME)"
	cp Resources/Info.plist "$(APP_BUNDLE)/Contents/Info.plist"
	/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $(VERSION)" "$(APP_BUNDLE)/Contents/Info.plist"
	/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $(VERSION)" "$(APP_BUNDLE)/Contents/Info.plist"
	codesign --force --sign - "$(APP_BUNDLE)"

run: dev-app
	/usr/bin/open -n "$(APP_BUNDLE)"

app:
	ARCHS="$(ARCHS)" ./scripts/build-app.sh

universal:
	$(MAKE) app ARCHS='arm64 x86_64'

package:
	./scripts/package-dmg.sh

release:
	$(MAKE) clean
	$(MAKE) validate
	$(MAKE) test
	$(MAKE) universal
	$(MAKE) package

clean:
	rm -rf "$(BUILD_ROOT)" "$(CURDIR)/dist"
