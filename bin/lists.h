#ifndef LISTS_H
#define LISTS_H

template<class NODETYPE>
class List;

template<class NODETYPE>
class ListIter;

template<class NODETYPE>
class ListSortIter;

template<class NODETYPE>
class ListNode {
  friend class List<NODETYPE>;
  friend class ListIter<NODETYPE>;
  friend class ListSortIter<NODETYPE>;
public:
  ListNode():Next(NULL) {}
private:
  NODETYPE Data;
  ListNode *Next;
};

template<class NODETYPE>
class List {
  friend class ListIter<NODETYPE>;
  friend class ListSortIter<NODETYPE>;
public:
  List():Head(NULL),Tail(NULL),Count(0) {}
  ~List() {
    ListNode<NODETYPE> *Temp;
    while (Head != NULL) {
      Temp = Head;
      Head = Head->Next;
      delete Temp;
    }
  }
  NODETYPE *AppendNew();
  int GetCount() {
    return Count;
  }
private:
  ListNode<NODETYPE> *Head, *Tail;
  int Count;
};

template <class NODETYPE>
NODETYPE *List<NODETYPE>::AppendNew() {
  ListNode<NODETYPE> *NewNode = new ListNode<NODETYPE>;
  if (Head == NULL)
    Head = NewNode;
  else
    Tail->Next = NewNode;
  Tail = NewNode;
  Count ++;
  return &NewNode->Data;
}

template <class NODETYPE>
class ListIter {
public:
  ListIter():Current(NULL) {}
  ListIter(List<NODETYPE> &theList) {
    Start(theList);
  }
  void Start(List<NODETYPE> &theList) {
    Current = theList.Head;
  }
  NODETYPE *Get() {
    NODETYPE *Data;
    if (Current == NULL)
      return NULL;
    Data = &Current->Data;
    Current = Current->Next;
    return Data;
  }
private:
  ListNode<NODETYPE> *Current;
};

template <class NODETYPE>
class ListSortIter {
public:
  ListSortIter():Total(0) {}
  ListSortIter(List<NODETYPE> &theList) {
    Start(theList);
  }
  void Start(List<NODETYPE> &theList) {
    Head = theList.Head;
    Last = NULL;
    Total = theList.Count;
  }
  NODETYPE *Get();
private:
  ListNode<NODETYPE> *Head;
  NODETYPE *Last;
  int Total;
};

template <class NODETYPE>
NODETYPE *ListSortIter<NODETYPE>::Get()
{
  if (Total == 0) return NULL;
  ListNode<NODETYPE> *Iter = Head;
  NODETYPE *Current = NULL;
  while (Iter) {
    if ((Last    == NULL || Iter->Data > *Last   ) &&
	(Current == NULL || Iter->Data < *Current)) {
      Current = &Iter->Data;
    }
    Iter = Iter->Next;
  }
  Last = Current; Total--;
  return Current;
}

#endif
