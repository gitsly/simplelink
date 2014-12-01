TARGET ?= ledblink
DEBUG ?=

ROOT= $(dir $(lastword $(MAKEFILE_LIST)))
SRC_DIR= $(ROOT)
OBJECT_DIR= $(ROOT)/obj
BIN_DIR= $(ROOT)/bin

# Source files common to all targets
SRC	 = main.c \
			 startup.s \
			 
.PRECIOUS: %.s

# Tool names
CC		 = arm-none-eabi-gcc
OBJCOPY		 = arm-none-eabi-objcopy

#
# Tool options.
#
INCLUDE_DIRS	 = $(SRC_DIR)

ARCH_FLAGS	 = -mthumb -mcpu=cortex-m4

ifeq ($(DEBUG),GDB)
OPTIMIZE	 = -O0
LTO_FLAGS	 = $(OPTIMIZE)
else
OPTIMIZE	 = -Os
LTO_FLAGS	 = -flto -fuse-linker-plugin $(OPTIMIZE)
endif

DEBUG_FLAGS	 = -ggdb3

CFLAGS		 = $(ARCH_FLAGS) \
			 $(LTO_FLAGS) \
			 $(addprefix -D,$(OPTIONS)) \
			 $(addprefix -I,$(INCLUDE_DIRS)) \
			 $(DEBUG_FLAGS) \
			 -std=gnu99 \
			 -Wall -pedantic -Wextra -Wshadow -Wunsafe-loop-optimizations \
			 -D$(TARGET)
# these will make each function go into a separately named section for
# optimization reasons. makes the linker script harder to write =).
			 # -ffunction-sections \
			 # -fdata-sections \

ASFLAGS		 = $(ARCH_FLAGS) \
						 -g						 \
			 $(addprefix -I,$(INCLUDE_DIRS))

LD_SCRIPT	 = $(ROOT)/linker.ld
# arm-linux-gnueabi-ld -T linker.ld -o crt0.elf crt0.o
LDFLAGS		 = -lm \
						 -nostartfiles \
						 --specs=nano.specs \
						 -lc \
						 $(ARCH_FLAGS) \
						 $(LTO_FLAGS) \
						 $(DEBUG_FLAGS) \
						 -static \
						 -Wl,-gc-sections,-Map,$(TARGET_MAP) \
						 -T$(LD_SCRIPT)

# Build targets
#

TARGET_HEX	 = $(BIN_DIR)/$(TARGET).hex
TARGET_ELF	 = $(BIN_DIR)/$(TARGET).elf
TARGET_OBJS	 = $(addsuffix .o,$(addprefix $(OBJECT_DIR)/$(TARGET)/,$(basename $(SRC))))
TARGET_MAP   = $(OBJECT_DIR)/$(TARGET).map

$(TARGET_HEX): $(TARGET_ELF)
	$(OBJCOPY) -O ihex --set-start 0x00000000 $< $@

$(TARGET_ELF):  $(TARGET_OBJS)
	@echo $(TARGET_OBJS)
	$(CC) -o $@ $^ $(LDFLAGS)

# Compile
$(OBJECT_DIR)/$(TARGET)/%.o: %.c
	@mkdir -p $(dir $@)
	@echo %% $(notdir $<)
	@$(CC) -c -o $@ $(CFLAGS) $<

# Assemble
$(OBJECT_DIR)/$(TARGET)/%.o: %.s
	@mkdir -p $(dir $@)
	@echo %% $(notdir $<)
	@$(CC) -c -o $@ $(ASFLAGS) $< 
$(OBJECT_DIR)/$(TARGET)/%.o): %.S
	@mkdir -p $(dir $@)
	@echo %% $(notdir $<)
	@$(CC) -c -o $@ $(ASFLAGS) $< 

clean:
	rm -f $(TARGET_HEX) $(TARGET_ELF) $(TARGET_OBJS) $(TARGET_MAP)
