struct ident {
        char lexeme[30];
        char val[30];
        char type[5];
        int scope;
        int line;
   };
typedef struct ident Ident;

struct node{
  Ident* identifier[20];
  struct node *parent;
  struct node* children[10];
};
typedef struct node Node;

struct symbol_table
{
  Node *root;
};
typedef struct symbol_table ST;

struct ast_node
{
  struct ast_node *right;
  struct ast_node *left;
  char* lexeme;
};
typedef struct ast_node ast_node;


Node* enter_scope(Node *curr);
Node* exit_scope(Node *curr);