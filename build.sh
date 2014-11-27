#!/bin/bash
. clean.sh
arm-none-eabi-as -g -mthumb -mcpu=cortex-m4 -o startup.o startup.s
arm-none-eabi-gcc -mthumb -mcpu=cortex-m4 -c -std=gnu99 -Os -flto -fuse-linker-plugin -o main.o main.c
arm-none-eabi-ld -T linker.ld -o test.elf startup.o main.o
arm-none-eabi-objcopy -O ihex -R .eeprom test.elf test.hex
#arm-none-eabi-objcopy -O binary -R .eeprom crt0.elf crt0.bin
