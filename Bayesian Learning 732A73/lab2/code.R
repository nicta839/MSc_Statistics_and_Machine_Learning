# Lab 2

# rm(list = ls())
#########
### 1 ###
#########


################# 1) A ################

library(ggplot2)
library(mvtnorm)
# working directory change as needed
setwd("C:/Users/nicol/Documents/MSc/MSc_Statistics_and_Machine_Learning/Bayesian Learning 732A73/lab2")


# Get data
temp_data <- read.table(file = "TempLinkoping.txt", header = TRUE)
time_matrix <- as.matrix(cbind("bias" = 1,"linear" = temp_data$time,"quad" = (temp_data$time)^2))
temp_matrix <- as.matrix(temp_data$temp)

# Lecture 5 slides
#  Inverse chisquare
rInvChisq <- function(draws, n, tau_sq){
  #  n are the degrees of freedom
  X <- rchisq(draws, n)
  sample <- (tau_sq * n)/X
  return(sample)
}
# Variance prior
var_prior <- function(nu, var){
  return(rInvChisq(draws = 1, nu, var))
}
# Beta parameters prior
beta_prior <- function(mu, var, omega){
  return(rmvnorm(1, mu, sigma = var * solve(omega)))
}


# Initial parameters
mu_0 <- matrix(c(-10, 100, -100), nrow = 3)
ohm_0 <- 0.01 * diag(3)
nu_0 <- 4
sigma_0 <- 1

set.seed(12345)

# data frames for plotting
df_init <- data.frame(x = temp_data$time, y = 0)
df_imrpove <- data.frame(x = temp_data$time, y = 0)


# generate the variance
sigma_2 <- var_prior(nu = nu_0, var = sigma_0)
# generate the betas using the previous variance
beta_vector <- beta_prior(mu = mu_0, var = sigma_2, omega = ohm_0)
df_init$y <- time_matrix%*%t(beta_vector)
# initialize plot
plot_init <- ggplot(data = df_init, aes(x = x, y = y, col="init_param"))+
  geom_line()

plot_init
# simulate many draws and plot

# Simulation with initial parameters
nDraws <- 100
for (i in 1:nDraws){
  # generate the variance
  sigma_2 <- var_prior(nu = nu_0, var = sigma_0)
  # generate the betas using the previous variance
  beta_vector <- beta_prior(mu = mu_0, var = sigma_2, omega = ohm_0)
  df_init$y <- time_matrix%*%t(beta_vector)
  plot_init <- plot_init + geom_line(data = df_init, aes(x = x, y = y, col = "init_param"))
}


# Simulation with improved parameters
mu_0_improve <- c(-10, 100, -100)
ohm_0_improve <-  diag(3)
nu_0_improve <- 4
sigma_0_improve<- 1

for (i in 1:nDraws){
  # generate the variance
  sigma_2 <- var_prior(nu = nu_0_improve, var = sigma_0_improve)
  # generate the betas using the previous variance
  beta_vector <- beta_prior(mu = mu_0_improve, var = sigma_2, omega = ohm_0_improve)
  df_init$y <- time_matrix%*%t(beta_vector)
  plot_init <- plot_init + geom_line(data = df_init, aes(x = x, y = y, col = "improved_param"))
}

plot_init

################# 1) B ################
tXX <- t(time_matrix)%*%time_matrix
beta_hat <- solve(tXX)%*%t(time_matrix)%*%temp_matrix
mu_n <- solve(tXX + ohm_0) %*% (tXX%*%beta_hat + ohm_0%*%mu_0)

ohm_n <- tXX + ohm_0

nu_n <- nu_0 + length(temp_matrix)

sigma_n <- (nu_0 * sigma_0 + (t(temp_matrix)%*%temp_matrix + t(mu_0)%*%ohm_0%*%mu_0 - t(mu_n)%*%ohm_n%*%mu_n)) / nu_n

# posterior
sigma_2_posterior <- var_prior(nu = nu_n, var = sigma_n)
beta_posterior <- rmvnorm(1, mean = mu_n, sigma = sigma_2_posterior[1]*solve(ohm_n))

#posterior data frame and plot initialization
posterior_df <- data.frame(x = temp_data$time, y = time_matrix%*%t(beta_posterior))

# plot posterior
posterior_plot <- ggplot(data = posterior_df, aes(x = x, y = y, col="posterior draws"))+
  geom_line()

# Multiple draws
nDraws <- 100

for (i in 1:nDraws){
  # generate the variance
  sigma_2_posterior <- var_prior(nu = nu_n, var = sigma_n)
  # generate the betas using the previous variance
  beta_posterior <- rmvnorm(1, mean = mu_n, sigma = sigma_2_posterior[1]*solve(ohm_n))
  posterior_df <- data.frame(x = temp_data$time, y = time_matrix%*%t(beta_posterior))
  posterior_plot <- posterior_plot + geom_line(data = posterior_df, aes(x = x, y = y, col="posterior draws"))
}

posterior_plot


### histogram of each posterior parameter
Ndraws <- 10000
df_beta <- data.frame("Beta_0" = 0, "Beta_1" = 0, "Beta_2" = 0, "sigma_2" = 0)

