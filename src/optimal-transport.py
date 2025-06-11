#%%
import numpy as np
import matplotlib.pyplot as plt
import ot
import ot.plot

#%%
n = 50  # nb samples

mu_s = np.array([0, 0])
cov_s = np.array([[1, 0], [0, 1]])

mu_t = np.array([4, 4])
cov_t = np.array([[1, -0.8], [-0.8, 1]])

xs = ot.datasets.make_2D_samples_gauss(n, mu_s, cov_s)
xt = ot.datasets.make_2D_samples_gauss(n, mu_t, cov_t)

a, b = np.ones((n,)) / n, np.ones((n,)) / n  # uniform distribution on samples

# loss matrix
M = ot.dist(xs, xt)

#%%
plt.figure(1)
plt.plot(xs[:, 0], xs[:, 1], "+b", label="Source samples")
plt.plot(xt[:, 0], xt[:, 1], "xr", label="Target samples")
plt.legend(loc=0)
plt.title("Source and target distributions")

plt.figure(2)
plt.imshow(M, interpolation="nearest")
plt.title("Cost matrix M")

#%%
G0, log = ot.emd(a, b, M, log=True)
print(f"Exact W1 cost: {log['cost']:.3f}") # 33.422

plt.figure(3)
plt.imshow(G0, interpolation="nearest")
plt.title("OT matrix G0")

plt.figure(4)
ot.plot.plot2D_samples_mat(xs, xt, G0, c=[0.5, 0.5, 1])
plt.plot(xs[:, 0], xs[:, 1], "+b", label="Source samples")
plt.plot(xt[:, 0], xt[:, 1], "xr", label="Target samples")
plt.legend(loc=0)
plt.title("OT matrix with samples")
plt.show()

#%%
# reg term
lambd = 1e-1

Gs = ot.sinkhorn(a, b, M, lambd)
cost = np.sum(Gs * M)
print(f"Sinkhorn W1 cost: {cost:.3f}") # 33.469
indep_plan = np.outer(a, b)  # independent plan for comparison
indep_cost = np.sum(indep_plan * M)
print(f"cost of independent coupling: {indep_cost:.3f}") # 37

plt.figure(5)
plt.imshow(Gs, interpolation="nearest")
plt.title("OT matrix sinkhorn")

plt.figure(6)
ot.plot.plot2D_samples_mat(xs, xt, Gs, color=[0.5, 0.5, 1])
plt.plot(xs[:, 0], xs[:, 1], "+b", label="Source samples")
plt.plot(xt[:, 0], xt[:, 1], "xr", label="Target samples")
plt.legend(loc=0)
plt.title("OT matrix Sinkhorn with samples")

plt.show()

#%%
"Illustrates the bound  E W₁(μₙ, μ) ≤ D/2·√(k/n)  on a finite metric space, where D = diam(X) and k = |X|."

# ---------- parameters ----------
k, n, seed = 2, 100, 0         # |X|, # samples, RNG seed
rng       = np.random.default_rng(seed)

# ---------- 1. build the space X ⊂ ℝ² ----------
X = rng.uniform(0, 1, size=(k, 2))                     # k random points
M = ot.dist(X, X)
D = M.max()                                            # diameter of X

# ---------- 2. define the true measure μ on X ----------
mu = rng.random(k)
mu /= mu.sum()                                         # non-negative, ∑μᵢ=1

# ---------- 3. empirical measure μₙ ----------
idx     = rng.choice(k, size=n, p=mu)                  # iid samples
counts  = np.bincount(idx, minlength=k)
mu_n    = counts / n                                   # histogram on X

# ---------- 4. exact W₁ with EMD ----------
G, log  = ot.emd(mu_n, mu, M, log=True)
cost    = log["cost"]                                  # W₁(μₙ, μ)

bound   = D * 0.5 * np.sqrt(k / n)                     # RHS of inequality

print(f"W1(μ_n, μ) = {cost:.4f}")
print(f"Bound      = {bound:.4f}")

# ---------- 5. visualisation ----------
plt.figure(1)
plt.imshow(G, origin="lower")
plt.title("OT matrix G"); plt.colorbar()

plt.figure(2)
ot.plot.plot2D_samples_mat(X, X, G, c=[0.5, 0.5, 1])
plt.scatter(X[:, 0], X[:, 1], marker="+", color="b", label="support")
plt.legend(); plt.title("Transport plan")
plt.show()

#%%
# Vary the seeds and plot the histogram of W1 costs, the mean, and the bound

num_trials = 1000
k, n = 2, 100  # keep consistent with previous example
costs = []

for seed in range(num_trials):
    rng = np.random.default_rng(seed)
    X = rng.uniform(0, 1, size=(k, 2))
    M = ot.dist(X, X)
    D = M.max()
    mu = rng.random(k)
    mu /= mu.sum()
    idx = rng.choice(k, size=n, p=mu)
    counts = np.bincount(idx, minlength=k)
    mu_n = counts / n
    G, log = ot.emd(mu_n, mu, M, log=True)
    cost = log["cost"]
    costs.append(cost)

costs = np.array(costs)
bound = D * 0.5 * np.sqrt(k / n)  # last D from last trial

plt.figure()
plt.hist(costs, bins=30, alpha=0.7, label="W1(μₙ, μ) histogram")
plt.axvline(costs.mean(), color='r', linestyle='--', label=f"Mean: {costs.mean():.4f}")
plt.axvline(bound, color='g', linestyle='-', label=f"Bound: {bound:.4f}")
plt.xlabel("W1(μₙ, μ)")
plt.ylabel("Frequency")
plt.title(f"Histogram of W1 costs over {num_trials} seeds (k={k}, n={n})")
plt.legend()
plt.show()
