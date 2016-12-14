#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <string>
#include <iostream>
#include <sstream>

#include "node.hpp"
#include "parser.hpp"
#include "codegen.hpp"
using namespace std;


// TODO: Does string copy waste a lot of time?
string codeGenTyp(typNodeType *p) {
    return "var";
}

// TODO: maybe saved as string at the beginning
string codeGenInt(intNodeType *p) {
    string ans = to_string(p->value);
    cout << ans << endl;
    cout << "get num " << endl;
    return ans;
}

string codeGenChr(chrNodeType *p) {
    ostringstream stream;
    stream << p->value;
    return "\'" + stream.str() + "\'";
}

string codeGenStr(strNodeType *p) {
    return str[p->i];
}

string codeGenId(idNodeType *p) {
    return sym[p->i];
}

string codeGenOpr(nodeType *p) {
    string ans = "";
    switch (p->type) {
        case typeInt:
            cout << "get int" << endl;
            ans = codeGenInt(p);
            cout << "get int" << endl;
            break;
        case typeChr:
            ans = codeGenChr(p);
            break;
        case typeStr:
            ans = codeGenStr(p);
            break;
        case typeId:
            ans = codeGenId(p);
            break;
        case typeOpr:
            oprNodeType* pt = (oprNodeType*)p;
            switch (pt->oper) {
                case '-':
                    ans = codeGenOpr(pt->op[0]) + " - " + codeGenOpr(pt->op[1]);
                    break;
            }
            break;
    }
    return ans;
}

string codeGenSta(staNodeType *p) {
    string ans = "";
    switch (p->mark) {
        case RETURN:
            cout << "get return " << endl;
            ans = "return " + codeGenOpr(p->pt[0]) + ";";
            break;
        case DECLARE_ARRAY:
            ans = "var " + codeGenId(p->pt[1]) + " = " + "new Array(" + codeGenInt(p->pt[2]) + ");";
            break;
        case DECLARE:
            ans = "var " + codeGenId(p->pt[1]) + " = " + codeGenOpr(p->pt[2]) + ";";
            break;
        case PRINTF:
            string param = codeGenStr(p->pt[0]);
            if (param[param.length() - 1] == '\n') {
                param = param.substr(0, param.length() - 1);
            }
            ans = "console.log(" + param + ");";
            break;
    }
    return ans;
}

string codeGenLis(lisNodeType *p) {
    string ans = "{\n";
    for (int i = 0; i < p->nsts; i++) {
        cout << "get every statement" << endl;
        ans += codeGenSta(p->st[i]) + "\n";
    }
    ans += "}\n";
    return ans;
}

string codeGenFun(funNodeType *p) {
    cout << "enter codeGenFun" << endl;
    string ans = "function ";
    ans += codeGenId(p->pt[1]);
    cout << "get id" << endl;
    ans += "()";
    ans += codeGenLis(p->pt[2]);
    cout << "get list" << endl;
    return ans;
}

