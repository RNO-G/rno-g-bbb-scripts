#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>


int main()
{
  sync();
  int fd = open("/proc/sys/vm/drop_caches",O_WRONLY);
  if (fd < 0)
  {
    fprintf(stderr,"Couldn't open /proc/sys/vm/drop_caches\n");
    return 1;
  }
  write(fd,"3",1);
  close(fd);
  return 0;
}
