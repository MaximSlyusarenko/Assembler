#ifndef _PRACTICE20_STRINGCMP_H
#define _PRACTICE20_STRINGCMP_H
#include <stdint.h>
#include <stddef.h>
#include <string>

typedef void* BigInt;

#ifdef __cplusplus
extern "C" {
#endif

long long stringCmp(std::string s, std::string t);
int rabinkarp(std::string s, std::string t);

#ifdef __cplusplus
}
#endif

#endif