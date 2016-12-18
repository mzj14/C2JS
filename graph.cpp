/* Generation of the graph of the syntax tree */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <string>

#include "node.hpp"
#include "parser.hpp"

using namespace std;

int del = 1; /* distance of graph columns */
int eps = 3; /* distance of graph lines */

FILE* out_graph; /* out put file for graph */

/* interface for drawing (can be replaced by "real" graphic using GD or other) */
void graphInit (void);
void graphFinish();
void graphBox (char *s, int *w, int *h);
void graphDrawBox (char *s, int c, int l);
void graphDrawArrow (int c1, int l1, int c2, int l2);

/* recursive drawing of the syntax tree */
void exNode (nodeType *p, int c, int l, int *ce, int *cm);

/*****************************************************************************/

/* main entry point of the manipulation of the syntax tree */
int ex (nodeType *p) {
    int rte, rtm;
    graphInit();
    exNode(p, 0, 0, &rte, &rtm);
    graphFinish();
    return 0;
}

/*c----cm---ce---->                       drawing of leaf-nodes
 l leaf-info
 */

/*c---------------cm--------------ce----> drawing of non-leaf-nodes
 l            node-info
 *                |
 *    -------------     ...----
 *    |       |               |
 *    v       v               v
 * child1  child2  ...     child-n
 *        che     che             che
 *cs      cs      cs              cs
 *
 */

