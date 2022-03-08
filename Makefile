SRC_DIR := src
BIN_DIR := bin
BOCHSRC_DIR := bochsrc

all: $(BIN_DIR)/master.img $(BIN_DIR)/boot.bin

$(BIN_DIR)/master.img: $(BIN_DIR)/boot.bin
	yes | bximage -q -hd=16 -func=create -sectsize=512 -imgmode=flat $@
	dd if=$< of=$@ bs=512 count=1 conv=notrunc

$(BIN_DIR)/boot.bin: $(SRC_DIR)/boot.asm
	mkdir $(BIN_DIR)
	nasm -f bin $< -o $@

bochs: $(BOCHSRC_DIR)/bochsrc $(BIN_DIR)/master.img
	sudo bochs -f $< -q

.PHONY: clean
clean:
	rm -f $(BIN_DIR)/master.img.lock
	rm $(BIN_DIR)/*
	rmdir $(BIN_DIR)
	rm -f bx_enh_dbg.ini