for (i in 1:Ndraws){
  # generate the variance
  sigma_2_posterior <- var_prior(nu = nu_n, var = sigma_n)
  beta_posterior <- rmvnorm(1, mean = mu_n, sigma = sigma_2_posterior[1]*solve(ohm_n))
  df_beta[i, ] <- cbind(beta_posterior, sigma_2_posterior)
}

histogram_b0 <- ggplot(df_beta, aes(x = Beta_0))+
  geom_histogram()

histogram_b0

histogram_b1 <- ggplot(df_beta, aes(x = Beta_1))+
  geom_histogram()

histogram_b1

histogram_b2 <- ggplot(df_beta, aes(x = Beta_2))+
  geom_histogram()

histogram_b2

histogram_sigma <- ggplot(df_beta, aes(x = sigma_2))+
  geom_histogram()

histogram_sigma

#### scatterplot
temp_posterior <- time_matrix%*%t(as.matrix(df_beta[,1:3]))

df_scatter <- data.frame("median" = rep(0, nrow(temp_posterior)), "upper" = rep(1, nrow(temp_posterior)), "lower" = rep(2, nrow(temp_posterior)))

for (i in 1:nrow(temp_posterior)){
  df_scatter[i, ] <- cbind(median(temp_posterior[i, ]), quantile(temp_posterior[i, ], probs=0.975), quantile(temp_posterior[i, ], probs = 0.025))
}

df_scatter$temp <- temp_data$temp
df_scatter$time <- temp_data$time

scatter_plot <- ggplot(df_scatter, aes(x=time, y=temp)) +
  geom_point()+
  geom_line(aes(x = time, y = median, col = "median"))+
  geom_line(aes(x = time, y = upper, col = "CI"))+
  geom_line(aes(x = time, y = lower, col ="CI"))



scatter_plot


################ 1C ############
# differentiate the function with respect to x
# The analytical position of the maximum is x = -beta_1/(2*beta_2) (the bias vanishes)

df_beta$max <- -(df_beta$Beta_1)/(2 * df_beta$Beta_2)

plot_max_temp <- ggplot(df_beta, aes(x=max))+
  geom_histogram()

plot_max_temp



########## 1D ############
#See slides lecture 5 slide 9

#########
### 2 ###
#########

library(ggplot2)
library(mvtnorm)
# working directory change as needed
setwd("C:/Users/nicol/Documents/MSc/MSc_Statistics_and_Machine_Learning/Bayesian Learning 732A73/lab2")
# Read data
data_women <- read.csv("womenWork.dat", sep = "")

# glm model
glm_estimate <- glm(formula = Work ~ 0 + ., data = data_women, family = binomial)
summary(glm_estimate)

covariates <- as.matrix(data_women[,2:ncol(data_women)])
target <- data_women[, 1]

Npar <- ncol(covariates)

# Initialize prior
mu <- as.matrix(rep(0, Npar))
tau <- 10
Sigma <- tau^2 * diag(Npar)

# Logposterior for logistic regression (code from Lisam)
LogPostLogistic <- function(betas,y,X,mu,Sigma){
  linPred <- X%*%betas;
  logLik <- sum( linPred*y - log(1 + exp(linPred)) );
  logPrior <- dmvnorm(betas, mu, Sigma, log=TRUE);
  
  return(logLik + logPrior)
}

# Initialize betas
initVal <- matrix(0, Npar, 1)


# Optimizer
OptimRes <- optim(initVal, LogPostLogistic, gr = NULL, y = target, X = covariates, mu = mu, Sigma = Sigma, method=c("BFGS"), control=list(fnscale=-1), hessian=TRUE)

beta_mode <- OptimRes$par
inv_hessian <- solve(-OptimRes$hessian)

print(beta_mode)
print(inv_hessian)

# 95% interval is 2 std deviation away from mean for normal distribution
upper <- beta_mode[7]+(2*sqrt(inv_hessian[7,7]))
lower <- beta_mode[7]-(2*sqrt(inv_hessian[7,7]))

cat("The 95% posterior probability interval is [", lower, upper,"]")

################### 2B

covariates_1 <- c(1, 13, 8, 11, (11/10)^2, 37, 2, 0)

posterior_pred <- function(x, beta){
  return((exp(t(x)%*%beta))/(1 + exp(t(x)%*%beta)))
}


draws <- 1000
pred_data <- rep(0, draws)


for(i in 1:draws){
  draws_data <- rmvnorm(n=1, mean = beta_mode, sigma = inv_hessian)
  pred_data[i] <- posterior_pred(x = covariates_1, beta = t(draws_data))
}


df_pred <- as.data.frame(pred_data)

pred_plot <- ggplot()+
  geom_histogram(data = df_pred, aes(x = pred_data))

pred_plot


################### 2C
n <- 10000
binom_pred <- rep(0, n)
for(i in 1:n){
  binom_pred[i] <- rbinom(1, 8, sample(pred_data, 1))
}

df_binomPred <- as.data.frame(binom_pred)

binom_plot <- ggplot()+
  geom_histogram(data = df_binomPred, aes(x=binom_pred))

binom_plot

