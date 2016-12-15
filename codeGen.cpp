#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <string>
#include <iostream>
#include <sstream>
#include <vector>
#include <algorithm>

#include "node.hpp"
#include "parser.hpp"
#include "codegen.hpp"

using namespace std;

// TODO: Does string copy waste a lot of time?
// TODO: Something maybe wrong with char
// TODO: Do we need reference type for params and return value?
// vectors for node js require module statements
vector<string> container;
vector<string> module;

FILE *generated_code;

#define UNIT_INDENT 2

// set js module for require module statements
void setModuleInfo(string container_name, string module_name);

// get require module statements based on module info
string getModuleInfo();

// return the code of a function
void codeGenFun(funNodeType* p);

// return the code of a block
string codeGenLis(lisNodeType* p, int indent_level);

// return the code of a statement
// note that a statement could also be a block
string codeGenSta(staNodeType* p, int indent_level);

// return the code of a expression
// note that an expression could also be an id, int, char or string
string codeGenOpr(nodeType *p);

// return the code of a identifier
string codeGenId(idNodeType *p);

// return the code of a string
string codeGenStr(strNodeType *p);

// return the code of a integer
string codeGenInt(intNodeType *p);

// return the code of a char
string codeGenChar(chrNodeType *p);

void setModuleInfo(string container_name, string module_name) {
    // cout << "set module info" << endl;
    vector<string>::iterator result = find(module.begin( ), module.end( ), module_name);
    // can not find the module
    if (result == module.end()) {
        container.push_back(container_name);
        module.push_back(module_name);
    }
    return;
}

string getModuleInfo() {
    string ans = "";
    for (int i = 0; i < module.size(); i++) {
        ans += "var " + container[i] + " = " + "require(\"" + module[i] + "\");\n";
    }
    return ans;
}

string codeGenTyp(typNodeType *p) {
    // there is no obvious type in js declaration, so return "var" instead of data type.
    return "var";
}

string codeGenInt(intNodeType *p) {
    string ans = to_string(p->value);
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
            ans = codeGenInt(p);
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
                case '+':
                case '-':
                case '*':
                case '/':
                case '<':
                case '>':
                    ans = codeGenOpr(pt->op[0]) + " ";
                    ans += pt->oper;
                    ans += " " + codeGenOpr(pt->op[1]);
                    break;
                case EQ_OP:
                    ans = codeGenOpr(pt->op[0]) + " == " + codeGenOpr(pt->op[1]);
                    break;
                case NE_OP:
                    ans = codeGenOpr(pt->op[0]) + " != " + codeGenOpr(pt->op[1]);
                    break;
                case AND_OP:
                    ans = codeGenOpr(pt->op[0]) + " && " + codeGenOpr(pt->op[1]);
                    break;
                case OR_OP:
                    ans = codeGenOpr(pt->op[0]) + " || " + codeGenOpr(pt->op[1]);
                    break;
                case '[':
                    ans = codeGenId(pt->op[0]) + "[" + codeGenOpr(pt->op[1]) + "]";
                    break;
                case '(':
                    ans = "(" + codeGenOpr(pt->op[0]) + ")";
                    break;
                case STRLEN:
                    ans = codeGenId(pt->op[0]) + ".length";
                    break;
                case UMINUS:
                    ans = "-" + codeGenOpr(pt->op[0]);
            }
            break;
    }
    return ans;
}

string codeGenSta(staNodeType* p, int indent_level) {
    // cout << "in the statement function" << endl;
    // cout << "p->mark = " << p->mark << endl;
    string ans = "";
    switch (p->mark) {
        case BREAK:
            ans = "break;";
            break;
        case WHILE:
            ans = "while (" + codeGenOpr(p->pt[0]) + ") " + codeGenLis(p->pt[1], indent_level + 1);
            break;
        case IF:
            ans = "if (" + codeGenOpr(p->pt[0]) + ") " + codeGenLis(p->pt[1], indent_level + 1);
            break;
        case ELSE:
            // cout << "else statement" << endl;
            ans = "if (" + codeGenOpr(p->pt[0]) + ") "
                  + codeGenLis(p->pt[1], indent_level + 1) + " else " + codeGenLis(p->pt[2], indent_level + 1);
            break;
        case GETS:
            // cout << "gets statement" << endl;
            setModuleInfo("readlineSync", "readline-sync");
            ans = codeGenId(p->pt[0]) + " = " + "readlineSync.question('');";
            break;
        case RETURN:
            // cout << "return statement" << endl;
            ans = "return " + codeGenOpr(p->pt[0]) + ";";
            break;
        case DECLARE_ARRAY:
            cout << "declare array statement" << endl;
            if (((typNodeType*)(p->pt[0]))->value == charType) {
                ans = "var " + codeGenId(p->pt[1]) + " = " + "\";";
            } else {
                ans = "var " + codeGenId(p->pt[1]) + " = " + "new Array(" + codeGenInt(p->pt[2]) + ");";
            }
            break;
        case DECLARE:
            // cout << "declare statement" << endl;
            ans = "var " + codeGenId(p->pt[1]) + " = " + codeGenOpr(p->pt[2]) + ";";
            break;
        case '=':
            if (p->npts == 2) {
                ans = codeGenId(p->pt[0]) + " = " + codeGenOpr(p->pt[1]) + ";";
            } else {
                ans = codeGenId(p->pt[0]) + "[" + codeGenOpr(p->pt[1]) + "] = " + codeGenOpr(p->pt[2]) + ";";
            }
            break;
        case PRINTF:
            // cout << "printf statement" << endl;
            string param = codeGenStr(p->pt[0]);
            if (param[param.length() - 1] == '\n') {
                param = param.substr(0, param.length() - 1);
            }
            ans = "console.log(" + param + ");";
            break;
    }
    ans.insert(0, indent_level * UNIT_INDENT, ' ');
    return ans;
}

string codeGenLis(lisNodeType* p, int indent_level) {
    string ans = "";
    ans += "{\n";
    // cout << "totally " << p->nsts << " statements." << endl;
    for (int i = 0; i < p->nsts; i++) {
        cout << "get every statement" << endl;
        ans += codeGenSta(p->st[i], indent_level) + "\n";
    }
    // ans.insert(0, (indent_level - 1) * UNIT_INDENT, ' ');
    ans.insert(ans.length(), (indent_level - 1) * UNIT_INDENT, ' ');
    ans += "}";
    return ans;
}

void codeGenFun(funNodeType* p) {
    // cout << "enter codeGenFun" << endl;
    string ans = "function ";
    ans += codeGenId(p->pt[1]);
    ans += "()";
    ans += codeGenLis(p->pt[2], 1);
    ans.insert(0, getModuleInfo());
    ans += "\nmain();";
    fwrite(ans.c_str(), sizeof(char), ans.length(), generated_code);
    return;
}

