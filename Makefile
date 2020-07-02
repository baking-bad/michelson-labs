.PHONY: docs

install:
	yarn

postprocess:
	cd $$MDIR && rename 's/^([0-9]+).*/$$1.md/' *.md
	cd $$MDIR && sed -i 's/&quot;/"/g' *.md
	cd $$MDIR && sed -r -i 's/^>\sNote:\s(.*)$$/::: warning NOTE\n\1\n:::/g' *.md
	cd $$MDIR && sed -r -i 's/^>\sTip:\s(.*)$$/::: tip\n\1\n:::/g' *.md

docs:
	rm docs/chapters/*.md || true
	jupyter nbconvert notebooks/tutorials/**/*.ipynb --TemplateExporter.template_file=michelson.tpl --Exporter.preprocessors='["preprocess.RemoveExerciceCells", "preprocess.AddBinderComponent"]' --to markdown --output-dir docs/chapters
	jupyter nbconvert notebooks/tutorials/michelson_kernel.ipynb --TemplateExporter.template_file=michelson.tpl --Exporter.preprocessors=[\"preprocess.AddBinderComponent\"] --to markdown --output-dir docs/chapters
	MDIR=docs/chapters $(MAKE) postprocess
	rm docs/advanced/*.md || true
	jupyter nbconvert notebooks/examples/*.ipynb --TemplateExporter.template_file=michelson.tpl --Exporter.preprocessors=[\"preprocess.AddBinderComponent\"] --to markdown --output-dir docs/advanced
	MDIR=docs/advanced $(MAKE) postprocess

build:
	yarn build

dev:
	yarn dev