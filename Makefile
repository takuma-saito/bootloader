# Makefile

ARC = i686-elf
ADDNAME += $(ARC)-

ISO = os.iso
MK_ISO = mkisofs

ASM = nasm
ASMFLAG_BIN = -f bin
IMG = os.img
SIZE = 4096
DD = dd
KERNEL = kernel.bin
#KERNEL = func.bin

B_SRCS = ipl.asm boot.asm
BINS = $(B_SRCS:.asm=.bin) $(KERNEL)

LD = $(ADDNAME)ld
CC = $(ADDNAME)gcc
OBJCOPY = $(ADDNAME)objcopy
COPYFLAGS = -S -O binary
CFLAGS = -g -Wall
LDFLAGS = -static -T ldscript.x
ASMFLAG_COFF = -f coff
C_SRCS = kernel.c segment.c interrupt.c
C_OBJS = $(C_SRCS:.c=.o)

# Initial Process Loader, Boot Loader compile

# サフィックスルール
.SUFFIXES: .c .o .bin .asm

#####################
# Create BOOT IMAGE #
#####################

$(IMG): $(BINS)
	$(DD) if=/dev/zero of=$(IMG) bs=1024 count=1440
	cat $(BINS) > bin
	$(DD) if=bin of=$(IMG) bs=256 conv=notrunc
	$(RM) bin

iso: $(IMG)
	$(MK_ISO) -r -b $(IMG) -c boot.catalog -o $(ISO) .

.asm.bin:
	$(ASM) -o $@ $(ASMFLAG_BIN) $<


###############################
# Compile C and Assembly File #
###############################

$(KERNEL): func.o $(C_OBJS)
	$(LD) $(LDFLAGS) -o kernel $(C_OBJS) func.o
	$(OBJCOPY) $(COPYFLAGS) kernel $(KERNEL)
	$(RM) kernel

func.o: func.asm
	$(ASM) -o $@ $(ASMFLAG_COFF) $<

.c.o:
	$(CC) $(CFLAGS) -o $@ -c $<

# Debug function
# func.bin: func.asm
# 	$(ASM) -o $@ $(ASMFLAG_COFF) $<
# 	$(LD) $(LDFLAGS) -o kernel $@
# 	$(OBJCOPY) $(COPYFLAGS) kernel $@

##################################
# Clean Objects and Binary File  #
##################################

.PHONY: clean
clean:
	$(RM) $(C_OBJS)
	$(RM) *.o *.bin kernel
	$(RM) $(KERNEL) $(IMG) $(ISO)

