# 个人学习笔记
-------------------
## make&download
> 由于Exynos4412的启动原理和S5PV210的不同，虽然都有一个检验拷贝的16K代码较验和的过程，      
但是Exynos4412好像第一段程序是是一段叫BL1的程序，然后才能执行我们所写的程序，具体   
原理启动原理大家可以好好看一下Exynos4412手册的第5节启动原理说明。我想找到写BL1程序方法，    
但我从网上找不到Exynos4412的类似S5PV210的启动说明文档《S5PV210_iROM_ApplicationNote_Preliminary_20091126.pdf》，          
所以，我想uboot里面有一个sd_fuse的文件夹，是用来烧写U-boot程序到SD卡的。我想他可能可以工作，   
我拷贝了里面必要的文件到我们的裸机程序下，进行了必要的修改，发现其真的能运行，   
所以我们裸机程序不像Mini512S的是用write2sd脚本文件了。为了这个修改过的sd_fuse文件夹的程序，   
能在不同的裸机程序上运行，所以这里让我们裸机程序来匹配sd_fuse下的程序。  
这里写成arm-linux-objcopy -O binary led.elf u-boot.bin，让其生成的Bin文件名为u-boot。   
> 从三星提供的S5PV210文档《S5PV210_iROM_ApplicationNote_Preliminary_20091126.pdf》以及芯片手册   
《S5PV210_UM_REV1.1.pdf》得知，S5PV210启动时，会先运行内部IROM中的固化代码进行一些必要的初始化，   
执行完后硬件上会自动读取NAND Flash或sd卡等启动设备的前16K的数据到IRAM中，这16K数据中的前16byte   
中保存了一个叫校验和的值，拷贝数据时S5PV210会统计出待运行的bin文件中含‘1’的个数，然后和校验和做比较，   
如果相等则继续运行程序，否则停止运行。所以所有在S5PV210上运行的bin文件都必须具有一个16byte的头部   
该头部中需包含校验和信息。   
> Exynos4412的启动顺序和S5PV210的虽然不同，要先执行一个BL1.bin的文件，但其第二个BL2.bin的文件也是   
需要这个的校验和信息的，V310-EVT1-mkbl2.c作用就是用来给原始的bin文件添加较验和信息的，不过不同于   
S5PV210是在bin文件的状况，4412的是在这个14K的Bin文件尾部。V310-EVT1-mkbl2.c程序中虽然我做了必要    
修改，让其程序适应我们裸机程序，但其核心部分是没有变动的，程序主要内容也是别人写的，我也不做过多   
说明，如有需求，大家可以自己分析理解一下，如不想了解，直接应用就行。   
## 修改代码
 - V310-EVT1-mkbl2.c   
	mkbl2文件中需要修改，文件在读入过程中会进行判断，发现文件小于buff大小时，   
	会拒绝生成，需要将该限制解除，才可以生成裸机的代码.   
	1. 45行   
	增加部分：    
		``` c
			if(fileLen > (BufLen-4))  
			{      
				printf("Error: size over \n");   
				free(Buf);    
				fclose(fp);
				return -1;
			}
		```    
	注释部分：   
	~~if ( BufLen > fileLen )  
		{   
			printf("Usage: unsupported size\n");   
			free(Buf);   
			fclose(fp);  
			return -1;   
		}~~       
	2. 63行   
	注释部分：   
	~~if ( nbytes != BufLen )    
		{   
			printf("source file read error\n");   
			free(Buf);   
			fclose(fp);   
			return -1;   
		}~~	
 - sd_fusing.sh     
	裸机运行执行的BL2，所有后面的保护解除的程序可以直接不用写入SD卡中，  
	降低擦写时间，主要是裸机的程序会非常小的。   
	sd_fusing.sh注释部分：   
	~~\#\<u-boot fusing>   
	\# echo "---------------------------------------"   
	\# echo "u-boot fusing"   
	\# dd iflag=dsync oflag=dsync if=${E4412_UBOOT} of=$1 seek=$uboot_position   
	\# \#<TrustZone S/W fusing>    
	\# echo "---------------------------------------"    
	\# echo "TrustZone S/W fusing"   
	\# dd iflag=dsync oflag=dsync if=./E4412_tzsw.bin of=$1 seek=$tzsw_position~~	
 - fast_fuse.sh
	在已经通过sd_fusing.sh 处理过的SD卡可以直接使用fast_fuse.sh加载修改后的程序   
	fast_fuse.sh注释部分：   
	~~\#\<u-boot fusing>   
	\# echo "---------------------------------------"    
	\# echo "u-boot fusing"   
	\# dd iflag=dsync oflag=dsync if=${E4412_UBOOT} of=$1 seek=$uboot_position~~

