%{
    #ifndef YYSTYPE
    #define YYSTYPE char*
    #endif

    #include<stdio.h>
    #include<string.h>
    #include"y.tab.h"
    #include"3.h"
    #define MAX 100

    void getToken(int type,char* lexeme);
    void installID(char* lexeme);
    void error();

    int err[MAX];
    int i_err = 0;
    extern int scope;
    int max_scope=0;
    int lineNo=1;
    FILE *fp;


    extern struct ident symbol_table[MAX];
    extern int i_symtab;

    void error()
    {
        err[i_err] = lineNo;
        i_err++;
    }

    void installID(char* lexeme)
    {
        //printf("-----------------------------------------installID\n");
        int i=0;
        int flag = 1;
        while(i<i_symtab)
        {
            //printf("SYMBOL TABLE READ:%s\n",symbol_table[i].lexeme);
            if(strcmp(symbol_table[i].lexeme,lexeme)==0)
            {
                if(symbol_table[i].scope==scope)
                {
                   flag = 0; 
                }
            }
            i++;
        }
        // printf("done\n");
        if(flag==1)
        {
            // struct ident token=malloc(sizeof(struct ident));
            // strcpy(token.lexeme,lexeme);
            // token.scope = scope;
            // token.line = lineNo;

            strcpy(symbol_table[i_symtab].lexeme,lexeme);
            symbol_table[i_symtab].scope = scope;
            symbol_table[i_symtab].line = lineNo;
            i_symtab+=1;
            //printf("l added\n");
            

            fp = fopen("out.txt","a+");
            // fprintf(fp,"%s,%d,%s,%s,%d\n",lexeme,scope,NULL,NULL,lineNo);
            fclose(fp);
        }
    }

    void getToken(int type,char* lexeme)
    {
        //printf("%d\n",type);

        // if(type==1)
        // {
        //     printf("<T_keyword,%s,%d>\n",lexeme,lineNo);
        // }

        // if(type==2)
        // {
        //     printf("<T_ident,%s,%s,%s,%d,%d>\n",lexeme,NULL,NULL,scope,lineNo);
        // }

        // if(type==31)
        // {
        //     printf("<T_op,%s,%s,%d>\n",lexeme,"Arithmetic",lineNo);   
        // }

        // if(type==32)
        // {
        //     printf("<T_op,%s,%s,%d>\n",lexeme,"Logical",lineNo);
        // }

        // if(type==33)
        // {
        //     printf("<T_op,%s,%s,%d>\n",lexeme,"Assignment",lineNo);
        // }

        // if(type==34)
        // {
        //     printf("<T_op,%s,%s,%d>\n",lexeme,"Relational",lineNo);
        // }

        // if(type==4)
        // {
        //     printf("<T_symb,%s,%d>\n",lexeme,lineNo);
        // }

        // if(type==51)
        // {
        //    printf("<T_const,%s,%s,%d>\n",lexeme,"Num",lineNo); 
        // }

        // if(type==52)
        // {
        //     printf("<T_const,%s,%s,%d>\n",lexeme,"Char",lineNo);
        // }

        // if(type==6)
        // {
        //     printf("<T_error,%s,%d>\n",lexeme,lineNo);
        // }
    }
void inc_scope(){
    if(scope<max_scope)
    {
        max_scope++;
        scope=max_scope;
    }
    else
    if(scope==max_scope)
    {
        scope++;
        max_scope++;
    }
}

%}

start               \/\*
end                 \*\/
SINGLE_LINE_COMMENT \/\/(.*)
MULTI_LINE_COMMENT  {start}(.*\n.*)*{end}

IDENTIFIER          [A-Za-z_][A-Za-z0-9_]*

PL             \+
MI             \-
MUL            \*
DIV            \/
MOD            \%

OP_AND2     &&
OP_OR2     \|\|


