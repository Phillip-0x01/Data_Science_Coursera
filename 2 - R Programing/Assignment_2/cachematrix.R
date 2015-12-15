## This is a pair of functions to cache the an inverse of a matrix so it
## so it does not need to be completed repeatedly

## This function creates a special "matrix" object that can cache its inverse

makeCacheMatrix <- function(x = matrix()) {
  inv_matrix <- NULL
  set <- function(y)  {
        x <<- y
        inv_matrix <<- NULL
  } 
  
  get <- function() x
  setinverse <- function(solve) inv_matrix <<- solve
  getinverse <- function() inv_matrix
  list(set = set, get = get, 
       setinverse = setinverse, 
       getinverse = getinverse)
}


## This funtion computes the invers of the special "matrix" returned by makeCacheMatrix
## above.  If the inverse has already been calculated (and the matrix has not been
## changed), then the cachcesolve should retrieve the inverse from the cache.

cacheSolve <- function(x, ...) {
  inv_matrix <- x$getinverse()
  if(!is.null(inv_matrix)) {
      message ("getting cached data")
      return(inv_matrix)
  }
  data <- x$get()
  inv_matrix <- solve(data, ...)
  x$setinverse(inv_matrix)
  inv_matrix
  
}

## Test basic caching
##

