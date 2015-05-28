#include <iostream>
#include <cmath>
#include <algorithm>
#include <string>
#include <cstdio>
#include "stringCmp.h"

using namespace std;

int main()
{
	string s, t;
	cin >> s >> t;
	int res = rabinkarp(s, t);
	cout << res << endl;
}