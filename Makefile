.PHONY: docs

run:
	docker pull bakingbad/michelson-kernel
	docker run --rm -it -p 127.0.0.1:8888:8888 -v $$(pwd)/notebooks:/home/jupyter/notebooks bakingbad/michelson-kernel

install:
	yarn
	pip install nbconvert
	apt install rename -y

postprocess:
	cd $$MDIR && rename 's/^([0-9]+).*/$$1.md/' *.md
	cd $$MDIR && sed -i 's/&quot;/"/g' *.md
	cd $$MDIR && sed -r -i 's/^>\sNote:\s(.*)$$/::: warning NOTE\n\1\n:::/g' *.md
	cd $$MDIR && sed -r -i 's/^>\sTip:\s(.*)$$/::: tip\n\1\n:::/g' *.md

docs:
	rm docs/chapters/*.md || true
	jupyter nbconvert notebooks/tutorials/**/*.ipynb --TemplateExporter.template_file=jupyter.tpl --Exporter.preprocessors='["preprocess.RemoveExerciceCells", "preprocess.AddBinderComponent"]' --to markdown --output-dir docs/chapters
	jupyter nbconvert notebooks/tutorials/michelson_kernel.ipynb --TemplateExporter.template_file=jupyter.tpl --Exporter.preprocessors=[\"preprocess.AddBinderComponent\"] --to markdown --output-dir docs/chapters
	MDIR=docs/chapters $(MAKE) postprocess
	rm docs/advanced/*.md || true
	jupyter nbconvert notebooks/examples/*.ipynb --TemplateExporter.template_file=jupyter.tpl --Exporter.preprocessors=[\"preprocess.AddBinderComponent\"] --to markdown --output-dir docs/advanced
	MDIR=docs/advanced $(MAKE) postprocess

build:
	yarn build

dev:
	yarn dev
