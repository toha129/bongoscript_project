#include <stdio.h>
int main() {
setvbuf(stdout, NULL, _IONBF, 0);
int arr[5];
int i = 42;
printf("%d\n", i);
return 0;
}