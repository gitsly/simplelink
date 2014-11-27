#include <stdio.h>

int* test = (int*)0x400FF080;  // GPIOC_PDOR doc: K20P64M50SF0RM.pdf ( Pages: 1180, 1182 )

void quickSort( int[], int, int);
int partition( int[], int, int);

// Functions in assembly
extern void delay();
extern void led_on();
extern void led_off();

int main() 
{
	int a[] = { 7, 12, 1, -2, 0, 15, 4, 11, 9};

	quickSort( a, 0, 8);

	while (1)
	{
		led_on();
		delay();
		led_off();
		delay();
	}
}



void quickSort( int a[], int l, int r)
{
   int j;

   if( l < r ) 
   {
   	// divide and conquer
        j = partition( a, l, r);
       quickSort( a, l, j-1);
       quickSort( a, j+1, r);
   }
	
}



int partition( int a[], int l, int r) {
   int pivot, i, j, t;
   pivot = a[l];
   i = l; j = r+1;
		
   while( 1)
   {
   	do ++i; while( a[i] <= pivot && i <= r );
   	do --j; while( a[j] > pivot );
   	if( i >= j ) break;
   	t = a[i]; a[i] = a[j]; a[j] = t;
   }
   t = a[l]; a[l] = a[j]; a[j] = t;
   return j;
}







