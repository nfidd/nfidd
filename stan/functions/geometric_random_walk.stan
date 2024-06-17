array[] real geometric_random_walk(real init, array[] real noise, real std) {
    int n = num_elements(noise) + 1;
    array[n] real x;
    x[1] = init;
    x[2:n] = to_array_1d(init + cumulative_sum(to_vector(noise) * std));
    return exp(x);
}