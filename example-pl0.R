#' PL/0 language using Ramble
#' 
#' [PL/0](http://en.wikipedia.org/wiki/PL/0) is a simple language which is
#' used for educational purposes. Here we will provide a sample implementation
#' based on it.
#' 
#' ## EBNF grammar
#' 
#' program = block "." .
#' 
#' block = [ "const" ident "=" number {"," ident "=" number} ";"]
#' [ "var" ident {"," ident} ";"]
#' { "procedure" ident ";" block ";" } statement .
#' 
#' statement = [ ident ":=" expression | "call" ident 
#'               | "?" ident | "!" expression 
#'               | "begin" statement {";" statement } "end" 
#'               | "if" condition "then" statement 
#'               | "while" condition "do" statement ].
#' 
#' condition = "odd" expression |
#'   expression ("="|"#"|"<"|"<="|">"|">=") expression .
#' 
#' expression = [ "+"|"-"] term { ("+"|"-") term}.
#' 
#' term = factor {("*"|"/") factor}.
#' 
#' factor = ident | number | "(" expression ")".

#' for the purposes of this example, all the assignments will be of the form
#' `assign(x, value, env=PL0)`, this will then assign the variable to 
#' PL0 environment, which we will define.
#' 
#' Currently this implementation is incomplete, as it is missing block and while grammar and logic

PL0 <- new.env()

# statement("if 1 > 2 then var1 := 3")
# statement("test := 1+2+3")
# statement("call test")
# invisible(statement("begin x := 1; x := x + 1; ! x end"))
statement <- (((identifier() %then% token(String(":=")) %then% expr)
               %using% function(stateVar) {
                 if (stateVar[[2]] == ":=") {
                   assign(stateVar[[1]], stateVar[[3]], env=PL0)
                 }
                 return(stateVar)
               })
            %alt% (symbol("!") %then% identifier() 
                    %using% function(stateVar) {
                      # this calls a defined function (procedure)
                      print(get(stateVar[[2]], envir = PL0))
                      return(stateVar)
                    })
            %alt% (token(String("if")) %then% condition %then% token(String("then")) 
                    %then% statement %using% function(x) {
                      if(x[[2]]) {
                        return(x[[4]])
                      }
                      else {
                        return(x)
                      }
                    })
             %alt% (token(String("begin")) %then% (statement %then% many(symbol(";") %then% statement))
                    %then% token(String("end")))
             %alt% (token(String("call")) %then% identifier())
             # while loop not implemented
            )

condition <- (expr %then% (token(String("<="))
                           %alt% token(String(">="))
                           %alt% symbol("=") 
                           %alt% symbol("<")
                           %alt% symbol(">")) 
                   %then% expr
                   %using% function(bool) {
                     if (bool[[2]] == "<") {
                       try(bool1 <- as.numeric(bool[[1]]) < as.numeric(bool[3]), silent=TRUE)
                       return(if (is.na(bool1)) bool else bool1)
                     }
                     else if (bool[[2]] == ">") {
                       try(bool1 <- as.numeric(bool[[1]]) > as.numeric(bool[3]), silent=TRUE)
                       return(if (is.na(bool1)) bool else bool1)
                     }
                     else if (bool[[2]] == "=") {
                       try(bool1 <- as.numeric(bool[[1]]) == as.numeric(bool[3]), silent=TRUE)
                       return(if (is.na(bool1)) bool else bool1)
                     }
                     else if (bool[[2]] == "<=") {
                       try(bool1 <- as.numeric(bool[[1]]) <= as.numeric(bool[3]), silent=TRUE)
                       return(if (is.na(bool1)) bool else bool1)
                     }
                     else if (bool[[2]] == ">=") {
                       try(bool1 <- as.numeric(bool[[1]]) >= as.numeric(bool[3]), silent=TRUE)
                       return(if (is.na(bool1)) bool else bool1)
                     }
                     else {
                       warning("boolean symbol should have matched, please check PL\\0 implementation")
                       return(bool)
                     }
                   })

expr <- ((term %then% 
            symbol("+") %then%
            expr %using% function(x) {
              #print(unlist(c(x)))
              return(sum(as.numeric(unlist(c(x))[c(1,3)])))
            }) %alt% 
           (term %then% 
              symbol("-") %then%
              expr %using% function(x) {
                #print(unlist(c(x)))
                return(Reduce("-", as.numeric(unlist(c(x))[c(1,3)])))
              }) %alt% term)

term <- ((factor %then% 
            symbol("*") %then%
            term %using% function(x) {
              #print(unlist(c(x)))
              return(prod(as.numeric(unlist(c(x))[c(1,3)])))
            }) %alt% 
           (factor %then% 
              symbol("/") %then%
              term %using% function(x) {
                #print(unlist(c(x)))
                return(Reduce("/", as.numeric(unlist(c(x))[c(1,3)])))
              }) %alt% factor)

factor <- ((symbol("(") %then%
              expr %then%
              symbol(")") %using% function(x){
                #print(unlist(c(x)))
                return(as.numeric(unlist(c(x))[2]))
              }) %alt% (natural() %using% function(x) {
                as.numeric(x)
              })
                 %alt% (identifier() %using% function(x) {
                   # try to get the value from environment
                   get(x[[1]], envir = PL0)
                 }))

