#' Matrix Multiplication
#' 
#' Conceptually, this computes \code{t(x) \%*\% x} for a shaq \code{x}.
#' 
#' @section Communication:
#' The operation consists of a local crossproduct, followed by an
#' \code{allreduce()} call, quadratic on the number of columns.
#' 
#' @param x
#' A shaq.
#' @param y
#' Must be \code{NULL}.
#' 
#' @return 
#' A regular matrix.
#' 
#' @examples
#' \dontrun{
#' library(kazaam)
#' x = ranshaq(runif, 10, 3)
#' 
#' cp = crossprod(x)
#' comm.print(cp)
#' 
#' finalize()
#' }
#' 
#' @name crossprod
#' @rdname crossprod
NULL



cp.internal = function(x, alpha)
{
  data = Data(x)
  if (!is.double(data))
    storage.mode(data) = "double"
  
  alpha = as.double(alpha)
  
  .Call(R_mpicrossprod, data, alpha)
}

cp.shaq = function(x, y = NULL)
{
  if (!is.null(y))
  {
    if (is.shaq(y))
    {
      cp.local = crossprod(Data(x), Data(y))
      allreduce(cp.local)
    }
    else
      comm.stop("argument 'y' must be a shaq or NULL")
  }
  else
  {
    # cp.local = base::crossprod(Data(x))
    # allreduce(cp.local)
    cp.internal(x, 1.0)
  }
}



#' @rdname crossprod
#' @export
setMethod("crossprod", signature(x="shaq", y="ANY"), cp.shaq)

# TODO matrix-shaq method
