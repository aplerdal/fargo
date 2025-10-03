#include "flinker.h"

class Section92B : public SectionGeneric {
public:
  virtual LONG GetAddress() { return 0; }
  virtual bool CanReference() { return FALSE; }
  virtual bool CanReference(Section92B *SectionInfo) { return FALSE; }
  virtual bool InBackup() { return FALSE; }
  virtual bool IsStatic() { return FALSE; }
};

class Section92B_static : public Section92B {
public:
  Section92B_static() {}
  void SetAddress(LONG theAddress) { Address = theAddress; }
  LONG GetAddress() { return Address; }
  bool CanReference() { return TRUE; }
  bool CanReference(Section92B *SectionInfo)
    { return SectionInfo->IsStatic(); }
  bool InBackup() { return TRUE; }
  bool IsStatic() { return TRUE; }
private:
  LONG Address;
};

class Section92B_boot : public Section92B {
public:
  Section92B_boot(LONG theAddress) { Address = theAddress; }
  LONG GetAddress() { return Address; }
  bool CanReference() { return TRUE; }
  bool CanReference(Section92B *SectionInfo)
    { return SectionInfo->InBackup(); }
  bool InBackup() { return TRUE; }
  bool IsStatic() { return FALSE; }
private:
  LONG Address;
};

class Section92B_tios : public Section92B {
public:
  Section92B_tios() {}
  bool CanReference() { return FALSE; }
  bool CanReference(Section92B *SectionInfo)
    { return FALSE; }
};

class Section92B_tios_skipped : public Section92B {
public:
  Section92B_tios_skipped() {}
  bool CanReference() { return FALSE; }
  bool CanReference(Section92B *SectionInfo)
    { return FALSE; }
};

class Fixup92B : public FixupGeneric {
public:
  Fixup92B(LONG theAddress) {
    Address = theAddress;
  }
  LONG DoFixup(Section *SectionPtr, LONG Offset) {
    return Address;
  }
private:
  LONG Address;
};

class Reloc92B : public RelocGeneric {
public:
  Reloc92B() {}
  FixupGeneric *Func(SectionGeneric *Ref_Section, int Type,
		     SectionGeneric *Def_Section, LONG Offset) {
    if (((Section92B *)Ref_Section)->CanReference((Section92B *)Def_Section))
      return new Fixup92B(Def_Section->GetAddress() + Offset);
    else
      return new FixupError("illegal");
  }
};

class Import92B : public ImportGeneric {
public:
  Import92B():has_hook1(FALSE),has_hook2(FALSE) {}
  FixupGeneric *Func(SectionGeneric *Ref_Section, int Type, char *Name);

  LONG RAM_size;
  LONG ROM_origin;
  int ROM_exports;
  LONG tios_table;
  LONG *ROM_table_ptr;
  LONG hook1, hook2;
  bool has_hook1, has_hook2;

  LONG CopySource, CopyLength;
};

FixupGeneric *Import92B::Func(SectionGeneric *Ref_Section, int Type, char *Name)
{
  int i;

  if (!((Section92B *)Ref_Section)->CanReference())
    return new FixupError("illegal");

  char *d = strchr(Name, '@');
  if (d != NULL) {
    char *c = d + 1;
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
    if (strcmp(Name, "hook1") == 0) {
      *d = '@';
      if (has_hook1)
	return new Fixup92B(hook1);
      else
	return NULL;
    }
    else if (strcmp(Name, "hook2") == 0) {
      *d = '@';
      if (has_hook2)
	return new Fixup92B(hook2);
      else
	return NULL;
    }
    else if (strcmp(Name, "tios") == 0) {
      *d = '@';
      if (SymNum >= ROM_exports)
	return NULL;
      LONG Address = convBE(ROM_table_ptr[SymNum]);
      return new Fixup92B(Address & 0x400000 ? Address - 0x400000 + ROM_origin : Address);
    }
    else {
      *d = '@';
      return NULL;
    }
  }

  if (strcmp(Name, "_copy_source") == 0) return new Fixup92B(CopySource);
  if (strcmp(Name, "_copy_target") == 0) return new Fixup92B(RAM_size);
  if (strcmp(Name, "_copy_length") == 0) return new Fixup92B(CopyLength);
  if (strcmp(Name, "_tios_table" ) == 0) return new Fixup92B(tios_table);
  if (strcmp(Name, "_tios_count" ) == 0) return new Fixup92B(ROM_exports);
  return NULL;
}

