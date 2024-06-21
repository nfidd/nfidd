array[] real geometric_random_walk(real init, array[] real noise, real std) {
    int n = num_elements(noise) + 1;
    array[n] real x;
    x[1] = init;
    for (i in 2:n) {
        x[i] = x[i-1] + noise[i-1] * std;
    }
    return exp(x);
}
