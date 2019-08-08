#! /usr/bin/make
#
# Makefile for github.com/eric-isakson/goaeric
#
export GO111MODULE=on
GOPATH=$(shell go env GOPATH)
MODULE=$(shell go list -m)
MODULE_DIR=$(shell go list -m -f "{{.Dir}}")

.PHONY: all travis tidy fmt gen lint test build clean

all: gen lint test build

travis: all

$(GOPATH)/bin/goimports:
	@go get golang.org/x/tools/cmd/goimports

$(GOPATH)/bin/golint:
	@go get golang.org/x/lint/golint

$(GOPATH)/bin/staticcheck:
	@go get honnef.co/go/tools/cmd/staticcheck

$(GOPATH)/bin/goa:
	@go install goa.design/goa/v3/cmd/goa && goa version

tidy:
	@go mod tidy -v

fmt: $(GOPATH)/bin/goimports
	@files=$$(find . -type f -not -path '*/\.*' -not -path "./vendor/*" -name "*\.go" | grep -Ev '/(gen)/'); \
	$(GOPATH)/bin/goimports -w -l $$files

gen: $(GOPATH)/bin/goa
	@ rm -rf "$(MODULE_DIR)/internal/examples/calc/cmd" && \
	goa gen $(MODULE)/internal/examples/calc/design -o "internal/examples/calc" && \
	goa example $(MODULE)/internal/examples/calc/design -o "internal/examples/calc"

test:
	@go test ./...

lint: $(GOPATH)/bin/goimports $(GOPATH)/bin/golint $(GOPATH)/bin/staticcheck
	$(eval GO_FILES := $(shell find . -type f -name '*.go'))
	@if [ "`goimports -l $(GO_FILES) | tee /dev/stderr`" ]; then \
		echo "^ - Repo contains improperly formatted go files" && echo && exit 1; \
	fi
	@if [ "`golint ./... | grep -vf .golint_exclude | tee /dev/stderr`" ]; then \
		echo "^ - Lint errors!" && echo && exit 1; \
	fi
	@if [ "`staticcheck -checks all,-ST1000,-ST1001 ./... | tee /dev/stderr`" ]; then \
		echo "^ - staticcheck errors!" && echo && exit 1; \
	fi

build:
	@cd "$(MODULE_DIR)/internal/examples/calc" && \
		go build ./cmd/calc && go build ./cmd/calc-cli

clean:
	@cd "$(MODULE_DIR)/internal/examples/calc" && \
		rm -f calc calc-cli
