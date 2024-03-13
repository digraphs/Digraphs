#include <stdlib.h>
#include "digraphs-debug.h"
#include "safemalloc.h"

void* safe_malloc(size_t size){
	void* allocation = malloc(size);
	DIGRAPHS_ASSERT(allocation!=NULL);

	return allocation;
}