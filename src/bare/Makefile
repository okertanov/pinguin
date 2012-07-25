
all:
	arm-linux-gnueabi-as -mcpu=arm926ej-s -g startup.s -o startup.o
	arm-linux-gnueabi-gcc -c -mcpu=arm926ej-s -g test.c -o test.o
	arm-linux-gnueabi-ld -T test.ld test.o startup.o -o test.elf
	arm-linux-gnueabi-objcopy -O binary test.elf test.bin

run:
	qemu-system-arm -M versatilepb -m 128M -nographic -kernel test.bin

