%{
   #ifndef YYSTYPE
   #define YYSTYPE char*
   #endif

   int yylex();
   void yyerror();
   
   #include<stdio.h>
   #include<string.h>
   #include<stdlib.h>
   #include"2.h"
   #define MAX 100

   int valid=1;

   struct ident symbol_table[MAX];
   int i_symtab;
   int scope;
   int e[100];
   int i_error=0;
   int flag = 0;
   extern int lineNo;

   ST *st;
   Node *curr;

   


   

   int add_value(char lexeme[],char val[],char type[])
   {
      for(int i=0;i<i_symtab;i++)
      {
         // printf("@@@@@%s:%s\n",symbol_table[i].lexeme,lexeme);
         if(strcmp(symbol_table[i].lexeme,lexeme)==0)
         {
            // printf("@@@@%s\n",lexeme);
            if(symbol_table[i].scope == scope)
            {
               strcpy(symbol_table[i].val,val);
               strcpy(symbol_table[i].type,type);
               return 1;
               // printf("val added\n");
            }
         }
      }
      return 0;
   }

   void print_st()
   {
      for(int i=0;i<i_symtab;i++)
      {
         printf("%s,%s,%s,%d,%d\n",symbol_table[i].lexeme,symbol_table[i].val,symbol_table[i].type,symbol_table[i].scope,symbol_table[i].line);
      }
   }

void init_node(Node *n)
{
  for(int i=0;i<20;i++)
  {
    n->identifier[i]=NULL;
  }

  for(int i=0;i<10;i++)
  {
    n->children[i] = NULL;
  }
}

void init_ST(ST *s)
{
  s->root = (Node*)malloc(sizeof(Node));
  s->root->parent=NULL;
  init_node(s->root);
  // return(s->root);
}

void make_ident(char* lexeme,char* val, char* type)
{
  return;
}

void addEntry(Node *curr,char* lexeme,char* val, char* type)
{
  //if(flag==0) //implies variable declaration
  //{
   //   printf("h1\n");
    int i=0;
    while(i<20)
    {
       if(curr->identifier[i]==NULL)
      {
      //   printf("h3\n");
        Ident *id = (Ident*)malloc(sizeof(Ident));
        strcpy(id->lexeme, lexeme);
        strcpy(id->val,val);
        strcpy(id->type,type);
        curr->identifier[i]=id;
        break;
      }
      else
      if(strcmp(curr->identifier[i]->lexeme,lexeme)==0)
      {
        strcpy(curr->identifier[i]->val,val);
        strcpy(curr->identifier[i]->type, type);
        break;
      }  

      i++;
    }
   //  printf("h2\n");
  //}
  // else
  // {
  //   int i=0;
  //   while(i<20)
  //   {
  //     if(strcmp(curr->identifier[i]->lexeme,id->lexeme)==0)
  //     {
  //       strcpy(curr->identifier[i]->val,id->val);
  //       strcpy(curr->identifier[i]->type, id->type);
  //       break;
  //     }  

  //     if(curr->identifier[i]==NULL)
  //     {
  //       Node *p = curr->parent;
  //       addEntry(id,p,flag);
  //       break;
  //     }

  //     i++;
  //   }
  // }
}

void updEntry(Node *curr,char* lexeme,char* val)
{
    int i=0;
    while(i<20)
    {
       if(curr->identifier[i]==NULL)
      {
        Node *p = curr->parent;
        updEntry(p,lexeme,val);
        break;
      }
      else
      if(strcmp(curr->identifier[i]->lexeme,lexeme)==0)
      {
        strcpy(curr->identifier[i]->val,val);
        break;
      }  

      i++;
    }
}

Node* enter_scope(Node *curr)
{
  int i=0;
  while(curr->children[i]!=NULL)
  {
    i++;
  }
  Node *temp;
  temp = (Node*) malloc(sizeof(Node));
  temp->parent=curr;
  init_node(temp);
  curr->children[i]=temp;
  curr = curr->children[i];
  return(curr);
}

Node* exit_scope(Node *curr)
{
  curr = curr->parent;
  return(curr);
}
  
void print_nodes(Node *n)
{
  int i=0;
  while(i<20)
  {
    if(n->identifier[i]!=NULL)
    {
      Ident *id = n->identifier[i];
      printf("%s\t%s\t%s\n",id->lexeme,id->val,id->type);
    }
    i++;
  }
}

void print_ST(Node* n[],int i_r,int i_e)
{
  if(i_r>=i_e)
   return;
  Node *root = n[i_r];
  print_nodes(root);
  i_r++;
  int i=0;
  while(i<10)
  {
    if(root->children[i]!=NULL)
    {
      n[i_e]=root->children[i];
      i_e++;
    }
    else
    {
        break;
    }
    i++;
  }
  print_ST(n,i_r,i_e);
}

ast_node* make_node(ast_node *left, ast_node *right, char* lexeme)
{
   ast_node *newnode = (ast_node*)malloc(sizeof(ast_node));
   char *newstr = (char*)malloc(strlen(lexeme)+1);
   strcpy(newstr,lexeme);
   newnode->left = left;
   newnode->right = right;
   newnode->lexeme = newstr;
   return(newnode);
}

void print_ast(ast_node *tree)
{
   int i;
   if(tree->left || tree->right)
      printf("(");

   printf(" %s ",tree->lexeme);

   if(tree->left)
      print_ast(tree->left);
   if(tree->right)
      print_ast(tree->right);

   if(tree->left || tree->right)
      printf(")");
}


%}

