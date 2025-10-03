extern "C" {
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <time.h>
#include <assert.h>
}
#include "endian.h"
#include "lists.h"
#include "hash.h"

#define FALSE 0
#define TRUE !FALSE

#define VERBOSE if (verbose) printf
#define VVERBOSE if (verbose > 1) printf

typedef enum {Hunk_Code, Hunk_Data, Hunk_BSS} HunkType;
typedef enum {relref32, relref16, absref16, absref8} XRefType;
typedef enum {reldef, absdef} XDefType;

extern unsigned int verbose;
extern int is_invalid_name(const BYTE *s);

class Unit;
class Section;
class SectionGeneric;

struct OffsetList {
  LONG Size;  // number of entries in list
  LONG *List; // list of offsets
};

struct RelTab {
  union {
    LONG SectionNum;     // index of referenced section
    Section *SectionPtr; // pointer to referenced section
  };
  XRefType Type;         // operand type of reference
  OffsetList Offsets; /* offsets of all the references to
			 the given section with the given
			 operand type */
};

struct XRef {
  XRefType Type;      // operand type of reference
  char *Name;         // referenced symbol name
  OffsetList Offsets; /* offsets of all the references to
			 the given symbol with the given
			 operand type */
};

class Section {
public:
  char *FullName();
  Unit *UnitPtr; // parent unit
  char *Name;    // name of section
  HunkType Type; // hunk type
  LONG Size;     // size of section in longwords
  BYTE *Data;    // pointer to section data
  List<struct RelTab> RelTabs;
  List<struct XRef> XRefs;
  SectionGeneric *Info;
};

class Unit {
public:
  char *filename;
  char *Name;
  List<Section> Sections;
};

class SectionGeneric {
public:
  virtual LONG GetAddress() { return 0; }
};

class XDef {
public:
  XDefType Type;       // type of definition
  Section *SectionPtr; // section where symbol is located
  union {
    LONG Offset;       // if Type=reldef: offset of symbol in section
    LONG Value;        // if Type=absdef: value of symbol
  };

  LONG GetAddress() {
    switch (Type) {
    case reldef:
      return SectionPtr->Info->GetAddress() + Offset;
    default: /*absdef*/
      return Value;
    }
  }
};

class FixupGeneric {
public:
  virtual char *Error() { return NULL; }
  virtual LONG DoFixup(Section *SectionPtr, LONG Offset) { return 0; }
};

class FixupError : public FixupGeneric {
public:
  FixupError(char *theError) { ErrorStr = theError; }
  char *Error() { return ErrorStr; }
private:
  char *ErrorStr;
};

class RelocGeneric {
public:
  virtual FixupGeneric *Func(SectionGeneric *Ref_Section, int Type,
			     SectionGeneric *Def_Section, LONG Offset)
    { return NULL; }
};

class ImportGeneric {
public:
  virtual FixupGeneric *Func(SectionGeneric *Ref_Section, int Type, char *Name)
    { return NULL; }
};

class ObjectGroup {
public:
  ObjectGroup():XDefs(2048) {}

  int ReadA68k(char *input_file);
  int Write92P(char *output_file, char *symbol_name, char *folder_name);
  int Write9XZ(char *plusasm_file, char *symbol_name, char *folder_name);
  int WriteOld92P(char *old92p_file, char *symbol_name, char *folder_name);
  int Write92B(char *backup_file);

  int ResolveReloc(RelocGeneric &RelocInfo, ImportGeneric &ImportInfo);

  List<Unit> Units;
  SymTable<XDef> XDefs;
};
