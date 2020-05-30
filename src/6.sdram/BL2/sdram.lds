SECTIONS
{
	. = 0x43E00000;
	.text : {
		start.o
		* (.text)
	}

	.bss : {
		* (.bss)
	}
	
	.data : {
		* (.data)
	}
}
