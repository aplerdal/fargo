#include "flinker.h"
extern "C" {
#include "ctype.h"
#include "gnu/getopt.h"
}

char *progname;
unsigned int verbose = 0;

int is_invalid_name(const BYTE *name)
{
  const BYTE *s = (BYTE *)name;
  for (; *s != '\0'; s++) {
    if (!(*s >= 'a' && *s <= 'z'
	  || (s != name && (*s >= '0' && *s <= '9' || *s == '_'))
	  || *s >= 128))
      return 1;
  }
  return 0;
}

void print_error(const char *format, ...)
{
  va_list va;
  va_start(va, format);
  fprintf(stderr, "%s: ", progname);
  vfprintf(stderr, format, va);
  fprintf(stderr, "\nTry `%s --help' for more information.\n", progname);
  va_end(va);
}

int main(int argc, char *argv[])
{
  bool literal = FALSE;
  char *option;
  char *output_file = NULL;
  char *backup_file = NULL;
  char *plusasm_file = NULL;
  char *old92p_file = NULL;
  char *symbol_name = NULL;
  char *folder_name = NULL;
  List<char *> input_files;
  int show_help = FALSE;
  int show_version = FALSE;
  ObjectGroup Objects;
  int i, len;

  progname = argv[0];

  for (;;) {
    struct option long_options[] = {
      {"output", 1, 0, 'o'},
      {"backup", 1, 0, 'b'},
      {"plusasm", 1, 0, 'p'},
      {"old92p", 1, 0, 128},
      {"name", 1, 0, 'n'},
      {"folder", 1, 0, 'f'},
      {"verbose", 1, 0, 'v'},
      {"help", 0, &show_help, 1},
      {"version", 0, &show_version, 1},
      {0, 0, 0, 0}
    };
    int option_index = 0;

    c = getopt_long(argc, argv, "o:n:b:p:f:vhV", long_options, &option_index);

    if (c == -1)
      break;

    if (c == 0 && !long_options[option_index].flag)
      c = long_options[option_index].val;
    
    switch (c) {
    case 0:
      break;
    case 'o':
      output_file = optarg;
      break;
    case 'b':
      backup_file = optarg;
      break;
    case 'p':
      plusasm_file = optarg;
      break;
    case 'n':
      symbol_name = optarg;
      break;
    case 'f':
      folder_name = optarg;
      break;
    case 128:
      old92p_file = optarg;
      break;
    case 'v':
      verbose++;
      break;
    case 'h':
      show_help = TRUE;
      break;
    case 'V':
      show_version = TRUE;
      break;
    default:
      return 1;
    }
  }  

  while (optind < argc)
    *input_files.AppendNew() = argv[optind++];

  if (show_version) {
    printf("Fargo v0.2.8 Linker (flinker)\n"
	   "Copyright 1999 by David Ellsworth\n"
	   "Email: davidell@earthling.net\n");
    if (show_help)
      printf("\n");
    else
      return 0;
  }
  if (show_help) {
    printf("Usage: flinker <options> <input files>\n"
	   "\n"
	   " -o FILE, --output=FILE     Create TI-Graph Link PRGM (92p) file\n"
	   " -b FILE, --backup=FILE     Install kernel into TI-Graph Link backup file\n"
	   " -p FILE, --plusasm=FILE    Generate TI-92 Plus assembly program\n"
	   "          --old92p=FILE     Generate a Fargo 0.1.x PRGM file\n"
	   " -n NAME, --name=NAME       Symbol name is it should appear on a TI-92\n"
	   "                            (use with option `-o')\n"
	   " -v, --verbose              Output lots of information during link; if used\n"
	   "                            more than once, output even more information\n"
	   " --help                     display this help and exit\n"
	   " --version                  output version information and exit\n"
	   "\n"
	   "   Input files must be AmigaDOS object files.\n"
	   "   Options `-o' and `-b' are mutually exclusive.\n"
	   "   If `-o' is specified without `-n', symbol name is based on output file name.\n"
	   "   The options `-p' and `--old92p' are syntactically equivalent to `-o'.\n"
	   "\n"
	   );
    return 0;
  }

  if (output_file == NULL && backup_file == NULL && plusasm_file == NULL && old92p_file == NULL) {
    print_error("Output file not specified");
    return 1;
  }
  else if (backup_file != NULL && symbol_name != NULL) {
    print_error("Option `-n' should not be used with `-b'");
    return 1;
  }
  else if (input_files.GetCount() == 0) {
    print_error("No input files");
    return 1;
  }

  ListIter<char *> InputFileIter(input_files);
  while (char **InputFilePtr = InputFileIter.Get()) {
    if (Objects.ReadA68k(*InputFilePtr)) {
      printf("Errors found -- aborting link\n");
      return 1;
    }
  }

  /**/ if (output_file  != NULL) return Objects.Write92P(output_file, symbol_name, folder_name);
  else if (plusasm_file != NULL) return Objects.Write9XZ(plusasm_file, symbol_name, folder_name);
  else if (old92p_file  != NULL) return Objects.WriteOld92P(old92p_file, symbol_name, folder_name);
  else if (backup_file  != NULL) return Objects.Write92B(backup_file);
}
