#include <cmath>
#include <iostream>
#include <assert.h>
#include <algorithm>
#include <cstdio>
#include "practice.h"

bool eq(double a, double b)
{
    using namespace std;
    return abs(a-b) < max(0.00001, abs(a) * 0.00001);
}

int main()
{
    assert(eq(str2double("0.0"), 0.0));
    assert(eq(str2double("1.0"), 1.0));
    assert(eq(str2double("1000000.0"), 1000000.0));
    assert(eq(str2double("0.5"), 0.5));
    assert(eq(str2double("0.33333"), 0.33333));
    assert(eq(str2double("-.1234"), -0.1234)); 
    return 0;
}
