#include "flinker.h"

#define HEADER_SIZE 0x56
static BYTE header[] =
(
 "**TI92P*\x01\x00"
 "\x00\x00\x00\x00\x00\x00\x00\x00"
 "                                        "
 "\x01\x00"
 "\x52\x00\x00\x00"
 "\x00\x00\x00\x00\x00\x00\x00\x00"
 "\x12\x00\x00\x00"
 "\x00\x00\x00\x00"
 "\xA5\x5A"
 "\x00\x00\x00\x00"
);

class Section9XZ : public SectionGeneric {
public:
  Section9XZ(LONG theAddress) { Address = theAddress; }
  virtual LONG GetAddress() { return Address; }
private:
  LONG Address;
};

struct RelocEntry {
  LONG RefOffset;
  LONG DefOffset;
};

bool operator > (RelocEntry a, RelocEntry b) {
  return a.RefOffset > b.RefOffset;
}
bool operator < (RelocEntry a, RelocEntry b) {
  return a.RefOffset < b.RefOffset;
}

class Fixup9XZ : public FixupGeneric {
public:
  Fixup9XZ(List<RelocEntry> &theRelocList, LONG theAddress) {
    RelocList = &theRelocList;
    Address = theAddress;
  }
  LONG DoFixup(Section *SectionPtr, LONG Offset) {
    RelocEntry *R = RelocList->AppendNew();
    R->RefOffset = SectionPtr->Info->GetAddress() + Offset;
    R->DefOffset = Address + convBE(*(LONG *)((BYTE *)SectionPtr->Data + Offset));
    return Address;
  }
private:
  List<RelocEntry> *RelocList;
  LONG Address;
};

class Reloc9XZ : public RelocGeneric {
public:
  Reloc9XZ() {}
  FixupGeneric *Func(SectionGeneric *Ref_Section, int Type,
		     SectionGeneric *Def_Section, LONG Offset) {
    if (Type == relref32)
      return new Fixup9XZ(Reloc, Def_Section->GetAddress() + Offset);
    else
      return new FixupError("illegal operand size in");
  }
  List<RelocEntry> Reloc;
};

class Import9XZ : public ImportGeneric {
public:
  Import9XZ() {}
  FixupGeneric *Func(SectionGeneric *Ref_Section, int Type, char *Name);
};

class Output9XZ {
public:
  Output9XZ(ObjectGroup &theObject, char *the_output_file, char *the_symbol_name, char *the_folder_name)
    :Object(theObject),output_file(the_output_file),symbol_name(the_symbol_name),folder_name(the_folder_name) {}
  int DumpHeader(BYTE *Data);
  void DumpTables(BYTE *Data, LONG &Offset);
  int Write();
private:
  ObjectGroup &Object;
  char *output_file;
  char *symbol_name;
  char *folder_name;
  
  LONG SymbolSize;  // Total size of TI-92 variable
  
  Reloc9XZ RelocInfo;   // relocation info
  Import9XZ ImportInfo; // import info
};

FixupGeneric *Import9XZ::Func(SectionGeneric *Ref_Section, int Type, char *Name)
{
  return NULL;
}

int Output9XZ::DumpHeader(BYTE *Data)
{
  {
    // symbol name is it will appear on a TI-92
    int len = 0;
    if (symbol_name == NULL) {
      // name was not specified; attempt to guess it
      bool not_first = FALSE;
      BYTE *d = (BYTE *)Data + 0x40;
#ifdef MSDOS
      BYTE *c = (BYTE *)strrchr(output_file, '\\');
#else
      BYTE *c = (BYTE *)strrchr(output_file, '/');
#endif
      if (c == NULL)
	c = (BYTE *)output_file;
      else
	c++;
      while (TRUE) {
	if (*c == '\0' || *c == '.')
	  break;
	else if (*c >= 'A' && *c <= 'Z')
	  *d = *c + 'a' - 'A';
	else if (*c >= 'a' && *c <= 'z' || *c >= 128 ||
		 not_first && *c >= '0' && *c <= '9')
	  *d = *c;
	else
	  *d = '_';
	not_first = TRUE;
	*c++, *d++;
      }
    }
    if (symbol_name != NULL) {
      len = strlen(symbol_name);
      if (len > 8) {
	printf("Error: Program name is too long (cannot be >8 characters).\n");
	return 1;
      }
      memcpy(Data + 0x40, symbol_name, len);
    }
    if (folder_name != NULL) {
      len = strlen(folder_name);
      if (len > 8) {
	printf("Error: Folder name is too long (cannot be >8 characters).\n");
	return 1;
      }
      memcpy(header + 0x0A, folder_name, len);
    } else
      memcpy(header + 0x0A, "main", 4);
  }

  // offset following data portion
  *(LONG *)(Data + 0x4C) = convLE(HEADER_SIZE + SymbolSize + 2);

  {
    // file comment
    time_t tt = time(NULL);
    struct tm *lt = localtime(&tt);
    int i;
    i = /*snprintf*/sprintf((char *)(Data + 0x12), /*40,*/
			    "ASM program dated %d.%.2d.%.2d %.2d:%.2d:%.2d",
			    1900+lt->tm_year, lt->tm_mon+1, lt->tm_mday,
			    lt->tm_hour, lt->tm_min, lt->tm_sec);
    if (i != 40) *(char *)(Data + 0x12 + i) = ' ';
  }

  return 0;
}

