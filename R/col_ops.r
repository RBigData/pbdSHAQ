colsum.shaq = function(x, na.rm = FALSE, dims = 1L)
{
  cs = base::colSums(Data(x), na.rm=na.rm)
  allreduce(cs)
}



colmean.shaq = function(x, na.rm = FALSE, dims = 1L)
{
  cs = base::colSums(Data(x), na.rm=na.rm)
  allreduce(cs) / nrow(x)
}



#' Column Operations
#' 
#' Column operations (currently sums/means) for shaq objects.
#' 
#' @param x
#' A shaq.
#' @param na.rm
#' Should \code{NA}'s be removed?
#' @param dims
#' Ignored.
#' 
#' @return
#' A regular vector.
#' 
#' @name col_ops
#' @rdname col_ops
NULL

#' @rdname col_ops
#' @export
setMethod("colSums", signature(x="shaq"), colsum.shaq)

#' @rdname col_ops
#' @export
setMethod("colMeans", signature(x="shaq"), colmean.shaq)
