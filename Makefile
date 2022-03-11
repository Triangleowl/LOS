SRC_DIR := src
BIN_DIR := bin
BOCHSRC_DIR := bochsrc

all: $(BIN_DIR)/master.img $(BIN_DIR)/boot.bin $(BIN_DIR)/loader.bin

$(BIN_DIR)/master.img: $(BIN_DIR)/boot.bin $(BIN_DIR)/loader.bin
	yes | bximage -q -hd=16 -func=create -sectsize=512 -imgmode=flat $@
	dd if=$(BIN_DIR)/boot.bin of=$@ bs=512 count=1 conv=notrunc
# the bs is 512 default
	dd if=$(BIN_DIR)/loader.bin of=$@ count=1 seek=1 conv=notrunc

$(BIN_DIR)/boot.bin: $(SRC_DIR)/boot.asm
	mkdir $(BIN_DIR) >/dev/null
	nasm -f bin $< -o $@

$(BIN_DIR)/loader.bin: $(SRC_DIR)/loader.asm
	nasm -f bin $< -o $@

bochs: $(BOCHSRC_DIR)/bochsrc $(BIN_DIR)/master.img
	sudo bochs -f $< -q

.PHONY: clean
clean:
	rm -f $(BIN_DIR)/*
	rmdir $(BIN_DIR)
	rm -f bx_enh_dbg.ini

