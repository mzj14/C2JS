double Calc(char str[])
{
    double stDit[300];
    char stOp[300];
    int top1;
    int top2;

    double x;
    double y;
    double tmp;
    char op;
    int i;
    int n = strlen(str);

    top1 = -1;
    top2 = -1;
    stOp[++top2] = '#';
    str[n++] = '#';

        if (str[i]==' ' || str[i] == '\n' || str[i] == '\t') {
            continue;
        }
        if (isdigit(str[i]))
        {
            int n = sscanf(str+i,"%lf",&tmp);
            stDit[++top1] = tmp;
            while(isdigit(str[i+1]) || str[i+1] == '.' ) {
                i ++;
            }
        }
        if(str[i] == '(') {
            stOp[++top2] = str[i];
        }
        if (str[i] == ')') {
            while(stOp[top2] != '(')  {
                y = stDit[top1--];
                x = stDit[top1--];
                op = stOp[top2--];
                stDit[++top1] = Operate(x,y,op);
            }
            top2 --;
        }
        else
        {
            while (Priority(stOp[top2]) >= Priority(str[i]))
            {
                if (str[i]=='#' && stOp[top2]=='#') {
                    return stDit[top1];
                }
                y = stDit[top1--];
                x = stDit[top1--];
                op = stOp[top2--];
                stDit[++top1] = Operate(x,y,op);
            }
            stOp[++top2] = str[i];
        }
    return stDit[top1];
}



