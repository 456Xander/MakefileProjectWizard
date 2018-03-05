.PHONY: all clean debug release
#Name of the Executable file
EXEC_NAME := create-proj
SRC_DIR := ./src
DEBUG_DIR := ./Debug
RELEASE_DIR := ./Release
OUT_DIR = .

DEBUG_EXEC := $(DEBUG_DIR)/$(EXEC_NAME)
RELEASE_EXEC := $(RELEASE_DIR)/$(EXEC_NAME)

SRC := $(shell find $(SRC_DIR) -name '*.c' -o -name '*.cpp')
OBJS := $(filter %.o, $(SRC:.c=.o) $(SRC:.cpp=.o))
OBJS_T = $(subst $(SRC_DIR), $(OUT_DIR), $(OBJS))

SRC_CPP := $(filter %.cpp, $(SRC))

LN := ln -sf
RM := rm -rf
CC := gcc
CXX := g++

ifeq ($(SRC_CPP),)
	LD := $(CC)
else
	#Build everything with g++, just to be safe
	CC := $(CXX)
	LD := $(CXX)
endif

CFLAGS := -Wall -Wextra 
CXXFLAGS := $(CFLAGS) -std=c++14
CFLAGS += -std=c11
all: directories release

debug: CFLAGS += -O0 -ggdb
debug: CXXFLAGS += -O0 -ggdb
debug: $(DEBUG_EXEC)
	$(LN) $< ./$(EXEC_NAME)

release: CFLAGS += -O2
release: CXXFLAGSX += -O2
release: $(RELEASE_EXEC)
	$(LN) $< ./$(EXEC_NAME)

clean:
	$(RM) $(DEBUG_DIR)/*.o
	$(RM) $(RELEASE_DIR)/*.o

$(DEBUG_EXEC): $(subst $(SRC_DIR), $(DEBUG_DIR), $(OBJS))
	$(LD) $^ -o $@

$(RELEASE_EXEC): $(subst $(SRC_DIR), $(RELEASE_DIR), $(OBJS))
	$(LD) $^ -o $@

$(RELEASE_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

$(RELEASE_DIR)/%.o: $(SRC_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(DEBUG_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

$(DEBUG_DIR)/%.o: $(SRC_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

directories: $(DEBUG_DIR) $(RELEASE_DIR)

$(DEBUG_DIR):
	mkdir -p $(DEBUG_DIR)
	
$(RELEASE_DIR):
	mkdir -p $(RELEASE_DIR)
