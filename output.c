#include <stdio.h>
int main() {
setvbuf(stdout, NULL, _IONBF, 0);
int a;
scanf("%d", &a);
printf("%d\n", a);
return 0;
}