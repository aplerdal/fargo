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

class SectionOld92P : public SectionGeneric {
public:
  virtual LONG GetAddress() { return 0; }
  virtual bool CanReference() { return FALSE; }
  virtual bool CanReference(SectionOld92P *SectionInfo) { return FALSE; }
  virtual bool InSymbol() { return FALSE; }
  virtual bool IsLoaded() { return FALSE; }
};

class SectionOld92P_CodeData : public SectionOld92P {
public:
  SectionOld92P_CodeData(LONG theAddress)
    { Address = theAddress; }
  LONG GetAddress() { return Address; }
  bool CanReference() { return TRUE; }
  bool CanReference(SectionOld92P *SectionInfo)
    { return SectionInfo->IsLoaded(); }
  bool InSymbol() { return TRUE; }
  bool IsLoaded() { return TRUE; }
private:
  LONG Address;
};

class FixupOld92P : public FixupGeneric {
public:
  FixupOld92P(List<LONG> &theRelocList) {
    RelocList = &theRelocList;
    Address = 0;
  }
  FixupOld92P(List<LONG> &theRelocList, LONG theAddress) {
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

class RelocOld92P : public RelocGeneric {
public:
  RelocOld92P(List<LONG> &theReloc):Reloc(theReloc) {}
  FixupGeneric *Func(SectionGeneric *Ref_Section, int Type,
		     SectionGeneric *Def_Section, LONG Offset) {
    if (((SectionOld92P *)Ref_Section)->CanReference((SectionOld92P *)Def_Section)) {
      if (Type == relref32)
	return new FixupOld92P(Reloc, Def_Section->GetAddress() + Offset - 2);
      else
	return new FixupError("illegal operand size in");
    }
    else
      return new FixupError("illegal");
  }
  List<LONG> &Reloc;
};

class ImportOld92P : public ImportGeneric {
public:
  ImportOld92P(List<LONG> &theReloc, SymTable<XDef> &theXDefs):Reloc(theReloc),XDefs(theXDefs),ImportNums(256) {}
  FixupGeneric *Func(SectionGeneric *Ref_Section, int Type, char *Name);
  void DumpLibs(BYTE *Data, LONG &Offset);
  void DumpSpace(BYTE *Data, LONG &Offset);

  List<LONG> &Reloc;
  SymTable<XDef> &XDefs;
  List<char *> ImportLibs;
  SymTable<WORD> ImportNums;
};

class ExportOld92P {
public:
  ExportOld92P(SymTable<XDef> &theXDefs):XDefs(theXDefs) {}
  int Count();
  int Func(ObjectGroup &Object);
  void Dump(BYTE *Data, LONG Offset);

  SymTable<XDef> &XDefs;
  int NumExports;
  LONG *Exports;
  char subtype;   // 'P' or 'L'
  char *file_desc; // "Fargo program" or "Fargo library"
  char *library_name;
  char *program_comment;
  LONG library_name_Offset;
  LONG program_comment_Offset;
};

class OutputOld92P {
public:
  OutputOld92P(ObjectGroup &theObject, char *the_output_file, char *the_symbol_name, char *the_folder_name)
    :Object(theObject),output_file(the_output_file),symbol_name(the_symbol_name),folder_name(the_folder_name),
     RelocInfo(Reloc),ImportInfo(Reloc, theObject.XDefs),ExportInfo(theObject.XDefs) {}
  int DumpHeader(BYTE *Data);
  void DumpTables(BYTE *Data, LONG &Offset);
  int Write();
private:
  ObjectGroup &Object;
  char *output_file;
  char *symbol_name;
  char *folder_name;

  LONG SymbolSize;  // Total size of TI-92 variable

  List<LONG> Reloc; // relocation table

  RelocOld92P RelocInfo;   // relocation info
  ImportOld92P ImportInfo; // import info
  ExportOld92P ExportInfo; // export info
};

FixupGeneric *ImportOld92P::Func(SectionGeneric *Ref_Section, int Type, char *Name)
{
  if (!((SectionOld92P *)Ref_Section)->CanReference())
    return new FixupError("illegal");

  int len = strlen(Name);
  char *d = strchr(Name, '[');
  if (d != NULL && Name[len-1] == ']') {
    XDef *theXDef;
    WORD SymNum, LibNum;

    char *splice = new char [strlen(Name) + 8];
    memcpy(splice, Name, len);
    memcpy(splice+len, ".index", 7);
    if ((theXDef = XDefs.Find(splice)) != NULL && theXDef->Type == absdef)
      SymNum = theXDef->Value;
    else
      return NULL;

    *d = '\0';
    if (strcmp(Name, "core") == 0)
      LibNum = 0xFF;
    else {
      WORD *ImportNumPtr = ImportNums.Find(Name);
      if (ImportNumPtr == NULL) {
	ImportNumPtr = ImportNums.AddNew(Name);
	*ImportNumPtr = ImportLibs.GetCount();

	char * *ImportLibPtr = ImportLibs.AppendNew();
	*ImportLibPtr = new char [strlen(Name)+1];
	strcpy(*ImportLibPtr, Name);
      }
      LibNum = *ImportNumPtr + 1;
    }
    *d = '[';

    if (Type == relref32)
      return new FixupOld92P(Reloc, LibNum * 0x1000000 + SymNum * 2);
    else
      return new FixupError("illegal operand size in");
  }
  else
    return NULL;
}

int ExportOld92P::Count()
{
  XDef *XDefPtr;
  char *Name;
  int len;
  int n, Count = 0;

  if (XDefPtr = XDefs.Find("_library")) {
    SymIter<XDef> XDefIter(XDefs);
    while (SymNode<XDef> *XDefSymPtr = XDefIter.Get()) {
      Name = XDefSymPtr->GetName();
      if (strncmp(Name, "_label[", 7) == 0) {
	len = strlen(Name);
	if (strncmp(Name+len-7, "].index", 6) == 0) {
	  if ((n = XDefSymPtr->GetData()->Value) > Count)
	    Count = n;
	}
      }
    }
    NumExports = Count + 1;
  }
  else {
    NumExports = XDefs.Find("_main") ? 1 : 0;
  }

  Exports = new LONG [NumExports];
  memset(Exports, sizeof(LONG) * NumExports, 0);

  return NumExports;
}

int ExportOld92P::Func(ObjectGroup &Object)
{
  XDef *XDefPtr;
  char *Name;
  int len;
  int i, j;

  if (XDefPtr = XDefs.Find("_library")) {
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
      if (is_invalid_name((BYTE *)library_name))
	printf("Warning: Invalid character(s) in library name\n");

      SymIter<XDef> XDefIter(XDefs);
      while (SymNode<XDef> *XDefSymPtr = XDefIter.Get()) {
	Name = XDefSymPtr->GetName();
	XDefPtr = XDefSymPtr->GetData();
	len = strlen(Name);
	if (strncmp(Name, "_label[", 7) == 0) {
	  if (Name[len-1] == ']') {
	    char *name = new char [len+7];
	    memcpy(name, Name, len);
	    strcpy(name+len, ".index");
	    XDef *IndexXDefPtr;
	    if ((IndexXDefPtr = XDefs.Find(name)) != NULL && IndexXDefPtr->Type == absdef)
	      Exports[IndexXDefPtr->Value] = XDefPtr->SectionPtr->Info->GetAddress() + XDefPtr->Offset;
	  }
	}
      }
      subtype = 'L';
    }
    else {
      printf("Warning: Library name too long\n");
      subtype = '?';
    }
  }
  else {
    file_desc = "Fargo program";
    library_name_Offset = 0;

    XDefPtr = XDefs.Find("_main");
    if (XDefPtr != NULL) {
      Exports[0] = XDefPtr->SectionPtr->Info->GetAddress() + XDefPtr->Offset;
      subtype = 'P';
    }
    else
      subtype = '?';

    XDefPtr = XDefs.Find("_comment");
    if (XDefPtr != NULL) {
      if (XDefPtr->Offset == 0)
	program_comment_Offset = 2; /* 2 will be subtracted later */
      else {
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
    }
    else
      program_comment_Offset = 0;
  }

  return 0;
}

void DumpReloc(List<LONG> &Reloc, BYTE *Data, LONG &Offset)
{
  ListSortIter<LONG> RelocIter(Reloc);
  while (LONG *current = RelocIter.Get()) {
    if (Data) *(WORD *)(Data + Offset) = convBE((WORD)(*current-2));
    Offset += 2;
  }
  if (Data) *(WORD *)(Data + Offset) = 0;
  Offset += 2;
}

void ImportOld92P::DumpLibs(BYTE *Data, LONG &Offset)
{
  if (Data) *(WORD *)(Data + Offset) = convBE((WORD)ImportLibs.GetCount());
  Offset += 2;
  ListIter<char *> ImportLibIter(ImportLibs);
  while (char * *ImportLibPtr = ImportLibIter.Get()) {
    char *c = *ImportLibPtr;
    int len = 0;
    while (TRUE) {
      if (Data) *(BYTE *)(Data + Offset) = *c;
      len++;
      if (len == 8) break;
      Offset++;
      if (*c == '\0') break;
      c++;
    }
  }
}

void ImportOld92P::DumpSpace(BYTE *Data, LONG &Offset)
{
  int size = ImportLibs.GetCount() * 2;
  if (Data) memset(Data + Offset, size, 0);
  Offset += size;
}

void ExportOld92P::Dump(BYTE *Data, LONG Offset)
{
  int i;

  for (i=0; i < NumExports; i++) {
    if (Data) *(WORD *)(Data + Offset) = convBE((WORD)(Exports[i]-2));
    Offset += 2;
  }
}

int OutputOld92P::DumpHeader(BYTE *Data)
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

void OutputOld92P::DumpTables(BYTE *Data, LONG &Offset)
{
  if (Data) *(WORD *)(Data + 0) = convBE((WORD)(SymbolSize-2));

  if (Data) *(BYTE *)(Data + 2+0) = 0;
  if (Data) *(BYTE *)(Data + 2+1) = ExportInfo.subtype;
  if (Data) memcpy(Data + 2+2, "10", 2);

  if (Data) *(WORD *)(Data + 2+4) = convBE((WORD)(Offset-2));
  DumpReloc(RelocInfo.Reloc, Data, Offset);

  if (Data) *(WORD *)(Data + 2+8) = convBE((WORD)(Offset-2));
  ImportInfo.DumpSpace(Data, Offset);

  if (Data) *(WORD *)(Data + 2+6) = convBE((WORD)(Offset-2));
  ImportInfo.DumpLibs(Data, Offset);

  if (Data) *(WORD *)(Data + 2+10) = 0;

  if (Data) {
    *(WORD *)(Data + 2+12) = convBE
      ((WORD)((ExportInfo.library_name_Offset ?
	       ExportInfo.library_name_Offset :
	       ExportInfo.program_comment_Offset)-2));
  }

  ExportInfo.Dump(Data, 2+14);

  if (Data) memcpy(Data + Offset, tibasic_fork, tibasic_fork_size);
  Offset += tibasic_fork_size;
}

int OutputOld92P::Write()
{
  LONG TableOffset;
  int errcode;

  VERBOSE("Entering Pass 1 of link output\n");

  SymbolSize =
    2 + // first word = size of data portion
    2 + // Fargo II signature / file type
    2 + // Version
    2 + // Relocation table pointer
    2 + // Library linking table #1 pointer
    2 + // Library linking table #2 pointer
    2 + // Relocation (usage) count
    2 + // Program comment / Library name
    ExportInfo.Count() * 2; // Export table

  {
    ListIter<Unit> UnitIter(Object.Units);
    while (Unit *UnitPtr = UnitIter.Get()) {
      ListIter<Section> SectionIter(UnitPtr->Sections);
      while (Section *SectionPtr = SectionIter.Get()) {
	LONG x = SectionPtr->Size * 4;
	SectionPtr->Info = new SectionOld92P_CodeData(SymbolSize);
	SymbolSize += x;
      }
    }
  }

  if (errcode = Object.ResolveReloc(RelocInfo, ImportInfo))
    return errcode;

  if (errcode = ExportInfo.Func(Object))
    return errcode;

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
	if (((SectionOld92P *)SectionPtr->Info)->InSymbol())
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

int ObjectGroup::WriteOld92P(char *the_output_file, char *the_symbol_name, char *the_folder_name)
{
  OutputOld92P Output(*this, the_output_file, the_symbol_name, the_folder_name);
  return Output.Write();
}
