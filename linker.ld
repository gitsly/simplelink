/*
 * Simple linker script information:
 * https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/4/html/Using_ld_the_GNU_Linker/simple-example.html
 * http://www.lurklurk.org/linkers/linkers.html (Beginners guide)
 * try use the 'arm-none-eabi-nm main.o'
 *
 * http://www.math.utah.edu/docs/info/ld_3.html (good)
 * 
 * Utility to monitor .o files:
 *    arm-none-eabi-nm
 * Description of output:
 * U: A class of U indicates an undefined reference, one of the "blanks" mentioned
 *    previously. For this object, there are two: "fn_a" and "z_global". (Some
 *    versions of nm may also print out a section, which will be *UND* or UNDEF in
 *    this case)
 *
 * T: A class of t or T indicates where code is defined; the different
 *    classes indicate whether the function is local to this file (t) or not
 *    (T)—i.e. whether the function was originally declared with static. Again,
 *    some systems may also show a section, something like .text
 * 
 * D: A class of d or D indicates an initialized global variable, and again the
 *    particular class indicates whether the variable is local (d) or not (D).
 *    If there's a section, it will be something like .data For an uninitialized
 *    global variable, we get b if it's static/local, and B or C when it's not.
 *    The section in this case will probably be something like .bss or *COM*.
 */
OUTPUT_FORMAT("elf32-littlearm", "elf32-littlearm", "elf32-littlearm")
OUTPUT_ARCH(arm)
ENTRY(_start)

EXTERN(_vectors);

MEMORY
{
    FLASH (rx) : ORIGIN = 0x00000000, LENGTH = 512K
    SRAM (W!RX) : ORIGIN = 0x20000000, LENGTH = 64K
}

SECTIONS 
{
	.text :
	{
    . = ALIGN(4);
		CREATE_OBJECT_SYMBOLS
		_vectors = .;
		KEEP(*(.vectors))
		KEEP(*(.startup))
		KEEP(*(.text))
		KEEP(*(.text.*))

    KEEP (*(.init))

	} > FLASH
  
  /* Initialized data sections goes into RAM, load LMA copy after code */
  .data : 
  {
    . = ALIGN(4);
    _sdata = .;        /* create a global symbol at data start */
    *(.data)           /* .data sections */
    *(.data*)          /* .data* sections */

    . = ALIGN(4);
    _edata = .;        /* define a global symbol at data end */
  } >SRAM AT> FLASH

  /* Uninitialized data section */
  . = ALIGN(4);
  .bss :
  {
    /* This is used by the startup in order to initialize the .bss secion */
    _sbss = .;         /* define a global symbol at bss start */
    __bss_start__ = _sbss;
    *(.bss)
    *(.bss*)
    *(COMMON)

    . = ALIGN(4);
    _ebss = .;         /* define a global symbol at bss end */
    __bss_end__ = _ebss;
  } >SRAM
}
