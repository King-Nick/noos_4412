#define 	GPM4CON 	(*(volatile unsigned long *) 0x110002E0)
#define 	GPM4DAT		(*(volatile unsigned long *) 0x110002E4)
// —” ±∫Ø ˝
void delay(int r0)					// —” ±
{
    volatile int count = r0;
    while (count--);
}

void led_blink()					// LED…¡À∏
{
	GPM4CON = 0x00001111;			// ≈‰÷√“˝Ω≈
	while(1)							
	{
		GPM4DAT = 0;				// LED on
		delay(0x200000);
		GPM4DAT = 0xf;				// LED off
		delay(0x200000);
	}
}
