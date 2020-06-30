install:
	yarn

markdown:
	rm docs/chapters/*.md || true
	jupyter nbconvert notebooks/**/*.ipynb --TemplateExporter.template_file=michelson.tpl --Exporter.preprocessors=[\"preprocess.RemoveExerciceCells\"] --to markdown --output-dir docs/chapters
	cd docs/chapters && rename 's/^([0-9]+).*/$$1.md/' *.md
	cd docs/chapters && sed -i 's/&quot;/"/g' *.md
	cd docs/chapters && sed -r -i 's/^>\sNote:\s(.*)$$/::: warning NOTE\n\1\n:::/g' *.md
	cd docs/chapters && sed -r -i 's/^>\sTip:\s(.*)$$/::: tip\n\1\n:::/g' *.md

build:
	yarn build

dev:
	yarn dev