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

/* vectors for node js require module statements */
// variable related to package
vector<string> container;
// package name
vector<string> module;

FILE *generated_code;

// set js code indentation to 4 spaces
#define UNIT_INDENT 4

/**************************************************************** require module **********************************************/
// set js module for 'require' module statements
void setModuleInfo(string container_name, string module_name);

// get require module statements based on module info
string getModuleInfo();
/******************************************************************************************************************************/


/********************************************** code generation function on different level *********************************/
// return the code of a function
string codeGenFun(nodeType* p);

// return the code of a param list
string codeGenPrs(nodeType* p);

// return the code of a param
string codeGenPar(nodeType* p);

// return the code of a block
string codeGenLis(nodeType* p, int indent_level);

// return the code of a statement
string codeGenSta(nodeType* p, int indent_level);

// return the code of a expression list
string codeGenEps(nodeType* p);

// return the code of a expression
string codeGenOpr(nodeType *p);

// return the code of a identifier
string codeGenId(nodeType *p);

// return the code of a string
string codeGenStr(nodeType *p);

// return the code of a integer
string codeGenInt(nodeType *p);

// return the code of a double
string codeGenDbl(nodeType *p);

// return the code of a char
string codeGenChr(nodeType *p);

// return the code of a type
string codeGenTyp(nodeType *p);
/*********************************************************************************************************************/

void setModuleInfo(string container_name, string module_name) {
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
        ans += "let " + container[i] + " = " + "require(\"" + module[i] + "\");\n";
    }
    return ans;
}

string codeGenTyp(nodeType *p) {
    // there is no obvious type in js declaration, so return "let" instead of data type.
    if (p->type != typeTyp) {
        cerr << "not typNodeType !" << endl;
    }
    return "let";
}

string codeGenInt(nodeType *p_temp) {
    if (p_temp->type != typeInt) {
        cerr << "not intNodeType !" << endl;
    }
    intNodeType* p = (intNodeType*)p_temp;
    string ans = to_string(p->value);
    return ans;
}

string codeGenDbl(nodeType *p_temp) {
    if (p_temp->type != typeDbl) {
        cerr << "not dblNodeType !" << endl;
    }
    dblNodeType* p = (dblNodeType*)p_temp;
    stringstream ss;
    ss << p->value;
    return ss.str();
}

string codeGenChr(nodeType *p_temp) {
    if (p_temp->type != typeChr) {
        cerr << "not chrNodeType !" << endl;
    }
    chrNodeType* p = (chrNodeType*)p_temp;
    // return character as well as the single quotes
    return chr[p->i];
}

string codeGenStr(nodeType *p_temp) {
    if (p_temp->type != typeStr) {
        cerr << "not strNodeType !" << endl;
    }
    strNodeType* p = (strNodeType*)p_temp;
    // return the string as well as the double quotes
    return str[p->i];
}

string codeGenId(nodeType *p_temp) {
    if (p_temp->type != typeId) {
        cerr << "not idNodeType !" << endl;
    }
    idNodeType* p = (idNodeType*)p_temp;
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
        case typeDbl:
            ans = codeGenDbl(p);
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
                case INC_OP_LEFT:
                    ans = "++" + codeGenOpr(pt->op[0]);
                    break;
                case DEC_OP_LEFT:
                    ans = "--" + codeGenOpr(pt->op[0]);
                    break;
                case INC_OP_RIGHT:
                    ans = codeGenOpr(pt->op[0]) + "++";
                    break;
                case DEC_OP_RIGHT:
                    ans = codeGenOpr(pt->op[0]) + "--";
                    break;
                case LE_OP:
                    ans = codeGenOpr(pt->op[0]) + " <= " + codeGenOpr(pt->op[1]);
                    break;
                case GE_OP:
                    ans = codeGenOpr(pt->op[0]) + " >= " + codeGenOpr(pt->op[1]);
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
                case '!':
                    ans = "!" + codeGenOpr(pt->op[0]);
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
                case STRCMP:
                    ans = codeGenOpr(pt->op[0]) + " != " + codeGenOpr(pt->op[1]);
                    break;
                case ISDIGIT:
                    ans = "!isNaN(parseInt(" + codeGenOpr(pt->op[0]) + "))";
                    break;
                case UMINUS:
                    ans = "-" + codeGenOpr(pt->op[0]);
                    break;
                case IDENTIFIER:
                    ans = codeGenId(pt->op[0]) + "(" + codeGenEps(pt->op[1]) + ")";
                    break;
            }
            break;
    }
    return ans;
}

