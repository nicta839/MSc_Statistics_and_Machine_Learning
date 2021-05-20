## Bayesian learning lab3

# rm(list = ls())
#########
### 1 ###
#########


########### A ###############
library(ggplot2)
library(mvtnorm)
# working directory change as needed
setwd("C:/Users/nicol/Documents/MSc/MSc_Statistics_and_Machine_Learning/Bayesian Learning 732A73/lab3")

data_raw <- read.table("rainfall.dat")
data_log <- unlist(log(data_raw))

# Scaled inverse chisq
#  Inverse chisquare
rInvChisq <- function(draws, n, tau_sq){
  #  n are the degrees of freedom
  X <- rchisq(draws, n)
  sample <- (tau_sq * n)/X
  return(sample)
}


mu_post <- function(x, var, mu_0, tau_0){
  n <- length(x)
  tau_n <- 1 / ((n/var) + (1 / tau_0))
  w <- (n/var) / ((n/var) + (1 / tau_0))
  mu_n <- w * mean(x) + (1-w) * mu_0
  
  return(rnorm(1, mu_n, sqrt(tau_n)))
}


var_post <- function(x, mu, v_0, var_0){
  n <- length(x)
  v_n <- v_0 + n
  variance <- (v_0*var_0 + sum((x-mu)^2)) / v_n
  return(rInvChisq(1, v_n, variance))
}

# initialize values
mu_0 <- 0
sigma_0 <- 1
tau_0 <- 1
nu_0 <- 1

draws <- 10000

gibbs_sampler <- function(data, mu_0, sigma_0, tau_0, nu_0, draws){
  mu_val <- c(mu_0, rep(0, draws))
  sigma_val <- c(sigma_0, rep(0, draws))
  # tau_val <- c(tau_0, rep(0, draws))
  # nu_val <- c(nu_0, rep(0, draws))
  dist_val <- c(rnorm(1, mu_0, sigma_0), rep(0, draws))
  
  for(i in 2:draws){
    mu_val[i] <- mu_post(x = data_log, var = sigma_val[i-1], mu_0 = mu_val[i-1], tau_0 = tau_0)
    sigma_val[i] <- var_post(x = data_log, mu = mu_val[i], v_0 = (nu_0+length(data)), var_0 = sigma_0)
    dist_val[i] <- rnorm(1, mu_val[i], sqrt(sigma_val[i]))
    
    # # Update tau and nu (why do we get correlated draws?) -> (because tau and nu are not randomly sampled)
    # tau_val[i] <- 1 / ((length(data)/sigma_val[i-1]) + (1 / tau_val[i-1]))
    # nu_val[i] <- nu_val[i-1] + length(data)
  }
  final_df <- data.frame(mu_sample = mu_val, sigma_sample = sigma_val, norm_dist = dist_val, tau_sample = tau_val, nu_sample = nu_val)
  return(final_df)
}

sample_gibbs <- gibbs_sampler(data = data_log, mu_0 = mu_0, sigma_0 = sigma_0, tau_0 = tau_0, nu_0 = nu_0, draws = draws)


# autocorrelation

mu_autocorr <- acf(sample_gibbs$mu_sample[2:10000], plot = FALSE)
sigma_autocorr <- acf(sample_gibbs$sigma_sample[2:10000], plot = FALSE)

IF_mu <- 1 + 2 * sum(mu_autocorr$acf[-1])
IF_sigma <- 1 + 2 * sum(sigma_autocorr$acf[-1])

#########
### 2 ###
#########

############# A ############
data_ebay <- read.table("eBayNumberOfBidderData.dat", stringsAsFactors = FALSE, header = TRUE)
data_ebay_glm <- data_ebay[, -2]

#fit glm model
glm_model <- glm(formula = nBids~., data = data_ebay_glm, family = "poisson")

summary(glm_model)

############# B ############
library(mvtnorm)

log_posterior <- function(Beta, X, y, mu, sigma){
  
  loglik <- sum(-log(factorial(y)) + X%*%Beta * y - exp(X%*%Beta))
  log_prior <- dmvnorm(Beta, mu, sigma, log=TRUE)
  
  #log posterior is loglik + log_prior instead of lik*prior because of the logarithm
  return(loglik + log_prior)
}

# set up the data
covariates = as.matrix(data_ebay[, -1])
target <- as.vector(data_ebay[, 1])
N <- ncol(covariates)
mu <- rep(0, N)
sigma <- (100 * solve(t(covariates)%*%covariates))