OP_ASSNG            \+=|\-=|\*=|\/=|%=|\^=|&=|<<=|>>=
OP_EQ               =

OP_LT       <
OP_GT       >
OP_LE       <=
OP_GE       >=
OP_EQQ      ==
OP_NEQ      \!=


CONST_CHAR          \'[^\']\'
CONST_BYTE          b{CONST_CHAR}
CONST_STR           \"[^\"]*\"
CONST_BSTR          b{CONST_STR}
CONST_RSTR          r#{CONST_STR}#
CONST_RBSTR         b{CONST_RSTR} 
CONST_INT           [1-9][0-9]*|0
CONST_NINT          -{CONST_INT}
CONST_FLT           [0-9]+\.[0-9]*
CONST_NFLT          -{CONST_FLT}
CONST_BOOL          true|false

SYMB_DOT            \.\.
SYMB_SEMICOLON      ;
SYMB_COMMA          ,
SYMB_COLON          :
SYMB_SLASH          \\
SYMB_PARENTHOP      \(
SYMB_PARENTHCL      \)
SYMB_SQBRKTOP       \[
SYMB_SQBRKTCL       \]
SYMB_CURBRKOP       \{
SYMB_CURBRKCL       \}
SYMB_AMPERSAND      & 

ESCCHAR             \\n


KW_INT              i8|i16|i32|i64|i128|isize|u8|u16|u32|u64|u128|usize
KW_FLT              f32|f64
KW_BOOL             bool
KW_CHAR             char
KW_FOR              for
KW_WHILE            while
KW_IF               if
KW_ELSE             else
KW_IN               in
KW_PRINT            println!
KW_LET              let
KW_MUT              mut
KW_FN               fn
KW_MAIN             main
KW_CONST            const
KW_BREAK            break
KW_RETURN           return
KW_CONTINUE         continue

%%
\n                      {;lineNo++;}
{MULTI_LINE_COMMENT}    {;}
{SINGLE_LINE_COMMENT}   {;}
                      
{KW_INT}                {getToken(1,yytext);yylval = strdup(yytext);return(DATATYPE);}
{KW_FLT}                {getToken(1,yytext);yylval = strdup(yytext);return(DATATYPE);}
{KW_BOOL}               {getToken(1,yytext);yylval = strdup(yytext);return(DATATYPE);}
{KW_CHAR}               {getToken(1,yytext);yylval = strdup(yytext);return(DATATYPE);}
{KW_FOR}                {getToken(1,yytext);yylval = strdup(yytext);return(FOR);}
{KW_WHILE}              {getToken(1,yytext);yylval = strdup(yytext);return(WHILE);}
{KW_IF}                 {getToken(1,yytext);yylval = strdup(yytext);return(IF);}
{KW_ELSE}               {getToken(1,yytext);yylval = strdup(yytext);return(ELSE);}
{KW_IN}                 {getToken(1,yytext);yylval = strdup(yytext);return(IN);}
{KW_PRINT}              {getToken(1,yytext);yylval = strdup(yytext);return(PRINTLN);}
{KW_LET}                {getToken(1,yytext);yylval = strdup(yytext);return(LET);}
{KW_MUT}                {getToken(1,yytext);yylval = strdup(yytext);}
{KW_FN}                 {getToken(1,yytext);yylval = strdup(yytext);return(FN);}
{KW_MAIN}               {getToken(1,yytext);yylval = strdup(yytext);return(MAIN);}
{KW_CONST}              {getToken(1,yytext);yylval = strdup(yytext);}
{KW_BREAK}              {getToken(1,yytext);yylval = strdup(yytext);}
{KW_RETURN}             {getToken(1,yytext);yylval = strdup(yytext);}
{KW_CONTINUE}           {getToken(1,yytext);yylval = strdup(yytext);}

