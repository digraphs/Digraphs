#include <stdlib.h>
#include <stdbool.h>
#include <assert.h>

#ifdef SYS_IS_64_BIT
#define MAXVERTS 512
typedef unsigned long int UIntL;
#define SMALLINTLIMIT 1152921504606846976
#define SYS_BITS 64
#else
#define MAXVERTS 256
typedef unsigned int UIntL;
#define SMALLINTLIMIT 268435456
#define SYS_BITS 32
#endif

typedef unsigned short int UIntS;

static UIntS perm_buf[MAXVERTS];
typedef UIntS* perm;
