#include <cmath>
#include <iostream>
#include <assert.h>
#include <algorithm>
#include "practice27.h"

using namespace std;

int main()
{
    long long k;
    Node tmp = NULL;
    tmp = treeInsert(tmp, 4);
    treeInsert(tmp, 5);
    Node ans = treeFind(tmp, 4);
    cout << "Find, expected: 4, found: ";
    if (ans == NULL)
    {
        cout << "NULL" << endl;
    }
    else
    {
        k = *(long long*) ans;
        cout << k << endl;
    }

    ans = treeFind(tmp, 5);
    cout << "Find, expected: 5, found: ";
    if (ans == NULL)
    {
        cout << "NULL" << endl;
    }
    else
    {
        k = *(long long*) ans;
        cout << k << endl;
    }

    treeInsert(tmp, 8);
    treeInsert(tmp, 7);

    ans = treeFind(tmp, 8);
    cout << "Find, expected: 8, found: ";
    if (ans == NULL)
    {
        cout << "NULL" << endl;
    }
    else
    {
        k = *(long long*) ans;
        cout << k << endl;
    }

    ans = treeFind(tmp, 7);
    cout << "Find, expected: 7, found: ";
    if (ans == NULL) 
    {
        cout << "NULL" << endl;
    }
    else
    {
        k = *(long long*) ans;
        cout << k << endl;
    }

    ans = treeFind(tmp, 6);
    cout << "Find, expected: NULL, found: ";
    if (ans == NULL)
    {
        cout << "NULL" << endl;
    }
    else
    {
        k = *(long long*) ans;
        cout << k << endl;
    }

    ans = treeFind(tmp, 8);
    Node ans1 = nextTree(ans);
    cout << "Next, expected: NULL, found: ";
    if (ans1 == NULL)
    {
        cout << "NULL" << endl;
    }
    else
    {
        k = *(long long*) ans1;
        cout << k << endl;
    }

    ans = treeFind(tmp, 5);
    ans1 = nextTree(ans);
    cout << "Next, expected: 7, found: ";
    if (ans1 == NULL)
    {
        cout << "NULL" << endl;
    }
    else
    {
        k = *(long long*) ans1;
        cout << k << endl;
    }

    Node ans2 = prevTree(ans);
    cout << "Prev, expected: 4, found: ";
    if (ans2 == NULL)
    {
        cout << "NULL" << endl;
    }
    else
    {
        k = *(long long*) ans2;
        cout << k << endl;
    }

    ans = treeFind(tmp, 4);
    ans2 = prevTree(ans);
    cout << "Prev, expected: NULL, found: ";
    if (ans2 == NULL)
    {
        cout << "NULL" << endl;
    }
    else
    {
        k = *(long long*) ans2;
        cout << k << endl;
    }

    tmp = treeInsert(tmp, 4);
    treeInsert(tmp, 3);
    treeInsert(tmp, 5);
    ans = treeFind(tmp, 4);
    removeTree(ans);
    ans = treeFind(tmp, 5);
    ans2 = prevTree(ans);
    cout << "Prev is left and right, expected: 3, found: ";
    if (ans2 == NULL)
    {
        cout << "NULL" << endl;
    }
    else 
    {
        long long k = *(long long*) ans2;
        cout << k << endl;
    }

    Node tree = NULL;
    tree = treeInsert(tree, 0);
    treeInsert(tree, 1);
    treeInsert(tree, 3);
    treeInsert(tree, 2);
    Node q = treeFind(tree, 1);
    removeTree(q);
    Node root = treeFind(tree, 0);
    Node n = nextTree(root);
    cout << "Remove not left, expected: 2, found: ";
    if (n == NULL)
    {
        cout << "NULL" << endl;
    }
    else
    {
        long long k = *(long long*) n;
        cout << k << endl;
    }

    tree = NULL;
    tree = treeInsert(tree, 5);
    treeInsert(tree, 1);
    treeInsert(tree, 3);
    treeInsert(tree, 2);
    q = treeFind(tree, 3);
    removeTree(q);
    Node r = treeFind(tree, 2);
    n = nextTree(r);
    cout << "Remove not right, expected: 5, found: ";
    if (n == NULL)
    {
        cout << "NULL" << endl;
    }
    else
    {
        long long k = *(long long*) n;
        cout << k << endl;
    }
    return 0;
}
