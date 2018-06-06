
#########################################################################
# ADAPTATION DE LA DESCENTE DE GRADIENT A UN JEU DE RECHERCHE POUR ENFANT
#########################################################################

###########
# FONCTIONS


# fonction de coût pour le calcul du gradient, on prend la distance quadratique (sans la racine carree, plus simple a deriver).
compCost = function(X, theta){  1/2*(    (X[1]-theta[1])^2 + (X[2]-theta[2])^2    ) }

### FONCTION PRINCIPALE pour la descente de gradient orthogonal seul
DGort = function(X=NULL, return.path = FALSE, stepfactor=0.8){
  # choix d'un point de depart aleatoire si pas spécifié
  if (is.null(X)) {
    X = runif(2, 0, 100)
  }
  # démarrage au centre du plan
  theta_hist <- c(50, 50)
  # initialisation de l'historique des coûts
  cost_hist  <- compCost(X, theta_hist)
  # initialisation de l'historique des ALPHAS (les alphas sont en fait les vecteurs de changement de position)
  # on initialise en prenant aléatoiremnet l'un des 4 points sur les axes à distance de 10.
  alpha_hist <- cbind(matrix(c(0,10,10,0,-10,0,0,-10), nrow=2)[, sample(1:4, 1)])
  # initialissation de l'historique des positions thetas, la seconde étant déjà additionnée du premier vecteur alpha
  theta_hist <- cbind(theta_hist, theta_hist + alpha_hist[, 1])
  # et on ajoute un second cout pour pouvoir calculer le gradient dès le début de la boucle while
  cost_hist  <- c(cost_hist, compCost(X, theta_hist[, 2]))
  # initialisation de l'indice de la boucle while, et du booléen converged
  i=1; converged <- TRUE
  # tant qu'on n'a pas atteint le critère de convergence, on continue...
  while(cost_hist[i] > 1){
    i <- i + 1
    # le gradient est ici, en fait, constitué de la différence entre les deux derniers couts. il doit etre négatif. 
    (     gradient = diff(tail(cost_hist, 2))     )
    # on détermine le prochain vecteur de déplacement selon le signe du gradient. négatif: on réitère le meme vecteur
    # mais si positif, on inverse aléatoirement les deux coordonnées et on met un (-) devant, pour partir dans une direction 90° aléatoire.
    # si positif, on multiplie aussi par un taux d'apprentissage pour diminuer le pas.
    (     alpha_hist <- cbind(alpha_hist, switch(2-(gradient < 0), alpha_hist[, i-1], -alpha_hist[, i-1][sample.int(2, 2)]*stepfactor))     )
    # mise à jour de la nouvelle position
    (     theta_hist <- cbind(theta_hist, theta_hist[, i] + alpha_hist[, i])     )
    # mise à jour du coût.
    (     cost_hist  <- c(cost_hist, compCost(X, theta_hist[, i+1]))     )
    # si absence de convergence après 1000 itérations, fin de boucle.
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

### FONCTION PRINCIPALE pour la descente de gradient oblique aléatoire
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


### Fonctions de repartition de probabilité, choisir celle qui convient

# yet another: double triangle disjoint (equivalent orthogonal seul mais avec tolérance)
rcustomdistr = function(n=1, offs=0){
  replicate(n, switch(sample(1:2, 1), rtriangle(1, offs, pi+offs), rtriangle(1, pi+offs, 2*pi+offs)))
}
# a very simple one (1/3 orthogonal, 1/3 orthogonal opposé, 1/3 en arrière)
rcustomdistr = function(n=1, offs=0){
  replicate(n, switch(sample(1:3, 1), pi/2+offs, pi+offs, 3*pi/2+offs))
}
# densité de probabilité triple triangulaire avec plateau
rcustomdistr = function(n=1, offs=0){
  replicate(n, switch(sample(1:3, 1), rtriangle(1, offs, pi+offs), rtriangle(1, pi/2+offs, 3/2*pi+offs), rtriangle(1, pi+offs, 2*pi+offs)))
}

# fonction qui calcule l'angle d'un vecteur à partir de ses coordonénes x,y.
anglefromxy = function(vec){
  return(atan2(vec[2], vec[1]))
}

# fonction qui renvoie un vecteur faisant un angle aléatoirement choisi dans la fonction de répartition, avec un éventuel décalage angulaire "offset"
rcossin = function(offset){
  temp <- rcustomdistr(offs=offset)
  return(c(cos(temp), sin(temp)))
}





