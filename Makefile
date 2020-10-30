.PHONY: docs

run:
	docker pull bakingbad/michelson-kernel
	docker run --rm -it -p 127.0.0.1:8888:8888 -v $$(pwd)/notebooks:/home/jupyter/notebooks bakingbad/michelson-kernel

install:
	yarn
	pip install nbconvert==5.6.1
	sudo apt install rename -y

postprocess:
	cd $$MDIR && rename 's/^([0-9]+).*/$$1.md/' *.md
	cd $$MDIR && sed -i 's/&quot;/"/g' *.md
	cd $$MDIR && sed -r -i 's/^>\sNote:\s(.*)$$/::: warning NOTE\n\1\n:::/g' *.md
	cd $$MDIR && sed -r -i 's/^>\sTip:\s(.*)$$/::: tip\n\1\n:::/g' *.md

docs:
	rm docs/michelson/[0-9]*.md || true
	rm docs/pytezos/[0-9]*.md || true
	jupyter nbconvert notebooks/michelson/*.ipynb --TemplateExporter.template_file=jupyter.tpl --Exporter.preprocessors='["preprocess.RemoveExerciceCells", "preprocess.AddBinderComponent"]' --to markdown --output-dir docs/michelson
	jupyter nbconvert notebooks/pytezos/*.ipynb --TemplateExporter.template_file=jupyter.tpl --Exporter.preprocessors='["preprocess.AddBinderComponent"]' --to markdown --output-dir docs/pytezos
	MDIR=docs/michelson $(MAKE) postprocess
	MDIR=docs/pytezos $(MAKE) postprocess

build:
	yarn build
	echo "michelson.baking-bad.org" > ./docs/.vuepress/dist/CNAME

dev:
	yarn dev
