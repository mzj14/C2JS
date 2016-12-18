#include <stdio.h>
#include <string.h>

int main() {
    char str[100];
    printf("Please enter a string less than 100 character, terminated by an enter key:\n");
    gets(str);

    int i = 0;
    int total = strlen(str) - 1;
    int flag = 1;

    for (i = 0; i <= total; i++) {
        if (str[i] != str[total - i]) {
            // not a palindromic string
            flag = 0;
            break;
        }
    }

    if (flag == 1) {
        printf("True\n");
    } else {
        printf("False\n");
    }

    return 0;
}

