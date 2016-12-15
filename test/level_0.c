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



