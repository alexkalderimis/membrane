
test: test/projects/build/simple.js test/projects/build/with-deps.js
	./node_modules/.bin/mocha \
		--reporter spec \
		test/build/*.js

test/projects/build/with-deps.js: build
	node membrane.js test/projects/with-external-deps
	mkdir -p test/build
	cp test/projects/with-external-deps/with-deps.js test/build/

test/projects/build/simple.js: build
	node membrane.js test/projects/simple
	mkdir -p test/build
	cat test/projects/simple/simple.js test/projects/simple/test.js > test/build/simple.js

build: install
	./node_modules/coffee-script/bin/coffee --compile --output lib/ src/membrane.coffee.md

install:
	npm install


.PHONY: build install test clean
