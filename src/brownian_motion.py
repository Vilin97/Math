import numpy as np

import matplotlib.pyplot as plt
import matplotlib.animation as animation

# Parameters
n_particles = 400
n_steps = 1000
dt = 0.02
drift_strength = 0.0
diffusion = 1.0

# Initialize particles in Gaussian distribution in top-left corner
np.random.seed(42)
initial_x = np.random.normal(-3, 0.5, n_particles)
initial_y = np.random.normal(3, 0.5, n_particles)

# Store particle positions
x_positions = np.zeros((n_steps, n_particles))
y_positions = np.zeros((n_steps, n_particles))

# Set initial positions
x_positions[0] = initial_x
y_positions[0] = initial_y

# Generate Brownian motion with drift toward origin
for i in range(1, n_steps):
    # Drift toward origin
    drift_x = -drift_strength * x_positions[i-1] * dt
    drift_y = -drift_strength * y_positions[i-1] * dt
    
    # Random walk component
    random_x = np.random.normal(0, np.sqrt(dt), n_particles) * diffusion
    random_y = np.random.normal(0, np.sqrt(dt), n_particles) * diffusion
    
    # Update positions
    x_positions[i] = x_positions[i-1] + drift_x + random_x
    y_positions[i] = y_positions[i-1] + drift_y + random_y
    
    # Apply reflecting boundaries
    # Reflect particles that go beyond x boundaries
    x_out_of_bounds = (x_positions[i] < -5) | (x_positions[i] > 5)
    x_positions[i][x_out_of_bounds] = np.clip(x_positions[i][x_out_of_bounds], -5, 5)
    
    # Reflect particles that go beyond y boundaries
    y_out_of_bounds = (y_positions[i] < -5) | (y_positions[i] > 5)
    y_positions[i][y_out_of_bounds] = np.clip(y_positions[i][y_out_of_bounds], -5, 5)

# Create animation
fig, ax = plt.subplots(figsize=(8, 8))
ax.set_xlim(-5, 5)
ax.set_ylim(-5, 5)
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

# Create scatter plot for particles
scat = ax.scatter(x_positions[0], y_positions[0], s=50, alpha=0.7, c=range(n_particles), cmap='viridis')

# Add time text in bottom right corner
time_text = ax.text(0.95, 0.05, '', transform=ax.transAxes, fontsize=12, 
                    verticalalignment='bottom', horizontalalignment='right',
                    bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

def animate(frame):
    scat.set_offsets(np.column_stack((x_positions[frame], y_positions[frame])))
    time_text.set_text(f'Time: {frame * dt:.2f}s')
    return scat, time_text

# Create animation
# Calculate interval: we want 1 second simulated time = 1 second real time
# Each frame represents dt seconds, so interval should be dt * 1000 ms
interval_ms = dt * 1000  # Convert dt to milliseconds
anim = animation.FuncAnimation(fig, animate, frames=n_steps, interval=interval_ms, blit=True, repeat=True)

plt.show()

# Uncomment to save animation
# Calculate fps for saved animation to match real-time playback
# fps = 1 / dt gives frames per simulated second, which equals real-time fps
save_fps = 1 / dt
anim.save('brownian_motion.gif', writer='pillow', fps=save_fps, savefig_kwargs={'facecolor': 'white'}, bitrate=1000)
# 
# For smaller file size, use mp4 format:
# anim.save('brownian_motion.mp4', writer='ffmpeg', fps=save_fps, bitrate=1800)