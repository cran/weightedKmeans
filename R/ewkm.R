

ewkm <- function(x, k, lambda=1, maxiter=100, delta=0.00001, maxrestart=10)
{
  if (missing(k)) 
    stop("the number of clusters 'k' must be provided")
  
  vars <- colnames(x)

  nr <- as.integer(nrow(x))
  nc <- as.integer(ncol(x))
  k <- as.integer(k)
  
  Z <- .C("ewkm",
          x=as.double(as.matrix(x)), # needs to accept a data.frame
          nr=nr,
          nc=nc,
          k=k,
          lambda=as.double(lambda),
          maxiter=as.integer(maxiter),
          delta=as.double(delta),
          maxrestart=as.integer(maxrestart),
          iterations=integer(1),
          cluster=integer(nr),
          centers=double(k * nc),
          weights=double(k * nc),
          restarts=integer(1),
          totiters=integer(1),
		  totss=double(1),
		  withinss=double(k),
          PACKAGE="weightedKmeans")

  centers <- matrix(Z$centers, ncol=ncol(x))
  colnames(centers) <- vars

  weights <- matrix(Z$weights, ncol=ncol(x))
  colnames(weights) <- vars

  # Identify missing clusters to be removed.  110804 Deal with the
  # case whereby a single cluster is returned. Previous version did it
  # properly in that centers[-ignore,] returns a matrix. But now it
  # returns a vector. So need to use drop=FALSE
  
  ignore <- which(rowSums(centers==0) == ncol(centers))
  if (length(ignore))
  {
    centers <- centers[-ignore,, drop=FALSE]
    weights <- weights[-ignore,, drop=FALSE]
  }

  # Give the rows names.

  rownames(centers) <- 1:nrow(centers)
  rownames(weights) <- 1:nrow(weights)

  cluster <- Z$cluster + 1
  
  size <- aggregate(cluster, list(cluster=cluster), length)[[2]]
  
  result <- list(cluster=cluster,
                 centers=centers,
                 totss=Z$totss,
                 withinss=Z$withinss,
                 tot.withinss=sum(Z$withinss),
                 betweenss=Z$totss-sum(Z$withinss),
                 size=size,
                 iterations=Z$iterations,
                 total.iterations=Z$totiters,
                 restarts=Z$restarts,
                 weights=weights)

  class(result) <- c("kmeans", "ewkm")

  return(result)
#  return(Z)
}

