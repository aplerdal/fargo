extern "C" {
#include <stdio.h>
}

int main(int argc, char *argv[])
{
  FILE *f1, *f2;
  char buf1[8], buf2[7];
  int last, sofar, total;

  if (argc != 3) {
    printf("Usage: romconv <infile> <outfile>\n"
	   "Decodes a ROM dump that was downloaded using \"romdump2.92p\"\n");
    return 1;
  }

  if ((f1 = fopen(argv[1], "rb")) == NULL) {
    printf("Error opening infile \"%s\"\n", argv[1]);
    return 1;
  }

  if ((f2 = fopen(argv[2], "wb")) == NULL) {
    printf("Error creating outfile \"%s\"\n", argv[2]);
    return 1;
  }

  printf("Decoding %s to %s...", argv[1], argv[2]);

  last = sofar = 0;

  fseek(f1, 0, SEEK_END);
  total = ftell(f1);

  fseek(f1, 0, SEEK_SET);
  while (!feof(f1)) {
    if (sofar - last > 1024) {
      printf("\rDecoding %s to %s...%d/%d", argv[1], argv[2], sofar, total);
      last = sofar;
    }

    fread(buf1, 1, 8, f1);
    
    buf2[0] = (buf1[0] << 1) | ((buf1[1] & 0x7F) >> 6);
    buf2[1] = (buf1[1] << 1) | ((buf1[2] & 0x7F) >> 5);
    buf2[2] = (buf1[2] << 1) | ((buf1[3] & 0x7F) >> 4);
    buf2[3] = (buf1[3] << 1) | ((buf1[4] & 0x7F) >> 3);
    buf2[4] = (buf1[4] << 1) | ((buf1[5] & 0x7F) >> 2);
    buf2[5] = (buf1[5] << 1) | ((buf1[6] & 0x7F) >> 1);
    buf2[6] = (buf1[6] << 1) | ((buf1[7] & 0x7F) >> 0);

    if (sofar == 1048572)
      fwrite(buf2, 1, 4, f2);
    else
      fwrite(buf2, 1, 7, f2);

    sofar += 7;
  }

  fclose(f1);
  fclose(f2);

  printf("\nFinished!\n");

  return 0;
}
