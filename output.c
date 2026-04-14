#include <stdio.h>
int main() {
setvbuf(stdout, NULL, _IONBF, 0);
int x;
scanf("%d", &x);
printf("%d\n", x);
printf("%s\n", "Program shesh.");
return 0;
}