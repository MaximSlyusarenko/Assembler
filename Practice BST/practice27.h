#ifndef _PRACTICE27_H
#define _PRACTICE27_H
#include <stdint.h>
#include <stddef.h>

typedef void* Node;

#ifdef __cplusplus
extern "C" {
#endif

Node treeInsert(Node tree, int64_t x);
Node treeFind(Node tree, int64_t x);
Node nextTree(Node tree);
Node prevTree(Node tree);
//void delete(Node tree, int64_t x);

#ifdef __cplusplus
}
#endif

#endif
