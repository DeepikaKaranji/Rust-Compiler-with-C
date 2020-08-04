%{
   #ifndef YYSTYPE
   #define YYSTYPE char*
   #endif

	#include<stdio.h>

   int yylex();
   int yyerror();
   
   #include<stdio.h>
   #include<string.h>
   #include<stdlib.h>
   #include"3.h"
   #define MAX 100

   int valid=1;

   struct ident symbol_table[MAX];
   int i_symtab;
   int scope;
   int l= 0;
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
   char temp[10];


%}

%token T_char T_ident T_const SEMICOLON LET COMMA COLON DATATYPE IN FOR DOT FN MAIN PRINTLN
%token IF ELSE WHILE
%token PAR_OP PAR_CL CUR_OP CUR_CL
%token LT LE EQQ NEQ GE GT AND2 OR2 EQ SHORTASSGN
%token PLUS MINUS STAR FSLASH MOD

%%

Main:{printf("level:%d MAIN \n",l);} FN MAIN PAR_OP PAR_CL CUR_OP Blk CUR_CL;
Blk:Code Blk {}
   |{printf("level:%d IF blk\n",++l);}If Blk
   |{printf("level:%d WHILE blk\n",++l);}While Blk
   |{printf("level:%d FOR blk\n",l-=1 );}For Blk
   |  
   ;
Code: Eval
    |Out
    |Exp
    |Var_dec 
    ;
Eval:T_ident  {printf("level:%d = level:%d %s ", l+1,l+2,$1);} EQ Exp SEMICOLON 
   ;

Exp: Val T_op Exp {printf("level:%d %s level:%d %s level:%d %s\n",l+1,$2,l+2,$1,l+2,$3);}
   | PAR_OP Exp PAR_CL
   |Val
   ;

T_op: PLUS
   |MINUS
   |FSLASH
   |STAR
   |MOD
   |LT
   |GT
   |LE
   |GE
   |NEQ
   |EQQ
   |OR2
   |AND2
   |EQ
   |SHORTASSGN
   

   ;

Val: T_ident
   | T_const
   ;

Out: PRINTLN PAR_OP Body PAR_CL SEMICOLON;
Body: T_char
    | T_char COMMA Val
    | 
    ;

Var_dec:LET T_ident COLON DATATYPE EQ Val SEMICOLON 
      {printf("level:%d = level:%d %s level:%d %s\n",l+1,l+2,$2,l+2,$6);add_value($2,$6,$4); }
      ;

If:IF PAR_OP Exp PAR_CL CUR_OP Blk CUR_CL Else;
Else: ELSE CUR_OP Blk{printf("level:%d ELSE Blk\n",l);} CUR_CL| ;

While: WHILE PAR_OP Exp PAR_CL CUR_OP Blk CUR_CL;

For: FOR T_ident IN T_const DOT T_const CUR_OP Blk CUR_CL {printf("level:%d in level:%d %s level:%d .. level:%d %s level:%d %s\n", l+1,l+2,$2,l+2,l+3,$4,l+3,$6);} ;
%%
int main()
{
   yyparse();
   //printf("Accepted\n");
   if(valid==0)
   {
      printf("----------------------------------------------\nSYNTAX ERROR\n");
      printf("SYMBOL TABLE:\n");
      // print_st();
   }
      
   else
   {
      printf("----------------------------------------------\nACCEPTED\n");
      // printf("SYMBOL TABLE:\n");
      // print_st();
   }
}

int yyerror(char* s) 
 { 
    valid=0;
    //printf("\nSyntax Error\n"); 
    return 1;
 } 