int ObjectGroup::Write92B(char *backup_file)
{
  Reloc92B RelocInfo;
  Import92B ImportInfo;

  LONG CoreSize;
  LONG Offset;

  Section *BootSection = NULL;
  Section *tios_Section = NULL;

  char ROM_version[8+1];
  LONG ROM_extra_ID;
  LONG ROM_origin;
  int ROM_exports;
  LONG tios_table;
  LONG *ROM_table_ptr;
  LONG RAM_size, backup_start, bottom_estack, estack_max_index;
  LONG tmp;
  int i;

  FILE *f = fopen(backup_file, "r+b");
  if (f == NULL) {
    printf("Error opening backup file `%s'\n", backup_file);
    return 1;
  }

  {
    char temp[8];
    fseek(f, 0, SEEK_SET);
    fread(temp, 1, 8, f);
    if (memcmp(temp, "**TI92**", 8) != 0) {
      printf("This is not a proper TI-92 Graph Link backup file\n");
      return 1;
    }
  }
  {
    LONG temp;
    fseek(f, 0x48, SEEK_SET);
    fread(&temp, 1, 4, f);
    temp = convLE(temp);
    if (temp != 0x1D) {
      printf("This is not a proper TI-92 Graph Link backup file\n");
      return 1;
    }
  }

  fseek(f, 0x40, SEEK_SET);
  fread(ROM_version, 1, 8, f);
  ROM_version[8] = '\0';

  fseek(f, 0x168, SEEK_SET);
  fread(&ROM_origin, 4, 1, f);
  ROM_origin = convBE(ROM_origin) & 0xFFF00000;

  fseek(f, 0x29C, SEEK_SET);
  fread(&ROM_extra_ID, 4, 1, f);
  ROM_extra_ID = convBE(ROM_extra_ID) - ROM_origin + 0x400000;

  VERBOSE("Backup has ROM version %s and origin address 0x%X\n", ROM_version, ROM_origin);
  
  fseek(f, 0x52, SEEK_SET);
  fread(&tmp, 1, 4, f);
  ImportInfo.RAM_size = RAM_size = convBE(tmp) + 0xC;

  fseek(f, 0x01E2, SEEK_SET);
  fread(&tmp, 4, 1, f);
  bottom_estack = convBE(tmp);

  fseek(f, 0x01D8, SEEK_SET);
  fread(&tmp, 4, 1, f);
  estack_max_index = convBE(tmp);

  CoreSize = 0;
  {
    ListIter<Unit> UnitIter(Units);
    while (Unit *UnitPtr = UnitIter.Get()) {
      ListIter<Section> SectionIter(UnitPtr->Sections);
      while (Section *SectionPtr = SectionIter.Get()) {
	if (strncmp(SectionPtr->Name, "_tios_", 6) == 0) {
	  if (strcmp(SectionPtr->Name + 6, ROM_version) == 0
	      && (convBE(*(LONG *)SectionPtr->Data)) == ROM_extra_ID) {
	    if (tios_Section == NULL) {
	      SectionPtr->Info = new Section92B_tios();
	      tios_Section = SectionPtr;
	    }
	    else {
	      printf("Multiple tios sections defined for this ROM version\n");
	      return 1;
	    }
	  }
	  else
	    SectionPtr->Info = new Section92B_tios_skipped();
	}
	else if (strcmp(SectionPtr->Name, "_boot") == 0) {
	  if (BootSection == NULL) {
	    SectionPtr->Info = new Section92B_boot(bottom_estack);
	    BootSection = SectionPtr;
	  }
	  else {
	    printf("Multiple boot sections defined\n");
	    return 1;
	  }
	}
	else {
	  SectionPtr->Info = new Section92B_static();
	  CoreSize += SectionPtr->Size * 4;
	}
      }
    }
  }
  if (BootSection == NULL) {
    printf("No boot section found\n");
    return 1;
  }
  if (tios_Section == NULL) {
    printf("No tios section found for this ROM version\n");
    return 1;
  }

  ROM_table_ptr = ((LONG *)tios_Section->Data) + 1;
  ROM_exports = tios_Section->Size - 1;
  tios_table = RAM_size - ROM_exports * 4;
  CoreSize += ROM_exports * 4;

  Offset = RAM_size - CoreSize;
  {
    ListIter<Unit> UnitIter(Units);
    while (Unit *UnitPtr = UnitIter.Get()) {
      ListIter<Section> SectionIter(UnitPtr->Sections);
      while (Section *SectionPtr = SectionIter.Get()) {
	if (((Section92B *)SectionPtr->Info)->IsStatic()) {
	  ((Section92B_static *)SectionPtr->Info)->SetAddress(Offset);
	  Offset += SectionPtr->Size * 4;
	}
      }
    }
  }

  VERBOSE("Boot section is %d bytes, static kernel is %d bytes\n", BootSection->Size * 4, CoreSize);

  ImportInfo.ROM_exports = ROM_exports;
  ImportInfo.ROM_origin = ROM_origin;
  ImportInfo.tios_table = tios_table;
  ImportInfo.ROM_table_ptr = ROM_table_ptr;
  ImportInfo.CopyLength = CoreSize / 4 - 1;

  Offset -= BootSection->Size * 4;
  CoreSize += BootSection->Size * 4;

  ImportInfo.CopySource = bottom_estack + CoreSize;

  if (ImportInfo.CopySource > estack_max_index) {
    printf("Kernel is too big\n");
    return 1;
  }

  {
    XDef *XDefPtr;
    if ((XDefPtr = XDefs.Find("_hook1")) != NULL && XDefPtr->Type == reldef) {
      ImportInfo.hook1 = XDefPtr->GetAddress();
      ImportInfo.has_hook1 = TRUE;
    }
    if ((XDefPtr = XDefs.Find("_hook2")) != NULL && XDefPtr->Type == reldef) {
      ImportInfo.hook2 = XDefPtr->GetAddress();
      ImportInfo.has_hook2 = TRUE;
    }
  }

  if (ResolveReloc(RelocInfo, ImportInfo))
    return 1;

  BYTE *Core = new BYTE [CoreSize];

  {
    BYTE *Dest = Core;

    memcpy(Dest, BootSection->Data, BootSection->Size * 4);
    Dest += BootSection->Size * 4;

    ListIter<Unit> UnitIter(Units);
    while (Unit *UnitPtr = UnitIter.Get()) {
      ListIter<Section> SectionIter(UnitPtr->Sections);
      while (Section *SectionPtr = SectionIter.Get()) {
	if (((Section92B *)SectionPtr->Info)->IsStatic()) {
	  memcpy(Dest, SectionPtr->Data, SectionPtr->Size * 4);
	  Dest += SectionPtr->Size * 4;
	}
      }
    }

    for (i = 0; i < ROM_exports; i++) {
      LONG y = convBE(ROM_table_ptr[i]);
      if (y & 0x400000) y = y - 0x400000 + ROM_origin;
      *(((LONG *)Dest) + i) = convBE(y);
    }
  }

  VERBOSE("Writing kernel to backup file...", backup_file);

  fseek(f, 0x02D8, SEEK_SET);
  tmp = convBE(bottom_estack);
  fwrite(&tmp, 4, 1, f);
  
  fseek(f, bottom_estack - (convBE(ROM_table_ptr[0x1C])+0x1088 /* tios::main_lcd+$1088 */), SEEK_SET);
  fwrite(Core, 1, CoreSize, f);

  delete [] Core;

  VERBOSE("fixing checksum...");

  {
    BYTE buf[0x8000];
    WORD checksum = 0;
    LONG size, bytes_left;
    int i, j;

    fseek(f, 0x4C, SEEK_SET);
    fread(&tmp, 4, 1, f);
    size = convLE(tmp);

    fseek(f, 0x52, SEEK_SET);
    bytes_left = size - 0x52 - 2;
    while (bytes_left > 0) {
      j = sizeof(buf) < bytes_left ? sizeof(buf) : bytes_left;
      fread(buf, 1, j, f); bytes_left -= j;
      for (i = 0; i < j; checksum += buf[i++]);
    }

    fseek(f, size - 2, SEEK_SET);
    tmp = convLE(checksum);
    fwrite(&tmp, 2, 1, f);
  }

  fclose(f);

  VERBOSE("done!\n");

  return 0;
}
