
#########################################################################
# ADAPTATION DE LA DESCENTE DE GRADIENT A UN JEU DE RECHERCHE POUR ENFANT
#########################################################################

################
# INITIALISATION

setwd("C:/Users/user/Desktop/gradient-descent-forkids")
source("packages.R")
source("fonctions.R")

########
# SCRIPT

# vue de l'algorithme
print(GB)

# definition des fonctions de répartition pour le choix de l'angle:
# visualiser les tirages
rcustomdistr(50000) %>% hist(breaks=200)
# visualiser sur le cercle
res = rcustomdistr(1000, offs=anglefromxy(c(0,10)))
data.frame(x=cos(res), y=sin(res)) %>% ggplot(.) + aes(x=x, y=y) + geom_point(alpha=0.05, size=8, col="blue")

# visualiser le résultat d'un chemin unique
point.fixe = c(90, -36)
example = DGort(return.path = TRUE, X=point.fixe)
data.frame(t(example$chemin)) %>% setNames(c("x", "y")) %>% ggplot(.) +
  aes(x=x, y=y) + geom_path() + geom_point() + geom_point(aes(x=point.fixe[1], y=point.fixe[2]), col="red", size=4)

# analyse du nombre d'iterations et taux convergence
# choisir celle qui convient et modifier le stepfactor pour couvrir le plan d'experience
analyse = function() {temp <- DGobl(stepfactor = 0.9); c(temp$iterations, temp$distance)}
analyse = function() {temp <- DGort(stepfactor = 0.9); c(temp$iterations, temp$distance)}
# on fait un grand nombre d'itérations
res = replicate(2000, analyse())
hist(res, breaks=100); res[1, ] %>% na.fill(fill=1E4) %>% median %T>% print %>% abline(v=., col="red")
table(!is.na(res[1, ])) %>% prop.table %>% '*'(100) # pourcentage de cas de convergence

# représentation de pluseiurs chemins pour le meme objectif
point.fixe = c(66.7, 88.9)
analyse = function() {
  temp <- DGort(return.path = TRUE, X=point.fixe, stepfactor = 0.95) # changer ici DGort en DGobl
  if (temp$converged==T){temp$chemin %>% t %>% data.frame %>% setNames(c("x", "y"))}
}
res = replicate(2, analyse())
res2 = res %>% bind_rows(.id="id_iter") %>% setNames(c("id_iter", "x", "y"))
ggplot(res2) +
  aes(x=x, y=y, group=id_iter) +
  geom_hline(yintercept = 50, size=2) + geom_vline(xintercept = 50, size=2) +
  geom_path(alpha=0.01, size=3, color="blue") +
  coord_cartesian(xlim=c(30,100), ylim=c(30,100)) +
  geom_point(aes(x=50, y=50), size=8, col="blue") +
  geom_point(aes(x=point.fixe[1], y=point.fixe[2]), size=8, col="red")

