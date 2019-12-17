
/* This routine generates a sine lookup table for use with programmable logic */
/* and DDS algorithm. */
/* compile with: */
/* gcc -lm -Wall -g3 -o sine_table sine_table.c */
//
/* Shahab, 08.10.2006 */
//
/* n is the resolution of the DAC */
/* each phase increment is (i * (2*pi) / pow (2,n)) */
/* the sine value of that, should be divided into 1/(2^(n-1)) */
/* n-1 because sine value go plus and minus. */
/* for streight binary, offset could be set. */

#include<stdio.h>
#include<math.h>

int  main(void)
{
     int n = 7;
     double pi = 3.14159;
     int i, val, j = 0;

     printf("library ieee;\n");
     printf("use ieee.std_logic_arith.all;\n");
     printf("use ieee.std_logic_1164.all;\n\n");
     printf("entity lut is\n\n");
     printf("generic \(\n");
     printf("length : integer := 8);\n\n");
     printf("port \(\n");
     printf("dat_o : out std_logic_vector (length - 1 downto 0);\n");
     printf("adr_i : in  std_logic_vector (length - 1 downto 0));\n\n");
     printf("end lut;\n\n");
     printf("architecture lut_arch of lut is\n\n");
     printf("begin\n\n");
     printf("with adr_i select\n");
     printf("dat_o <=\n");

     for(i = 0; i < (pow(2,n)); i++)
     {
	  val = (int) pow(2,n) / 2 + (int) floor( pow (2, (n-1)) * sin (i * (2*pi) / pow (2,n)));
//	  printf("%d-> 0x%X,", i , val);
//	  printf("0x%X,", val);
//	  printf("x\"%x\" when x\"%x\"", val, i);
	  printf("conv_std_logic_vector (%d, %d) when conv_std_logic_vector (%d, %d)", val, n, i, n);
	  if(i == (pow(2,n) - 1)) printf(";\n");
	  else printf(",\n");

	  if(j == 15) {
	       printf("\n");
	       j = 0;
	  }
	  else j++;
     }

     printf("end lut_arch;\n");

     return 0;
}
