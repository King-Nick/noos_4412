.globl _start

_start:
	// 关闭看门狗
	ldr	r0, =0x10060000 
	mov	r1, #0
	str	r1, [r0]

    // 设置GPM4CON的bit[0:15]，配置GGPM4CON_0/1/2/3引脚为输出功能
 	ldr r1, =0x110002E0
    ldr r0, =0x00001111
    str r0, [r1]

	
	mov r2, #0x1000
led_blink:
	// 设置 GPM4DAT的bit[0:3]，使GPM4DAT_0/1/2/3引脚输出低电平，LED亮
	ldr r1, =0x110002E4
    mov r0, #0
    str r0, [r1]

    // 延时
	mov r0, #0x100000
	bl delay

	// 设置GPM4DAT的bit[0:3]，使GPM4DAT_0/1/2/3引脚输出高电平，LED灭
	ldr r1, =0x110002E4
    mov r0, #0xf
    str r0, [r1]
    
    // 延时
	mov r0, #0x100000
	bl delay
	
    sub r2, r2, #1
	cmp r2, #0
	bne led_blink


halt:
	b halt




