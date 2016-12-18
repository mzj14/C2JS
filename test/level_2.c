#include <stdio.h>
#include <string.h>

int main(){
    char source[100];
    char target[100];

    // get a non-empty source string
    while (1)
    {
        printf("Please enter a non-empty source string less than 100 characters, terminated by an enter key:\n");
        gets(source);
        if (strcmp(source, ""))
        {
            break;
        }
    }

    // get a non-empty target string
    while (1)
    {
        printf("Please enter a target string less than 100 characters:\n");
        gets(target);
        if (strcmp(target, ""))
        {
            break;
        }
    }

    int source_len = strlen(source);
    int target_len = strlen(target);

    int k = -1;
    int z = 0;
    int next_pose[100];
    next_pose[0] = -1;

    /* calculate next_pos array for the target string */
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
        /* matched the target string ! */
        if (j == target_len)
        {
            if (flag == 0)
            {
                // matched for the first time
                // not print comma
                printf("%d", i - target_len);
                flag = 1;
            }
            else
            {
                // otherwise print comma
                printf(",%d", i - target_len);
            }
            j = 0;
        }
        else
        {
            break;
        }
    }
    if (flag == 0)
    {
        printf("False\n");
    }
    else
    {
        printf("\n");
    }
    return 0;
}

