
/* This program writes to the serial port. */
/* Could be used to send a parameter to the FIB-AGC */
/* S. Sanjari */


#include <stdio.h> /* Standard input/output definitions */ 
#include <string.h> /* String function definitions */ 
#include <unistd.h> /* UNIX standard function definitions */ 
#include <fcntl.h> /* File control definitions */ 
#include <errno.h> /* Error number definitions */ 
#include <termios.h> /* POSIX terminal control definitions */ 
#include <math.h>/* for math functions! */

int fd; /* File descriptor for the serialport */ 
struct termios options; //serial port POSIX parameters

struct message {
     unsigned short addr   ;
     unsigned char data;
     unsigned char crc;
};


/* 
 * 'open_port()'   Open serial port 1. 
 * 
 * Returns the file descriptor on success or  1 on error. 
 */ 

int open_port(void) 
{ 

/* The O_NOCTTY flag tells UNIX that this program doesn't want to be the "controlling terminal" for that port. */
/* The O_NDELAY flag tells UNIX that this program doesn't care what state the DCD signal line is in   whether  */
/* the other end of the port is up and running. */

//     fd = open("/dev/ttyS0", O_RDWR | O_NOCTTY | O_NDELAY); 

// CYGWIN
     fd = open("/dev/com3", O_RDWR | O_NOCTTY | O_NDELAY); 


     if (fd ==  1) { 
/* 
 * Could not open the port. 
 */ 
	  perror("open_port: Unable to open /dev/ttyS0   "); 
     } 
     else fcntl(fd, F_SETFL, 0); 
     return (fd); 

}

int init_port(void)
{

/* 
 * Get the current options for the port... 
 */ 

     tcgetattr(fd, &options); 
/* 
 * Set the baud rates to 19200... 
 */ 

     cfsetispeed(&options, B19200); 
     cfsetospeed(&options, B19200); 

/* 
 * Enable the receiver and set local mode... 
 */ 

     options.c_cflag |= (CLOCAL | CREAD); 

/* set parameters to 8N1 */

     options.c_cflag &= ~PARENB; 
     options.c_cflag &= ~CSTOPB; 
     options.c_cflag &= ~CSIZE; 
     options.c_cflag |= CS8;

/* 
 * Set the new options for the port... 
 */ 

     tcsetattr(fd, TCSANOW, &options);
     return 0;
}

int send_message(struct message msg)
{
     int i;
     char * foo;
     foo = (char *)&msg;
     for (i = 0; i < sizeof(msg); i++)
     {
	  printf("0x%X", *foo);

	  if (write(fd, foo, 1) < 0)
	  {
	       fputs("Write operation failed!\n", stdout);
	       return -1;
	  }
          foo++;
     }
     return 0;
}

int main (void)
{
     char read_data [200];
     struct message msg;
     int ret;
     unsigned short answer;

/* set values to be calculated by DTE */

     msg.addr = 0x0000;
     msg.data = 0xAA;
     msg.crc = 0xAA;

     fputs("Trying to open the serial port....\n", stdout);
     if (open_port() < 0)
     {
	  fputs("Failed oppening serial port.\n", stdout);
	  return -1;
     }     
     else
     {
	  fputs("Port oppened successfully.\n", stdout);
	  fputs("Initializing port....\n", stdout);

     }
     init_port();			//initialize port

     fcntl(fd, F_SETFL, 0);		//set "wait" for charachters to come. chaneges the behavior of read.

     printf("Size of message to be sent: %d\n", sizeof(msg));

     fputs("Writting to the port...\n", stdout);

     if(0 < send_message(msg)) fputs("some error occured...", stdout);
     ret = read(fd, &read_data[0], 4);	// read charachters
     if (ret < 0)
     {
	  fputs("Failed reading from serial port.\n", stdout);
	  return -1;
     }
     else read_data[ret] = '\0';

     fputs("DTE answered with: ", stdout);

     fputs(read_data, stdout);

     fputs("\nNow closing the serial port....\n", stdout);

     if (close(fd) < 0)
     {
	  fputs("Failed closing the serial port.\n", stdout);
	  return -1;
     }     
     fputs("Device closed successfully, bye! \n", stdout);
     return 0;
}
