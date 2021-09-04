using LinearAlgebra, IterTools

function order(A, p)
    for k in 1:1000000
        if k > 100
            @show k, A
        end
        if (A^k).%p == I
            return k
        end
    end
end

function is_upper(A)
    A = A
    return A == UpperTriangular(A)
end

p = 2
n = 2
GL_n = []
order_p = []
for A in Iterators.product([0:(p-1) for i in 1:n^2]...)
    A = reshape(collect(A), n, n)
    if det(A)%p != 0
        append!(GL_n, [A])
        if order(A, p) == p
            append!(order_p, [A])
        end
    end
end


A = [1 1; 0 1]
B = [1 0; 1 1]
for S in GL_n
    C1 = floor.(Int, S*A*inv(S)).%p
    C2 = floor.(Int, S*B*inv(S)).%p
    @show A, B, S, C1, C2, is_upper(C1), is_upper(C2)
end


for (A,B) in Iterators.product(order_p, order_p)
    if A*B != B*A
        @show order(A*B,p)
    end
end






A = [1 1; 0 1]
B = [1 0; 1 1]
A*B


B*A

n = 2
p=2

GL_n
