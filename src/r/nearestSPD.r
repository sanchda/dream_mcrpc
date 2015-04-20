nearestSPD <- function(A)
{
  library(matrixcalc)
  dims = dim(A);
  
  if( !identical( "matrix",class(A) ) ) {
    print("A is not a matrix, exiting");
    return();
  }
  
  if( dims[1] != dims[2] ) {
    print("A is not square, exiting");
    return();
  }
  
  # Symmetrize A into B
  B = (A + t(A))/2;
  
  # Compute the symmetric polar factor of B. Call it H.
  # Clearly H is itself SPD.
  svdB = svd(B);
  H = svdB$v %*% diag(svdB$d) %*% t( svdB$v );
  
  # Get Ahat int he above formula
  Ahat = (B + H)/2;
  
  # Ensure symmetry!
  Ahat = (Ahat + t(Ahat))/2;
  
  #
  k=0;
  while( !is.positive.definite(Ahat) ) {
    # Ahat failed the SPD. It must have been just a hair off,
    # due to floating point trash, so it is simplest now just to
    # tweak by adding a tiny multiple of an identity matrix.
    
    k=k+1;
    mineig = min( eigen(Ahat)$values );
    
    Ahat = Ahat + (-mineig*k^2 + .Machine$double.eps ) * diag( dims[1] );
    
  }
  
  output = list();
  output$Ahat = Ahat;
  output$res = norm( Ahat - A, "F");
  
  return(output);
}