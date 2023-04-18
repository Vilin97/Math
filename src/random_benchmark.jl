using Random, BenchmarkTools, DataStructures, RandomNumbers

"reuse random number"
function reuse_randomness(pq, rx, t, oldrate, cur_rate)
    oldrate / cur_rate * (pq[rx] - t)
end

"generate new random number"
function new_randomness(rng, cur_rate)
    randexp(rng) / cur_rate
end

n = 10^5
firing_times = rand(n)
pq = MutableBinaryMinHeap(firing_times)

t = 0.0
oldrate = 1.0
cur_rate = 1.0
rng1 = Xorshifts.Xoroshiro128Star(rand(UInt64))
rng2 = Random.default_rng()

rx = 100
b1=@benchmark reuse_randomness($pq, $rx, $t, $oldrate, $cur_rate) # median 3.6 ns
b2=@benchmark new_randomness($rng1, $cur_rate) # median 6.7 ns
b3=@benchmark new_randomness($rng2, $cur_rate) # median 9.5 ns