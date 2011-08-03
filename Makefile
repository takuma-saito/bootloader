# Makefile

ISO = os.iso
MK_ISO = mkisofs

ASM = nasm
ASMFLAG_BIN = -f bin
IMG = os.img
SIZE = 4096
DD = dd
KERNEL = kernel.bin

B_SRCS = ipl.asm boot.asm
BINS = $(B_SRCS:.asm=.bin) $(KERNEL)

LD = i686-coff-ld
CC = i686-coff-gcc
OBJCOPY = i686-coff-objcopy
COPYFLAGS = -S -O binary
CFLAGS = -g -Wall
ASMFLAG_COFF = -f coff
START_NAME = kernel_main
#START_MEM = 0x00100000
C_SRCS = kernel.c # segment.c
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
#	$(LD) -e $(START_NAME) -Ttext $(START_MEM) -o $(KERNEL) func.o $(C_OBJS)
	$(LD) -e $(START_NAME) -o $(KERNEL) func.o $(C_OBJS)
	$(OBJCOPY) $(COPYFLAGS) kernel $(KERNEL)
#	$(RM) kernel

func.o: func.asm
	$(ASM) -o $@ $(ASMFLAG_COFF) $<

.c.o:
	$(CC) $(CFLAGS) -o $@ -c $<

# Debug function
# func: func.asm
# 	$(ASM) $(ASMFLAG_BIN) func.asm

##################################
# Clean Objects and Binary File  #
##################################

.PHONY: clean
clean:
	$(RM) $(C_OBJS)
	$(RM) *.o *.bin
	$(RM) $(KERNEL) $(IMG) $(ISO)

