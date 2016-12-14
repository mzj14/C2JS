/* source code courtesy of Frank Thomas Braun */

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
            switch(((typeNodeType*)p)->value) {
                case intType:
                    sprintf(s, "int");
                    break;
                case charType:
                    sprintf(s, "char");
                    break;
            }
            break;
        case typeInt:  sprintf (word, "integer(%d)", ((intNodeType*)p)->value); break;
        case typeChr:  sprintf (word, "character(%c)", ((chrNodeType*)p)->value); break;
        case typeStr:  sprintf (word, "string(%s)", str[((strNodeType*)p)->i].c_str()); break;
        case typeId :  sprintf (word, "id(%s)", sym[((idNodeType*)p)->i].c_str()); break;
        case typeLis:  sprintf (word, "lis * %d", ((lisNodeType*)p)->nsts); break;
        case typeFun:  sprintf (word, "function"); break;
        case typeSta:
            switch(((staNodeType*)p)->mark) {
                case WHILE:
                    sprintf(s, "while");
                    break;
                case IF:
                    sprintf(s, "if");
                    break;
                case PRINTF:
                    sprintf(s, "printf");
                    break;
                case DECLARE:
                    sprintf(s, "declare");
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
                // case MAIN:      sprintf(s, "main");    break;
                case STRLEN:    sprintf(s, "strlen");  break;
                case '=':       sprintf(s, "[=]");     break;
                case '+':       sprintf(s, "[+]");      break;
                case '-':       sprintf(s, "[-]");     break;
                case '*':       sprintf(s, "[*]");     break;
                case '/':       sprintf(s, "[/]");      break;
                case '<':       sprintf(s, "[<]");     break;
                case '>':       sprintf(s, "[>]");     break;
                case '[':       sprintf(s, "[[]");      break;
                case ',':       sprintf(s, "[,]");      break;
                case NE_OP:     sprintf(s, "[!=]");     break;
                case EQ_OP:     sprintf(s, "[==]");    break;
                case AND_OP:    sprintf(s, "[&&]");    break;
                case OR_OP:     sprintf(s, "[||]");    break;
                case UMINUS:    sprintf(s, "[minus]"); break;
            }
            break;
    }

    /* construct node text box */
    graphBox (s, &w, &h);
    cbar = c;
    *ce = c + w;
    *cm = c + w / 2;

    /* node is leaf */
    if (p->type == typeTyp || p->type == typeInt || p->type == typeChr || p->type == typeStr || p->type == typeId) {
        graphDrawBox (s, cbar, l);
        return;
    }

    if (p->type == typeOpr && ((oprNodeType*)p)->nops == 0) {
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
    // printf ("\n\nGraph %d:\n", graphNumber++);
    for (j = 0; j <= i; j++) {
      sprintf(out_stream, "\n%s", graph[j]);
      fwrite(out_stream, sizeof(char), strlen(out_stream), out_graph);
      // printf ("\n%s", graph[j]);
    }
    // printf("\n");
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
