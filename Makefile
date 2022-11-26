TARGET := blink
# debug build?Release
BUILD_TYPE = Debug
BUILD_DIR:= build

TRIPLE  = 	arm-none-eabi
CC 		=	${TRIPLE}-gcc
LD 		= 	${TRIPLE}-ld
AS 		= 	${TRIPLE}-as
GDB 	= 	${TRIPLE}-gdb
OBJCOPY =  	${TRIPLE}-objcopy

INCFLAGS 	:= -Iinclude
CFLAGS 		:= -mcpu=cortex-m3 -mfloat-abi=soft -mthumb  --specs=nano.specs $(INCFLAGS) -std=gnu11 -Os -Wall -fstack-usage  -fdata-sections -ffunction-sections -DSTM32F103xB
ASFLAGS 	:= -mcpu=cortex-m3 -mfloat-abi=soft -mthumb --specs=nano.specs $(INCFLAGS) -x assembler-with-cpp
LDFLAGS 	:= -mcpu=cortex-m3 -mfloat-abi=soft -mthumb --specs=nosys.specs $(INCFLAGS)

# add debug flags if build type is debug
ifeq ($(BUILD_TYPE), Debug)
CFLAGS += -g -gdwarf-2
endif

# Generate dependency information
CFLAGS += -MMD -MP 
ASLAGS += -MMD -MP 

SRC_DIR := src
SRCS := $(shell find $(SRC_DIR) -name '*.c')
OBJS := $(BUILD_DIR)/$(SRC_DIR)/startup_stm32f103c8tx.o $(SRCS:%.c=$(BUILD_DIR)/%.o) 

$(BUILD_DIR)/$(TARGET).bin: $(BUILD_DIR)/$(TARGET).elf
	$(OBJCOPY) -R .stack -O binary $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).bin

$(BUILD_DIR)/$(TARGET).elf: $(OBJS) STM32F103C8TX_FLASH.ld
	$(CC) $(LDFLAGS) -o $@ $(OBJS) -T"STM32F103C8TX_FLASH.ld" -Wl,-Map="$(BUILD_DIR)/$(TARGET).map" -Wl,--gc-sections -static -Wl,--start-group -lc -lm -Wl,--end-group

$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) -c $< -o $@
	@echo "CC " $< " ==> " $@

$(BUILD_DIR)/%.o: %.s
	@mkdir -p $(dir $@)
	@$(CC) $(ASFLAGS) -c $< -o $@
	@echo "AS " $< " ==> " $@

flash:
	st-flash write $(BUILD_DIR)/$(TARGET).bin 0x8000000

all: $(BUILD_DIR)/$(TARGET).bin

clean:
	rm -rf $(BUILD_DIR)
