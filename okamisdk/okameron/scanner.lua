--[[
ident = letter {letter | digit}.
integer = digit {digit}.
selector = {"." ident | "[" expression "]"}.
number = integer.
factor = ident selector | number | "(" expression ")" | "~" factor.
term = factor {("*" | "DIV" | "MOD" | "&") factor}.
SimpleExpression = ["+"|"-"] term {("+"|"-" | "OR") term}.
expression = SimpleExpression
 [("=" | "#" | "<" | "<=" | ">" | ">=") SimpleExpression].
assignment = ident selector ":=" expression.
ActualParameters = "(" [expression {"," expression}] ")" .
ProcedureCall = ident selector [ActualParameters].
IfStatement = "IF" expression "THEN" StatementSequence
 {"ELSIF" expression "THEN" StatementSequence}
 ["ELSE" StatementSequence] "END".
WhileStatement = "WHILE" expression "DO" StatementSequence "END".
RepeatStatement = “REPEAT” Statement Sequence “UNTIL” expression.
statement = [assignment | ProcedureCall | IfStatement | WhileStatement].
StatementSequence = statement {";" statement}. 
31
IdentList = ident {"," ident}.
ArrayType = "ARRAY" expression "OF" type.
FieldList = [IdentList ":" type].
RecordType = "RECORD" FieldList {";" FieldList} "END".
type = ident | ArrayType | RecordType.
FPSection = ["VAR"] IdentList ":" type.
FormalParameters = "(" [FPSection {";" FPSection}] ")".
ProcedureHeading = "PROCEDURE" ident [FormalParameters].
ProcedureBody = declarations ["BEGIN" StatementSequence] "END" ident.
ProcedureDeclaration = ProcedureHeading ";" ProcedureBody.
declarations = ["CONST" {ident "=" expression ";"}]
 ["TYPE" {ident "=" type ";"}]
 ["VAR" {IdentList ":" type ";"}]
 {ProcedureDeclaration ";"}.
asm = "ASM" file ";".
module = "MODULE" ident ";" declarations
["BEGIN" StatementSequence] "END" ident "." . 
]]

return function(fileName,module)
    local keywords = {
        ["ARRAY"] = "arrayKw",
        ["ASM"] = "asmKw",
        ["BEGIN"] = "beginKw",
        ["CASE"] = false,
        ["CONST"] = "constKw",
        ["DIV"] = "divKw",
        ["DO"] = "doKw",
        ["ELSE"] = "elseKw",
        ["ELSIF"] = "elsifKw",
        ["END"] = "endKw",
        ["EXIT"] = false,
        ["IF"] = "ifKw",
        ["IMPORT"] = "importKw",
        ["IN"] = false,
        ["IS"] = false,
        ["LOOP"] = false,
        ["MOD"] = "modKw",
        ["MODULE"] = "moduleKw",
        ["NIL"] = "nilKw",
        ["OF"] = "ofKw",
        ["OR"] = "orKw",
        ["POINTER"] = "pointerKw",
        ["PROCEDURE"] = "procedureKw",
        ["RECORD"] = "recordKw",
        ["REPEAT"] = false,
        ["RETURN"] = false,
        ["THEN"] = "thenKw",
        ["TO"] = "toKw",
        ["TYPE"] = "typeKw",
        ["UNTIL"] = false,
        ["VAR"] = "varKw",
        ["WHILE"] = "whileKw",
        ["WITH"] = false,
        ["XOR"] = "xorKw",
    }
    local symbols = {
        ["+"] = "plus",
        ["-"] = "minus",
        ["*"] = "mul",
        ["/"] = "div",
        ["~"] = "not",
        ["&"] = "and",
        ["."] = "dot",
        [","] = "comma",
        [";"] = "semicolon",
        ["|"] = "pipe",
        ["("] = "lparen",
        ["["] = "lbracket",
        ["{"] = "lbrace",
        [":="] = "assign",
        ["^"] = "caret",
        ["="] = "eq",
        ["#"] = "neq",
        ["<"] = "lt",
        [">"] = "gt",
        ["<="] = "leq",
        [">="] = "geq",
        [".."] = "dots",
        [":"] = "colon",
        [")"] = "rparen",
        ["]"] = "rbracket",
        ["}"] = "rbrace",
    }
    local tokens = {}
    local lineStart = 1
    local line = 1
    local cursor = 1
    local cursorStart = 1
    local function addToken(t)
        table.insert(tokens,{type=t,file=fileName,line=line,col=cursorStart-lineStart,txt=module:sub(cursorStart,cursor)})
        cursor = cursor + 1
        cursorStart = cursor
    end
    local function isAlpha(c)
        return (c >= "A" and c <= "Z") or (c >= "a" and c <= "z") or c == "_"
    end
    local function isDigit(c)
        return c >= "0" and c <= "9"
    end
    while cursor < #module do
        if module:sub(cursorStart,cursor) == "\n" or module:sub(cursorStart,cursor) == "\r" then
            cursor = cursor + 1
            cursorStart = cursor
            line = line + 1
            lineStart = cursorStart
        elseif module:sub(cursorStart,cursor) == " " or module:sub(cursorStart,cursor) == "\t" then
            cursor = cursor + 1
            cursorStart = cursor
        elseif module:sub(cursorStart,cursor+1) == "(*" then
            cursor = cursor + 2
            while module:sub(cursor,cursor+1) != "*)" do
                if module:sub(cursor,cursor) == "\n" or module:sub(cursor,cursor) == "\r" then
                    line = line + 1
                    lineStart = cursor+1
                end
                cursor = cursor + 1
            end
            cursor = cursor + 2
            cursorStart = cursor
        elseif isAlpha(module:sub(cursor,cursor)) then
            while isAlpha(module:sub(cursor,cursor)) or isDigit(module:sub(cursor,cursor)) do cursor = cursor + 1 end
            cursor = cursor - 1
            if keywords[module:sub(cursorStart,cursor)] then
                addToken(keywords[module:sub(cursorStart,cursor)])
            else
                addToken("identifier")
            end
        elseif module:sub(cursor,cursor) == "\"" then
            cursor = cursor + 1
            while module:sub(cursor,cursor) != "\"" do cursor = cursor + 1 end
            addToken("string")
        elseif isDigit(module:sub(cursor,cursor)) then
            while isAlpha(module:sub(cursor,cursor)) or isDigit(module:sub(cursor,cursor)) do cursor = cursor + 1 end
            addToken("number")
        elseif symbols[module:sub(cursor,cursor)] then
            while symbols[module:sub(cursor,cursor)] do cursor = cursor + 1 end
            cursor = cursor - 1
            addToken(symbols[module:sub(cursor,cursor)])
        else
            io.stderr:write("\x1b[1;31m"..fileName.."("..line..":"..(cursorStart-lineStart)..") Unknown Token!\x1b[0m\n")
            os.exit(2)
        end
    end
    return tokens
end