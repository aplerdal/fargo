#include "flinker.h"

char *Section::FullName()
{
  if (Name[0] != ' ' || Name[1] != '\0')
    return Name;
  else
    switch (Type) {
    case Hunk_Code: return ".code";
    case Hunk_Data: return ".data";
    case Hunk_BSS:  return ".bss";
    }
}

class RefList {
public:
  virtual OffsetList GetOffsets() {}
  virtual int GetType() {}
  virtual int print(FILE *f) {}
};

class RefListXRef : public RefList {
public:
  RefListXRef(XRef *theXRefPtr) {
    XRefPtr = theXRefPtr;
  }
  OffsetList GetOffsets() { return XRefPtr->Offsets; }
  int GetType() { return XRefPtr->Type; }
  int print(FILE *f) {
    return fprintf(f, "`%s'\n", XRefPtr->Name);
  }
private:
  XRef *XRefPtr;
};

class RefListRelTab : public RefList {
public:
  RefListRelTab(RelTab *theRelTabPtr) {
    RelTabPtr = theRelTabPtr;
  }
  OffsetList GetOffsets() { return RelTabPtr->Offsets; }
  int GetType() { return RelTabPtr->Type; }
  int print(FILE *f) {
    return fprintf(f, "section %s\n", RelTabPtr->SectionPtr->FullName());
  }
  //private:
  RelTab *RelTabPtr;
};

bool DoFixups(Section *SectionPtr, RefList *RefListInfo, FixupGeneric *FixupInfo)
{
  OffsetList Offsets = RefListInfo->GetOffsets();
  int XRefType = RefListInfo->GetType();
  char *ErrorStr = FixupInfo->Error();
  bool Error = FALSE;
  for (int i = 0; i < Offsets.Size; i++) {
    LONG Offset = Offsets.List[i];
    if (!ErrorStr) {
      LONG Address = FixupInfo->DoFixup(SectionPtr, Offset);
      if (Address != 0) {
	void *OperandPtr = (BYTE *)SectionPtr->Data + Offset;
	LONG OperandAddress = SectionPtr->Info->GetAddress() + Offset;
	switch (XRefType) {
	case relref32: {
	  LONG OldOperand = convBE(*(LONG *)OperandPtr);
	  if ((LONG)(OldOperand ^ 0xFFFFFFFF) < Address)
	    ErrorStr = "out-of-range 32-bit absolute";
	  else {
	    *(LONG *)OperandPtr = convBE(Address + OldOperand);
	    ErrorStr = NULL;
	  }
	  break;
	}
	case relref16: {
	  SWORD OldOperand = (SWORD)convBE(*(WORD *)OperandPtr);
	  SLONG NewOperand = (SLONG)(Address - OperandAddress) + OldOperand;
	  if (NewOperand < -0x8000 || NewOperand >= 0x8000)
	    ErrorStr = "out-of-range 16-bit PC-relative";
	  else {
	    *(WORD *)OperandPtr = convBE((WORD)NewOperand);
	    ErrorStr = NULL;
	  }
	  break;
	}
	case absref16: {
	  SLONG NewOperand = Address + (SWORD)convBE(*(WORD *)OperandPtr);
	  if (NewOperand < -0x8000 || NewOperand >= 0x8000)
	    ErrorStr = "out-of-range 16-bit absolute";
	  else {
	    *(WORD *)OperandPtr = convBE((WORD)NewOperand);
	    ErrorStr = NULL;
	  }
	  break;
	}
	case absref8: {
	  SLONG NewOperand = Address + *(BYTE *)OperandPtr;
	  if (NewOperand < -0x80 || NewOperand >= 0x80)
	    ErrorStr = "out-of-range 8-bit absolute";
	  else {
	    *(BYTE *)OperandPtr = (BYTE)NewOperand;
	    ErrorStr = NULL;
	  }
	  break;
	}
	default:
	  ErrorStr = "unsupported operand type in";
	}	      
      }
    }
    if (ErrorStr) {
      printf("%s(%s+0x%X): %s reference to ",
	     SectionPtr->UnitPtr->filename, SectionPtr->FullName(), Offset, ErrorStr);
      RefListInfo->print(stdout);
      Error = TRUE;
    }
  }
  return Error;
}

int ObjectGroup::ResolveReloc(RelocGeneric &RelocInfo, ImportGeneric &ImportInfo)
{
  ListIter<Unit>    UnitIter;    Unit    *UnitPtr;
  ListIter<Section> SectionIter; Section *SectionPtr;
  ListIter<RelTab>  RelTabIter;  RelTab  *RelTabPtr;
  ListIter<XRef>    XRefIter;    XRef    *XRefPtr;
  LONG Target;
  int Error = 0;

  VERBOSE("Resolving internal and external references\n");
  UnitIter.Start(Units);
  while (UnitPtr = UnitIter.Get()) {
    Section **Sections = new Section*[UnitPtr->Sections.GetCount()];
    int SectionNum = 0;

    SectionIter.Start(UnitPtr->Sections);
    while (SectionPtr = SectionIter.Get()) {
      XRefIter.Start(SectionPtr->XRefs);
      while (XRefPtr = XRefIter.Get()) {
	FixupGeneric *FixupInfo;
	XDef *XDefPtr = XDefs.Find(XRefPtr->Name);
	if (XDefPtr) {
	  FixupInfo = RelocInfo.Func(SectionPtr->Info, XRefPtr->Type,
				     XDefPtr->SectionPtr->Info, XDefPtr->Offset);
	  if (FixupInfo == NULL)
	    FixupInfo = new FixupError("illegal");
	}
	else {
	  FixupInfo = ImportInfo.Func(SectionPtr->Info, XRefPtr->Type, XRefPtr->Name);
	  if (FixupInfo == NULL)
	    FixupInfo = new FixupError("undefined");
	}
	RefListXRef TempRefList(XRefPtr);
	if (DoFixups(SectionPtr, &TempRefList, FixupInfo))
	  Error = 1;
	delete FixupInfo;
      }
      Sections[SectionNum++] = SectionPtr;
    }

    SectionIter.Start(UnitPtr->Sections);
    while (SectionPtr = SectionIter.Get()) {
      RelTabIter.Start(SectionPtr->RelTabs);
      while (RelTabPtr = RelTabIter.Get()) {
	RelTabPtr->SectionPtr = Sections[RelTabPtr->SectionNum];
	FixupGeneric *FixupInfo;
	FixupInfo = RelocInfo.Func(SectionPtr->Info, RelTabPtr->Type,
				   RelTabPtr->SectionPtr->Info, 0);
	if (FixupInfo == NULL)
	  FixupInfo = new FixupError("illegal");
	RefListRelTab TempRefList(RelTabPtr);
	if (DoFixups(SectionPtr, &TempRefList, FixupInfo))
	  Error = 1;
	delete FixupInfo;
      }
    }

    delete [] Sections;
  }

  return Error;
}
