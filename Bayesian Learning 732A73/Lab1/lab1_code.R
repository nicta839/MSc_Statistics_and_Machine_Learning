#########
### 1 ###
#########
library(ggplot2)
set.seed(12345)

############## a)
# Parameters given by the problem
s <- 8
n <- 24
f <- n - s
a_0 <- 3
b_0 <- a_0

# Derived values
a_pos <- a_0 + s
b_pos <- b_0 + f

# theoretical/ true values
t_mean <- a_pos/(a_pos + b_pos)
t_sd <- sqrt((a_pos * b_pos)/((a_pos + b_pos + 1) * (a_pos + b_pos)^2))

df <- data.frame("sample_size" = 1, "mean" = NA, "sd"  = NA)
draws <- seq(4, 10000, 2)
cnt <- 1

for(i in draws){
  rand_beta <- rbeta(i, a_pos, b_pos)
  df[cnt,] <- c(i, mean(rand_beta), sd(rand_beta))
  cnt <- cnt + 1
}


plot1 <- ggplot(df) +
  geom_line(mapping = aes(x = sample_size, y = mean), color = "green")+
  geom_hline(yintercept = t_mean, color = "red")

plot2 <- ggplot(df) +
  geom_line(mapping = aes(x = sample_size, y = sd), color = "red")+
  geom_hline(yintercept = t_sd, color = "green")

plot1
plot2

############ b)
# theoretical probability
set.seed(12345)
t_prob <- pbeta(0.4, a_pos, b_pos)

# Simulated probability
set.seed(12345)
sim_beta <- rbeta(10000, a_pos, b_pos)
sim_prob <- sum((sim_beta <= 0.4))/ length(sim_beta)

cat("The theoretical probability is: ", t_prob)
cat("\nThe calculated probability is: ", sim_prob)

######### c)

log_odds <- log(sim_beta/ (1-sim_beta))

log_df <- as.data.frame(log_odds)

plot3 <- ggplot(log_df)+
  geom_histogram(mapping = aes(x = log_df$log_odds, y = ..density..), bins = 50, fill = "green", color = "black")+
  geom_density(mapping = aes(x = log_df$log_odds), color = "red", size = 1.5)

plot3

# Are we supposed to show something else here. ASK DURING LAB SESSION


#########
### 2 ###
#########

################## a)
# Data provided
obs <- c(38, 20, 49, 58, 31, 70, 18, 56, 25, 78)
mu <- 3.8
n <- length(obs) - 1


# https://en.wikipedia.org/wiki/Inverse-chi-squared_distribution
# https://en.wikipedia.org/wiki/Scaled_inverse_chi-squared_distribution
# Information about the PDF and how to sample from the scaled inverse chi-square distribution
# X~scale-inv-chisq(nu, t^2) then X/(t^2 * nu) ~inv-chisq and the inv-chisq is just 1/X if X is chisq distributed

set.seed(12345)
rInvChisq <- function(draws, n, tau_sq){
  X <- rchisq(draws, n)
  sample <- (tau_sq * n)/X
  return(sample)
}

n_draw <- 10000
tau_sq <- sum((log(obs) - mu)^2)/n


sim_sample <- rInvChisq(n_draw, n, tau_sq)

# PDF of scaled inv chi-sq
# https://en.wikipedia.org/wiki/Scaled_inverse_chi-squared_distribution

scl_inv_chisq <- function(n, tau_sq, x){
  frac1 <- ((tau_sq * n/2)^(n/2))/(gamma(n/2))
  frac2 <- (exp((-n * tau_sq)/(2*x)))/(x^(1 + (n/2)))
  res <- frac1 * frac2
  return(res)
}


# Plotting to compare
df_sim_sample <- as.data.frame(sim_sample)

plot_chi_sq <- ggplot(df_sim_sample)+
  geom_histogram(mapping = aes(x = sim_sample, y = ..density..), bins = 50, fill = "green", color = "black")+
  stat_function(mapping = aes(x = sim_sample), fun = scl_inv_chisq, args = list(n = n, tau_sq = tau_sq), color = "red", size = 1.5)

plot_chi_sq

################# b)
set.seed(12345)
gini <- (2 * pnorm(sqrt(sim_sample)/sqrt(2))) - 1
df_gini <- as.data.frame(gini)

plot_gini <- ggplot(df_gini)+
  geom_histogram(mapping = aes(x = gini, y = ..density..), bins = 50, fill = "green", color = "black")+
  geom_density(mapping = aes(x = gini, y = ..density..), color = "red", size = 1.5)

plot_gini

################# c)
# Equal tail interval
equal_tail <- c(quantile(gini, 0.05), quantile(gini, 0.95))

#HPDI
kernel_density <- density(gini)
densities_df <- data.frame(x = kernel_density$x, density = kernel_density$y)
densities_df <- densities_df[order(densities_df$density, decreasing = TRUE), ]
cutoff <- round(nrow(densities_df) * 0.9)
densities_df <- densities_df[1:cutoff, ]
HDPI <- c(min(densities_df$x), max(densities_df$x))

cat("The equal tail interval is: ", equal_tail, "\nThe HDPI interval is: ", HDPI)

plot_density <- ggplot()+
  geom_density(mapping = aes(x = df_gini$gini, y = ..density..), color = "green", size = 1)+
  geom_segment(aes(x = equal_tail[1], y = 0.5, xend = equal_tail[2], yend = 0.5, colour = "Equal tails"))+
  geom_segment(aes(x = HDPI[1], y = 1, xend = HDPI[2], yend = 1, colour = "HDPI"))

plot_density



#########
### 3 ###
#########

# data given
data <- c(-2.44, 2.14, 2.54, 1.83, 2.02, 2.33, -2.79, 2.23, 2.07, 2.02)
mu <- 2.39
lambda <- 1

# a)
posterior <- function(kappa, data){
  n <- length(data)
  fac1 <- (1/(besselI(kappa, 0)))^n
  fac2 <- exp(kappa * (sum(cos(data - mu)) - lambda))
  res <- fac1 * fac2
  return(res)
}

kappa_seq <- seq(0, 10, 0.01)

dist <- posterior(kappa_seq, data = data)
dist_df <- data.frame(x = kappa_seq ,y = dist)


plot_von_mises <- ggplot(dist_df)+
  geom_line(mapping = aes(x = x, y = y), color = "green")

plot_von_mises

# b)
# mode is max value

mode <- dist_df[which.max(dist_df$y),]$x

cat("The approximate posterior mode of kappa is: ", mode)
