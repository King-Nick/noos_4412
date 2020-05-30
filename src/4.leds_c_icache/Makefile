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

led_icache.bin: start.o led.o
	$(LD) -Ttext 0x0 -o led_icache.elf $^
	$(OBJCOPY)  -O binary led_icache.elf ../u-boot.bin
	$(OBJDUMP)  -D led_icache.elf > led_icache_elf.dis
	
%.o : %.S
	$(CC) -o $@ $< -c

%.o : %.c
	$(CC)-o $@ $< -c 

clean:
	rm *.o *.elf ../*.bin *.dis -f
