array[] real geometric_diff_ar(real init, array[] real noise, real std, real damp) {
    int n = num_elements(noise) + 1;
    array[n] real x;
    x[1] = init;
    x[2] = init + noise[1] * std;
    for (i in 3:n) {
        x[i] = x[i - 1] + damp * (x[i -1] - x[i- 2]) * noise[i - 1] * std;
    }
    return exp(x);
}