{CONST_CHAR}            {getToken(52,yytext);yylval = strdup(yytext);return(T_const);}          
{CONST_BYTE}            {getToken(52,yytext);yylval = strdup(yytext);return(T_const);}
{CONST_STR}             {getToken(52,yytext);yylval = strdup(yytext);return(T_const);}
{CONST_BSTR}            {getToken(52,yytext);yylval = strdup(yytext);return(T_const);}
{CONST_RSTR}            {getToken(52,yytext);yylval = strdup(yytext);return(T_const);}
{CONST_RBSTR}           {getToken(52,yytext);yylval = strdup(yytext);return(T_const);}
{CONST_INT}             {getToken(51,yytext);yylval = strdup(yytext);return(T_const);}
{CONST_FLT}             {getToken(51,yytext);yylval = strdup(yytext);return(T_const);}
{CONST_BOOL}            {getToken(52,yytext);yylval = strdup(yytext);return(T_const);}

{IDENTIFIER}            {getToken(2,yytext);installID(yytext);yylval = strdup(yytext);return(T_ident);}

{PL}                    {getToken(31,yytext);yylval = strdup(yytext);return(PLUS);}
{MI}                    {getToken(31,yytext);yylval = strdup(yytext);return(MINUS);}
{MUL}                   {getToken(31,yytext);yylval = strdup(yytext);return(STAR);}
{DIV}                   {getToken(31,yytext);yylval = strdup(yytext);return(FSLASH);}
{MOD}                   {getToken(31,yytext);yylval = strdup(yytext);return(MOD);}

{OP_AND2}               {getToken(32,yytext);yylval = strdup(yytext);return(AND2);}
{OP_OR2}                {getToken(32,yytext);yylval = strdup(yytext);return(OR2);}

{OP_ASSNG}              {getToken(33,yytext);yylval = strdup(yytext);return(SHORTASSGN);}

{OP_LT}                 {getToken(34,yytext);yylval = strdup(yytext);return(LT);}
{OP_GT}                 {getToken(34,yytext);yylval = strdup(yytext);return(GT);}
{OP_LE}                 {getToken(34,yytext);yylval = strdup(yytext);return(LE);}
{OP_GE}                 {getToken(34,yytext);yylval = strdup(yytext);return(GE);}
{OP_EQQ}                {getToken(34,yytext);yylval = strdup(yytext);return(EQQ);}
{OP_NEQ}                {getToken(34,yytext);yylval = strdup(yytext);return(NEQ);}

{OP_EQ}                 {getToken(34,yytext);yylval = strdup(yytext);return(EQ);}

{SYMB_DOT}              {getToken(4,yytext);yylval = strdup(yytext);return(DOT);}           
{SYMB_SEMICOLON}        {getToken(4,yytext);yylval = strdup(yytext);return(SEMICOLON);}
{SYMB_COMMA}            {getToken(4,yytext);yylval = strdup(yytext);}
{SYMB_COLON}            {getToken(4,yytext);yylval = strdup(yytext);return(COLON);}
{SYMB_SLASH}            {getToken(4,yytext);yylval = strdup(yytext);}
{SYMB_PARENTHOP}        {getToken(4,yytext);yylval = strdup(yytext);return(PAR_OP);}
{SYMB_PARENTHCL}        {getToken(4,yytext);yylval = strdup(yytext);return(PAR_CL);}
{SYMB_SQBRKTOP}         {getToken(4,yytext);yylval = strdup(yytext);}
{SYMB_SQBRKTCL}         {getToken(4,yytext);yylval = strdup(yytext);}
{SYMB_CURBRKOP}         {getToken(4,yytext);yylval = strdup(yytext);inc_scope();return(CUR_OP);}
{SYMB_CURBRKCL}         {getToken(4,yytext);yylval = strdup(yytext);scope--;return(CUR_CL);}
{SYMB_AMPERSAND}        {getToken(4,yytext);yylval = strdup(yytext);}    



[ ]                     {;}
.                       {getToken(6,yytext);error();}
%%
