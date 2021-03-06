% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/parser.R
\name{some}
\alias{some}
\title{\code{some} matches 1 or more of pattern \code{p}. in BNF notation, repetition occurs often enough to merit its own abbreviation. When zero or 
more repetitions of a phrase \code{p} are admissible, we simply write 
\code{p+}. The \code{some} combinator corresponds directly to this operator,
and is defined in much the same way.}
\usage{
some(p)
}
\arguments{
\item{p}{is the parser to match 1 or more times.}
}
\description{
\code{some} matches 1 or more of pattern \code{p}. in BNF notation, repetition occurs often enough to merit its own abbreviation. When zero or 
more repetitions of a phrase \code{p} are admissible, we simply write 
\code{p+}. The \code{some} combinator corresponds directly to this operator,
and is defined in much the same way.
}
\examples{
Digit <- function(...) {satisfy(function(x) {return(!!length(grep("[0-9]", x)))})}
some(Digit()) ("123abc")
}
\seealso{
\code{\link{maybe}}, \code{\link{many}}
}

