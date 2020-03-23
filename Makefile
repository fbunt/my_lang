EXE := parser
SRC_DIR := src
FB_SRCS := $(SRC_DIR)/parser.cpp $(SRC_DIR)/tokens.cpp
BHDR := $(SRC_DIR)/parser.hpp
OBJ_DIR := obj
OBJS := $(OBJ_DIR)/parser.o  $(OBJ_DIR)/tokens.o $(OBJ_DIR)/ast.o

CC := $(shell ./scripts/get_compiler.sh)
CFLAGS := -O3 -std=c++11
LDLIBS := -l$(shell ./scripts/get_flex_lib.sh)

.PHONY: all clean

all: $(EXE)

$(EXE): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) $(LDLIBS) -o $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp | $(OBJ_DIR)
	$(CC) -c $(CFLAGS) -o $@ $<

$(SRC_DIR)/parser.cpp: $(SRC_DIR)/parser.y
	bison -d -o $@ $^

$(SRC_DIR)/tokens.cpp: $(SRC_DIR)/tokens.l
	flex -o $@ $^

$(OBJ_DIR):
	mkdir $@

clean:
	rm -rf $(FB_SRCS) $(BHDR) $(EXE) $(OBJ_DIR)/*.o