init <- rep(0, N)

res <- optim(init, log_posterior, X=covariates, y=target, mu=mu, sigma=sigma, method = "BFGS", control = list(fnscale=-1), hessian=TRUE)

coefficients <- res$par
J <- -solve(res$hessian)
colnames(J) <- colnames(data_ebay)[2:ncol(data_ebay)]
rownames(J) <- colnames(data_ebay)[2:ncol(data_ebay)]


# Draw
beta_samples <- as.matrix(rmvnorm(n=1000, mean = coefficients, sigma = J))
beta_estimates <- apply(beta_samples, 2, mean)

############# C ############

Metro_sampler <- function(draws, func, c, mu){
  coefficients <- matrix(0, nrow = draws, ncol = 9)
  coefficients[1, ] <- mu
  
  for(i in 2:draws){
    # proposal
    temp <- as.vector(rmvnorm(1, mean = as.vector(coefficients[i-1, ]), c * as.matrix(sigma_posterior)))
    #acceptance probability, use log to avoid overflow issues
    log_prob <- exp(func(temp) - func(coefficients[i-1, ]))
    # accept-reject
    a <- min(1, log_prob)
    u <- runif(1)
    
    if(u<=a){
      coefficients[i, ] <- temp
    }else{
      coefficients[i, ] <- coefficients[i-1, ]
    }
  
  }
  return(coefficients)
}

# posterior func
posterior_distrib <- function(variables){
  log_post <- dmvnorm(variables, beta_estimates, sigma_posterior, log=TRUE)
  return(log_post)
}


# Variables
betas <- rep(0, N)
sigma_posterior <- J
c <- 1

# prior
mu <- rep(0, N)
sigma_prior <-(100 * solve(t(covariates)%*%covariates))
draws <- 5000

new_beta <- Metro_sampler(draws = draws, func= posterior_distrib, c = c, mu = mu)

################ D #################
params <- c(1,1,1,1,0,1,0,1,0.7) # added 1 for const
artif_data <- exp(new_beta[1000:nrow(new_beta), ] %*% params)

pred_dist <- sapply(artif_data, rpois, n=1)

hist(pred_dist)

prob_0 <- sum(pred_dist == 0)/ length(pred_dist)

#########
### 3 ###
#########


################# A ##################
AR <- function(phi){
  # set parameters
  mu <- 20
  sigma2 <- 4
  t <- 200
  
  # initialize
  output <- rep(0, t)
  x_1 <- mu
  output[1] <- mu + rnorm(1, 0, sqrt(sigma2))
 
  # remaining of the process
  for(i in 2:t){
    output[i] <- mu + phi*(output[i-1] - mu) + rnorm(1, 0, sqrt(sigma2))
  }
  return(output)
}

# testing different values of phi
test_phi <- c(-0.5, 0, 0.5, 0.8)
tests <- sapply(test_phi, AR)
column_names <- test_phi

# Data frame
df_ar <- data.frame(tests)
colnames(df_ar) = column_names



# plot all this stuff
plot_1 <- ggplot(data = df_ar)+
  ggplot
plot_1



plot_2
plot_3
plot_4


#################### B ################
library(rstan)

# synthetic data
x <- AR(0.3)
y <- AR(0.9)

# stan model
StanModel <- "
data {
  int<lower=0> N;
  vector[N] h;
}

parameters {
  real mu;
  real phi; 
  real<lower=0> sigma;
}

model {
  mu ~ normal(0, 100);
  phi ~ normal(0, 1);
  sigma ~ normal(1, 10);
  h[2:N] ~ normal(mu + phi * (h[1:(N - 1)] - mu), sigma); 
}"

data_x <- list(N=length(x), h = x)
data_y <- list(N=length(y), h = y)
warmup <- 1000
niter <- 2000

#fit stan model
fit_x <- stan(model_code=StanModel, data=data_x, warmup=warmup, iter=niter, chains=4)
fit_y <- stan(model_code=StanModel, data=data_y, warmup=warmup, iter=niter, chains=4)

# summary
summary_x <- print(summary(fit_x)$summary)
summary_y <- print(summary(fit_y)$summary)

# get posterior samples
post_x <- extract(fit_x)
post_y <- extract(fit_y)

# Plot time series and joints

