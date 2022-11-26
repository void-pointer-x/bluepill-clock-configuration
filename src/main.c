/**
 ******************************************************************************
 * @file           : main.c
 * @author         : Rohit Nimkar <nehalnimkar@gmail.com> <https://csrohit.github.io>
 * @brief          : Main program body
 ******************************************************************************
 * @attention
 *
 * This software component is licensed by Rohit Nimkar under BSD 3-Clause license,
 * the "License"; You may not use this file except in compliance with the
 * License. You may obtain a copy of the License at:
 *                        opensource.org/licenses/BSD-3-Clause
 *
 ******************************************************************************
 */

#include <stm32f1xx.h>
#include <stdint.h>

/**
 * @brief Configure and initialise clock for SysCLK of 72 MHz
 * 
 */
void init_clock(void)
{
	FLASH->ACR	|= FLASH_ACR_LATENCY_2; 	// Two wait states, per datasheet
	RCC->CFGR	|= RCC_CFGR_PPRE1_2;		// prescale AHB1 = HCLK/2
	RCC->CFGR 	|= RCC_CFGR_PLLXTPRE_HSE;	// PREDIV1 = 0
	RCC->CR 	|= RCC_CR_HSEON; 			// enable HSE clock
	while (!(RCC->CR & RCC_CR_HSERDY))
		; // wait for the HSEREADY flag

	RCC->CFGR 	|= RCC_CFGR_PLLSRC;			// set PLL source to HSE
	RCC->CFGR 	|= RCC_CFGR_PLLMULL9; 		// multiply by 9
	RCC->CR |= RCC_CR_PLLON;				// enable the PLL
	while (!(RCC->CR & RCC_CR_PLLRDY))
		; // wait for the PLLRDY flag

	RCC->CFGR 	|= RCC_CFGR_SW_PLL; 		// set clock source to pll

	while (!(RCC->CFGR & RCC_CFGR_SWS_PLL))
		; // wait for PLL to be CLK

	SystemCoreClockUpdate(); 				// calculate the SYSCLOCK value
}

void init_gpio()
{
	RCC->APB2ENR |= RCC_APB2ENR_IOPCEN;
	GPIOC->CRH |= 0x02 << ((13 - 8) << 2);
}

int main(void)
{
	init_clock();
	init_gpio();

	int ret = SysTick_Config(SystemCoreClock / 1000);
	if (ret < 0)
		while (1)
			;

	while (1)
	{
		GPIOC->ODR ^= 1U << 13;
		delay(500U);
	}
}
