#%%
import jax
import jax.numpy as jnp
import jax.random as jr
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from tqdm import trange

def rbf_kernel(x, y, sigma=1.0):
    diff = x - y
    return jnp.exp(-jnp.sum(diff**2) / (2 * sigma**2))

def grad_rbf_kernel_wrt_x(x, y, sigma=1.0):
    # gradient wrt x (the particle) of φ(y−x)
    diff = y - x
    return diff / (sigma**2) * rbf_kernel(x, y, sigma)

def empirical_bayes_samples(key, n):
    key_theta, key_eps = jr.split(key)
    # Sample standard 2D normal, then normalize each row to unit length
    theta_raw = jr.normal(key_theta, (n, 2))
    theta = theta_raw / jnp.linalg.norm(theta_raw, axis=1, keepdims=True) * R
    eps = jr.normal(key_eps, (n, 2))
    Y = theta + eps
    return Y

@jax.jit
def _step(Y, X, sigma, dt):
    # diff = x_i - Y_k  →  shape (n,m,2)
    diff = X[None, :, :] - Y[:, None, :]
    sq   = jnp.sum(diff**2, axis=-1)

    phi      = jnp.exp(-sq / (2*sigma**2))           # (n,m)
    denom    = phi.mean(axis=1, keepdims=True)       # (n,1)
    grad_phi = diff * (phi[..., None] / sigma**2)    # (n,m,2)

    drift = (grad_phi / denom[..., None]).mean(0)    # (m,2)
    dt = dt * 1/jnp.linalg.norm(drift)**0.5
    return X - dt * drift                            # Euler step

def wasserstein_gf_trajectory(Y, X_init, *, n_steps=100, dt=0.1, sigma=1.0):
    X = X_init
    traj = [X]
    for _ in trange(n_steps):
        X = _step(Y, X, sigma, dt)
        traj.append(X)
    return jnp.stack(traj)        # (n_steps+1, m, 2)

# Generate data and run the gradient flow
R = 3
key = jr.PRNGKey(42)
n = 200_000
m = 400
n_steps = 50
Y = empirical_bayes_samples(key, n)

# Select a small random subset of Y for X
key_subset = jr.PRNGKey(123)
subset_idx = jr.choice(key_subset, n, shape=(m,), replace=False)
X_init = Y[subset_idx]

trajectory = wasserstein_gf_trajectory(Y, X_init, n_steps=n_steps, dt=1., sigma=1.0)

#%%
# # Plot heatmap of Y in a separate figure
# fig_heatmap, ax_heatmap = plt.subplots(figsize=(6, 6))
# hist, xedges, yedges = jnp.histogram2d(Y[:,0], Y[:,1], bins=200, range=[[-10,10],[-10,10]])
# ax_heatmap.imshow(
#     hist.T,
#     extent=[xedges[0], xedges[-1], yedges[0], yedges[-1]],
#     origin='lower',
#     cmap='hot',
#     alpha=0.8,
#     aspect='auto'
# )
# # Draw the unit circle on the heatmap
# unit_circle_heatmap = plt.Circle((0, 0), R, color='red', fill=False, linewidth=2, label='Circle')
# ax_heatmap.add_patch(unit_circle_heatmap)

# ax_heatmap.set_title("Heatmap of Y")
# ax_heatmap.set_xlim(-10, 10)
# ax_heatmap.set_ylim(-10, 10)

#%%
# Animate
fig, ax = plt.subplots(figsize=(6, 6))
ax.scatter(Y[:,0], Y[:,1], color='gray', alpha=0.2, s=2, label='Data Y')
particles, = ax.plot([], [], 'bo', markersize=1, label='Particles')

# Draw the unit circle
unit_circle = plt.Circle((0, 0), R, color='red', fill=False, linewidth=2, label='Circle')
ax.add_patch(unit_circle)

ax.set_xlim(-10, 10)
ax.set_ylim(-10, 10)
ax.legend()

def init():
    particles.set_data([], [])
    return particles,

def animate(frame):
    X = trajectory[frame]
    particles.set_data(X[:,0], X[:,1])
    ax.set_title(f"Wasserstein Gradient Flow Step {frame}")
    return particles,

ani = animation.FuncAnimation(
    fig, animate, frames=n_steps+1, interval=100, blit=True, init_func=init
)

plt.show()

# %%
