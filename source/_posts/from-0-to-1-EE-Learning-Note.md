---
title: 从零开始的电子学习之路
date: 2022-12-08 20:53:14
tags: 
- 嵌入式
- 硬件
---

## 前言

对于0并无正负之分，之前我都对电子一无所知，因此也谈不上感兴趣与否。自这学期的电分模电开始才第一次对EE有了印象，感觉还蛮有意思。

十月份某日，*Java老师提到他的网站是跑在作为服务器的树莓派上的*，说者无心听者有意，我那时不知道脑子怎么一抽，对树莓派突然来了兴趣。那时我在写[基于原生JavaWeb+Mybatis+Vue+ElementUI的文件管理系统](https://github.com/Kizureina/java_web_file_manger)，让我想到一个非常有意思的想法，如果有足够稳定的内网穿透服务，实现的效果会比组NAS更好而成本也低得多。在花了一点功夫之后，我成功用裸板149r的orangepi几乎完美实现了上述功能，具体细节参见上篇[Blog](/2022/11/18/Java-web-file-manger-cloud-online/)。

玩过orangePi之后，对它几十个GPIO接口自然也有了兴趣，渐渐也对更底层的东西感到好奇。刚好那时学校里的电子爱好者协会在招新培训，再加上游园会上又在ICEC的摊子上焊接过双闪灯，经过一阵子的纠结，还是决定报名去参加了。

写到这里，想起来去年这时候也去参加安全相关实验室的培训了，果然我多半是个一事无成的人，发现有趣的事就忍不住去做。回想过去自己也一直是随性而为，不过我是不会后悔的，无论结果如何，都决不后悔自己经过思考作出的决定。我只要能够做感兴趣的事，能够思考就已经很幸福了。

## 硬件

### 电容

1. 降压

   利用电容的**容抗**实现降压电路，容抗公式计算如下：

   ![image-20221222203138900](https://files.catbox.moe/xxgq9i.png)

   但如果电容很大时，可能在电源断开后电容放电导致烧毁元件，因此需要根据容抗计算出并联电阻加在电容旁。

   那么为什么不用电阻直接分压？**电阻分压需要做功，且要发热，电容为无用功率**。

2. 滤波

   滤波实际上也是利用容抗，即电容的*通高频阻低频*。

   例如高通滤波器：

   ![img](https://files.catbox.moe/fju1iw.png)

3. 延时

   电容两边的电压不能突变，电容充电可实现演示。

4. 耦合

   同样是通高阻低

5. 旁路

   ![img1](https://files.catbox.moe/1hop0k.png)

   在芯片旁接一个旁路电容，可使芯片免受高频信号干扰。

### 三极管

可作为小电流控制大电流的电气开关，也可作为放大器。

### 运算放大器

虚短+虚短可完成几乎所有计算。

### IC芯片

仔细读芯片手册，研究每个引脚的作用即可。

### 实例1：双闪灯电路

![img3](https://files.catbox.moe/u1uu3z.png)

利用两个三极管性质不可能完全相同，以及电容两侧电压不能突变，实现固定频率的双闪灯，如此简单的电路就实现震荡，实在很有意思。

### 实例2：循迹小车循迹模块

本以为是通过摄像头加图像处理实现的，结果非常非常简单的硬件模块就能完成：利用几个红外发射管与红外接收管实现的，不同颜色地面反射的红外线量不同，通过这种差别实现循迹。

![img4](https://files.catbox.moe/4fzk5u.png)

根据接收管通断位置判断循迹的线位置，再用PWM波控制左轮或者右轮转速实现差速控制，就能完成转向和循迹。

## 嵌入式软件

对STM32单片机，最高效的开发环境为CubeMX + Keil5。

### 外部中断

检测外部按键需要用到上拉电阻或者下拉电阻，实现稳定的电平检测：

![img](https://files.catbox.moe/419yhs.png)

读取外部按键，调用相应的回调函数实现外部中断：

```c
void HAL_GPIO_EXTI_Falling_Callback(uint16_t GPIO_Pin)
{
	if (GPIO_Pin == KEY_Pin){
		model = 1;
	}
	if (GPIO_Pin == KEY_RESET_Pin){
		HAL_Delay(50);
		model = 2;	
	}
	if (GPIO_Pin == SWITCH_VIDEO_Pin){
		model = 3;
	}
}
```

实际上是覆盖了弱定义的HAL库函数。

计算机读取外部硬件信号都是使用外部中断的形式，但一个中断需要占用一个GPIO口，而GPIO口是有限资源，对于键盘这种需要大量中断的外设怎么办呢？答案是**矩阵扫描**

![img6](https://files.catbox.moe/ghbtvy.png)

但这种扫描会造成鬼影之类的问题，因此实际是通过非常快的翻转row和column电平实现读取的，顺带一提，手机屏幕获取触屏位置也是类似的原理。

### 定时器

定时器实际上就是周期执行任务，具体频率需要经过仔细计算：

![](https://files.catbox.moe/ekltrp.png)

定时器的输入时钟频率，计算定时器Prc（Prescaler 预分频值）与Arr（AutoReload Register 自动重装载值）。我们默认将单片机主频率设置为64MHz，通过查看STM32G070RB芯片的数 据手册，可确定所使用时钟TIM7挂载在APB（Advanced Peripheral Bus[低速总线]）总线上，因此其输 入时钟频率与APB总线上的频率一致,通过查看时钟树，可确定其输入时钟频率为64Mhz。

例如周期为1s时，主频律64Mhz，则取Psc = 6399, Arr = 9999。

中断开启定时器：

```c
 HAL_TIM_Base_Start_IT(&htim7);
```



同样需要重写弱函数：

```c
void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim){
	 if(htim == &htim7){
		if (counter <= 100){
			counter++;
			if (counter <= pwmrate){
				HAL_GPIO_WritePin(GPIOB, LED_TEST_Pin, GPIO_PIN_SET);
			}else{
				HAL_GPIO_WritePin(GPIOB, LED_TEST_Pin, GPIO_PIN_RESET);
			}
		}else{
			counter = 0;
		}
	}
}
```

定时器通常用于输出PWM波。

### PWM波

脉冲宽度调制(PWM)，是英文“Pulse Width Modulation”的缩写，简称脉宽调制，是利用微处理器的数字输出来对模拟电路进行控制的一种非常有效的技术。简单一点，就是对脉冲宽度的控制。STM32 的定时器除了 TIM6 和 7。其他的定时器都可以用来产生 PWM 输出。其中高级定时器 TIM1 和 TIM8 可以同时产生多达 7 路的 PWM 输出。而通用定时器也能同时产生多达 4路的 PWM 输出，这样，STM32 最多可以同时产生 30 路 PWM 输出！

![img](https://files.catbox.moe/k8lp0r.png)

利用PWM的频率和占空比可实现输出变化的电平——实际上是非常快速的改变占空比。

```c
while
{
		/*软件PWM实现控制蜂鸣器响度*/
		/* 当pwmrate即占空比小于100，且sw为0时，占空比逐渐增加，直至100 */
		if (pwmrate < 100 && sw == 0)
		{
			pwmrate++;
		}
		/* 当pwmrate即占空比大于或等于100时，sw置为1 */
		else
		{
			sw = 1;
		}
		/* 当pwmrate即占空比大于20，且sw为1时，占空比逐渐减小，直至20 */
		if (pwmrate > 30 && sw == 1)
		pwmrate--;
		/* 当pwmrate即占空比小于或等于20时，sw置0 */
		else
		sw = 0;
		/* 延时20ms，使现象可以被人观测到 */
		HAL_Delay(10);
}
```

与上面的定时器合用可实现呼吸灯或蜂鸣器响度随时间周期性变化。

另外也可用于控制[舵机](https://blog.csdn.net/weixin_44234294/article/details/114173000)，当然直接用32自带的PWM通道也可以。

### 串口通信

即UART协议通信，是最常用的单片机通信协议。

实际上就是通过约定的一串高低电平实现通信，例如UART就是八位，其中首位是通信标志位，当首位由低电平转为高电平时通信结束，这之间就是传输的数据。

一般通信需要用RX接TX，TX接RX完成。

软件层的通信定义与以中断模式开启UART（也可用DMA模式开启）:

```c
#define RXBUFFERSIZE  256     //最大接收字节数
char RxBuffer[RXBUFFERSIZE];   //接收数据
uint8_t aRxBuffer;            //接收中断缓冲
uint8_t Uart1_Rx_Cnt = 0;        //接收缓冲计数
char ch[8][8] = {"a", "b", "S", "D","N"};//自己定义
HAL_UART_Receive_IT(&huart2, (uint8_t *)&aRxBuffer, 1);
```

回调函数如下：

```c
void HAL_UART_RxCpltCallback(UART_HandleTypeDef *huart)
{

    UNUSED(huart);
    if(Uart1_Rx_Cnt >= 255)  //溢出判断
    {
        Uart1_Rx_Cnt = 0;
        memset(RxBuffer,0x00,sizeof(RxBuffer));
        HAL_UART_Transmit(&huart2, (uint8_t *)"数据溢出", 10,0xFFFF);     

    }
    else
    {
        RxBuffer[Uart1_Rx_Cnt++] = aRxBuffer;   //接收数据转存

        if((RxBuffer[Uart1_Rx_Cnt-1] == '!')&&(RxBuffer[Uart1_Rx_Cnt-2] == '!')) //判断结束位
        {
            RxBuffer[Uart1_Rx_Cnt-1] = '\0';
            RxBuffer[Uart1_Rx_Cnt-2] = '\0';
            if (strstr((const char*)RxBuffer,ch[0]))
            {
                printf("a ok!!!!\r\n");
				//HAL_GPIO_WritePin(GPIOC, LED_TEST_Pin, GPIO_PIN_SET);
				//HAL_GPIO_TogglePin(GPIOB, LED_TEST_Pin);
				//HAL_GPIO_TogglePin(GPIOC, LED2_Pin);
				__HAL_TIM_SET_COMPARE(&htim3,TIM_CHANNEL_4, 500);
				//HAL_Delay(500);
				//__HAL_TIM_SET_COMPARE(&htim3,TIM_CHANNEL_4, 0);
            }
			if (strstr((const char*)RxBuffer,ch[1]))
            {
                printf("b ok!!!!\r\n");
				//HAL_GPIO_WritePin(GPIOC, LED_TEST_Pin, GPIO_PIN_SET);
				//HAL_GPIO_TogglePin(GPIOB, LED_TEST_Pin);
				//HAL_GPIO_TogglePin(GPIOC, LED2_Pin);
				//__HAL_TIM_SET_COMPARE(&htim3,TIM_CHANNEL_4, 1400);
				//HAL_Delay(1000);
				__HAL_TIM_SET_COMPARE(&htim3,TIM_CHANNEL_4, 1300);
            }
			if (strstr((const char*)RxBuffer,ch[2]))
            {
                printf("b ok!!!!\r\n");
				//HAL_GPIO_WritePin(GPIOC, LED_TEST_Pin, GPIO_PIN_SET);
				//HAL_GPIO_TogglePin(GPIOB, LED_TEST_Pin);
				//HAL_GPIO_TogglePin(GPIOC, LED2_Pin);
				//__HAL_TIM_SET_COMPARE(&htim3,TIM_CHANNEL_4, 1400);
				//HAL_Delay(1000);
				__HAL_TIM_SET_COMPARE(&htim3,TIM_CHANNEL_4, 900);
            }
            Uart1_Rx_Cnt = 0;
            memset(RxBuffer,0x00,sizeof(RxBuffer)); //清空数组
        }
    }

    HAL_UART_Receive_IT(&huart2, (uint8_t *)&aRxBuffer, 1);   //再开启接收中断

}
```

蓝牙通信与串口通信几乎没区别，只是需要设置波特率以及用AT命令模式自定义密码。

### LCD屏幕显示

LCD使用SPI通信协议，实际上与串口没多少区别，一般用写好库直接调函数比较方便，但汉字输出只能取模，再定义在静态数组中调用了（图片显示也是一样的逻辑）。

```c
#include "lcd.h"
#include "lcd_init.h"
#include "lcdfont.h"
//#include "pic.h"
/******************************************************************************
      函数说明：在指定区域填充颜色
      入口数据：xsta,ysta   起始坐标
                xend,yend   终止坐标
								color       要填充的颜色
      返回值：  无
******************************************************************************/
void LCD_Fill(u16 xsta, u16 ysta, u16 xend, u16 yend, u16 color)
{
	u16 i, j;
	LCD_Address_Set(xsta, ysta, xend - 1, yend - 1); //设置显示范围
	for(i = ysta; i < yend; i++)
	{
		for(j = xsta; j < xend; j++)
		{
			LCD_WR_DATA(color);
		}
	}
}

/******************************************************************************
      函数说明：在指定位置画点
      入口数据：x,y 画点坐标
                color 点的颜色
      返回值：  无
******************************************************************************/
void LCD_DrawPoint(u16 x, u16 y, u16 color)
{
	LCD_Address_Set(x, y, x, y); //设置光标位置
	LCD_WR_DATA(color);
}


/******************************************************************************
      函数说明：画线
      入口数据：x1,y1   起始坐标
                x2,y2   终止坐标
                color   线的颜色
      返回值：  无
******************************************************************************/
void LCD_DrawLine(u16 x1, u16 y1, u16 x2, u16 y2, u16 color)
{
	u16 t;
	int xerr = 0, yerr = 0, delta_x, delta_y, distance;
	int incx, incy, uRow, uCol;
	delta_x = x2 - x1; //计算坐标增量
	delta_y = y2 - y1;
	uRow = x1; //画线起点坐标
	uCol = y1;
	if(delta_x > 0)incx = 1; //设置单步方向
	else if (delta_x == 0)incx = 0; //垂直线
	else
	{
		incx = -1;
		delta_x = -delta_x;
	}
	if(delta_y > 0)incy = 1;
	else if (delta_y == 0)incy = 0; //水平线
	else
	{
		incy = -1;
		delta_y = -delta_y;
	}
	if(delta_x > delta_y)distance = delta_x; //选取基本增量坐标轴
	else distance = delta_y;
	for(t = 0; t < distance + 1; t++)
	{
		LCD_DrawPoint(uRow, uCol, color); //画点
		xerr += delta_x;
		yerr += delta_y;
		if(xerr > distance)
		{
			xerr -= distance;
			uRow += incx;
		}
		if(yerr > distance)
		{
			yerr -= distance;
			uCol += incy;
		}
	}
}


/******************************************************************************
      函数说明：画矩形
      入口数据：x1,y1   起始坐标
                x2,y2   终止坐标
                color   矩形的颜色
      返回值：  无
******************************************************************************/
void LCD_DrawRectangle(u16 x1, u16 y1, u16 x2, u16 y2, u16 color)
{
	LCD_DrawLine(x1, y1, x2, y1, color);
	LCD_DrawLine(x1, y1, x1, y2, color);
	LCD_DrawLine(x1, y2, x2, y2, color);
	LCD_DrawLine(x2, y1, x2, y2, color);
}


/******************************************************************************
      函数说明：画圆
      入口数据：x0,y0   圆心坐标
                r       半径
                color   圆的颜色
      返回值：  无
******************************************************************************/
void Draw_Circle(u16 x0, u16 y0, u8 r, u16 color)
{
	int a, b;
	a = 0;
	b = r;
	while(a <= b)
	{
		LCD_DrawPoint(x0 - b, y0 - a, color);       //3
		LCD_DrawPoint(x0 + b, y0 - a, color);       //0
		LCD_DrawPoint(x0 - a, y0 + b, color);       //1
		LCD_DrawPoint(x0 - a, y0 - b, color);       //2
		LCD_DrawPoint(x0 + b, y0 + a, color);       //4
		LCD_DrawPoint(x0 + a, y0 - b, color);       //5
		LCD_DrawPoint(x0 + a, y0 + b, color);       //6
		LCD_DrawPoint(x0 - b, y0 + a, color);       //7
		a++;
		if((a * a + b * b) > (r * r)) //判断要画的点是否过远
		{
			b--;
		}
	}
}

/******************************************************************************
      函数说明：显示汉字串
      入口数据：x,y显示坐标
                *s 要显示的汉字串
                fc 字的颜色
                bc 字的背景色
                sizey 字号 可选 16 24 32
                mode:  0非叠加模式  1叠加模式
      返回值：  无
******************************************************************************/
void LCD_ShowChinese(u16 x, u16 y, u8 *s, u16 fc, u16 bc, u8 sizey, u8 mode)
{
	while(*s != 0)
	{
		if(sizey == 12) LCD_ShowChinese12x12(x, y, s, fc, bc, sizey, mode);
		else if(sizey == 16) LCD_ShowChinese16x16(x, y, s, fc, bc, sizey, mode);
		else if(sizey == 24) LCD_ShowChinese24x24(x, y, s, fc, bc, sizey, mode);
		else if(sizey == 32) LCD_ShowChinese32x32(x, y, s, fc, bc, sizey, mode);
		else return;
		s += 2;
		x += sizey;
	}
}

/******************************************************************************
      函数说明：显示单个12x12汉字
      入口数据：x,y显示坐标
                *s 要显示的汉字
                fc 字的颜色
                bc 字的背景色
                sizey 字号
                mode:  0非叠加模式  1叠加模式
      返回值：  无
******************************************************************************/
void LCD_ShowChinese12x12(u16 x, u16 y, u8 *s, u16 fc, u16 bc, u8 sizey, u8 mode)
{
	u8 i, j, m = 0;
	u16 k;
	u16 HZnum;//汉字数目
	u16 TypefaceNum;//一个字符所占字节大小
	u16 x0 = x;
	TypefaceNum = (sizey / 8 + ((sizey % 8) ? 1 : 0)) * sizey;

	HZnum = sizeof(tfont12) / sizeof(typFNT_GB12);	//统计汉字数目
	for(k = 0; k < HZnum; k++)
	{
		if((tfont12[k].Index[0] == *(s)) && (tfont12[k].Index[1] == *(s + 1)))
		{
			LCD_Address_Set(x, y, x + sizey - 1, y + sizey - 1);
			for(i = 0; i < TypefaceNum; i++)
			{
				for(j = 0; j < 8; j++)
				{
					if(!mode)//非叠加方式
					{
						if(tfont12[k].Msk[i] & (0x01 << j))LCD_WR_DATA(fc);
						else LCD_WR_DATA(bc);
						m++;
						if(m % sizey == 0)
						{
							m = 0;
							break;
						}
					}
					else//叠加方式
					{
						if(tfont12[k].Msk[i] & (0x01 << j))	LCD_DrawPoint(x, y, fc); //画一个点
						x++;
						if((x - x0) == sizey)
						{
							x = x0;
							y++;
							break;
						}
					}
				}
			}
		}
		continue;  //查找到对应点阵字库立即退出，防止多个汉字重复取模带来影响
	}
}
```

写好库函数直接调用即可：

```c
LCD_Fill(26, 90, 42, 106,BLACK);
LCD_ShowChinese16x16(10, 90, "第", RED, BLUE, 16, 1);
LCD_ShowChinese16x16(26, 90, "一", RED, BLUE, 16, 1);
LCD_ShowChinese16x16(42, 90, "模", RED, BLUE, 16, 1);
LCD_ShowChinese16x16(58, 90, "式", RED, BLUE, 16, 1);
```

但要对汉字提取取模定义：

```c
typedef struct
{
	unsigned char Index[2];
	unsigned char Msk[32];
} typFNT_GB16;

//在PCtolLCD中取字模参数设置为
//阴码
//逆向
//逐行式
const typFNT_GB16 tfont16[] =
{	
"第",0x04,0x02,0xFC,0x7E,0x12,0x09,0xA1,0x10,0xFC,0x1F,0x80,0x10,0x80,0x10,0xFC,0x1F,0x84,0x00,0x84,0x00,0xFC,0x3F,0xC0,0x20,0xA0,0x20,0x98,0x14,0x87,0x08,0x80,0x00,
/*"第",0*/
"一",0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xFF,0x7F,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
/*"一",1*/
"模",0x88,0x08,0x88,0x08,0xE8,0x3F,0x88,0x08,0x3F,0x00,0xC8,0x1F,0x4C,0x10,0xDC,0x1F,0x6A,0x10,0xCA,0x1F,0x09,0x02,0xE8,0x3F,0x08,0x05,0x88,0x08,0x48,0x10,0x28,0x60,
/*"模",2*/
"式",0x00,0x12,0x00,0x22,0x00,0x22,0x00,0x02,0xFF,0x7F,0x00,0x02,0x00,0x02,0x7C,0x02,0x10,0x02,0x10,0x02,0x10,0x04,0x10,0x44,0xF0,0x48,0x1E,0x50,0x04,0x60,0x00,0x40,
/*"式",3*/
};

```

### ADC

即模拟信号转数字信号，多用于采集外部数据用于单片机分析。

DMA+ADC可实现高效的实时采集信息。

```c
HAL_ADC_PollForConversion(&hadc1, 50); //等待转换完成，50 为最大等待时间，单位为 ms
if(HAL_IS_BIT_SET(HAL_ADC_GetState(&hadc1), HAL_ADC_STATE_REG_EOC))
{
    ADC_Value = HAL_ADC_GetValue(&hadc1); //获取 AD 值
}
HAL_Delay(100);

for(i=0,get_v=0; i<20;i++){
    get_v += ADC_Value[i];
}
get_v /= 20;
printf("%d\r\n",get_v);
```

### 项目：蓝牙+舵机实现自动关灯

```c
if((RxBuffer[Uart1_Rx_Cnt-1] == '!')&&(RxBuffer[Uart1_Rx_Cnt-2] == '!')) //判断结束位
{
    RxBuffer[Uart1_Rx_Cnt-1] = '\0';
    RxBuffer[Uart1_Rx_Cnt-2] = '\0';
    if (strstr((const char*)RxBuffer,ch[0]))
    {
        printf("a ok!!!!\r\n");
        //HAL_GPIO_WritePin(GPIOC, LED_TEST_Pin, GPIO_PIN_SET);
        //HAL_GPIO_TogglePin(GPIOB, LED_TEST_Pin);
        //HAL_GPIO_TogglePin(GPIOC, LED2_Pin);
        __HAL_TIM_SET_COMPARE(&htim3,TIM_CHANNEL_4, 500);
        //HAL_Delay(500);
        //__HAL_TIM_SET_COMPARE(&htim3,TIM_CHANNEL_4, 0);
    }
    if (strstr((const char*)RxBuffer,ch[1]))
    {
        printf("b ok!!!!\r\n");
        //HAL_GPIO_WritePin(GPIOC, LED_TEST_Pin, GPIO_PIN_SET);
        //HAL_GPIO_TogglePin(GPIOB, LED_TEST_Pin);
        //HAL_GPIO_TogglePin(GPIOC, LED2_Pin);
        //__HAL_TIM_SET_COMPARE(&htim3,TIM_CHANNEL_4, 1400);
        //HAL_Delay(1000);
        __HAL_TIM_SET_COMPARE(&htim3,TIM_CHANNEL_4, 1300);
    }
    if (strstr((const char*)RxBuffer,ch[2]))
    {
        printf("b ok!!!!\r\n");
        //HAL_GPIO_WritePin(GPIOC, LED_TEST_Pin, GPIO_PIN_SET);
        //HAL_GPIO_TogglePin(GPIOB, LED_TEST_Pin);
        //HAL_GPIO_TogglePin(GPIOC, LED2_Pin);
        //__HAL_TIM_SET_COMPARE(&htim3,TIM_CHANNEL_4, 1400);
        //HAL_Delay(1000);
        __HAL_TIM_SET_COMPARE(&htim3,TIM_CHANNEL_4, 900);
    }
    Uart1_Rx_Cnt = 0;
    memset(RxBuffer,0x00,sizeof(RxBuffer)); //清空数组
}
```

配置好CubeMX实际上就是写蓝牙通信控制PWM舵机，再简单调试一下就搞定。
