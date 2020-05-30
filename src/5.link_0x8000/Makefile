CC_PREFIX := arm-none-linux-gnueabi-

AS      := $(CC_PREFIX)as
CC      := $(CC_PREFIX)gcc
CPP     := $(CC_PREFIX)g++
LD      := $(CC_PREFIX)ld
NM      := $(CC_PREFIX)nm
AR      := $(CC_PREFIX)ar
OBJCOPY := $(CC_PREFIX)objcopy
OBJDUMP := $(CC_PREFIX)objdump
SIZE    := $(CC_PREFIX)size
STRIP   := $(CC_PREFIX)strip

link.bin: start.o main.o
	$(LD) -Tlink.lds -o link.elf $^
	$(OBJCOPY)  -O binary link.elf ../u-boot.bin
	$(OBJDUMP)  -D link.elf > link_elf.dis
	
%.o : %.S
	$(CC) -o $@ $< -c

%.o : %.c
	$(CC)-o $@ $< -c 

clean:
	rm *.o *.elf ../*.bin *.dis -f