void exNode
    (   nodeType *p,
        int c, int l,        /* start column and line of node */
        int *ce, int *cm     /* resulting end column and mid of node */
    )
{
    int w, h;           /* node width and height */
    char *s;            /* node text */
    int cbar;           /* "real" start column of node (centred above subnodes) */
    int k;              /* child number */
    int che, chm;       /* end column and mid of children */
    int cs;             /* start column of children */
    char word[200];        /* extended node text */

    if (!p) return;

    strcpy (word, "???"); /* should never appear */
    s = word;
    switch(p->type) {
        case typeTyp:
            switch(((typNodeType*)p)->value) {
                case intType:
                    sprintf(s, "int");
                    break;
                case charType:
                    sprintf(s, "char");
                    break;
                case doubleType:
                    sprintf(s, "double");
                    break;
            }
            break;
        case typeInt:  sprintf (word, "integer(%d)", ((intNodeType*)p)->value); break;
        case typeDbl:  sprintf (word, "double(%f)", ((dblNodeType*)p)->value); break;
        case typeChr:  sprintf (word, "character(%s)", chr[((chrNodeType*)p)->i].c_str()); break;
        case typeStr:  sprintf (word, "string(%s)", str[((strNodeType*)p)->i].c_str()); break;
        case typeId :  sprintf (word, "id(%s)", sym[((idNodeType*)p)->i].c_str()); break;
        case typeEps:  sprintf (word, "expression list"); break;
        case typePar:  sprintf (word, "param"); break;
        case typePrs:  sprintf (word, "param list"); break;
        case typePro:  sprintf (word, "program"); break;
        case typeLis:  sprintf (word, "block"); break;
        case typeFun:  sprintf (word, "function"); break;
        case typeSta:
            switch(((staNodeType*)p)->mark) {
                case COMMENT:
                    sprintf(s, "comment");
                    break;
                case INC_OP_LEFT:
                case INC_OP_RIGHT:
                    sprintf(s, "++");
                    break;
                case DEC_OP_LEFT:
                case DEC_OP_RIGHT:
                    sprintf(s, "--");
                    break;
                case IDENTIFIER:
                    sprintf(s, "id");
                    break;
                case CONTINUE:
                    sprintf(s, "continue");
                    break;
                case WHILE:
                    sprintf(s, "while");
                    break;
                case FOR:
                    sprintf(s, "for");
                    break;
                case IF:
                    sprintf(s, "if");
                    break;
                case ELSE:
                    sprintf(s, "if/else");
                    break;
                case PRINTF:
                    sprintf(s, "printf");
                    break;
                case DECLARE:
                    sprintf(s, "declare");
                    break;
                case DECLARE_ARRAY:
                    sprintf(s, "declare_array");
                    break;
                case BREAK:
                    sprintf(s, "break");
                    break;
                case RETURN:
                    sprintf(s, "return");
                    break;
                case GETS:
                    sprintf(s, "gets");
                    break;
                case '=':
                    sprintf(s, "[=]");
                    break;
            }
            break;

        case typeOpr:
            switch(((oprNodeType*)p)->oper){
                case STRLEN:                      sprintf(s, "strlen");  break;
                case STRCMP:                      sprintf(s, "strcmp");  break;
                case ISDIGIT:                     sprintf(s, "isdigit"); break;

                case '+':                         sprintf(s, "[+]");     break;
                case '-':                         sprintf(s, "[-]");     break;
                case '*':                         sprintf(s, "[*]");     break;
                case '/':                         sprintf(s, "[/]");     break;
                case '<':                         sprintf(s, "[<]");     break;
                case '>':                         sprintf(s, "[>]");     break;
                case '[':                         sprintf(s, "[[]");     break;
                case '(':                         sprintf(s, "[(]");     break;
                case '!':                         sprintf(s, "[!]");     break;
                case UMINUS:                      sprintf(s, "[minus]"); break;

                case LE_OP:                       sprintf(s, "[<=]");    break;
                case GE_OP:                       sprintf(s, "[>=]");    break;
                case NE_OP:                       sprintf(s, "[!=]");    break;
                case EQ_OP:                       sprintf(s, "[==]");    break;
                case AND_OP:                      sprintf(s, "[&&]");    break;
                case OR_OP:                       sprintf(s, "[||]");    break;

                case INC_OP_LEFT:                 sprintf(s, "[++]");    break;
                case DEC_OP_LEFT:                 sprintf(s, "[--]");    break;
                case INC_OP_RIGHT:                sprintf(s, "[++]");    break;
                case DEC_OP_RIGHT:                sprintf(s, "[--]");    break;

                case IDENTIFIER:                  sprintf(s, "id");      break;
            }
            break;
    }

    /* construct node text box */
    graphBox (s, &w, &h);
    cbar = c;
    *ce = c + w;
    *cm = c + w / 2;

    /* node is leaf */
    if (p->type == typeTyp || p->type == typeInt || p->type == typeChr ||
        p->type == typeStr || p->type == typeId || p->type == typeDbl) {
        graphDrawBox (s, cbar, l);
        return;
    }

    /* node has children */
    cs = c;
    if (p->type == typeOpr) {
        oprNodeType* pt = (oprNodeType*)p;
        for (k = 0; k < pt->nops; k++) {
            exNode (pt->op[k], cs, l+h+eps, &che, &chm);
            cs = che;
        }
    }

    if (p->type == typeEps) {
        epsNodeType* pt = (epsNodeType*)p;
        for (k = 0; k < pt->neps; k++) {
            exNode (pt->ep[k], cs, l+h+eps, &che, &chm);
            cs = che;
        }
    }

    if (p->type == typeSta) {
        staNodeType* pt = (staNodeType*)p;
        for (k = 0; k < pt->npts; k++) {
            exNode (pt->pt[k], cs, l+h+eps, &che, &chm);
            cs = che;
        }
    }

    if (p->type == typeLis) {
        lisNodeType* pt = (lisNodeType*)p;
        for (k = 0; k < pt->nsts; k++) {
            exNode (pt->st[k], cs, l+h+eps, &che, &chm);
            cs = che;
        }
    }

    if (p->type == typeFun) {
        funNodeType* pt = (funNodeType*)p;
        for (k = 0; k < pt->npts; k++) {
            exNode (pt->pt[k], cs, l+h+eps, &che, &chm);
            cs = che;
        }
    }

    if (p->type == typePar) {
        parNodeType* pt = (parNodeType*)p;
        for (k = 0; k < pt->npts; k++) {
            exNode (pt->pt[k], cs, l+h+eps, &che, &chm);
            cs = che;
        }
    }

    if (p->type == typePrs) {
        prsNodeType* pt = (prsNodeType*)p;
        for (k = 0; k < pt->npas; k++) {
            exNode (pt->pa[k], cs, l+h+eps, &che, &chm);
            cs = che;
        }
    }

    if (p->type == typePro) {
        proNodeType* pt = (proNodeType*)p;
        for (k = 0; k < pt->nfns; k++) {
            exNode (pt->fn[k], cs, l+h+eps, &che, &chm);
            cs = che;
        }
    }

    /* total node width */
    if (w < che - c) {
        cbar += (che - c - w) / 2;
        *ce = che;
        *cm = (c + che) / 2;
    }

    /* draw node */
    graphDrawBox (s, cbar, l);

    /* draw arrows (not optimal: children are drawn a second time) */
    if (p->type == typeOpr) {
        cs = c;
        oprNodeType* pt = (oprNodeType*)p;
        for (k = 0; k < pt->nops; k++) {
            exNode (pt->op[k], cs, l+h+eps, &che, &chm);
            graphDrawArrow (*cm, l+h, chm, l+h+eps-1);
            cs = che;
        }
    }

    if (p->type == typeEps) {
        cs = c;
        epsNodeType* pt = (epsNodeType*)p;
        for (k = 0; k < pt->neps; k++) {
            exNode (pt->ep[k], cs, l+h+eps, &che, &chm);
            graphDrawArrow (*cm, l+h, chm, l+h+eps-1);
            cs = che;
        }
    }

    if (p->type == typeSta) {
        cs = c;
        staNodeType* pt = (staNodeType*)p;
        for (k = 0; k < pt->npts; k++) {
            exNode (pt->pt[k], cs, l+h+eps, &che, &chm);
            graphDrawArrow (*cm, l+h, chm, l+h+eps-1);
            cs = che;
        }
    }

    if (p->type == typeLis) {
        cs = c;
        lisNodeType* pt = (lisNodeType*)p;
        for (k = 0; k < pt->nsts; k++) {
            exNode (pt->st[k], cs, l+h+eps, &che, &chm);
            graphDrawArrow (*cm, l+h, chm, l+h+eps-1);
            cs = che;
        }
    }

    if (p->type == typeFun) {
        cs = c;
        funNodeType* pt = (funNodeType*)p;
        for (k = 0; k < pt->npts; k++) {
            exNode (pt->pt[k], cs, l+h+eps, &che, &chm);
            graphDrawArrow (*cm, l+h, chm, l+h+eps-1);
            cs = che;
        }
    }

    if (p->type == typePar) {
        cs = c;
        parNodeType* pt = (parNodeType*)p;
        for (k = 0; k < pt->npts; k++) {
            exNode (pt->pt[k], cs, l+h+eps, &che, &chm);
            graphDrawArrow (*cm, l+h, chm, l+h+eps-1);
            cs = che;
        }
    }

    if (p->type == typePrs) {
        cs = c;
        prsNodeType* pt = (prsNodeType*)p;
        for (k = 0; k < pt->npas; k++) {
            exNode (pt->pa[k], cs, l+h+eps, &che, &chm);
            graphDrawArrow (*cm, l+h, chm, l+h+eps-1);
            cs = che;
        }
    }

    if (p->type == typePro) {
        cs = c;
        proNodeType* pt = (proNodeType*)p;
        for (k = 0; k < pt->nfns; k++) {
            exNode (pt->fn[k], cs, l+h+eps, &che, &chm);
            graphDrawArrow (*cm, l+h, chm, l+h+eps-1);
            cs = che;
        }
    }
}

