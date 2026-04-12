#include <stdio.h>
int main() {
setvbuf(stdout, NULL, _IONBF, 0);
int x = 7;
if (x > 5) {
printf("%s\n", "boro");
if (x > 10) {
printf("%s\n", "onek boro");
} else {
printf("%s\n", "moddho");
}
} else {
printf("%s\n", "choto");
}
return 0;
}