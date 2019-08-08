package testdata

import (
	_ "github.com/eric-isakson/goaeric"
	. "goa.design/goa/v3/dsl"
)

var APIOnly = func() {
	API("API", func() {})
}
