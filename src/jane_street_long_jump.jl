using Plots
plotly()

############### Simulation ###############
c = 0.25
function X(c)
    res = 0.
    r = 0.
    while res < c
        r = rand()
        res += r
    end
    res-r, res
end

############### CDF and PDF of the score ###############
"P(0<X<x)"
function F(c, x)
    if x < c
        return 0.
    elseif c <= x < 1
        return exp(c)*(x-c)^2/2
    elseif 1 <= x < 1 + c
        return exp(c)*(1-c)*(2x - c - 1)/2
    elseif 1 + c <= x < 2
        return exp(c)*(4x - x^2 - 2c - 2)/2
    else
        return exp(c)*(1-c)
    end
end
"pdf of X"
function f(c, x)
    if x < c || x > 2.
        return 0.
    elseif x < 1.
        return exp(c)*(x-c)
    elseif x < 1. + c
        return exp(c)*(1-c)
    else
        return exp(c)*(2-x)
    end
end

using Zygote
function D(c)
    exp(c)*(1-c)
end
function dD(c)
    D(c) - exp(c)
end

function W(c1, c2)
if c1 > c2
    return 1/12 * (-1 + c1) * (-6 - 4c1 - c1^2 + c1^3 + 10c2 + 4c1 * c2 - 
    2c1^2 * c2 - 3c2^2 + 3c1 * c2^2 - 2c2^3) * exp(c1 + c2)
elseif c1 <= c2
    return -(1/12) * (-1 + c2) * (6 - 2c1 - 3c1^2 - 2c1^3 - 4c2 + 4c1 * c2 + 
    3c1^2 * c2 - c2^2 - 2c1 * c2^2 + c2^3) * exp(c1 + c2)
else
    return -(1/12) * (-1 + c1) * (6 - 2c1 - 5c1^2 + c1^3 - 4c2 + 8c1 * c2 + 
    2c1^2 * c2 - 3c2^2 - 3c1 * c2^2) * exp(c1 + c2)
    end
end

function dW1(c1, c2)
    if c1 <= c2
        return -(1/12) * (-1 + c2) * (-2c1^3 + 
        3c1^2 * (-3 + c2) + (-2 + c2)^2 * (1 + c2) - 
        2c1 * (4 - 5c2 + c2^2)) * exp(c1 + c2)
    else
        return 1/12 * (4 + c1^4 - 2c1^3 * (-1 + c2) - 4c2 - 3c2^2 + 
        3c1^2 * (-3 + c2^2) - 2c1 * (4 - 9c2 + c2^3)) * exp(c1 + c2)
    end
end

function win_prob(c1, c2)
    D1 = D(c1)
    D2 = D(c2)
    ((1-D2)*D1 + W(c1, c2))/(D1 + D2 - D1*D2)
end

function dwin1(c1,c2)
    D1 = D(c1)
    D2 = D(c2)
    dD1 = dD(c1)
    denominator = (D1 + D2 - D1*D2)^2
    numerator = (dD1*(1-D2) + dW1(c1, c2))*(D1 + D2 - D1*D2) - dD1*(1-D2)*((1-D2) * D1 + W(c1,c2))
    numerator/denominator
end

dwin(c1,c2) = (dwin1(c1,c2), -dwin1(c2,c1))

function win_prob_grad_norm_sq(c)
    g1, g2 = dwin(c,c)
    g1^2 + g2^2
end
win_prob_grad_norm_sq(c :: AbstractArray) = win_prob_grad_norm_sq(c[1])

using Plots, LinearAlgebra
gr()
plot(range(0.41619535485823, 0.41619535485824, 50), win_prob_grad_norm_sq)

plot(0:0.01:1, c2->1-win_prob(0.65,c2))
plot(0:0.01:1, c1->win_prob(c1,0.65))

using Roots
minimizer = solve(ZeroProblem(win_prob_grad_norm_sq, 0.41619535485823583), atol=0.0, rtol=0.0)
ANSWER=round(1-D(minimizer),digits=9)

# check answer
gr()
c = minimizer
dwin(c,c)
h = 4*10^-8
plot(range(c-h, c+h, 21), c2 -> win_prob(c,c2))