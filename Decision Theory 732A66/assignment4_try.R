# assignment 4


#### exercise 1 ####
#### A #####

# marginal of a guassian r.v. conditionned on another gaussian is a gaussian. Variance is the sqrt of the sum of squared variances
budget <- 120000
mu <- 115000
sigma <- sqrt(12000^2 + 9000^2)

## hypothesis
# H0: mu < budget
# H1: mu >= budget

# prior odds is the ratio between p(H0_true|H0) and p(H1_true|H0)

odds_prior <- (1-pnorm(budget, mean = mu, sd = sigma))/pnorm(budget, mean = mu, sd = sigma)

# prior odds smaller than 1 so we go in favor of H1 in the prior sense

#### B ####

n <- 6
sigma_0 <- 9000
x_bar <- 121000
# A normal distribution with a normal prior has a normal posterior distribution
# (see lecture notes from Bayesian Learning)
precision <- sqrt((n/sigma^2) + (1/sigma_0^2))
tau <- 1/precision


w <- (n/sigma^2)/(precision^2)
mu_n <- w*x_bar + (1-w)*mu

# posterior odds
odds_posterior <- (1-pnorm(budget, mean = mu_n, sd = tau^2))/pnorm(budget, mean = mu_n, sd = tau^2)

# Bayes factor
BF <- odds_posterior/odds_prior ## something is wrong in the calculation? I'm off by 0.07

#### C ####
#posterior probability from meeting 15 notes in DT

post_prob <- BF/(BF+odds_prior)

# expected loss given we think H0 but it turns out that H1
cost_1 <- post_prob * 4000
# expected loss given we think H1 but it turns out that H0
cost_2 <- (1 - post_prob) * 6000


# When minimizing expected loss, we should reject H0 and assume that we will go over the budget



######### 2 ############

#### A ####
# mean should be 1
vect <- c(1.0076, 1.0015, 0.9971)
mean_est <- mean(vect)
dev_est <- sd(vect)

alpha <- 2
beta <- 10^(-5)

summation <- sum(((vect - mean_est)^2)/2)

numerator <- beta + summation
denominator <- alpha + (3/2) + 1

mode <- numerator/denominator


### B ###