%token T_op T_ident T_symbol T_char T_const SEMICOLON LET COMMA COLON DATATYPE IN FOR DOT EQ FN MAIN PAR_OP PAR_CL CUR_OP CUR_CL PRINTLN IF ELSE WHILE

%%











Start: Main 
     | Var_dec Start
     |
     ;
Main: FN MAIN PAR_OP PAR_CL CUR_OP Blk CUR_CL   ;
Blk: Code Blk
   |If Blk
   |While Blk
   |For Blk
   |CUR_OP Blk CUR_CL Blk
   |  
   ;
Code: Eval
    |Out
    |Exp
    |Var_dec 
    ;
Eval: T_ident EQ Exp SEMICOLON {updEntry(curr, $1,$3);}; 

Exp: Val T_op Exp        
   | PAR_OP Exp PAR_CL  
   | Val               
   ;

Val: T_ident   
   | T_const   
   ;

Out: PRINTLN PAR_OP Body PAR_CL SEMICOLON;
Body: T_char
    | T_char COMMA Val
    | 
    ;

Var_dec: LET T_ident COLON DATATYPE EQ Val SEMICOLON {add_value($2,$6,$4);scope++;flag=0;addEntry(curr,$2,$6,$4);};

If: IF PAR_OP Exp PAR_CL CUR_OP Blk CUR_CL Else 
Else: ELSE CUR_OP Blk CUR_CL
    | 
    ;

While: WHILE Exp CUR_OP Blk CUR_CL;

For: FOR T_ident IN T_const DOT T_const CUR_OP Blk CUR_CL;










%%
int main()
{
   st = (ST*)malloc(sizeof(ST));
   init_ST(st);
   curr = st->root;
   printf("\n\nDemonstration of Phase 1 and 2 of RUST Compiler in Lex and Yacc\n");
    printf("\n---------------------------------------------------------------------\n");

   printf("Phase 1:\nTokens Generated:\n");
   yyparse();
   //printf("Accepted\n");
  //  printf("Phase 2:\n")
   if(valid==0)
   {
      printf("---------------------------------------------------------------------\nPhase 2:\nSYNTAX ERROR\n");
      printf("\n\nERROR IN LINES:\n");
      int i=0;
      // while(i<i_error)
      // {
      //    printf("%d\t",e[i]);
      //    i++;
      // }
      printf("%d\t",e[0]);
      printf("\n");
   }
      
   else
   {
      printf("---------------------------------------------------------------------\nPhase 2:\nACCEPTED: NO SYNTAX ERRORS\n");
      // printf("\n\nSYMBOL TABLE:\n");
      // print_st();
      printf("\n\n");
   }
   printf("---------------------------------------------------------------------\n");
  
   printf("\n\n;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;SYMBOL TABLE;;;;;;;;;;;;;;;;;;;;;;;;;;\n");
   Node* n[30];
   n[0]= st->root;
   print_ST(n,0,1);
}

void yyerror(char* s) 
 { 
    valid=0;
    e[i_error] = lineNo;
    i_error++;
    yyclearin;
   //  yyerrok;
    yyparse();
    //printf("\nSyntax Error\n"); 
   //  return 1;
    //yyparse();
   //  return 1;
 } 