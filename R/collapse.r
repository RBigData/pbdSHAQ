#' collapse
#' 
#' Collapse a shaq into a regular matrix.
#' 
#' @details
#' Only rank 0 will own the matrix on return.
#' 
#' @section Communication:
#' Short answer: quite a bit.  Each local submatrix has to be sent to rank 0.
#' 
#' @param x
#' A shaq.
#' 
#' @return
#' A regular matrix (rank 0) or \code{NULL} (everyone else).
#' 
#' @examples
#' spmd.code = "
#'   suppressMessages(library(kazaam))
#'   dx = ranshaq(runif, 10, 3)
#'   
#'   x = collapse(dx)
#'   comm.print(x)
#'   
#'   finalize()
#' "
#' 
#' pbdMPI::execmpi(spmd.code=spmd.code, nranks=2)
#' 
#' @export
collapse <- function (x) UseMethod("collapse", x)



#' @export
collapse.shaq = function(x)
{
  if (comm.rank() == 0)
  {
    size = comm.size()
    if (is.integer(DATA(x)))
      ret = matrix(0L, nrow(x), ncol(x))
    else if (is.logical(DATA(x)))
      ret = matrix(FALSE, nrow(x), ncol(x))
    else
      ret = matrix(0.0, nrow(x), ncol(x))
    
    top = nrow.local(x)
    ret[1:top, ] = DATA(x)
    
    if (size > 1)
    {
      for (i in 1:(size - 1L))
      {
        x.local = recv(rank.source=i)
        size = NROW(x.local)
        
        ret[top + (1:size), ] = x.local
        top = top + size
      }
    }
    
    # preserve attributes
    attrs = attributes(DATA(x))[-which(names(attributes(DATA(x)))=="dim")]
    if (length(attrs))
      attributes(ret) = c(attributes(ret), attrs)
    
    ret
  }
  else
  {
    send(DATA(x), rank.dest=0)
    
    invisible(NULL)
  }
}



#' @export
collapse.tshaq = function(x)
{
  if (comm.rank() == 0)
  {
    size = comm.size()
    if (is.integer(DATA(x)))
      ret = matrix(0L, nrow(x), ncol(x))
    else if (is.logical(DATA(x)))
      ret = matrix(FALSE, nrow(x), ncol(x))
    else
      ret = matrix(0.0, nrow(x), ncol(x))
    
    top = ncol.local(x)
    ret[, 1:top] = DATA(x)
    
    if (size > 1)
    {
      for (i in 1:(size - 1L))
      {
        x.local = recv(rank.source=i)
        size = NCOL(x.local)
        
        ret[, top + (1:size)] = x.local
        top = top + size
      }
    }
    
    # preserve attributes
    attrs = attributes(DATA(x))[-which(names(attributes(DATA(x)))=="dim")]
    if (length(attrs))
      attributes(ret) = c(attributes(ret), attrs)
    
    ret
  }
  else
  {
    send(DATA(x), rank.dest=0)
    
    invisible(NULL)
  }
}
