all: test

clean:
	rm -rf target

compile:
	mkdir -p target
	bash src/aggregate.sh > target/sbtest.sh

test: compile
	chmod +x target/sbtest.sh
	target/sbtest.sh