string codeGenSta(nodeType* p_temp, int indent_level) {
    if (p_temp->type != typeSta) {
        cerr << "not staNodeType !" << endl;
    }
    staNodeType* p = (staNodeType*)p_temp;
    string ans = "";
    switch (p->mark) {
        case COMMENT:
            ans = codeGenStr(p->pt[0]);
            break;
        case INC_OP_LEFT:
            ans = "++" + codeGenOpr(p->pt[0]) + ";";
            break;
        case DEC_OP_LEFT:
            ans = "--" + codeGenOpr(p->pt[0]) + ";";
            break;
        case INC_OP_RIGHT:
            ans = codeGenOpr(p->pt[0]) + "++;";
            break;
        case DEC_OP_RIGHT:
            ans = codeGenOpr(p->pt[0]) + "--;";
            break;
        case IDENTIFIER:
            ans = codeGenId(p->pt[0]) + "(" + codeGenEps(p->pt[1]) + ");";
            break;
        case CONTINUE:
            ans = "continue;";
            break;
        case BREAK:
            ans = "break;";
            break;
        case WHILE:
            ans = "while (" + codeGenOpr(p->pt[0]) + ") " + codeGenLis(p->pt[1], indent_level + 1);
            break;
        case FOR:
            ans = "for (" + codeGenSta(p->pt[0], 0) + codeGenOpr(p->pt[1]) + "; " + codeGenOpr(p->pt[2]) + ") " + codeGenLis(p->pt[3], indent_level + 1);
            break;
        case IF:
            ans = "if (" + codeGenOpr(p->pt[0]) + ") " + codeGenLis(p->pt[1], indent_level + 1);
            break;
        case ELSE:
            ans = "if (" + codeGenOpr(p->pt[0]) + ") "
                  + codeGenLis(p->pt[1], indent_level + 1) + " else " + codeGenLis(p->pt[2], indent_level + 1);
            break;
        case GETS:
            setModuleInfo("readlineSync", "readline-sync");
            ans = codeGenId(p->pt[0]) + " = " + "readlineSync.question('');";
            break;
        case RETURN:
            ans = "return " + codeGenOpr(p->pt[0]) + ";";
            break;
        case DECLARE_ARRAY:
            if (((typNodeType*)(p->pt[0]))->value == charType) {
                ans = codeGenTyp(p->pt[0]) + " " + codeGenId(p->pt[1]) + " = " + "\'\';";
            } else {
                ans = codeGenTyp(p->pt[0]) + " " + codeGenId(p->pt[1]) + " = " + "new Array(" + codeGenInt(p->pt[2]) + ");";
            }
            break;
        case DECLARE:
            if (p->npts == 3) {
                ans = codeGenTyp(p->pt[0]) + " " + codeGenId(p->pt[1]) + " = " + codeGenOpr(p->pt[2]) + ";";
            } else {
                ans = codeGenTyp(p->pt[0]) + " " + codeGenId(p->pt[1]) + " = undefined;";
            }
            break;
        case '=':
            if (p->npts == 2) {
                ans = codeGenId(p->pt[0]) + " = " + codeGenOpr(p->pt[1]) + ";";
            } else {
                ans = codeGenId(p->pt[0]) + "[" + codeGenOpr(p->pt[1]) + "] = " + codeGenOpr(p->pt[2]) + ";";
            }
            break;
        case PRINTF:
            setModuleInfo("printf", "printf");
            ans = "process.stdout.write(printf(" + codeGenEps(p->pt[0]) + "));";
            break;
    }
    ans.insert(0, indent_level * UNIT_INDENT, ' ');
    return ans;
}

string codeGenEps(nodeType* p_temp) {
    if (p_temp->type != typeEps) {
        cerr << "not epsTypeNode !" << endl;
    }
    epsNodeType* p = (epsNodeType*)p_temp;
    string ans = "";
    for (int i = 0; i < p->neps; i++) {
        ans += codeGenOpr(p->ep[i]);
        if (i != p->neps - 1) {
            ans += ", ";
        }
    }
    return ans;
}

string codeGenLis(nodeType* p_temp, int indent_level) {
    if (p_temp->type != typeLis) {
        cerr << "not lisTypeNode !" << endl;
    }
    lisNodeType* p = (lisNodeType*)p_temp;
    string ans = "";
    ans += "{\n";
    for (int i = 0; i < p->nsts; i++) {
        ans += codeGenSta(p->st[i], indent_level) + "\n";
    }
    ans.insert(ans.length(), (indent_level - 1) * UNIT_INDENT, ' ');
    ans += "}";
    return ans;
}

string codeGenPar(nodeType *p_temp) {
    if (p_temp->type != typePar) {
        cerr << "not parTypeNode !" << endl;
    }
    parNodeType* p = (parNodeType*)p_temp;
    return codeGenId(p->pt[1]);
}

string codeGenPrs(nodeType* p_temp) {
    if (p_temp->type != typePrs) {
        cerr << "not prsTypeNode !" << endl;
    }
    prsNodeType* p = (prsNodeType*)p_temp;
    string ans = "";
    for (int i = 0; i < p->npas; i++) {
        ans += codeGenPar(p->pa[i]);
        if (i != p->npas - 1) {
            ans += ", ";
        }
    }
    return ans;
}

string codeGenFun(nodeType* p_temp) {
    if (p_temp->type != typeFun) {
        cerr << "not funTypeNode !" << endl;
    }
    funNodeType* p = (funNodeType*)p_temp;
    string ans = "";
    ans += codeGenTyp(p->pt[0]);
    ans += " ";
    ans += codeGenId(p->pt[1]);
    ans += " = ";
    if (p->npts == 3) {
        ans += "() => ";
        ans += codeGenLis(p->pt[2], 1);
    } else {
        ans += "(" + codeGenPrs(p->pt[2]) + ") => ";
        ans += codeGenLis(p->pt[3], 1);
    }
    return ans;
}

void codeGenPro(nodeType* p_temp) {
    if (p_temp->type != typePro) {
        cerr << "not proTypeNode !" << endl;
    }
    proNodeType* p = (proNodeType*)p_temp;
    string ans = "";
    for (int i = 0; i < p->nfns; i++) {
        ans += codeGenFun(p->fn[i]);
        ans += "\n";
    }
    ans.insert(0, getModuleInfo());
    ans += "main();";
    fwrite(ans.c_str(), sizeof(char), ans.length(), generated_code);
    return;
}

