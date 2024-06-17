array[] real geometric_random_walk(real init, array[] real noise, real std) {
    int n = num_elements(noise) + 1;
    array[n] real x;
    x[1] = init;
    x[2:n] = init + cumulative_sum(noise) * std;
    return to_array_1d(exp(x));
}