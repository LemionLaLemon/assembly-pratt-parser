TARGET := calcengine
OBJDIR := obj
SOURCES := $(wildcard src/*.asm)
OBJECTS := $(patsubst src/%.asm,$(OBJDIR)/%.o,$(SOURCES))

.PHONY: all build clean run debug

all: build

build: $(TARGET)

$(TARGET): $(OBJECTS)
	ld -o $@ $^ -lc -dynamic-linker /lib64/ld-linux-x86-64.so.2

$(OBJDIR)/%.o: src/%.asm | $(OBJDIR)
	nasm -felf64 -g -F dwarf -o $@ $<

$(OBJDIR):
	mkdir -p $@

clean:
	rm -rf $(OBJDIR) $(TARGET)

run: build
	./$(TARGET)

debug: build
	gdb ./$(TARGET)
