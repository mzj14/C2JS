#include <stdio.h>
#include <string.h>

int main() {
    char str[100];
    printf("Please enter a string less than 100 character, terminated by an enter key:\n");
    gets(str);
    int i = 0;
    int j = strlen(str) - 1;
    int flag = 1;
    while (i < j) {
        if (str[i] == str[j]) {
            i = i + 1;
            j = j - 1;
        } else {
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

