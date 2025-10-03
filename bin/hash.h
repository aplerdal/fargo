#ifndef HASH_H
#define HASH_H

template<class NODETYPE>
class SymTable;

template<class NODETYPE>
class SymIter;

template<class NODETYPE>
class SymNode {
  friend class SymTable<NODETYPE>;
  friend class SymIter<NODETYPE>;
public:
  SymNode(const char *, SymNode<NODETYPE> *);
  ~SymNode();
  char *GetName() const {return Name;}
  NODETYPE *GetData() {return &Data;}
private:
  char *Name;
  NODETYPE Data;
  SymNode *Next;
};

template<class NODETYPE>
SymNode<NODETYPE>::SymNode(const char *NewName, SymNode<NODETYPE> *Link)
{
  Name = new char [strlen(NewName) + 1];
  strcpy(Name, NewName);
  Next = Link;
}

template<class NODETYPE>
SymNode<NODETYPE>::~SymNode()
{
  delete [] Name;
}

template<class NODETYPE>
class SymTable {
  friend class SymIter<NODETYPE>;
public:
  SymTable(const int size);
  ~SymTable();
  void Add(const char *, const NODETYPE &);
  NODETYPE *AddNew(const char *);
  NODETYPE *Find(const char *);
private:
  int HashSize;
  SymNode<NODETYPE> **Hash;
  SymNode<NODETYPE> **GetHash(const char *);
};

template<class NODETYPE>
SymTable<NODETYPE>::SymTable(const int size)
{
  Hash = new SymNode<NODETYPE> *[HashSize = size];
  for (int i = 0; i < HashSize; i++)
    Hash[i] = NULL;
}

template<class NODETYPE>
SymTable<NODETYPE>::~SymTable()
{
  for (int i = 0; i < HashSize; i++) {
    SymNode<NODETYPE> *Temp, *SymNodePtr = Hash[i];
    while (SymNodePtr) {
      Temp = SymNodePtr;
      SymNodePtr = SymNodePtr->Next;
      delete Temp;
    }
  }
  delete [] Hash;
}

template<class NODETYPE>
SymNode<NODETYPE> **SymTable<NODETYPE>::GetHash(const char *label)
{
  unsigned i = 0;
  while (*label) {
    i = ((i << 3) - i + *label++) % HashSize;
  }
  return &Hash[i];
}

template<class NODETYPE>
NODETYPE *SymTable<NODETYPE>::AddNew(const char *label)
{
  SymNode<NODETYPE> **HashPtr = GetHash(label);
  SymNode<NODETYPE> *NewSym = new SymNode<NODETYPE>(label, *HashPtr);
  *HashPtr = NewSym;
  return &NewSym->Data;
}

template<class NODETYPE>
NODETYPE *SymTable<NODETYPE>::Find(const char *label)
{
  SymNode<NODETYPE> *HashPtr = *GetHash(label);
  while (HashPtr != NULL) {
    if (strcmp(HashPtr->Name, label) == 0)
      return &HashPtr->Data;
    HashPtr = HashPtr->Next;
  }
  return NULL;
}

template <class NODETYPE>
class SymIter {
public:
  SymIter():HashSize(0),CurrentHash(0),CurrentNode(NULL) {}
  SymIter(SymTable<NODETYPE> &theSymTable) {
    Start(theSymTable);
  }
  void Start(SymTable<NODETYPE> &theSymTable) {
    HashSize = theSymTable.HashSize;
    Hash = theSymTable.Hash;
    CurrentHash = 0;
    CurrentNode = *Hash;
  }
  SymNode<NODETYPE> *Get() {
    SymNode<NODETYPE> *Data;
    while (CurrentNode == NULL) {
      if (++CurrentHash == HashSize)
	return NULL;
      CurrentNode = Hash[CurrentHash];
    }
    Data = CurrentNode;
    CurrentNode = CurrentNode->Next;
    return Data;
  }
private:
  int HashSize, CurrentHash;
  SymNode<NODETYPE> **Hash, *CurrentNode;
};

#endif
