#!/bin/bash
export LC_ALL=C
set -e
CC="${TEST_CC:-cc}"
CXX="${TEST_CXX:-c++}"
GCC="${TEST_GCC:-gcc}"
GXX="${TEST_GXX:-g++}"
OBJDUMP="${OBJDUMP:-objdump}"
MACHINE="${MACHINE:-$(uname -m)}"
testname=$(basename "$0" .sh)
echo -n "Testing $testname ... "
t=out/test/macho/$MACHINE/$testname
mkdir -p $t

cat <<EOF | $CC -o $t/a.o -c -xc - -O2
#include <stdio.h>

int foo = -1;
long bar = -1;

void hello() {
  printf("Hello world ");
}
EOF

cat <<EOF | $CC -o $t/b.o -c -xc - -O2
#include <stdio.h>

void hello();

extern int foo;
extern long bar;

int main() {
  hello();
  printf("%d %ld\n", foo, bar);
}
EOF

clang --ld-path=./ld64 -o $t/exe $t/a.o $t/b.o
$t/exe | grep -q 'Hello world -1 -1'

echo OK
