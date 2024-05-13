#include <stdio.h>



int main() 
{
  FILE * f = fopen("/proc/sys/vm/drop_caches","w");
  if (!f) 
  {
    fprintf(stderr,"Couldn't open /proc/sys/vm/drop_caches\n");
    return 1;
  }
  fprintf(f,"1"); 
  fclose(f);
  return 0;
}
