#include "flinker.h"

#define A68k_Hunk_Unit          999
#define A68k_Hunk_Name         1000
#define A68k_Hunk_Code         1001
#define A68k_Hunk_Data         1002
#define A68k_Hunk_BSS          1003
#define A68k_Hunk_Reloc32      1004
#define A68k_Hunk_Reloc16      1005
#define A68k_Hunk_Reloc8       1006
#define A68k_Hunk_Ext          1007
#define A68k_Hunk_Symbol       1008
#define A68k_Hunk_Debug        1009
#define A68k_Hunk_End          1010
#define A68k_Hunk_Header       1011

#define A68k_Hunk_Overlay      1013
#define A68k_Hunk_Break        1014
#define A68k_Hunk_Drel32       1015
#define A68k_Hunk_Drel16       1016
#define A68k_Hunk_Drel8        1017
#define A68k_Hunk_Lib          1018
#define A68k_Hunk_Index        1019
#define A68k_Hunk_Reloc32Short 1020
#define A68k_Hunk_RelReloc32   1021
#define A68k_Hunk_AbsReloc16   1022

#define A68k_Ext_symb         0   //  Symbol table
#define A68k_Ext_def          1   //  Relocatable definition
#define A68k_Ext_abs          2   //  Absolute definition
#define A68k_Ext_res          3   //  Reference to resident library [Obsolete]
#define A68k_Ext_CommonDef    4   //  Common definition (value is size in bytes)

#define A68k_Ext_ref32      129   //  32 bit absolute reference to symbol
#define A68k_Ext_common     130   //  32 bit absolute reference to COMMON block
#define A68k_Ext_ref16      131   //  16 bit PC-relative reference to symbol
#define A68k_Ext_ref8       132   //  8 bit PC-relative reference to symbol
#define A68k_Ext_dext32     133   //  32 bit data relative reference
#define A68k_Ext_dext16     134   //  16 bit data relative reference
#define A68k_Ext_dext8      135   //  8 bit data relative reference
#define A68k_Ext_relref32   136   //  32 bit PC-relative reference to symbol
#define A68k_Ext_relcommon  137   //  32 bit PC-relative reference to COMMON block
#define A68k_Ext_absref16   138   //  16 bit absolute reference to symbol
#define A68k_Ext_absref8    139   //  8 bit absolute reference to symbol

static char *ReadName(FILE *f)
{
  LONG size;
  char *name;

  fread(&size, 4, 1, f);
  size = convBE(size);
  name = new char [size * 4 + 1];
  fread(name, 4, size, f);
  name[size * 4] = '\0';

  return name;
}

static char *GetHunkName(int hunk_type)
{
  switch (hunk_type) {
  case A68k_Hunk_Unit: return "Hunk_Unit";
  case A68k_Hunk_Name: return "Hunk_Name";
  case A68k_Hunk_Code: return "Hunk_Code";
  case A68k_Hunk_Data: return "Hunk_Data";
  case A68k_Hunk_BSS: return "Hunk_BSS";
  case A68k_Hunk_Reloc32: return "Hunk_Reloc32";
  case A68k_Hunk_Reloc16: return "Hunk_Reloc16";
  case A68k_Hunk_Reloc8: return "Hunk_Reloc8";
  case A68k_Hunk_Ext: return "Hunk_Ext";
  case A68k_Hunk_Symbol: return "Hunk_Symbol";
  case A68k_Hunk_Debug: return "Hunk_Debug";
  case A68k_Hunk_End: return "Hunk_End";
  default: return NULL;
  }
}

static char *GetExtName(int ext_type)
{
  switch (ext_type) {
  case A68k_Ext_symb: return "Ext_symb";
  case A68k_Ext_def: return "Ext_def";
  case A68k_Ext_abs: return "Ext_abs";
  case A68k_Ext_res: return "Ext_res";
  case A68k_Ext_CommonDef: return "Ext_CommonDef";
  case A68k_Ext_ref32: return "Ext_ref32";
  case A68k_Ext_common: return "Ext_common";
  case A68k_Ext_ref16: return "Ext_ref16";
  case A68k_Ext_ref8: return "Ext_ref8";
  case A68k_Ext_dext32: return "Ext_dext32";
  case A68k_Ext_dext16: return "Ext_dext16";
  case A68k_Ext_dext8: return "Ext_dext8";
  case A68k_Ext_relref32: return "Ext_relref32";
  case A68k_Ext_relcommon: return "Ext_relcommon";
  case A68k_Ext_absref16: return "Ext_absref16";
  case A68k_Ext_absref8: return "Ext_absref8";
  default: return NULL;
  }
}

