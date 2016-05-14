SILENT=

AS    = $(SILENT)sjasm.exe -S
CC    = $(SILENT)gcc

RM    = $(SILENT)-rm -f
CP    = $(SILENT)-cp
MKDIR = $(SILENT)-mkdir
ECHO  = @echo
# Need to be Pletter v0.4a
PACK  = pletter.exe 0

.PHONY: all

all: snow

snow: $(PAD)
	$(MKDIR) release
	$(ECHO) Compiling Game
	$(AS) game.asm
	$(ECHO) Compiling Loader
	$(PACK) game.bin
	$(AS) loader.asm
	$(CP) maze.bin release/maze.bin
	$(AS) romloader.asm
	$(CP) maze.rom release/maze.rom
    	
clean:
	$(ECHO) Cleaning intermediate files
	$(RM) *.bin *.out
