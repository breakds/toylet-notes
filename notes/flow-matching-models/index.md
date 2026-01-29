---
id: flow-matching-models
title: Notes on Flow Matching Models
author: Break Yang
date: 2026-01-21
---

# The Denoising Intuition [id=denoising-intuition]

The intuition behind [#section:vae] teaches us that sampling from a simple distribution works well, as long as we can map those samples to the target distribution. The idea in [#section:step-by-step-dist-model] suggests this mapping can be done incrementally. Flow matching models build on this idea—let's develop intuition for how they learn to sample from a data distribution $p(z)$.

## Can you denoise it?

Below is an image of a cat. If we add some Gaussian white noise to it, it becomes a noisy cat image. It is not hard for you to "denoise" it in your mind and obtain a cat image that somewhat resembles the original, right? The denoised image in your mind may not be an exact copy of the original, but it would be close. This example illustrates that learning a model to denoise such images is not an unrealistic goal.

![Original and noisy cat](cat_denoise_example.png)

Both images can be viewed as points in a high-dimensional space $\mathbb{R}^d$. Let's denote the original image as $z$. The denoising process finds a way to map the noisy image back toward the original $z$.

![Denoising as mapping](plot_denoise_arrow.png)

## Can you still denoise it, step by step?

The procedure of adding white noise can go on and on, producing a sequence of images (points in $\mathbb{R}^d$). It becomes increasingly harder to denoise, until eventually we reach pure white noise.

![Noise sequence](noise_sequence.png)

Denoising step-by-step means going from the pure white noise image back to $z$. 

![Stepwise path](plot_stepwise_path.png)

It is natural to imagine that, as the noise-adding steps becomes more and more until it reaches infinity, the recovered path becomes smoother and smoother, and eventually it becomes a smooth trajectory like below.

![Smooth trajectory](plot_smooth_trajectory.png)

The goal now becomes "recover the trajectory". 

## Define "Recovering the Trajectory"

Let's get slightly more mathematical. Let $x_0$ denote the starting point (pure Gaussian white noise) and $x_1 = z$ the end goal (the cat image). The trajectory $\{x_t\}_{t \in [0,1]}$ traces a path from noise to data.

Depending on whether you are from a control theory background or Math background or both, such trajectory can be described by an ordinary differential equation (ODE) or first order system:

$$
\frac{\partial}{\partial t} x_t = u_t(x_t)
$$

It is straightforward to see that the function $u_t(\cdot)$ is a [#section:flow].

Here is how to understand the above equation intuitively. Suppose at time $t$ we are at point $x_t = x \in \mathbb{R}^d$. To reach the point at $t + h$, where $h$ is an infinitesimal timestep, we simulate using

$$
x_{t+h} \leftarrow x + u_t(x) \cdot h
$$

Note that since $u_t(\cdot)$ is a [#section:flow], it can move any starting point $x_0 \in \mathbb{R}^d$ to a corresponding endpoint $x_1 \in \mathbb{R}^d$. We don't yet have a way to find a good flow $u_t(\cdot)$, but we can describe the properties we want it to have.

Since the flow $u_t(\cdot)$ is defined for all $x \in \mathbb{R}^d$, it can move any $x_0$ sampled from $\mathcal{N}(0, I)$ along a trajectory to some endpoint $x_1 = z$. As it does so, the flow "carries" the probability density from $\mathbf{X}_0$ to $\mathbf{X}_1$. We want this transformed distribution of $\mathbf{X}_1$ to match the data distribution $p(z)$—meaning $\mathbf{X}_1$ and $\mathbf{Z}$ become equivalent random variables. In other words, the flow transforms a distribution that is easy to sample into the target data distribution.

If we find such a flow $u_t(\cdot)$, we can generate samples from the data distribution by:

1. Sample $x_0 \sim \mathcal{N}(0, I)$
2. Use $u_t(\cdot)$ to simulate the trajectory, reaching $x_1$
3. That $x_1$ is a sample $z$ from the target data distribution.

The remaining million dollar question is then: how do we find such a good flow?

# Finding The Flow (Analytically)

# Training - Finding The Flow (Approximately) In Practice

# The Gaussian Case

# References

