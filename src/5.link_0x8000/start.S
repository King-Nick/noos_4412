.global _start

_start:
	// 关闭看门狗
	ldr	r0, =0x10060000 			
	mov	r1, #0
	str	r1, [r0]

	// 设置栈，以便调用c函数
	ldr	sp, =0x02060000 					
			
										
	// 重定位						
	// _start当前所位于的地址：0x02020010
	adr r0, _start  		
	// _start的链接地址:0x02028000   看lds文件
	ldr r1, =_start 	
	// bss段的起始地址
	ldr r2, =bss_start
	// 如果r0 和 r1 相同不再执行复制操作 直接执行clean_bss 清除bss区 相当于复制完成了！
	cmp r0, r1			
	beq clean_bss
	
copy_loop:
	ldr r3, [r0], #4    // 源
	str r3, [r1], #4	// 目的
	cmp r1, r2
	bne copy_loop


	// 清bss段
clean_bss:
	//获得 bss 起始地址
	ldr r0, =bss_start					
	ldr r1, =bss_end
	//如果已经清除完成 标识bss 已经清空了 可以执行下一步
	cmp r0, r1
	beq run_on_dram
	//赋值 r2 为0
	mov r2, #0		
clear_loop:
	str r2, [r0], #4
	cmp r0, r1
	bne clear_loop


	// 跳转
run_on_dram:			 
	ldr pc, =main						


halt:
	b halt

