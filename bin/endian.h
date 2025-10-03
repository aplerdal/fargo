#include <stdint.h>
typedef uint8_t BYTE;
typedef uint16_t WORD;
typedef uint32_t LONG;
typedef uint8_t SBYTE;
typedef uint16_t SWORD;
typedef uint32_t SLONG;

#if defined(LITTLE_ENDIAN) && defined(BIG_ENDIAN) && defined(BYTE_ORDER)
#  define OUR_LITTLE_ENDIAN   LITTLE_ENDIAN
#  define OUR_BIG_ENDIAN      BIG_ENDIAN
#  define OUR_BYTE_ORDER      BYTE_ORDER
#else
#  define OUR_LITTLE_ENDIAN   1234    /* LSB first: i386, vax */
#  define OUR_BIG_ENDIAN      4321    /* MSB first: 68000, ibm, net */
#  define OUR_BYTE_ORDER      OUR_LITTLE_ENDIAN
#endif

#define BEtoLE convBE

static union {
  WORD a;
  BYTE b[2];
};

static union {
  LONG c;
  BYTE d[4];
};

inline WORD convLE(WORD n)
{
#if OUR_BYTE_ORDER == OUR_LITTLE_ENDIAN
  return n;
#else
  a = n;
  return ((b[0] << 0x00)|
	  (b[1] << 0x08));
#endif
}

inline LONG convLE(LONG n)
{
#if OUR_BYTE_ORDER == OUR_LITTLE_ENDIAN
  return n;
#else
  c = n;
  return ((d[0] << 0x00)|
	  (d[1] << 0x08)|
	  (d[2] << 0x10)|
	  (d[3] << 0x18));
#endif
}

inline WORD convBE(WORD n)
{
#if OUR_BYTE_ORDER == OUR_BIG_ENDIAN
  return n;
#else
  a = n;
  return ((b[0] << 0x08)|
	  (b[1] << 0x00));
#endif
}

inline LONG convBE(LONG n)
{
#if OUR_BYTE_ORDER == OUR_BIG_ENDIAN
  return n;
#else
  c = n;
  return ((d[0] << 24)|
	  (d[1] << 16)|
	  (d[2] << 8)|
	  (d[3] << 0));
#endif
}
