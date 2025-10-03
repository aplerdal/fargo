#ifndef BIGARRAY_H
#define BIGARRAY_H

template<class NODETYPE>
class BigArray {
  friend class BigArrayIndex;
  friend class BigArrayIter;
public:
  BigArray() {
    Indir = new (NODETYPE ***) [256] (NULL);
    Count = 0;
  }
  ~BigArray() {
  }
private:
  NODETYPE ****Indir;
};

template <class NODETYPE>
NODETYPE *BigArray<NODETYPE>::operator [] (BigArrayIndex &i)
{
  if (Indir[i.x]      == NULL) Indir[i.x]      = new (NODETYPE **) [256] (NULL);
  if (Indir[i.x][i.y] == NULL) Indir[i.x][i.y] = new (NODETYPE  *) [256] (NULL);
  NODETYPE **Node = &Indir[i.x][i.y][i.z];
  if (*Node == NULL)
    *Node = new NODETYPE;
  return *Node;
}

class BigArrayIndex {
public:
  BigArrayIndex():x(0),y(0),z(0) {}
  BigArrayIndex(int i) {
    x = i / 256 / 256;
    y = (i / 256) % 256;
    z = i % 256;
  }
  BigArrayIndex &operator ++ () {
    if (++z == 256) {
      if (++y == 256) {
	if (++x == 256) {
	  x = 256-1;
	  y = 256-1;
	  z = 256-1;
	  return this;
	}
	y = 0;
      }
      z = 0;
    }
    return this;
  }
  BigArrayIndex &operator -- () {
    if (z == 0) {
      if (y == 0) {
	if (x == 0) {
	  y = 0;
	  z = 0;
	  return this;
	}
	--x; y = 256;
      }
      --y; z = 256;
    }
    --z;
    return this;
  }
private:
  int x, y, z;
};

template <class NODETYPE>
class BigArrayIter {
public:
  BigArrayIter() {}
  void Start(BigArray<NODETYPE> &theBigArray) {
    CurBigArray = &theBigArray;
    i = 0;
  }
  NODETYPE *Get() {
    return CurBigArray[i++];
  }
private:
  BigArray *CurBigArray;
  BigArrayIndex i;
};

#endif
