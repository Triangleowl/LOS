#include <los.h>

char message[] = "hello, this is LOS :)";

void init_kernel() {
    char *vedio = (char *)0xb8000;
    for (int i = 0; i < sizeof(message); i++) {
        vedio[i * 2] = message[i];
    }
}