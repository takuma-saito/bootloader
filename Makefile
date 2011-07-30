# Makefile

ASM = nasm
ASMFLAG_BIN = -f bin
IMG = os.img
SIZE = 4096
DD = dd
KERNEL = kernel.bin

LD = i686-coff-ld
CC = i686-coff-gcc
OBJCOPY = i686-coff-objcopy
COPYFLAGS = -S -O binary
CFLAGS = -g -Wall
ASMFLAG_COFF = -f coff
START_NAME = kernel_main
START_MEM = 0x00010400 

# Initial Process Loader, Boot Loader compile

$(IMG): ipl boot $(KERNEL)
	$(DD) if=/dev/zero of=$(IMG) bs=1 count=$(SIZE)
	cat boot $(KERNEL) > bin
	$(DD) if=ipl of=$(IMG) bs=1 count=512 conv=notrunc
	$(DD) if=bin of=$(IMG) bs=1 seek=512 conv=notrunc
	$(RM) bin

ipl: ipl.asm
	$(ASM) $(ASMFLAG_BIN) ipl.asm

boot: boot.asm
	$(ASM) $(ASMFLAG_BIN) boot.asm

# C and Assembler compile

# func: func.asm
# 	$(ASM) $(ASMFLAG_BIN) func.asm

$(KERNEL): func.o kernel.o
	$(LD) -e $(START_NAME) -Ttext $(START_MEM) -o kernel func.o kernel.o
	$(OBJCOPY) $(COPYFLAGS) kernel $(KERNEL)
	$(RM) kernel

func.o: func.asm
	$(ASM) $(ASMFLAG_COFF) func.asm

kernel.o: kernel.c
	$(CC) $(CFLAGS) -c kernel.c

.PHONY: clean
clean:
	$(RM) boot ipl $(KERNEL) $(IMG)
	$(RM) *.o $(KERNEL)