void Output9XZ::DumpTables(BYTE *Data, LONG &Offset)
{
  if (Data) *(WORD *)(Data + 0) = convBE((WORD)(SymbolSize-2));

  Offset += 2 + 4 * RelocInfo.Reloc.GetCount();
  if (Data) {
    WORD *p = (WORD *)(Data + Offset);
    ListSortIter<RelocEntry> RelocIter(RelocInfo.Reloc);
    while (RelocEntry *current = RelocIter.Get()) {
      *(--p) = convBE((WORD)(current->RefOffset - 2));
      *(--p) = convBE((WORD)(current->DefOffset - 2));
    }
    *(--p) = 0;
  }

  if (Data) *(BYTE *)(Data + Offset) = 0xF3;
  Offset += 1;
}

int Output9XZ::Write()
{
  LONG TableOffset;
  int errcode;

  VERBOSE("Entering Pass 1 of link output\n");

  SymbolSize = 2; // first word = size of data portion

  {
    ListIter<Unit> UnitIter(Object.Units);
    while (Unit *UnitPtr = UnitIter.Get()) {
      ListIter<Section> SectionIter(UnitPtr->Sections);
      while (Section *SectionPtr = SectionIter.Get()) {
	LONG x = SectionPtr->Size * 4;
	SectionPtr->Info = new Section9XZ(SymbolSize);
	SymbolSize += x;
      }
    }
  }

  if (errcode = Object.ResolveReloc(RelocInfo, ImportInfo))
    return errcode;

  TableOffset = SymbolSize;
  DumpTables(NULL, SymbolSize);

  VERBOSE("ASM program is %d bytes\n", SymbolSize);

  if (SymbolSize > 0x10000) {
    printf("ASM program is too big to fit in 64K\n");
    return 1;
  }

  VERBOSE("Entering Pass 2 of link output\n");

  BYTE *Data = new BYTE [SymbolSize + 2];
  memset(Data, 0, SymbolSize + 2);

  {
    ListIter<Unit> UnitIter(Object.Units);
    while (Unit *UnitPtr = UnitIter.Get()) {
      ListIter<Section> SectionIter(UnitPtr->Sections);
      while (Section *SectionPtr = SectionIter.Get()) {
	memcpy(Data + SectionPtr->Info->GetAddress(), SectionPtr->Data, SectionPtr->Size * 4);
      }
    }
  }

  DumpTables(Data, TableOffset);

  {
    WORD checksum = 0;
    for (int i = 0; i < SymbolSize; i++)
      checksum += Data[i];
    *(WORD *)(Data + SymbolSize) = convLE(checksum); 
  }

  VERBOSE("Constructing TI-Graph Link header\n");

  if (errcode = DumpHeader(header))
    return errcode;

  FILE *f = fopen(output_file, "wb");
  if (f == NULL) {
    printf("Error creating file `%s'\n", output_file);
    return 1;
  }

  VERBOSE("Writing data to ASM program...");

  fwrite(header, 1, HEADER_SIZE, f);
  fwrite(Data, 1, SymbolSize + 2, f);

  fclose(f);

  VERBOSE("done!\n");

  return 0;
}

int ObjectGroup::Write9XZ(char *the_output_file, char *the_symbol_name, char *the_folder_name)
{
  Output9XZ Output(*this, the_output_file, the_symbol_name, the_folder_name);
  return Output.Write();
}
