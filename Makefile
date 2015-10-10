# Based on Karl Lunt's Makefile for Windows.
# Simplified for Linux/Unix by Mike Ditto <ford@omnicron.com>
# Docker-based flashing added by Dan Gillespie <dan@dg.gg>

#########################################################################
# First, describe the cross-compilation environment:

TARGETTYPE = arm-none-eabi

#  Tools paths
CC = $(BINDIR)$(TARGETTYPE)-gcc
AS = $(BINDIR)$(TARGETTYPE)-as
AR = $(BINDIR)$(TARGETTYPE)-ar
LD = $(BINDIR)$(TARGETTYPE)-ld
OBJCOPY = $(BINDIR)$(TARGETTYPE)-objcopy
SIZE = $(BINDIR)$(TARGETTYPE)-size
OBJDUMP = $(BINDIR)$(TARGETTYPE)-objdump

#  Path to Teensy firmware/headers folder, e.g. Karl Lunt's Teensy3xlib.zip .
TEENSY_BASEPATH = /teensy

#  Compiler options
INCDIRS += -I$(TEENSY_BASEPATH)/include
CFLAGS = -mcpu=$(CPU) -mthumb $(OPTIMIZATION) $(DEBUG) $(INCDIRS)

#  Linker options
LSCRIPT = $(TEENSY_BASEPATH)/common/$(BOARD_TYPE).ld
SYSOBJECTS = \
    $(TEENSY_BASEPATH)/common/crt0.o \
    $(TEENSY_BASEPATH)/common/sysinit.o
LDFLAGS = -nostdlib -nostartfiles -Wl,-T$(LSCRIPT) $(SYSOBJECTS)
LDLIBS = -lgcc


#########################################################################
# Which board we are building for

BOARD_TYPE = Teensy31_flash
CPU = cortex-m4
MCU = mk20dx256
#BOARD_TYPE = TeensyLC_flash
#CPU = cortex-m0plus


#########################################################################
# Project details

PROJECT=./src/blinky

OPTIMIZATION = -O0
# CFLAGS += -Wall
# DEBUG = -g
# LDFLAGS += -Wl,-Map=$(PROJECT).map -Wl,--cref

.PHONY: build docker-build docker-flash
OBJECTS	= $(PROJECT).o

# Docker Image
IMAGE = "ethernetdan/teensy"
all: docker-build docker-flash

docker-flash:
	docker run -i -t --privileged \
		-v /dev/ttyS1:/dev/ttyS1 \
		$(IMAGE)

docker-build:
	docker build -t $(IMAGE) .

deploy: build
	teensy_loader_cli --mmcu=$(MCU) -w -v $(PROJECT).hex


build: $(PROJECT).hex $(PROJECT).bin stats dump

$(PROJECT).bin: $(PROJECT).elf
	$(OBJCOPY) -O binary -j .text -j .data $(PROJECT).elf $(PROJECT).bin

$(PROJECT).hex: $(PROJECT).elf
	$(OBJCOPY) -R .stack -O ihex $(PROJECT).elf $(PROJECT).hex

$(PROJECT).elf: $(SYSOBJECTS) $(OBJECTS)
	$(CC) $(LDFLAGS) -o $(PROJECT).elf $(OBJECTS) $(LDLIBS)

$(PROJECT).o: $(PROJECT).c
	$(CC) $(CFLAGS) -o "$@" -c "$<"

stats: $(PROJECT).elf
	$(SIZE) $(PROJECT).elf

dump: $(PROJECT).elf
	$(OBJDUMP) -h $(PROJECT).elf

clean:
	$(RM) $(OBJECTS)
	$(RM) $(PROJECT).hex $(PROJECT).elf $(PROJECT).map $(PROJECT).bin
