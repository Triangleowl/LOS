SRC_DIR := src
INCLUDE_DIR := include
BUILD_DIR := build
BOCHSRC_DIR := bochsrc

ENTRYPOINT := 0x10000

CFLAGS := -m32 -fno-builtin -nostdinc -fno-pic -fno-pie -nostdlib -fno-stack-protector
DEBUG := -g
INCLUDE := -I$(INCLUDE_DIR)

all: 	$(BUILD_DIR)/boot/boot.bin \
		$(BUILD_DIR)/boot/loader.bin \
		$(BUILD_DIR)/kernel/start.o \
		$(BUILD_DIR)/kernel/main.o \
		$(BUILD_DIR)/system.bin \
		$(BUILD_DIR)/system.map \
		$(BUILD_DIR)/master.img

$(BUILD_DIR)/boot/%.bin: $(SRC_DIR)/boot/%.asm
	$(shell mkdir -p $(dir $@))
	nasm -f bin $< -o $@

$(BUILD_DIR)/kernel/%.o: $(SRC_DIR)/kernel/%.asm
	$(shell mkdir -p $(dir $@))
	nasm -f elf32 $< -o $@

$(BUILD_DIR)/kernel/%.o: $(SRC_DIR)/kernel/%.c
	$(shell mkdir -p $(dir $@))
	gcc $(CFLAGS) $(DEBUG) $(INCLUDE) -c $< -o $@

$(BUILD_DIR)/kernel.bin: $(BUILD_DIR)/kernel/start.o $(BUILD_DIR)/kernel/main.o
	$(shell mkdir -p $(dir $@))
	ld -m elf_i386 -static $^ -o $@ -Ttext $(ENTRYPOINT)

$(BUILD_DIR)/system.bin: $(BUILD_DIR)/kernel.bin
	objcopy -O binary $< $@

$(BUILD_DIR)/system.map: $(BUILD_DIR)/kernel.bin
	nm $< | sort > $@


$(BUILD_DIR)/master.img: $(BUILD_DIR)/boot/boot.bin \
						$(BUILD_DIR)/boot/loader.bin \
						$(BUILD_DIR)/system.bin \
						$(BUILD_DIR)/system.map

	yes | bximage -q -hd=16 -func=create -sectsize=512 -imgmode=flat $@
	dd if=$(BUILD_DIR)/boot/boot.bin of=$@ bs=512 count=1 conv=notrunc
# the bs is 512 default
	dd if=$(BUILD_DIR)/boot/loader.bin of=$@ count=1 seek=1 conv=notrunc
	dd if=$(BUILD_DIR)/system.bin of=$@ count=200 seek=10 conv=notrunc

bochs: $(BOCHSRC_DIR)/bochsrc $(BUILD_DIR)/master.img
	$(shell rm -f $(BUILD_DIR)/master.img.lock)
	sudo bochs -f $< -q

.PHONY: clean
clean:
	rm -rf ./$(BUILD_DIR)
	rm -f bx_enh_dbg.ini

