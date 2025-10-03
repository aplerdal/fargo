#include "flinker.h"

#define HEADER_SIZE 0x56
static BYTE header[] =
(
 "**TI92**\x01\x00"
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

static int tibasic_fork_size = 12;
static BYTE *tibasic_fork = (BYTE *)
(
 "\xE9"
 "\x12\xE4" // EndPrgm
 "\x00\xE8" // :
 "\x19\xE4" // Prgm
 "\xE5\x00\x00" // ()
 "\x40\xDC"
);

class Section92P : public SectionGeneric {
public:
  virtual LONG GetAddress() { return 0; }
  virtual bool CanReference() { return FALSE; }
  virtual bool CanReference(Section92P *SectionInfo) { return FALSE; }
  virtual bool InSymbol() { return FALSE; }
  virtual bool IsLoaded() { return FALSE; }
  virtual bool IsBSS() { return FALSE; }
};

class Section92P_CodeData : public Section92P {
public:
  Section92P_CodeData(LONG theAddress)
    { Address = theAddress; }
  LONG GetAddress() { return Address; }
  bool CanReference() { return TRUE; }
  bool CanReference(Section92P *SectionInfo)
    { return SectionInfo->IsLoaded(); }
  bool InSymbol() { return TRUE; }
  bool IsLoaded() { return TRUE; }
  bool IsBSS() { return FALSE; }
private:
  LONG Address;
};

class Section92P_BSS : public Section92P {
public:
  Section92P_BSS(LONG theAddress)
    { Address = theAddress; }
  LONG GetAddress() { return Address; }
  bool CanReference() { return FALSE; }
  bool CanReference(Section92P *SectionInfo)
    { return FALSE; }
  bool InSymbol() { return FALSE; }
  bool IsLoaded() { return TRUE; }
  bool IsBSS() { return TRUE; }
private:
  LONG Address;
};

class Section92P_tibasic : public Section92P {
public:
  Section92P_tibasic() {}
  bool CanReference() { return FALSE; }
  bool CanReference(Section92P *SectionInfo)
    { return FALSE; }
};

class Fixup92P : public FixupGeneric {
public:
  Fixup92P(List<LONG> &theRelocList) {
    RelocList = &theRelocList;
    Address = 0;
  }
  Fixup92P(List<LONG> &theRelocList, LONG theAddress) {
    RelocList = &theRelocList;
    Address = theAddress;
  }
  LONG DoFixup(Section *SectionPtr, LONG Offset) {
    *RelocList->AppendNew() = SectionPtr->Info->GetAddress() + Offset;
    return Address;
  }
private:
  List<LONG> *RelocList;
  LONG Address;
};

class Reloc92P : public RelocGeneric {
public:
  Reloc92P() {}
  FixupGeneric *Func(SectionGeneric *Ref_Section, int Type,
		     SectionGeneric *Def_Section, LONG Offset) {
    if (((Section92P *)Ref_Section)->CanReference((Section92P *)Def_Section)) {
      if (Type == relref32)
	return new Fixup92P(((Section92P *)Def_Section)->IsBSS() ? RelocBSS : Reloc,
			    Def_Section->GetAddress() + Offset);
      else
	return new FixupError("illegal operand size in");
    }
    else
      return new FixupError("illegal");
  }
  List<LONG> Reloc;
  List<LONG> RelocBSS;
};

class Import {
  friend class Import92P;
public:
  bool operator < (Import &other) {
    return LibNum < other.LibNum || LibNum == other.LibNum && SymNum < other.SymNum;
  }
  bool operator > (Import &other) {
    return LibNum > other.LibNum || LibNum == other.LibNum && SymNum > other.SymNum;
  }
private:
  WORD LibNum;
  WORD SymNum;
  List<LONG> Reloc;
};

class ImportLib {
  friend class Import92P;
private:
  char *Name;
  LONG Offset;
};

class Import92P : public ImportGeneric {
public:
  Import92P():ImportNums(256),LibOffsetTemp(0) {}
  FixupGeneric *Func(SectionGeneric *Ref_Section, int Type, char *Name);
  void DumpLibs(BYTE *Data, LONG &Offset);
  void Dump(BYTE *Data, LONG &Offset);

  List<Import> Imports;
  List<ImportLib> ImportLibs;
  SymTable<WORD> ImportNums;
  LONG LibOffset; // Offset of library name strings
  LONG LibOffsetTemp;
};

class Export92P {
public:
  Export92P():tibasic_Section(NULL),tibasic_Size(0) {}
  int Func(ObjectGroup &Object);
  void Dump(BYTE *Data, LONG &Offset);

  List<LONG> Exports;
  char *subtype;   // "APPL" or "DLL "
  char *file_desc; // "Fargo program" or "Fargo library"
  char *library_name;
  char *program_comment;
  LONG library_name_Offset;
  LONG program_comment_Offset;
  Section *tibasic_Section;
  LONG tibasic_Size;
};

class Output92P {
public:
  Output92P(ObjectGroup &theObject, char *the_output_file, char *the_symbol_name, char *the_folder_name)
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
  LONG BSS_Size;    // Total size of BSS section

  Reloc92P RelocInfo;   // relocation info
  Import92P ImportInfo; // import info
  Export92P ExportInfo; // export info
};

FixupGeneric *Import92P::Func(SectionGeneric *Ref_Section, int Type, char *Name)
{
  if (!((Section92P *)Ref_Section)->CanReference())
    return new FixupError("illegal");

  char *d = strchr(Name, '@');
  if (d != NULL) {
    char *c = d + 1;
    int i;
    WORD SymNum = 0;
    for (i = 0; i < 4; i++, c++) {
      if (*c >= '0' && *c <= '9')
	SymNum = (SymNum << 4) | (*c - '0');
      else if (*c >= 'A' && *c <= 'F')
	SymNum = (SymNum << 4) | (*c - 'A' + 0xA);
      else
	return NULL;
    }
    if (*c != '\0')
      return NULL;
    *d = '\0';
    WORD *ImportNumPtr = ImportNums.Find(Name);
    if (ImportNumPtr == NULL) {
      ImportNumPtr = ImportNums.AddNew(Name);
      *ImportNumPtr = ImportLibs.GetCount();

      ImportLib *ImportLibPtr = ImportLibs.AppendNew();
      ImportLibPtr->Name = new char [strlen(Name)+1];
      strcpy(ImportLibPtr->Name, Name);
      ImportLibPtr->Offset = LibOffsetTemp;
      LibOffsetTemp += strlen(Name) + 1;
    }
    *d = '@';
    Import *NewImport = Imports.AppendNew();
    NewImport->LibNum = *ImportNumPtr;
    NewImport->SymNum = SymNum;
    if (Type == relref32)
      return new Fixup92P(NewImport->Reloc);
    else
      return new FixupError("illegal operand size in");
  }
  else
    return NULL;
}

int Export92P::Func(ObjectGroup &Object)
{
  int i, j;
  XDef *XDefPtr;

  XDefPtr = Object.XDefs.Find("_library");
  if (XDefPtr != NULL && !(((Section92P *)XDefPtr->SectionPtr->Info))->IsBSS()) {
    // this is a library
    file_desc = "Fargo library";

    program_comment_Offset = 0;

    library_name_Offset = XDefPtr->SectionPtr->Info->GetAddress() + XDefPtr->Offset;
    library_name = (char *)(XDefPtr->SectionPtr->Data + (j = XDefPtr->Offset));
    LONG limit = XDefPtr->SectionPtr->Size * 4;
    for (i = 0; i <= 8; i++) {
      if (j >= limit) {
	i = 0; break;
      }
      if (library_name[i] == '\0')
	break;
      j++;
    }
    if (i > 0 && i <= 8) {
      if (is_invalid_name((BYTE *)library_name)) {
	printf("Warning: Invalid character(s) in library name\n");
      }

      char symname[8 + 1 + 4 + 1];
      char *c, *d;

      int symnum = 0;
      memcpy(symname, library_name, i);
      strcpy(symname + i, "@0000");
      c = symname + i + 4;

      while (XDefPtr = Object.XDefs.Find(symname)) {
	LONG *ExportPtr = Exports.AppendNew();
	*ExportPtr = XDefPtr->SectionPtr->Info->GetAddress() + XDefPtr->Offset;

	symnum++;
	for (d = c; *d != '@'; d--) {
	  if (*d < '9' || *d >= 'A' && *d < 'F') {
	    (*d)++; break;
	  }
	  else if (*d == '9') {
	    (*d) = 'A'; break;
	  }
	  (*d) = '0';
	}
	if (*d == '@') break;
      }

      subtype = "DLL ";
    }
    else {
      library_name_Offset = 0;

      subtype = "????";
    }
  }
  else {
    // this is a program
    file_desc = "Fargo program";

    library_name_Offset = 0;

    XDefPtr = Object.XDefs.Find("_main");
    if (XDefPtr != NULL) {
      LONG *ExportPtr = Exports.AppendNew();
      *ExportPtr = XDefPtr->SectionPtr->Info->GetAddress() + XDefPtr->Offset;

      XDefPtr = Object.XDefs.Find("_tibasic");
      if (XDefPtr != NULL && XDefPtr->SectionPtr == tibasic_Section) {
	tibasic_Size = XDefPtr->Offset;
	subtype = "PRGM";
      }
      else
	subtype = "APPL";
    }
    else
      subtype = "????";

    XDefPtr = Object.XDefs.Find("_comment");
    if (XDefPtr != NULL && !((Section92P *)(XDefPtr->SectionPtr->Info))->IsBSS()) {
      program_comment_Offset = XDefPtr->SectionPtr->Info->GetAddress() + XDefPtr->Offset;
      program_comment = (char *)(XDefPtr->SectionPtr->Data + (j = XDefPtr->Offset));
      LONG limit = XDefPtr->SectionPtr->Size * 4;
      for (i = 0; i <= 30; i++) {
	if (j >= limit) {
	  i = 0; break;
	}
	if (program_comment[i] == '\0')
	  break;
	j++;
      }
      if (i > 0) {
	if (i > 30)
	  printf("Warning: Program comment is >30 chars\n");
      }
      else
	program_comment_Offset = 0;
    }
    else
      program_comment_Offset = 0;
  }
  return 0;
}

static void DoNibbles(BYTE *Data, LONG &Offset, int nibble_count)
{
  LONG src = Offset -= nibble_count;
  while (nibble_count >= 3) {
    int n = (nibble_count - 1) / 2;
    if (n > 4) n = 4;
    nibble_count -= n * 2 + 1;
    if (Data)
      *(BYTE *)(Data + Offset) = ((8 + n - 1) << 4) | (*(BYTE *)(Data + src++) - 1);
    Offset += 1;
    if (Data) {
      while (--n >= 0) {
	*(BYTE *)(Data + Offset++) = (((*(BYTE *)(Data + src + 0) - 1) << 4) |
				      ((*(BYTE *)(Data + src + 1) - 1)));
	src += 2;
      }
    }
    else
      Offset += n;
  }
  if (Data) {
    while (nibble_count > 0) {
      *(BYTE *)(Data + Offset++) = *(BYTE *)(Data + src++);
      nibble_count--;
    }
  }
  else
    Offset += nibble_count;
}

static void DumpReloc(List<LONG> &Reloc, BYTE *Data, LONG &Offset)
{
  WORD last = 24;
  int count = Reloc.GetCount();
  int nibble_count = 0;
  ListSortIter<LONG> RelocIter(Reloc);
  while (LONG *current = RelocIter.Get()) {
    WORD diff = (*current - last) / 2;
    while (TRUE) {
      if (diff < 0x10) {
	if (Data) *(BYTE *)(Data + Offset) = diff + 1;
	Offset += 1;
	nibble_count++;
	break;
      }
      else {
	DoNibbles(Data, Offset, nibble_count);
	nibble_count = 0;
	if (diff < 0x7F) {
	  if (Data) *(BYTE *)(Data + Offset) = diff + 1;
	  Offset += 1;
	  break;
	}
	else {
	  diff -= 0x7F;
	  if (diff > 0x3FFF) {
	    if (Data) *(WORD *)(Data + Offset) = convBE((WORD)0xFFFF);
	    Offset += 2;
	    diff -= 0x3FFF;
	  }
	  else {
	    if (Data) *(WORD *)(Data + Offset) = convBE((WORD)(0xC000 + diff));
	    Offset += 2;
	    break;
	  }
	}
      }
    }
    last = *current + 4;
  }
  DoNibbles(Data, Offset, nibble_count);
  if (Data) *(BYTE *)(Data + Offset) = 0;
  Offset += 1;
}

void Import92P::DumpLibs(BYTE *Data, LONG &Offset)
{
  LibOffset = Offset;
  ListIter<ImportLib> ImportLibIter(ImportLibs);
  while (ImportLib *ImportLibPtr = ImportLibIter.Get()) {
    char *c = ImportLibPtr->Name;
    while (TRUE) {
      if (Data) *(BYTE *)(Data + Offset) = *c;
      Offset += 1;
      if (*c == '\0')
	break;
      c++;
    }
  }
}

void Import92P::Dump(BYTE *Data, LONG &Offset)
{
  if (Data) *(WORD *)(Data + Offset) = convBE((WORD)ImportLibs.GetCount());
  Offset += 2;

  if (ImportLibs.GetCount() == 0)
    return;
  if (Data) *(WORD *)(Data + Offset) = convBE((WORD)LibOffset);
  Offset += 2;
  ListIter<ImportLib> ImportLibIter(ImportLibs);
  for (WORD LibNum = 0; ImportLib *ImportLibPtr = ImportLibIter.Get(); LibNum++) {
    int LastSymNum = -1;
    ListSortIter<Import> ImportIter(Imports);
    while (Import *ImportPtr = ImportIter.Get()) {
      if (ImportPtr->LibNum == LibNum) {
	WORD diff = ImportPtr->SymNum - LastSymNum;
	if (diff < 0x80) {
	  if (Data) *(BYTE *)(Data + Offset) = diff;
	  Offset += 1;
	}
	else {
	  if (Data) *(WORD *)(Data + Offset) = convBE((WORD)(0x8000 + diff));
	  Offset += 2;
	}
	LastSymNum = ImportPtr->SymNum;
	DumpReloc(ImportPtr->Reloc, Data, Offset);
      }
    }
    if (Data) *(BYTE *)(Data + Offset) = 0;
    Offset += 1;
  }
  if (Data) *(BYTE *)(Data + Offset) = 0;
  Offset += 1;
}

void Export92P::Dump(BYTE *Data, LONG &Offset)
{
  if (Data) *(WORD *)(Data + Offset) = convBE((WORD)Exports.GetCount());
  Offset += 2;
  ListIter<LONG> ExportIter(Exports);
  while (LONG *ExportPtr = ExportIter.Get()) {
    if (Data) *(WORD *)(Data + Offset) = convBE((WORD)*ExportPtr);
    Offset += 2;
  }
}

int Output92P::DumpHeader(BYTE *Data)
{
  {
    // symbol name is it will appear on a TI-92
    int len = 0;
    if (symbol_name == NULL) {
      // name was not specified; attempt to guess it
      if (ExportInfo.library_name_Offset != 0)
	symbol_name = ExportInfo.library_name;
      else {
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
			    "%s dated %d.%.2d.%.2d %.2d:%.2d:%.2d", ExportInfo.file_desc,
			    1900+lt->tm_year, lt->tm_mon+1, lt->tm_mday,
			    lt->tm_hour, lt->tm_min, lt->tm_sec);
    if (i != 40) *(char *)(Data + 0x12 + i) = ' ';
  }

  return 0;
}

void Output92P::DumpTables(BYTE *Data, LONG &Offset)
{
  if (Data) *(WORD *)(Data + 0) = convBE((WORD)(SymbolSize-2));

  if (Data) *(WORD *)(Data + 2) = convBE((WORD)0x0032);
  if (Data) memcpy(Data + 4, "EXE ", 4);
  if (Data) memcpy(Data + 8, ExportInfo.subtype, 4);
  if (Data) *(WORD *)(Data + 12) = 0;

  if (Data) *(WORD *)(Data + 20) = convBE((WORD)Offset);
  ExportInfo.Dump(Data, Offset);

  if (Data) *(WORD *)(Data + 16) = convBE((WORD)Offset);
  if (Data) *(WORD *)(Data + Offset) = convBE((WORD)BSS_Size); Offset += 2;
  if (BSS_Size != 0)
    DumpReloc(RelocInfo.RelocBSS, Data, Offset);

  if (Data) *(WORD *)(Data + 14) = convBE((WORD)Offset);
  DumpReloc(RelocInfo.Reloc, Data, Offset);

  if (Offset & 1) {
    if (Data) *(BYTE *)(Data + Offset) = 0;
    Offset += 1;
  }
  if (Data) *(WORD *)(Data + 18) = convBE((WORD)Offset);
  ImportInfo.Dump(Data, Offset);

  ImportInfo.DumpLibs(Data, Offset);

  if (Data) {
    *(WORD *)(Data + 22) = convBE
      (ExportInfo.library_name_Offset ?
       (WORD)ExportInfo.library_name_Offset :
       (WORD)ExportInfo.program_comment_Offset);
  }
  
  if (Data) *(WORD *)(Data + 24) = convBE((WORD)1);

  if (Data) memcpy(Data + Offset, tibasic_fork, tibasic_fork_size);
  Offset += tibasic_fork_size;
}

int Output92P::Write()
{
  LONG TableOffset;
  int errcode;

  VERBOSE("Entering Pass 1 of link output\n");

  SymbolSize =
    2 + // first word = size of data portion
    2 + // Fargo II signature
    4 + // file type
    4 + // file subtype
    2 + // reserved for use by Fargo
    2 + // pointer to relocation table
    2 + // pointer to bss table
    2 + // pointer to import table
    2 + // pointer to export table
    2 + // pointer to program comment or library name
    2;  // flags

  BSS_Size = 0;
  {
    ListIter<Unit> UnitIter(Object.Units);
    while (Unit *UnitPtr = UnitIter.Get()) {
      ListIter<Section> SectionIter(UnitPtr->Sections);
      while (Section *SectionPtr = SectionIter.Get()) {
	if (strcmp(SectionPtr->Name, "_tibasic") == 0) {
	  if (ExportInfo.tibasic_Section == NULL) {
	    SectionPtr->Info = new Section92P_tibasic();
	    ExportInfo.tibasic_Section = SectionPtr;
	  }
	  else {
	    printf("Duplicate definition of tibasic section\n");
	    return 1;
	  }
	}
	else {
	  LONG x = SectionPtr->Size * 4;
	  if (SectionPtr->Type == Hunk_BSS) {
	    SectionPtr->Info = new Section92P_BSS(BSS_Size);
	    BSS_Size += x;
	  }
	  else {
	    SectionPtr->Info = new Section92P_CodeData(SymbolSize);
	    SymbolSize += x;
	  }
	}
      }
    }
  }

  if (BSS_Size > 0x10000) {
    printf("BSS section is larger than 64K\n");
    return 1;
  }

  if (errcode = Object.ResolveReloc(RelocInfo, ImportInfo))
    return errcode;

  if (errcode = ExportInfo.Func(Object))
    return errcode;

  if (ExportInfo.tibasic_Section != NULL && ExportInfo.tibasic_Size != 0) {
    tibasic_fork = (BYTE *)ExportInfo.tibasic_Section->Data;
    tibasic_fork_size = ExportInfo.tibasic_Size;
  }

  TableOffset = SymbolSize;
  DumpTables(NULL, SymbolSize);

  VERBOSE("%s is %d bytes\n", ExportInfo.file_desc, SymbolSize);

  if (SymbolSize > 0x10000) {
    printf("%s is too big to fit in 64K\n", ExportInfo.file_desc);
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
	if (((Section92P *)SectionPtr->Info)->InSymbol())
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

  VERBOSE("Writing data to %s...", ExportInfo.file_desc);

  fwrite(header, 1, HEADER_SIZE, f);
  fwrite(Data, 1, SymbolSize + 2, f);

  fclose(f);

  VERBOSE("done!\n");

  return 0;
}

int ObjectGroup::Write92P(char *the_output_file, char *the_symbol_name, char *the_folder_name)
{
  Output92P Output(*this, the_output_file, the_symbol_name, the_folder_name);
  return Output.Write();
}
