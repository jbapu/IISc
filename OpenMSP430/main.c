#include "omsp_system.h"
#include<stdio.h>
#include<stdlib.h>
#include<inttypes.h>

volatile uint16_t* adc_port = (volatile uint16_t*)(0x20A);	

int main(void) {

    WDTCTL = WDTPW | WDTHOLD;          // Disable watchdog timer
	
	P1DIR |= 0x01; 					// Set P1.0 to output direction
	P1OUT &= ~0x01; 			     	// Set the red LED on
	eint();


	while(1)
	{
		TACCR0 = 2;					// Count limit (16 bit)

		TACCTL0 = 0x10;					// Enable counter interrupts, bit 4=1

		TACTL = TASSEL_1 + MC_1; 			// Timer A 0 with ACLK @ 12KHz, count UP
	}	


return 0;
    
}

   interrupt(TIMERA0_VECTOR) timer0_isr(void) {		// Timer0 A0 interrupt service routine

	P1OUT = *adc_port;
	adc_port++;
		

}
