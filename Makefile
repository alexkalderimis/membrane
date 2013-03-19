
test: test/projects/simple/simple.js
	./node_modules/.bin/mocha \
		--reporter spec \
		test/projects/simple/simple.js

test/projects/simple/simple.js: build
	node membrane.js test/projects/simple

build: install
	./node_modules/coffee-script/bin/coffee --compile --output lib/ src/membrane.coffee.md

install:
	npm install


.PHONY: build install test clean
