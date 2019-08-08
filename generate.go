package goaeric

import (
	"fmt"
	"html/template"
	"path/filepath"

	"goa.design/goa/v3/codegen"
	"goa.design/goa/v3/eval"
	"goa.design/goa/v3/expr"
)

// init register's the plugin generator functions.
func init() {
	codegen.RegisterPluginFirst("goaeric", "gen", nil, Generate)
}

// Generate generates ...
func Generate(genpkg string, roots []eval.Root, files []*codegen.File) ([]*codegen.File, error) {
	for _, root := range roots {
		if r, ok := root.(*expr.RootExpr); ok {
			files = append(files, ericFile(r))
		}
	}
	return files, nil
}

func ericFile(r *expr.RootExpr) *codegen.File {
	ericPath := filepath.Join(codegen.Gendir, "eric.txt")
	ericSection := &codegen.SectionTemplate{
		Name:    "eric",
		FuncMap: template.FuncMap{"toText": toText},
		Source:  "{{ toText .}}",
		Data:    "Eric was here!",
	}
	return &codegen.File{
		Path:             ericPath,
		SectionTemplates: []*codegen.SectionTemplate{ericSection},
	}
}

func toText(d interface{}) string {
	return fmt.Sprintf("%v", d)
}
