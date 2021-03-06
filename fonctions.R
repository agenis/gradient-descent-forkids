
#########################################################################
# ADAPTATION DE LA DESCENTE DE GRADIENT A UN JEU DE RECHERCHE POUR ENFANT
#########################################################################

###########
# FONCTIONS


# fonction de co�t pour le calcul du gradient, on prend la distance quadratique (sans la racine carree, plus simple a deriver).
compCost = function(X, theta){  1/2*(    (X[1]-theta[1])^2 + (X[2]-theta[2])^2    ) }

### FONCTION PRINCIPALE pour la descente de gradient orthogonal seul
DGort = function(X=NULL, return.path = FALSE, stepfactor=0.8){
  # choix d'un point de depart aleatoire si pas sp�cifi�
  if (is.null(X)) {
    X = runif(2, 0, 100)
  }
  # d�marrage au centre du plan
  theta_hist <- c(50, 50)
  # initialisation de l'historique des co�ts
  cost_hist  <- compCost(X, theta_hist)
  # initialisation de l'historique des ALPHAS (les alphas sont en fait les vecteurs de changement de position)
  # on initialise en prenant al�atoiremnet l'un des 4 points sur les axes � distance de 10.
  alpha_hist <- cbind(matrix(c(0,10,10,0,-10,0,0,-10), nrow=2)[, sample(1:4, 1)])
  # initialissation de l'historique des positions thetas, la seconde �tant d�j� additionn�e du premier vecteur alpha
  theta_hist <- cbind(theta_hist, theta_hist + alpha_hist[, 1])
  # et on ajoute un second cout pour pouvoir calculer le gradient d�s le d�but de la boucle while
  cost_hist  <- c(cost_hist, compCost(X, theta_hist[, 2]))
  # initialisation de l'indice de la boucle while, et du bool�en converged
  i=1; converged <- TRUE
  # tant qu'on n'a pas atteint le crit�re de convergence, on continue...
  while(cost_hist[i] > 1){
    i <- i + 1
    # le gradient est ici, en fait, constitu� de la diff�rence entre les deux derniers couts. il doit etre n�gatif. 
    (     gradient = diff(tail(cost_hist, 2))     )
    # on d�termine le prochain vecteur de d�placement selon le signe du gradient. n�gatif: on r�it�re le meme vecteur
    # mais si positif, on inverse al�atoirement les deux coordonn�es et on met un (-) devant, pour partir dans une direction 90� al�atoire.
    # si positif, on multiplie aussi par un taux d'apprentissage pour diminuer le pas.
    (     alpha_hist <- cbind(alpha_hist, switch(2-(gradient < 0), alpha_hist[, i-1], -alpha_hist[, i-1][sample.int(2, 2)]*stepfactor))     )
    # mise � jour de la nouvelle position
    (     theta_hist <- cbind(theta_hist, theta_hist[, i] + alpha_hist[, i])     )
    # mise � jour du co�t.
    (     cost_hist  <- c(cost_hist, compCost(X, theta_hist[, i+1]))     )
    # si absence de convergence apr�s 1000 it�rations, fin de boucle.
    if (i > 1000) {
      converged = FALSE
      break
    }
  }
  # on retourne presque tout:
  output <- list("converged"=converged,
                 "iterations"=ifelse(converged, length(cost_hist), NA),
                 "position objet"= X,
                 "distance initiale"=sqrt(cost_hist[1]),
                 "chemin"=NA
  )
  if (return.path==TRUE) {
    output[["chemin"]] <- theta_hist
  }
  return(output)
}

### FONCTION PRINCIPALE pour la descente de gradient oblique al�atoire
DGobl = function(X=NULL, return.path = FALSE, stepfactor=0.95){
  if (is.null(X)) {
    X = runif(2, 0, 100)
  }
  theta_hist <- c(50, 50)
  cost_hist  <- compCost(X, theta_hist)
  alpha_hist <- rcustomdistr() %>% rcossin %>% '*'(10) %>% as.matrix(ncol=1)
  theta_hist <- cbind(theta_hist, theta_hist + alpha_hist[, 1])
  cost_hist  <- c(cost_hist, compCost(X, theta_hist[, 2]))
  i=1; converged <- TRUE
  while(cost_hist[i] > 1){
    i <- i + 1
    (     gradient = diff(tail(cost_hist, 2))     )
    (     alpha_hist <- cbind(alpha_hist, switch(2-(gradient < 0), alpha_hist[, i-1], stepfactor*max(abs(alpha_hist[, i-1]))*alpha_hist[, i-1] %>% anglefromxy %>% rcossin))     )
    (     theta_hist <- cbind(theta_hist, theta_hist[, i] + alpha_hist[, i])     )
    (     cost_hist  <- c(cost_hist, compCost(X, theta_hist[, i+1]))     )
    if (i > 1000) {
      converged = FALSE
      break
    }
  }
  output <- list("converged"=converged,
                 "iterations"=ifelse(converged, length(cost_hist), NA),
                 "position objet"= X,
                 "distance initiale"=sqrt(cost_hist[1]),
                 "chemin"=NA
  )
  if (return.path==TRUE) {
    output[["chemin"]] <- theta_hist
  }
  return(output)
}


### Fonctions de repartition de probabilit�, choisir celle qui convient

# yet another: double triangle disjoint (equivalent orthogonal seul mais avec tol�rance)
rcustomdistr = function(n=1, offs=0){
  replicate(n, switch(sample(1:2, 1), rtriangle(1, offs, pi+offs), rtriangle(1, pi+offs, 2*pi+offs)))
}
# a very simple one (1/3 orthogonal, 1/3 orthogonal oppos�, 1/3 en arri�re)
rcustomdistr = function(n=1, offs=0){
  replicate(n, switch(sample(1:3, 1), pi/2+offs, pi+offs, 3*pi/2+offs))
}
# densit� de probabilit� triple triangulaire avec plateau
rcustomdistr = function(n=1, offs=0){
  replicate(n, switch(sample(1:3, 1), rtriangle(1, offs, pi+offs), rtriangle(1, pi/2+offs, 3/2*pi+offs), rtriangle(1, pi+offs, 2*pi+offs)))
}

# fonction qui calcule l'angle d'un vecteur � partir de ses coordon�nes x,y.
anglefromxy = function(vec){
  return(atan2(vec[2], vec[1]))
}

# fonction qui renvoie un vecteur faisant un angle al�atoirement choisi dans la fonction de r�partition, avec un �ventuel d�calage angulaire "offset"
rcossin = function(offset){
  temp <- rcustomdistr(offs=offset)
  return(c(cos(temp), sin(temp)))
}





