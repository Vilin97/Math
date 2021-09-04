using AbstractAlgebra

G = SymmetricGroup(5)
A5 = [y for y in G if parity(y)==0]

function conjugacy_class(elt, group)
    conj_class = []
    for y in group
        append!(conj_class,[y*elt*inv(y)])
    end
    Set(conj_class)
end

x = Perm([2,3,1,4,5])
y = Perm([2,1,4,3,5])
z = Perm([2,3,4,5,1])
α = Perm([2,3,5,1,4])
id = Perm([1,2,3,4,5])
conjugacy_class(x, A5)
conjugacy_class(y, A5)
conjugacy_class(z, A5)
conjugacy_class(α, A5)
conjugacy_class(id,A5)
