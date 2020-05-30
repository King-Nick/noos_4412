.global _start

_start:
	// �رտ��Ź�
	ldr	r0, =0x10060000 			
	mov	r1, #0
	str	r1, [r0]

	// ����ջ���Ա����c����
	ldr	sp, =0x02060000 					
			
										
	// �ض�λ						
	// _start��ǰ��λ�ڵĵ�ַ��0x02020010
	adr r0, _start  		
	// _start�����ӵ�ַ:0x02028000   ��lds�ļ�
	ldr r1, =_start 	
	// bss�ε���ʼ��ַ
	ldr r2, =bss_start
	// ���r0 �� r1 ��ͬ����ִ�и��Ʋ��� ֱ��ִ��clean_bss ���bss�� �൱�ڸ�������ˣ�
	cmp r0, r1			
	beq clean_bss
	
copy_loop:
	ldr r3, [r0], #4    // Դ
	str r3, [r1], #4	// Ŀ��
	cmp r1, r2
	bne copy_loop


	// ��bss��
clean_bss:
	//��� bss ��ʼ��ַ
	ldr r0, =bss_start					
	ldr r1, =bss_end
	//����Ѿ������� ��ʶbss �Ѿ������ ����ִ����һ��
	cmp r0, r1
	beq run_on_dram
	//��ֵ r2 Ϊ0
	mov r2, #0		
clear_loop:
	str r2, [r0], #4
	cmp r0, r1
	bne clear_loop


	// ��ת
run_on_dram:			 
	ldr pc, =main						


halt:
	b halt
