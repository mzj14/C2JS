typedef enum { typeCon, typeId, typeOpr } nodeEnum;

/* constants */
typedef struct {
    int value;                  /* value of constant */
} conNodeType;

/* identifiers */
typedef struct {
    int i;                      /* index to sym array */
} idNodeType;

/* operators */
typedef struct {
    int oper;                   /* operator */
    int order;                  /* order in the set of the production */
    int nops;                   /* number of operands */
    struct nodeTypeTag *op[5];  /* operands, extended at runtime */
} oprNodeType;

typedef struct nodeTypeTag {
    nodeEnum type;              /* type of node */

    /* three types of nodes */
    union {
        conNodeType con;        /* constants */
        idNodeType id;          /* identifiers */
        oprNodeType opr;        /* operators */
    };
} nodeType;

// symbol table for variable
extern char* sym[100];
