grammar HaskellGrammar;

@parser::header
{
    import java.util.*;
	import java.io.FileWriter;
}

@lexer::header
{
    import java.util.*;
	import java.io.FileWriter;
}

@members
{
    void out (String outstring)
    {
        System.out.println(outstring);
    }

	FileWriter output = new FileWriter(".\\a.txt");

	String PythonMemoization = "import collections\n"+
		"import functools\n\n" +
		"class memoized(object):\n" +
		"\tdef __init__(self, func):\n" +
		"\t\tself.func = func\n" +
		"\t\tself.cache = {}\n" +
		"\tdef __call__(self, *args):\n" +
		"\t\tif not isinstance(args, collections.Hashable):\n" +
		"\t\t\treturn self.func(*args)\n" +
		"\t\tif args in self.cache:\n" +
		"\t\t\treturn self.cache[args]\n" +
		"\t\telse:\n" +
		"\t\t\tvalue = self.func(*args)\n" +
		"\t\t\tself.cache[args] = value\n" +
		"\t\t\treturn value\n" +
		"\tdef __get__(self, obj, objtype):\n" +
		"\t\treturn functools.partial(self.__call__, obj)\n" ;
	//output.write(PythonMemoization);

	Map<String, Integer> variables = new HashMap<String, Integer>();

	void closeWriter()
	{
		output.close();
	}
	//!!! TODO: IMPLEMENT FUNCTIONS TABLE AND VARIABLES TABLE
}


startRule
@after {this.closeWriter();}
: expr+ ;


expr: func_annotation
	| func_declaration
	| lvalue ASSIGN maybe_braced_rvalue {$lvalue.value = $maybe_braced_rvalue.value}
	| rvalue
	| output
	| input	;


//====================================================== FUNCTIONS =====================================================
//************************************************ function annotations ************************************************

func_annotation: func_name '::' LBRACKET type_restriction RBRACKET '=>' param_name ('->' param_name)* ;
type_restriction: type_name param_name (',' type_name)* ;

//*********************************************** function declarations ************************************************
//there're three ways to declare a function supported: with if...then...else, with guards, with pattern-matching

func_declaration: ifthenelse_decl | guards_decl | pattern_decl ;

ifthenelse_decl: func_name func_decl_params ASSIGN IF condition THEN maybe_braced_rvalue ELSE maybe_braced_rvalue;

guards_decl: func_name func_decl_params (guard)+ ;
guard: GUARD (condition | OTHERWISE) ASSIGN maybe_braced_rvalue;

pattern_decl: func_name func_pattern_value ASSIGN maybe_braced_rvalue;
func_pattern_value: literal | variable ;

func_decl_params: literal | variable ;

//*************************************************** function calls ***************************************************
//braces when calling a function are mandatory

func_call returns [int value]: func_name LBRACKET func_call_params RBRACKET
{

   put("   " + $func_name.text + "(" + $func_call_params.strvalue + ")");

}

;

func_call_params: maybe_braced_rvalue (COMMA maybe_braced_rvalue)*;

//===================================================== CONDITIONS =====================================================
//the only supported conditions are: < > <= >= == /=

condition: cond_less | cond_great | cond_leq | cond_geq | cond_eq | cond_neq;
cond_less: maybe_braced_rvalue LESS maybe_braced_rvalue;
cond_great: maybe_braced_rvalue GREAT maybe_braced_rvalue;
cond_leq: maybe_braced_rvalue LEQ maybe_braced_rvalue;
cond_geq: maybe_braced_rvalue GEQ maybe_braced_rvalue;
cond_eq: maybe_braced_rvalue EQ maybe_braced_rvalue;
cond_neq: maybe_braced_rvalue NEQ maybe_braced_rvalue;

//===================================================== VARIABLES ======================================================
variable_decl returns [String identifier]: LET x = variable
{
	$identifier = $x.identifier;
};


lvalue returns [String identifier, int value]: x = variable_decl
{
	$identifier = $x.identifier;
}
	| y = variable
{
	$identifier = $y.identifier;
	$value = $y.value
} ;

input: lvalue '<-' 'getInt'
{
	// $lvalue.value = ????
	writer.write("$lvalue.identifier = int(input())\n");
};

output: 'print' LBRACKET maybe_braced_rvalue RBRACKET 
{
	writer.write("$maybe_braced_rvalue.value");
};

//======================================================== MATH ========================================================

maybe_braced_rvalue returns [int value]: rvalue | (LBRACKET rvalue RBRACKET)

rvalue returns [int value]: binary_add 	{$value = $binary_add.value}		// |for binary expressions
	| binary_sub						{$value = $binary_sub.value}		// |
	| unary_expr						{$value = $unary_expr.value}	    //for unary minus
	| func_call							{$value = $func_call.value}
	| variable							{$value = $variable.value}
	| literal 							{$value = $literal.value};	

unary_expr returns [int value]: MINUS maybe_braced_rvalue {$value = -1 * $maybe_braced_rvalue.value};

//all binary expressions are expected to be (x1*...*xn) ± ((...) ± (y1*...*yn))

binary_add returns [int value]: addend (PLUS maybe_braced_addend)? 
{$value = $addend.value + $maybe_braced_addend.value};

binary_sub returns [int value]: addend (MINUS maybe_braced_addend)? 
{$value = $addend.value - $maybe_braced_addend.value};

maybe_braced_addend returns [int value]: (LBRACKET addend RBRACKET) | addend
{$value = $addend.value};
addend returns [int value]: addend_mult | addend_div | single_value;

addend_mult returns [int value]: x=single_value ASTERISK y=maybe_braced_addend
{$value = $x.value * $y.value};
addend_div returns [int value]: x=single_value SLASH y=maybe_braced_addend
{$value = $x.value / $y.value};
single_value returns [int value]: variable 		{$value = $variable.value}
								| literal 		{$value = $literal.value}
								| func_call 	{$value = $func_call.value}
								| unary_expr 	{$value = $unary_expr.value};

//======================================================== LEXER =======================================================

variable returns [String identifier, int value]: ID {$identifier = $ID.text /* $value = ???  */};
literal returns[int value]: INT {value = $INT.text};
func_name: ID;
type_name: 'Int' | 'Integral';
param_name: ID;

//keywords
IF: 'if';
THEN: 'then';
ELSE: 'else';
GUARD: '|';
LET: 'let' ;
OTHERWISE: 'otherwise';

//some characters
PLUS : '+' ;
MINUS: '-' ;
ASTERISK: '*';
SLASH: '/';
LBRACKET: '(';
RBRACKET: ')';
ASSIGN: '=';
LESS: '<';
GREAT: '>';
LEQ: '<=';
GEQ: '>=';
EQ: '==';
NEQ: '/=';

COMMA: ',';

//digits and numbers
fragment DIGIT: [0-9] ;
INT: DIGIT+;

//letters, words, strings
fragment LETTER: [a-zA-Z] ;
ID: LETTER+;// (LETTER | DIGIT | '_')* ;		//a single word indentifier; starts with letter

WS: [ \t] -> skip ;
NEWLINE: [\r\n] -> skip ;

COMMENT: ('--' (LETTER | DIGIT | WS| ['"()_,.!?] )* NEWLINE) -> skip;