/* interface for drawing */

#define lmax 20000
#define cmax 20000

char graph[lmax][cmax]; /* array for ASCII-Graphic */
int graphNumber = 0;

void graphTest (int l, int c)
{   int ok;
    ok = 1;
    if (l < 0) ok = 0;
    if (l >= lmax) ok = 0;
    if (c < 0) ok = 0;
    if (c >= cmax) ok = 0;
    if (ok) return;
    printf ("\n+++error: l=%d, c=%d not in drawing rectangle 0, 0 ... %d, %d",
        l, c, lmax, cmax);
    exit(1);
}

void graphInit (void) {
    int i, j;
    for (i = 0; i < lmax; i++) {
        for (j = 0; j < cmax; j++) {
            graph[i][j] = ' ';
        }
    }
}

void graphFinish() {
    int i, j;
    char out_stream[300];

    for (i = 0; i < lmax; i++) {
        for (j = cmax-1; j > 0 && graph[i][j] == ' '; j--);
        graph[i][cmax-1] = 0;
        if (j < cmax-1) graph[i][j+1] = 0;
        if (graph[i][j] == ' ') graph[i][j] = 0;
    }
    for (i = lmax-1; i > 0 && graph[i][0] == 0; i--);
    sprintf(out_stream, "\n\nGraph %d:\n", graphNumber++);
    fwrite(out_stream, sizeof(char), strlen(out_stream), out_graph);
    for (j = 0; j <= i; j++) {
      sprintf(out_stream, "\n%s", graph[j]);
      fwrite(out_stream, sizeof(char), strlen(out_stream), out_graph);
    }
    sprintf(out_stream, "\n");
    fwrite(out_stream, sizeof(char), strlen(out_stream), out_graph);
}

void graphBox (char *s, int *w, int *h) {
    *w = strlen (s) + del;
    *h = 1;
}

void graphDrawBox (char *s, int c, int l) {
    int i;
    graphTest (l, c+strlen(s)-1+del);
    for (i = 0; i < strlen (s); i++) {
        graph[l][c+i+del] = s[i];
    }
}

void graphDrawArrow (int c1, int l1, int c2, int l2) {
    int m;
    graphTest (l1, c1);
    graphTest (l2, c2);
    m = (l1 + l2) / 2;
    while (l1 != m) { graph[l1][c1] = '|'; if (l1 < l2) l1++; else l1--; }
    while (c1 != c2) { graph[l1][c1] = '-'; if (c1 < c2) c1++; else c1--; }
    while (l1 != l2) { graph[l1][c1] = '|'; if (l1 < l2) l1++; else l1--; }
    graph[l1][c1] = '|';
}
