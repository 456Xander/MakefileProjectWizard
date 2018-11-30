.PHONY: all clean debug release pch
#Name of the Executable file
EXEC_NAME := create-proj
SRC_DIR := ./src
DEBUG_DIR := ./Debug
RELEASE_DIR := ./Release
DEPDIR := ./Depends
OUT_DIR = .
PRECOMP_H := ./src/pch.h
PRECOMP_GCH := $(PRECOMP_H).gch

DEBUG_EXEC := $(DEBUG_DIR)/$(EXEC_NAME)
RELEASE_EXEC := $(RELEASE_DIR)/$(EXEC_NAME)

SRC := $(shell find $(SRC_DIR) -name '*.c' -o -name '*.cpp')
HEADER := $(shell find $(SRC_DIR) -name '*.h')
OBJS = $(filter %.o, $(SRC:.c=.o) $(SRC:.cpp=.o))
OBJS_T = $(subst $(SRC_DIR), $(OUT_DIR), $(OBJS))

SRC_CPP := $(filter %.cpp, $(SRC))

LN := ln -sf
RM := rm -rf
CC := gcc
CXX := g++

LDFLAGS :=

ifeq ($(SRC_CPP),)
	LD := $(CC)
else
	#Build everything with g++, just to be safe
	CC := $(CXX)
	LD := $(CXX)
endif

CCFLAGS = -Wall -Wextra -MMD -MP -MF $(subst $(subst ./,,$(SRC_DIR)), $(subst ./,,$(DEPDIR)), $(patsubst %.c, %.d, $<))
CXXFLAGS = $(CCFLAGS) -std=c++14
CFLAGS = $(CCFLAGS) -std=c11
all: directories debug

debug: CFLAGS += -O0 -ggdb -DDBG -fsanitize=address
debug: CXXFLAGS += -O0 -ggdb -DDBG -fsanitize=address
debug: LDFLAGS += -fsanitize=address
debug: $(PRECOMP_GCH) $(DEBUG_EXEC)
	$(LN) $< ./$(EXEC_NAME)

release: CFLAGS += -O2 -march=native
release: CXXFLAGSX += -O2 -march=native
release: $(PRECOMP_GCH) $(RELEASE_EXEC)
	$(LN) $< ./$(EXEC_NAME)

fast: CFLAGS += -O3 -march=native
fast: CXXFLAGSX += -O3 -march=native
fast: pch $(RELEASE_EXEC)
	$(LN) $< ./$(EXEC_NAME)

%.h.gch: %.h
	$(CXX) $(CXXFLAGS) $< -o $@

clean:
	$(RM) $(DEBUG_DIR)/*.o
	$(RM) $(RELEASE_DIR)/*.o
	$(RM) $(DEPDIR)/*.d
	$(ifneq $(strip $(PRECOMP_H)),)
		$(RM) $(PRECOMP_H).gch
	$(endif)

$(DEBUG_EXEC): $(subst $(SRC_DIR), $(DEBUG_DIR), $(OBJS))
	$(info $(OBJS))
	$(info $^)
	$(LD) $(LDFLAGS) $^ -o $@

$(RELEASE_EXEC): $(subst $(SRC_DIR), $(RELEASE_DIR), $(OBJS))
	$(LD) $(LDFLAGS) $^ -o $@

-include $(shell find $(DEPDIR) -name '*.d')

$(RELEASE_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

$(RELEASE_DIR)/%.o: $(SRC_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(DEBUG_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

$(DEBUG_DIR)/%.o: $(SRC_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(SRC_DIR)/%.h.gch: $(SRC_DIR)/%.h
	$(CXX) $(CXXFLAGS) $< -o $@

directories: $(DEBUG_DIR) $(RELEASE_DIR) $(DEPDIR)

$(DEBUG_DIR):
	mkdir -p $(DEBUG_DIR) 
	
$(RELEASE_DIR):
	mkdir -p $(RELEASE_DIR)

$(DEPDIR):
	mkdir -p $(DEPDIR)
