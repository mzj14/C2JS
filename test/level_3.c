#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

int Priority(char op)
{
    if (op=='#')
        return 0;
    if (op=='+' || op=='-')
        return 1;
    if (op=='*' || op=='/')
        return 2;
    else
        return -1;
}
double Operate(double x,double y,char op)
{
    if (op=='+') return x+y;
    if (op=='-') return x-y;
    if (op=='*') return x*y;
    if (op=='/') return x/y;
    else return -1;
}

double Calc(char str[])
{
    double stDit[300];
    char stOp[300];
    int top1,top2;

    double x,y,tmp;
    char op;
    int i,n = strlen(str);

    top1 = top2 = -1;
    stOp[++top2] = '#';
    str[n++] = '#';

    for(i=0; i < n; ++i)
    {
        if (str[i]==' ' || str[i] == '\n' || str[i] == '\t')
            continue;
        if (isdigit(str[i]))                //数字
        {
            int n = sscanf(str+i,"%lf",&tmp);
            stDit[++top1] = tmp;
            while(isdigit(str[i+1]) || str[i+1] == '.' ) {
                i ++;
            }
        }
        else if(str[i] == '(') {            // (
            stOp[++top2] = str[i];
        }
        else if(str[i] == ')') {            // )
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
            while (Priority(stOp[top2]) >= Priority(str[i]))//如果操作栈顶的操作符优先级高，则作+-*/运算
            {
               if (str[i]=='#' && stOp[top2]=='#')
                  return stDit[top1];
               y = stDit[top1--];
               x = stDit[top1--];
               op = stOp[top2--];
               stDit[++top1] = Operate(x,y,op);
            }
            stOp[++top2] = str[i];          //如果新操作符优先级高，str[i]进栈
        }
    }
    return stDit[top1];
}

int main()
{
    char str[100];
    while (fgets(str, 100, stdin) != NULL && strcmp(str,"0")!=0)
    {
        printf("%.2lf\n",Calc(str));
    }
    return 0;
}
