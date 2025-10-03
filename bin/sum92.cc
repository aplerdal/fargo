extern "C" {
#include <stdio.h>
}
#include "endian.h"

int main(int argc, char *argv[])
{
  FILE *f;
  BYTE buf[0x8000];
  WORD old_sum, checksum = 0;
  LONG size, bytes_left;
  LONG tmp;
  int i, j;

  if (argc != 2) {
    printf("Usage: SUM92 file\n"
	   " file = name of .92? file\n");
    return 1;
  }
  
  if ((f = fopen(argv[1], "r+b")) == NULL) {
    printf("Error opening file \"%s\"\n", argv[1]);
    return 1;
  }
  
  fseek(f, 0x4C, SEEK_SET);
  fread(&tmp, 4, 1, f);
  size = convLE(tmp);

  fseek(f, size - 2, SEEK_SET);
  fread(&tmp, 2, 1, f);
  old_sum = convLE(tmp);
  
  fseek(f, 0x52, SEEK_SET);
  bytes_left = size - 0x52 - 2;
  while (bytes_left > 0) {
    j = sizeof(buf) < bytes_left ? sizeof(buf) : bytes_left;
    fread(buf, 1, j, f); bytes_left -= j;
    for (i = 0; i < j; checksum += buf[i++]);
  }

  if (checksum != old_sum) {
    fseek(f, size - 2, SEEK_SET);
    tmp = convLE(checksum);
    fwrite(&tmp, 2, 1, f);
    printf("Fixed checksum of \"%s\"\n", argv[1]);
  }
  else {
    printf("Didn't need to fix checksum.\n");
  }

  fclose(f);

  return 0;
}