## 控制 icache 的代码
	``` c
		// 控制 icache 的代码
		#ifdef CONFIG_SYS_ICACHE_OFF   
		bic r0, r0, #0x00001000          @ clear bit 12 (I) I-cache 
		#else 
		orr r0, r0, #0x00001000          @ set bit 12 (I) I-cache 
		#endif 
		mcr p15, 0, r0, c1, c0, 0 
	```

## data、text和bss
下面解释一下什么是 data、text、bss 段： 
1. data 段：数据段（datasegment）通常是指用来存放程序中已初始化的全局变量的一块内存区域。数据段属于静态内存分配。
2. text 段：代码段通常是指用来存放程序执行代码的一块内存区域。这部分区域的大小在程序运行前就已经确定，并且内存区域通常属于只读,某些架构也允许代码段为可写，即允许修改程序。在代码段中，也有可能包含一些只读的常数变量，例如字符串常量等。
3. bss 段：指用来存放程序中未初始化的全局变量的一块内存区域。BSS 是英文 BlockStarted by Symbol 的简称。当我们的程序有全局变量是，它是放在 bss 段的，由于全局变量默认初始值都是0，所有我们需要手动清 bss 段。    

## 混编指令
> 在汇编程序中我们会使用cmp指令进行判断，类似于流程框图中的选择判断框（菱形框），其后面可以跟bne和beq两种指令，具体看下边例子：
1. 例一:cmp同bne搭配
	``` c  
		cmp r1,r2  //这个cmp搭配下边的bne指令构成了如果r1≠r2则执行bne指令，跳转到copy_loop函数处执行。否则，就跳过下边
		bne copy_loop//的bne指令向下执行。
	``` 
2. 例二：cmp同beq搭配
	``` c  
		cmp r0,r1//如果r0=r1，就执行beq，跳转到clean_bss函数处执行，否则跳过beq向下执行。
		beq clean_bss
	```    
	总结：其实上边两句都是跳转指令，跳转到相关函数处执行。区别在于执行跳转的条件不同。
3. LDR 是一条伪指令。从内存中读取数据到寄存器,编译器会根据 立即数的大小，决定用 ldr 指令或者是mov或mvn指令。  
	LDR r, label  和 LDR r, =label的区别：    
	LDR r, =label 会把label表示的值加载到寄存器中，而LDR r, label会把label当做地址，把label指向的地址中的值加载到寄存器中。   
	譬如 label的值是 0x8000， LDR r, =label会将 0x8000加载到寄存器中，而LDR r, label则会将内存0x8000处的值加载到寄存器中。
4. STR指令用亍从源寄存器中将一个32位的字数据传送到存储器中。将寄存器中的数据存储到内存中,同ldr相同，其源地址和目的地址不同。   
5. ADR 和 ADRL 伪指令：   
	ADR 和 ADRL 伪指令用于将一个地址加载到寄存器中。    
	ADR为小范围的地址读取伪指令。ADR指令将基于PC相对偏移的地址值读取到寄存器中。在汇编编译源程序时，ADR伪指令被编译器替换在一条合适的指令，通常，编译器用一条ADD指令或SUB指令来实现该ADR伪指令的功能，若不能使用一条指令实现，则产生错误。其能加载的地址范围，当为字节对齐时，是-1020~1020，当为非字对齐时在-255~255之间。    
	ADRL是中等范围的地址读取指令。会被编译器翻译成两条指令。如果不能用两条指令表示，则产生错误。    
	ADRL能加载的地址范围当为非字节对齐时是-64K~64K之间；当为字节对齐时是-256K~256K之间。   



### 细节引入
堆,权限可读写，可执行，无映像文件，匿名，可向上扩展（即：堆的起始指针在最底部）
栈，权限可读写，不可执行，无映像文件，匿名，可向下扩展（即：栈的起始指针在最顶部）

### 记录命令			
	grep -nr "查找内容"

**Markdown　Extra**　表格语法：

项目     | 价格
-------- | ---
Computer | $1600
Phone    | $12
Pipe     | $1

可以使用冒号来定义对齐方式：

| 项目      |    价格 | 数量  |
| :-------- | --------:| :--: |
| Computer  | 1600 元 |  5   |
| Phone     |   12 元 |  12  |
| Pipe      |    1 元 | 234  |

## 删除线
~~Hello~~

---------







- 加粗    `Ctrl + B` 
- 斜体    `Ctrl + I` 
- 引用    `Ctrl + Q`
- 插入链接    `Ctrl + L`
- 插入代码    `Ctrl + K`
- 插入图片    `Ctrl + G`
- 提升标题    `Ctrl + H`
- 有序列表    `Ctrl + O`
- 无序列表    `Ctrl + U`
- 横线    `Ctrl + R`
- 撤销    `Ctrl + Z`
- 重做    `Ctrl + Y`