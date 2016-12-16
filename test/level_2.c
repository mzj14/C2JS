#include <stdio.h>
#include <string.h>

int main(){
    char source[100];
    char target[100];
    printf("Please enter a source string less than 100 characters:\n");
    gets(source);
    printf("Please enter a target string less than 100 characters:\n");
    gets(target);
    int source_len = strlen(source);
    int target_len = strlen(target);

    int k = -1;
    int z = 0;
    int next_pose[100];
    next_pose[0] = -1;
    while (z < target_len)
    {
        if ((k == -1) || (target[z] == target[k]))
        {
            k = k + 1;
            z = z + 1;
            next_pose[z] = k;
        }
        else
        {
            k = next_pose[k];
        }
    }

    int i = 0;
    int j = 0;
    int flag = 0;
    while (1) {
        while ((i < source_len) && (j < target_len))
        {
            if ((j == -1) || source[i] == target[j])
            {
                i = i + 1;
                j = j + 1;
            }
            else
            {
                j = next_pose[j];
            }
        }
        if (j == target_len)
        {
            if (flag == 0) {
                printf("%d", i - target_len);
                flag = 1;
            } else {
                printf(",%d", i - target_len);
            }
            j = 0;
        }
        else
        {
            break;
        }
    }
    if (flag == 0) {
        printf("False");
    }
    return 0;
}

