.globl _start

_start:
	// �رտ��Ź�
	ldr	r0, =0x10060000 
	mov	r1, #0
	str	r1, [r0]

    // ����GPM4CON��bit[0:15]������GGPM4CON_0/1/2/3����Ϊ�������
 	ldr r1, =0x110002E0
    ldr r0, =0x00001111
    str r0, [r1]

	
	mov r2, #0x1000
led_blink:
	// ���� GPM4DAT��bit[0:3]��ʹGPM4DAT_0/1/2/3��������͵�ƽ��LED��
	ldr r1, =0x110002E4
    mov r0, #0
    str r0, [r1]

    // ��ʱ
	mov r0, #0x100000
	bl delay

	// ����GPM4DAT��bit[0:3]��ʹGPM4DAT_0/1/2/3��������ߵ�ƽ��LED��
	ldr r1, =0x110002E4
    mov r0, #0xf
    str r0, [r1]
    
    // ��ʱ
	mov r0, #0x100000
	bl delay
	
    sub r2, r2, #1
	cmp r2, #0
	bne led_blink


halt:
	b halt



