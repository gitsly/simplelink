#include <stdio.h>

// Functions in assembly
extern void delay();
extern void led_on();
extern void led_off();

int main() 
{
	while (1)
	{
		led_on();
		delay();

		led_off();
		delay();
		delay();
		delay();
		delay();
		delay();
		delay();
		delay();
		delay();
	}
	return 0;
}
