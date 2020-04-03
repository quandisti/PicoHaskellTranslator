BASE_DIR = $(shell pwd)

all: clean compile build test

ANTLR4 := java -jar ${BASE_DIR}/antlr-4.7.1-complete.jar
compile: 
	$(ANTLR4) -no-listener -no-visitor Haskellv6.g4
	@echo "Compiling grammar finished"
	
build: compile
	javac -classpath .:${BASE_DIR}/antlr-4.7.1-complete.jar:$$CLASSPATH *.java
	@echo "Building finished"

clean:
	@rm -f *.java *.tokens *.interp *.class
	@rm -f tests/*.py
	@echo "Cleaned"

TESTFILES := $(patsubst %.hs,%.py,$(wildcard $(BASE_DIR)/tests/*))

test: $(TESTFILES)
	@echo "Testing finished"

%.py: %.hs
	@echo "translating" $<
	@java -classpath .:${BASE_DIR}/antlr-4.7.1-complete.jar:$$CLASSPATH Haskellv6Parser $<
