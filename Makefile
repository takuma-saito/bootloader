# Makefile

ISO = os.iso
MK_ISO = mkisofs

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
START_MEM = 0x00100000

# Initial Process Loader, Boot Loader compile

$(IMG): ipl boot $(KERNEL)
	$(DD) if=/dev/zero of=$(IMG) bs=1024 count=1440
	cat ipl boot $(KERNEL) > bin
	$(DD) if=bin of=$(IMG) bs=1 conv=notrunc
	$(RM) bin

iso: $(IMG)
	$(MK_ISO) -r -b $(IMG) -c boot.catalog -o $(ISO) .
	$(RM) boot.img

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
	$(RM) boot ipl $(KERNEL) $(IMG) $(ISO)
	$(RM) *.o

