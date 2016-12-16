int main()
{
    char str[100];
    printf("Please enter an arithmetic expression, less than 100 characters:\n");
    while (true)
    {
        gets(str);
        if (!strcmp(str, "")) {
            continue;
        } else {
            if (!strcmp(str, "0")) {
                printf(0);
            } else {
                printf("%.2lf\n",Calc(str));
            }
            break;
        }
    }
    return 0;
}


