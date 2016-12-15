int Priority(char op)
{
    if (op=='#') {
        return 0;
    }
    if (op=='+' || op=='-') {
        return 1;
    }
    if (op=='*' || op=='/') {
        return 2;
    }
    return -1;
}

double Operate(double x,double y,char op)
{
    if (op=='+') {
        return x + y;
    }
    if (op=='-') {
        return x-y;
    }
    if (op=='*') {
        return x*y;
    }
    if (op=='/') {
        return x/y;
    }
    return -1;
}

