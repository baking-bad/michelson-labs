install:
	yarn

markdown:
	rm docs/chapters/*.md
	jupyter nbconvert notebooks/**/*.ipynb --to markdown --output-dir docs/chapters
	cd docs/chapters && rename 's/^Chapter\s([a-z]+).*/$$1.md/' *.md
	cd docs/chapters && sed -i 's/&quot;/"/g' *.md
	cd docs/chapters && sed -r -i 's/^>\sNote:\s(.*)$$/::: warning NOTE\n\1\n:::/g' *.md
	cd docs/chapters && sed -r -i 's/^>\sTip:\s(.*)$$/::: tip\n\1\n:::/g' *.md

build:
	yarn build

dev:
	yarn dev