% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_robust_vcxt_panel.R
\name{get_robust_vcxt_panel}
\alias{get_robust_vcxt_panel}
\title{Create and returns a function to estimate hc and clustered standard errors for panel data.}
\usage{
get_robust_vcxt_panel(func_name)
}
\arguments{
\item{func_name}{A character.}
}
\value{
A function.
}
\description{
Create and returns a function to estimate hc and clustered standard errors for panel data.
}
\references{
Croissant, Y., Millo, G. (2017). "Robust Standard Error Estimators for Panel Models: A Unifying Approach." \emph{Journal of Statistical Software}, 27(2), 1-43.
 \doi{10.18637/jss.v082.i03}.
}
\keyword{internal}