int ObjectGroup::ReadA68k(char *input_file)
{
  FILE *f;

  Unit *UnitPtr;
  int SectionNum = 0;
  Section *SectionPtr;
  RelTab *RelTabPtr;
  XRef *XRefPtr;
  XDef *XDefPtr;
  int first = TRUE;
  int in_section = FALSE;
  int error = 0;

  LONG hunk_type, hunk_size, hunk_misc;
  LONG x_type_len; int x_type; LONG x_len;
  char *x_name;

  if ((f = fopen(input_file, "rb")) == NULL) {
    printf("Error opening object file `%s'\n", input_file);
    return 1;
  }

  VERBOSE("Reading object file `%s'\n", input_file);

  while (TRUE) {
    if (fread(&hunk_type, sizeof(LONG), 1, f) == 0) break;
    VVERBOSE("Hunk Type nonconv:%x\n", hunk_type);
    hunk_type = convBE(hunk_type);
    VVERBOSE("Hunk Type:%x\n", hunk_type);

    if (first) {
      if (hunk_type != A68k_Hunk_Unit) {
	VVERBOSE("Hunk_Unit not found\n");
	return 1;
      }
    }

    VVERBOSE("%s", GetHunkName(hunk_type));

    switch (hunk_type) {
    case A68k_Hunk_Code:
    case A68k_Hunk_Data:
    case A68k_Hunk_BSS:
    case A68k_Hunk_Reloc32:
    case A68k_Hunk_Reloc16:
    case A68k_Hunk_Reloc8:
    case A68k_Hunk_Ext:
    case A68k_Hunk_Symbol:
    case A68k_Hunk_Debug:
      if (!in_section) {
	VVERBOSE(" defined outside of section\n");
	return 1;
      }
    }

    VVERBOSE(": ");

    switch (hunk_type) {
    case A68k_Hunk_Unit:
      if (!first) {
	VVERBOSE("Too many Hunk_Units\n");
	return 1;
      }
      first = FALSE;
      UnitPtr = Units.AppendNew();
      UnitPtr->filename = input_file;
      UnitPtr->Name = ReadName(f);
      VVERBOSE("name = `%s'\n", UnitPtr->Name);
      break;
    case A68k_Hunk_Name:
      in_section = TRUE;
      SectionPtr = UnitPtr->Sections.AppendNew();
      SectionPtr->UnitPtr = UnitPtr;
      SectionPtr->Name = ReadName(f);
      SectionPtr->Data = NULL;
      VVERBOSE("name = `%s', section num = %d\n", SectionPtr->Name, SectionNum);
      break;
    case A68k_Hunk_Code:
    case A68k_Hunk_Data:
    case A68k_Hunk_BSS:
      if (SectionPtr->Data != NULL) {
	VVERBOSE("Data in section already defined\n");
	return 1;
      }
      switch (hunk_type) {
      case A68k_Hunk_Code: SectionPtr->Type = Hunk_Code; break;
      case A68k_Hunk_Data: SectionPtr->Type = Hunk_Data; break;
      default: /*A68k_Hunk_BSS*/ SectionPtr->Type = Hunk_BSS; break;
      }
      fread(&SectionPtr->Size, 4, 1, f);
      SectionPtr->Size = convBE(SectionPtr->Size);
      SectionPtr->Data = new BYTE [SectionPtr->Size * 4];
      if (hunk_type != A68k_Hunk_BSS) {
	fread(SectionPtr->Data, 4, SectionPtr->Size, f);
      } else {
	memset(SectionPtr->Data, 0, SectionPtr->Size * 4);
      }
      VVERBOSE("size = 0x%08X longwords\n", SectionPtr->Size);
      break;
    case A68k_Hunk_Reloc32:
    case A68k_Hunk_Reloc16:
    case A68k_Hunk_Reloc8:
      VVERBOSE("\n");
      while (TRUE) {
	fread(&hunk_misc, 4, 1, f);
	if (hunk_misc == 0) break;
	
	RelTabPtr = SectionPtr->RelTabs.AppendNew();
	RelTabPtr->Type =
	  hunk_type == A68k_Hunk_Reloc32 ? relref32 :
	  hunk_type == A68k_Hunk_Reloc16 ? absref16 :
	  /*hunk_type == A68k_Hunk_Reloc8*/ absref8;

	fread(&RelTabPtr->SectionNum, 4, 1, f);
	RelTabPtr->SectionNum = convBE(RelTabPtr->SectionNum);

	RelTabPtr->Offsets.Size = convBE(hunk_misc);
	RelTabPtr->Offsets.List = new LONG [RelTabPtr->Offsets.Size];
	fread(RelTabPtr->Offsets.List, 4, RelTabPtr->Offsets.Size, f);
	{
	  for (int i = 0; i < RelTabPtr->Offsets.Size; i++)
	    RelTabPtr->Offsets.List[i] = convBE(RelTabPtr->Offsets.List[i]);
	}

	VVERBOSE(" num entries = %ld, section num = %ld\n",
		 RelTabPtr->Offsets.Size, RelTabPtr->SectionNum);
      }
      break;
    case A68k_Hunk_Ext:
    case A68k_Hunk_Symbol:
      VVERBOSE("\n");
      while (TRUE) {
	fread(&x_type_len, 4, 1, f); x_type_len = convBE(x_type_len);
	if (x_type_len == 0) break;
	x_type = x_type_len >> 24;
	x_len = x_type_len & 0xFFFFFF;
	x_name = new char [x_len * 4 + 1];
	fread(x_name, 4, x_len, f);
	x_name[x_len * 4] = '\0';
	VVERBOSE(" type = %s, name = `%s'", GetExtName(x_type), x_name);
	if (x_type > 128) /* symbol reference */ {
	  XRefPtr = SectionPtr->XRefs.AppendNew();
	  switch (x_type) {
	  case A68k_Ext_ref32: XRefPtr->Type = relref32; break;
	  case A68k_Ext_ref16: XRefPtr->Type = relref16; break;
	  case A68k_Ext_absref16: XRefPtr->Type = absref16; break;
	  case A68k_Ext_absref8: XRefPtr->Type = absref8; break;
	  default:
	    printf("Unsupported reference type %s\n", GetExtName(x_type));
	    error = 1;
	    break;
	  }
	  XRefPtr->Name = new char [strlen(x_name) + 1];
	  strcpy(XRefPtr->Name, x_name);
	  fread(&XRefPtr->Offsets.Size, 4, 1, f);
	  XRefPtr->Offsets.Size = convBE(XRefPtr->Offsets.Size);
	  XRefPtr->Offsets.List = new LONG [XRefPtr->Offsets.Size];
	  fread(XRefPtr->Offsets.List, 4, XRefPtr->Offsets.Size, f);
	  {
	    for (int i = 0; i < XRefPtr->Offsets.Size; i++)
	      XRefPtr->Offsets.List[i] = convBE(XRefPtr->Offsets.List[i]);
	  }
	  VVERBOSE(", %d reference%s", XRefPtr->Offsets.Size,
		   XRefPtr->Offsets.Size == 1 ? "" : "s");
	}
	else /* symbol definition */ {
	  fread(&hunk_misc, 4, 1, f);
	  hunk_misc = convBE(hunk_misc);
	  VVERBOSE(", %s = 0x%08hX", x_type == A68k_Ext_def ? "offset" : "value", hunk_misc);
	  if (x_type == A68k_Ext_def || x_type == A68k_Ext_abs) {
	    if (XDefs.Find(x_name) == NULL) {
	      XDefPtr = XDefs.AddNew(x_name);
	      XDefPtr->Type = x_type == A68k_Ext_def ? reldef : absdef;
	      XDefPtr->SectionPtr = SectionPtr;
	      XDefPtr->Offset = hunk_misc;
	    } else {
	      printf("Duplicate definition of `%s'\n", x_name);
	      error = 1;
	    }
	  }
	}
	VVERBOSE("\n");
	delete [] x_name;
      }
      break;
    case A68k_Hunk_Debug:
      fread(&hunk_size, 4, 1, f); hunk_size = convBE(hunk_size);
      VVERBOSE(" skipping %d longwords of debug info\n", hunk_size);
      fseek(f, hunk_size * 4, SEEK_CUR);
      return 1;
    case A68k_Hunk_End:
      if (!in_section) {
	VVERBOSE("Premature Hunk_End\n");
	return 1;
      }
      SectionNum ++;
      in_section = FALSE;
      VVERBOSE("\n");
      break;
    default:
      VVERBOSE("Invalid hunk ID (%d)\n", hunk_type);
      return 1;
    }
  }

  fclose(f);
  return error;
}
