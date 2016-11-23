all: test

clean:
	rm -rf target

compile:
	mkdir -p target
	bash src/aggregate.sh > target/sbtest.sh
	chmod +x target/sbtest.sh

test: compile
	target/sbtest.sh

.DEFAULT: compile
	target/sbtest.sh $@
