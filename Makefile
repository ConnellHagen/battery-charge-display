# CSCI 2021 Project 2, part 2 Makefile
AN = p3
CLASS = 2021

# -Wno-comment: disable warnings for multi-line comments, present in some tests
CFLAGS = -Wall -Wno-comment -Werror -g 
CC     = gcc $(CFLAGS)
SHELL  = /bin/bash
CWD    = $(shell pwd | sed 's/.*\///g')

PROGRAMS = \
	batt_main \

TESTPROGRAMS = \
	hybrid_main \
	test_batt_update \
	test_hybrid_batt_update


all : $(PROGRAMS)

clean :
	rm -f $(PROGRAMS) *.o $(TESTPROGRAMS)

help :
	@echo 'Typical usage is:'
	@echo '  > make                          # build all programs'
	@echo '  > make clean                    # remove all compiled items'
	@echo '  > make testnum=5                # run test #5 only'
	@echo '  > make test                     # run all tests'
	@echo 'SPECIAL TARGETS for this Part'      
	@echo '  > make hybrid_main              # build the combined C/assembly program'
	@echo '  > make test-hybrid              # run tests on the hybrid executable'

zip :
	@echo 'ERROR: The zip file must be made in the project_2 directory!'

################################################################################
# battery problem (asm)

# build .o files from corresponding .c files
%.o : %.c batt.h
	$(CC) -c $<

# build assembly object via gcc + debug flags
batt_update_asm.o : batt_update_asm.s batt.h
	$(CC) -c $<

batt_main : batt_main.o batt_sim.o batt_update_asm.o 
	$(CC) -o $@ $^

# batt_update functions testing program
test_batt_update : test_batt_update.o batt_sim.o batt_update_asm.o
	$(CC) -o $@ $^

# uses both assmebly and C update functions for incremental testing
hybrid_main : batt_main.o batt_sim.o batt_update_asm.o batt_update.o
	$(CC) -o $@ $^

# hybrid test program
test_hybrid_batt_update : test_batt_update.o batt_sim.o batt_update_asm.o batt_update.o
	$(CC) -o $@ $^

################################################################################
# Testing Targets
test-setup :
	@chmod u+rx testy

test: batt_main test_batt_update test-setup
	./testy test_batt_update.org $(testnum)

test-hybrid: hybrid_main test_hybrid_batt_update test-setup
	./testy test_hybrid.org $(testnum)
	@echo
	@echo "WARNING: These are the hybrid tests used for incremental development."
	@echo "         Make sure to run 'make test' to run the full tests before submitting."

clean-tests : 
	rm -rf test-results/ test_batt_update test_hybrid_batt_update

