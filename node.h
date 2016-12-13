/* node types */
typedef enum { typeTyp, typeInt, typeChr, typeStr, typeId, typeOpr, typeSta, typeLis } nodeEnum;

/* data types */
typedef enum { charType, intType } typeEnum;

/* types */
typedef struct {
    typeEnum value;                  /* type category */
} typNodeType;

/* integers */
typedef struct {
    int value;                  /* value of integer */
} intNodeType;

/* chars */
typedef struct {
    char value;                  /* value of char */
} chrNodeType;

/* strings */
typedef struct {
    int i;                  /* index to str array */
} strNodeType;

/* identifiers */
typedef struct {
    int i;                      /* index to sym array */
} idNodeType;

/* operators */
typedef struct {
    int oper;                   /* operator */
    int nops;                   /* number of operands */
    struct nodeTypeTag *op[5];  /* operands, extended at runtime */
} oprNodeType;

/* statements */
typedef struct {
    int mark;                   /* show the statement type */
    int npts;                   /* number of parts */
    struct nodeTypeTag *pt[5];  /* statements, extended at runtime */
} staNodeType;

/* lists */
typedef struct {
    int mark;
    int nsts;
    struct nodeTypeTag *st[30];
} lisNodeType;

typedef struct nodeTypeTag {
    nodeEnum type;              /* type of node */

    /* three types of nodes */
    union {
        typNodeType conTyp;        /* types */
        intNodeType conInt;        /* integers */
        chrNodeType conChr;        /* chars */
        strNodeType conStr;        /* strings */
        idNodeType id;             /* identifiers */
        oprNodeType opr;           /* operators */
        staNodeType sta;           /* statements */
        lisNodeType lis;           /* lists */
    };
} nodeType;

// symbol table for identifier
extern char* sym[100];
extern int sym_num;

// symbol table for string
extern char* str[100];
extern int str_num;