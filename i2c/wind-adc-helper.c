#include <stdio.h> 
#include <linux/i2c-dev.h>
#include <stdint.h> 
#include <unistd.h> 
#include <fcntl.h> 
#include <sys/ioctl.h>
#include <stdlib.h> 
#include <math.h>
#include <string.h>
#include <time.h> 
#include <errno.h> 


static int bus=2; 
static int nsamp_per_meas = 100; 
static int nmeas = 50; 
static float delay = 0; 
static int addr = 0x4e; 


void usage() 
{
  printf("wind-adc-helper [-b BUS=2] [-s NSAMP_PER_MEAS=100] [-m NMEAS=50] [-a ADDRESS=0x4e] -d [DELAY = 0.01] [-h]\n"); 
  printf( "  -b BUS: The i2c bus (almost certainly is 2, the default\n") ; 
  printf( "  -s NSAMP_PER_MEAS: Number of samples per measurement (max is 4096, set by the linux i2c-dev driver)\n") ; 
  printf("   -m NMEAS: number of measurments\n");
  printf("   -a ADDRESS address of the MCP4221 (likely 0x4e or 0x48)\n");
  printf("   -d DELAY delay between measurements\n");
  printf("   -h help (show this message)\n");
}




int parse_args(int nargs, char ** args) 
{
  for(int i = 1; i < nargs; i++) 
  {
    char * endptr = 0; 

    if (!strcmp(args[i],"-h") || i == nargs-1) 
    {
      goto fail; 
    }
    else if (!strcmp(args[i],"-b"))
    {
      bus = strtol(args[++i], &endptr,0); 
      if (bus < 0) goto fail; 
    }
    else if (!strcmp(args[i],"-s"))
    {
      nsamp_per_meas = strtol(args[++i], &endptr,0); 
      if (nsamp_per_meas <= 0) goto fail; 
      if (nsamp_per_meas > 4096) goto fail; 
    }

    else if (!strcmp(args[i],"-m"))
    {
      nmeas = strtol(args[++i], &endptr,0); 
      if (nmeas <= 0) goto fail; 
    }

    else if (!strcmp(args[i],"-a"))
    {
      addr = strtol(args[++i], &endptr,0); 
      if (addr < 7 || addr > 127) goto fail;
    }
    else if (!strcmp(args[i],"-d"))
    {
      delay = strtof(args[++i], &endptr); 
      if (!isfinite(delay) || delay < 0) goto fail; 
    }

    if (*endptr) goto fail; 
  }

return 0; 
fail: 
      usage(); 
      return 1;
}


int main(int nargs, char ** args) 
{

  if (parse_args(nargs, args)) return 0; 

  char fname[32]; 
  sprintf(fname, "/dev/i2c-%d",bus); 

  int fd = open(fname,O_RDWR); 
  if (fd < 0) 
  {
    fprintf(stderr,"Couldn't open %s\n", fname); 
    return 1; 
  }


  if (ioctl(fd,I2C_SLAVE,addr) < 0)
  {
    fprintf(stderr,"Couldn't set addr 0x%x on %s\n", addr, fname ); 
    return 1; 
  }

  uint8_t * buf = malloc(nsamp_per_meas*2); 
  if (!buf) 
  {
    fprintf(stderr,"Couldn't allocate memory\n");  
    return 1; 
  }


  printf("START 0x%x\n", addr); 
  struct timespec start;
  struct timespec end;
  struct timespec now;
  struct timespec slp; 
  for (int i = 0; i < nmeas; i++) 
  {
    int nread = 0;
    clock_gettime(CLOCK_REALTIME, &start); 
    while (nread < nsamp_per_meas*2) 
    {
      int howmany = read(fd, buf, nsamp_per_meas * 2-nread); 
      if (howmany < 0) 
      {
        fprintf(stderr,"READ RETURNED %d (%s)\n",errno,strerror(errno)); 
        return errno; 
      }
      nread+=howmany; 
    }
    clock_gettime(CLOCK_REALTIME, &end); 
    printf("%d\n",i+1); 
    printf("%d.%09d\n",start.tv_sec, start.tv_nsec); 
    for (int j = 0; j < nread; j++) 
    {
      printf("0x%02x%c", buf[j], j == nread-1 ? '\n' : ' '); 
    }
    printf("%d.%09d\n",end.tv_sec, end.tv_nsec); 
    clock_gettime(CLOCK_REALTIME, &now); 
    float elapsed = now.tv_sec - start.tv_sec + 1e-9 * (now.tv_nsec - start.tv_sec); 
    float sleepfor= delay - elapsed; 
    if (sleepfor < 0) continue; 

    slp.tv_sec = floorf(sleepfor); 
    slp.tv_nsec = (sleepfor-  floorf(sleepfor))*1e9; 

    while (nanosleep(&slp,&slp)); 
  }
  
  printf("END  0x%x\n", addr); 
  free(buf); 
  close(fd); 
  return 0; 
}