# BONUS - petit chaperon rouge
# on veut plotter un graphique avec 3 solutions de paths.
# creation de 100 images gif de l'évolution du chemin de deux tracés différents.
point.fixe = c(66.7, 88.9)
set.seed(111)
size=3
path.chaperon = GBc(return.path = TRUE, X=point.fixe)
path.loup     = GB(return.path = TRUE, X=point.fixe)
df.chaperon = data.frame(t(path.chaperon$chemin)) %>% setNames(c("x", "y"))
df.loup     = data.frame(t(path.loup$chemin)) %>% setNames(c("x", "y"))
chaperon = readPNG("image_chaperon_small.png") %>% rasterGrob(interpolate=TRUE)
loup     = readPNG("image_loup_small.png") %>% rasterGrob(interpolate=TRUE)
maison   = readPNG("image_maison_small.png") %>% rasterGrob(interpolate=TRUE)
for (i in 1:50){
  df.chaperon.i = df.chaperon %>% head(i)
  df.loup.i = df.loup %>% head(i)
  last.chaperon = as.numeric(tail(df.chaperon.i, 1))
  last.loup = as.numeric(tail(df.loup.i, 1))
  g <- ggplot(data=df.chaperon) + aes(x=x, y=y) + 
    coord_cartesian(xlim=c(40, 90), ylim=c(40, 100)) +
    geom_hline(yintercept = 50, size=1) + geom_vline(xintercept = 50, size=1) +
    geom_path(data=df.chaperon.i, color="blue", size=1.5) + geom_point(data=df.chaperon.i, color="blue", size=3) + 
    geom_path(data=df.loup.i, color="red", size=1.5) + geom_point(data=df.loup.i, color="red", size=3) + 
    annotation_custom(chaperon, xmin=last.chaperon[1]-size, xmax=last.chaperon[1]+size, ymin=last.chaperon[2]-size, ymax=last.chaperon[2]+size) +
    annotation_custom(loup, xmin=last.loup[1]-size, xmax=last.loup[1]+size, ymin=last.loup[2]-size, ymax=last.loup[2]+size) +
    annotation_custom(maison, xmin=point.fixe[1]-size, xmax=point.fixe[1]+size, ymin=point.fixe[2]-size, ymax=point.fixe[2]+size)
  png(file=paste0("film_mere_grand_", i+9, '.png'))
  print(g)
  dev.off()
}
set.seed(11111)
size=3
path.chaperon = GBc(return.path = TRUE, X=point.fixe)
path.loup     = GB(return.path = TRUE, X=point.fixe)
df.chaperon = data.frame(t(path.chaperon$chemin)) %>% setNames(c("x", "y"))
df.loup     = data.frame(t(path.loup$chemin)) %>% setNames(c("x", "y"))
chaperon = readPNG("image_chaperon_small.png") %>% rasterGrob(interpolate=TRUE)
loup     = readPNG("image_loup_small.png") %>% rasterGrob(interpolate=TRUE)
maison   = readPNG("image_maison_small.png") %>% rasterGrob(interpolate=TRUE)
for (i in 1:50){
  df.chaperon.i = df.chaperon %>% head(i)
  df.loup.i = df.loup %>% head(i)
  last.chaperon = as.numeric(tail(df.chaperon.i, 1))
  last.loup = as.numeric(tail(df.loup.i, 1))
  g <- ggplot(data=df.chaperon) + aes(x=x, y=y) + 
    coord_cartesian(xlim=c(40, 90), ylim=c(40, 100)) +
    geom_hline(yintercept = 50, size=1) + geom_vline(xintercept = 50, size=1) +
    geom_path(data=df.chaperon.i, color="blue", size=1.5) + geom_point(data=df.chaperon.i, color="blue", size=3) + 
    geom_path(data=df.loup.i, color="red", size=1.5) + geom_point(data=df.loup.i, color="red", size=3) + 
    annotation_custom(chaperon, xmin=last.chaperon[1]-size, xmax=last.chaperon[1]+size, ymin=last.chaperon[2]-size, ymax=last.chaperon[2]+size) +
    annotation_custom(loup, xmin=last.loup[1]-size, xmax=last.loup[1]+size, ymin=last.loup[2]-size, ymax=last.loup[2]+size) +
    annotation_custom(maison, xmin=point.fixe[1]-size, xmax=point.fixe[1]+size, ymin=point.fixe[2]-size, ymax=point.fixe[2]+size)
  png(file=paste0("film_mere_grand_", i+9+51, '.png'))
  print(g)
  dev.off()
}




#############################################

#######
# DRAFT

# remarques et idées:
# remarque: pêut etre intégrer un saut d'alpha plus fort au bout de n itérations infructueuses...
# remarque: faire evoluer la direction aléatoire pour prendre une portion de cercle...
# remarque: tester des stratégies, comme la randomisation légère meme lorsque le gradient est négatif...
# remarque: ajouter de l'incertitude dans la mesure du gradient, pour pas créer d'effets de proche de zéro alors qu'on est éloigné...
# genre: si le gradient est positif mais proche de zéro, et qu'on est loin de l'objet, inutile d'emmerder l'enfant


# # create distribution function
# p = function(x){
#   A = 3/4*pi^2
#   if (x < 0)      return(0)
#   if (x < pi/2)   return(x/A)
#   if (x < 3*pi/2) return(pi/2/A)
#   if (x < 2*pi)   return((2*pi-x)/A)
#   if (x > 2*pi)   return(0)
# }
# library(distr)
# pv = Vectorize(p, SIMPLIFY=TRUE)
# plot(dv(seq(-1,8,0.1)), type="l")
# dist <-AbscontDistribution(p=pv)
# rdist <- r(dist)
# 
# # liaison distance/ iterations
# data.frame(t(res)) %>%
#   setNames(c("iterations", "distance")) %>%
#   mutate(converged=!is.na(iterations)) %>%
#   ggplot(.) +
#   # aes(x=distance, y=iterations) + geom_point() + geom_smooth(method="lm")
#   aes(y=distance, x=converged) + geom_boxplot()
# 
