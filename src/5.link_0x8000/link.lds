SECTIONS
{
	. = 0x02028000;
	
	.text : {
		start.o
		* (.text)
	}
    		
	.data : {
		* (.data)
	}
	
	bss_start = .; 
	.bss : {
		* (.bss)
	}
	
	bss_end  = .;	
}
