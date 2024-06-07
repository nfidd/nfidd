data {
  int trials;
  int heads;
}

parameters {
   real<lower = 0, upper = 1> prob_heads;
}

model {
  prob_heads ~ beta(5, 5);
  heads ~ binomial(trials, prob_heads);
}
