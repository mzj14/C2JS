let printf = require("printf");
let readlineSync = require("readline-sync");
let Priority = (op) => {
    if (op == '#') {
        return 0;
    }
    if (op == '+' || op == '-') {
        return 1;
    }
    if (op == '*' || op == '/') {
        return 2;
    }
    return -1;
}
let Operate = (x, y, op) => {
    if (op == '+') {
        return x + y;
    }
    if (op == '-') {
        return x - y;
    }
    if (op == '*') {
        return x * y;
    }
    if (op == '/') {
        return x / y;
    }
    return -1;
}
let Calc = (str) => {
    let stDit = new Array(300);
    let stOp = new Array(300);
    let top1 = undefined;
    let top2 = undefined;
    let x = undefined;
    let y = undefined;
    let tmp = undefined;
    let op = undefined;
    let i = undefined;
    let n = str.length;
    top1 = -1;
    top2 = -1;
    stOp[++top2] = '#';
    str[n++] = '#';
    for (i = 0;i < n; ++i) {
        if (str[i] == ' ' || str[i] == '\n' || str[i] == '\t') {
            continue;
        }
        if (!isNaN(parseInt(str[i]))) {
            //数字
            tmp = str[i] - '0';
            while (!isNaN(parseInt(str[i + 1]))) {
                i++;
                tmp = tmp * 10 + (str[i] - '0');
            }
            stDit[++top1] = tmp;
            continue;
        }
        if (str[i] == '(') {
            // (
            stOp[++top2] = str[i];
            continue;
        }
        if (str[i] == ')') {
            // )
            while (stOp[top2] != '(') {
                y = stDit[top1--];
                x = stDit[top1--];
                op = stOp[top2--];
                stDit[++top1] = Operate(x, y, op);
            }
            top2--;
        } else {
            while (Priority(stOp[top2]) >= Priority(str[i])) {
                //如果操作栈顶的操作符优先级高，则作+-*/运算
                if (str[i] == '#' && stOp[top2] == '#') {
                    return stDit[top1];
                }
                y = stDit[top1--];
                x = stDit[top1--];
                op = stOp[top2--];
                stDit[++top1] = Operate(x, y, op);
            }
            stOp[++top2] = str[i];
            //如果新操作符优先级高，str[i]进栈
        }
    }
    return stDit[top1];
}
let main = () => {
    let str = new Array(100);
    process.stdout.write(printf("Please enter an arithmetic expression, less than 100 characters:\n"));
    while (1) {
        str = readlineSync.question('').split('');
        if (!(str != "")) {
            continue;
        } else {
            process.stdout.write(printf("%.2lf\n", Calc(str)));
            return 0;
        }
    }
}
main();