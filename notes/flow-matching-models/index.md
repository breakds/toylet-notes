---
id: flow-matching-models
title: Notes on Flow Matching Models
author: Break Yang
date: 2026-01-21
---

# The Denoising Intuition [id=denoising-intuition]

The intuition behind [#section:vae] teaches us that sampling from a simple distribution works well, as long as we can map those samples to the target distribution. The idea in [#section:step-by-step-dist-model] suggests this mapping can be done incrementally. Flow matching models build on this idea—let's develop intuition for how they learn to sample from a data distribution $p(z)$.

## Can you denoise it?

Below is an image of a cat (credit to GPT-5.2). If we add some Gaussian white noise to it, it becomes a noisy cat image. It is not hard for you to "denoise" it in your mind and obtain a cat image that somewhat resembles the original, right? The denoised image in your mind may not be an exact copy of the original, but it would be close. This example illustrates that learning a model to denoise such images is not an unrealistic goal.

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

## The View of Distribution Transformation

Since the flow $u_t(\cdot)$ is defined for all $x \in \mathbb{R}^d$ and all $t \in [0, 1]$ it can move any $x_0$ sampled from $\mathcal{N}(0, I)$ along a trajectory to some endpoint $x_1 = z$. As it does so, the flow "carries" the probability density from $\mathbf{X}_0 \sim \mathcal{N}(0, I)$ to $\mathbf{X}_1$. We want this transformed distribution of $\mathbf{X}_1$ to match the data distribution $p(z)$—meaning $\mathbf{X}_1$ and $\mathbf{Z}$ become equivalent random variables. In other words, the flow transforms a distribution that is easy to sample into the target data distribution.

If we find such a flow $u_t(\cdot)$, we can generate samples from the data distribution by:

1. Sample $x_0 \sim \mathcal{N}(0, I)$
2. Use $u_t(\cdot)$ to simulate the trajectory, reaching $x_1$
3. That $x_1$ is a sample $z$ from the target data distribution.

The remaining million dollar question is then: how do we find such a good flow?

# The Hunt of An Ideal Flow (Single Data Point Case) [id=single-data-point-flow]

Let's start from a single data point $z \in \mathbb{R}^d$ (think of that cat image). We'll construct a simple "noise-adding" procedure and then derive the flow that reverses it.

## The noise-adding procedure

Define two **smooth monotonic** scheduling functions $\alpha_t$ and $\beta_t$ with boundary conditions:
- $\alpha_0 = 0$, $\alpha_1 = 1$ (weight on data grows from 0 to 1)
- $\beta_0 = 1$, $\beta_1 = 0$ (weight on noise shrinks from 1 to 0)

Now sample a noise vector $\epsilon \sim \mathcal{N}(0, I)$. The "noise-added" image at time $t$ is the random variable:

$$
X_t = \alpha_t z + \beta_t \epsilon, \quad \epsilon \sim \mathcal{N}(0, I)
$$

At $t=0$, we have $X_0 = \epsilon$, so $X_0$ and $\epsilon$ are equivalent random variables. This lets us rewrite the equation as:

$$
X_t = \alpha_t z + \beta_t X_0, \quad X_0 \sim \mathcal{N}(0, I)
$$

Concretely, this noise-adding procedure works by: (1) sampling an endpoint $X_0$ from Gaussian noise, then (2) linearly interpolating from $z$ toward $X_0$ using time-varying weights $\alpha_t$ and $\beta_t$.

![Interpolation from z to noise](interpolation.gif)

It is straightforward to show that 

$$
X_t \sim \mathcal{N}(\alpha_t z, \beta_t^2 I)
$$

We introduce the notation $p_t(x|z)$ for the **conditional** distribution of $X_t$ given a fixed data point $z$:

$$
p_t(x|z) = \mathcal{N}(\alpha_t z, \beta_t^2 I)
$$

This is the probability density of where we might land at time $t$ when following the noise-adding procedure from $z$. It satisfies the boundary conditions:

$$
\begin{aligned}
p_0(x|z) &= \mathcal{N}(0, I) \\
p_1(x|z) &= \delta_z(x)
\end{aligned}
$$

Here $\delta_z(\cdot)$ is the [#section:dirac-delta-function], a distribution that puts all its density on a single point $z$.

In other words, going from $t=1$ to $t=0$, we transform a point mass at $z$ into pure Gaussian noise.

## The flow that guides $X_t$ back to $z$

Recall that the noise-adding procedure linearly interpolates from $z$ toward a sampled noise endpoint $X_0$. This procedure is **reversible**: if we know both $X_t = x$ and the target $z$, we can recover which noise sample $X_0$ was used:

$$
X_0 = \frac{X_t - \alpha_t z}{\beta_t}
$$


We can construct a [#section:flow] that guides any $X_0 \sim \mathcal{N}(0, I)$ back to $X_1 = z$. The idea: take the time derivative of the interpolation formula. We use the notation $u_t(x|z)$ to emphasize this flow depends on knowing the target $z$:

$$
u_t(X_t|z) = \frac{\partial}{\partial t}X_t = \frac{\partial}{\partial t}(\alpha_t z + \beta_t X_0) = \dot{\alpha}_t z + \dot{\beta}_t X_0
$$

Substituting $X_0 = \frac{X_t - \alpha_t z}{\beta_t}$:

$$
u_t(X_t|z) = \dot{\alpha}_t z + \dot{\beta}_t \frac{X_t - \alpha_t z}{\beta_t} = \left( \dot{\alpha}_t - \frac{\alpha_t\dot{\beta}_t}{\beta_t} \right) z + \frac{\dot{\beta}_t}{\beta_t} X_t
$$

This is remarkable: if we know the target data point $z$, the flow $u_t(\cdot|z)$ that transforms Gaussian noise to a point mass at $z$ has a simple analytical form—just a linear combination of $z$ and the current position $x$!

# The Hunt of An Ideal Flow (In General)

Let's reiterate that our goal is to transform Gaussian noise to the underlying data distribution $p(z)$. We are making good progress to find a flow that can transform Gaussian noise to a single data point $z$, which will turn out to be an excellent building block to our goal, as we will see in this section.

## Getting lost going back home

Remember the key idea for us to transform Gaussian noise to a single known data point $z$ is that the trajectory that reaches a point $x$ at time $t$ (will write in short as $X_t = x$) is **reversible**, which enables all $X_t$ to find their way home (back to $z$) - the [#section:flow] $u_t(x|z)$ will tell the direction. If instead $z$ is **sampled** from $p(z)$, standing at $X_t = x$, even though we already know that $X_t$ is reached by the **same noise-adding** procedure, we are unsure which $z$ it comes from since every possible $z$ sampled from $p(z)$ has the probability to raech $X_t = x$. Therefore we cannot decide which **direction** (flow) to use to "go back home".

(TODO: A gif concatenated from two gifs. On the left an `X_t = x` that comes from a single $z$, they are connected with a line. An annimated arrow grow from $X_t$ to $z$, along the direction of the line, but the arrow does not need to actually reach $z$, because it is used to indicate the $u_t(x|z)$. On the right it is a similar one but with 4 different $z$s, $z_1$, $z_2$, $z_3$, $z_4$, and ellipsis to indicate there will be more. Each will have that line connecting to $X_t = x$ and their own animated arrow to indicate the direction of the flow $u_t(x|z_1)$, $u_t(x|z_2)$, $u_t(x|z_3)$, $u_t(x|z_4)$, probably also a sentence with question mark or something to say: "which way to go" or something similar).

## Intuition: the (weighted) average direction

Because we know that staring from a paricular $z$, the probability that it will reach $X_t = x$ is just $p_t(x|z)$. Thanks to Bayes's rule, we can answer 2 questions:

1. What is the probability of such noise-adding process from a sampled $z \sim p(z)$ to reach $X_t = x$? 

   This is equivalent to ask, what is the induced distribution of $X_t$? The straightforward answer (note that we have introduce a new notation $p_t(x)$ here) is
   
   $$
   p_t(x) = \mathbb{P}(X_t = x) = \int_z p_t(x|z) p(z) \mathrm{d}z
   $$
   
2. Standing at $X_t = t$, can we make an educated estimation on how likely which home ($z$) that I come from?

   $$
   \mathbb{P}(z | X_t = x) = \frac{\mathbb{P}(X_t = x, z)}{\mathbb{P}(X_t = x)} = \frac{p_t(x|z) p(z)}{p_t(x)}
   $$

With this, we can make an intuitive yet **VERY BOLD** move. If there is a 10% chance that my home is $z_A$, and another 20% chance that my home is $z_B$, ..., what happens if I just take the average direction that is the sum of 10% of the direction to $z_A$, 20% of the direction to $z_B$ and so on and so forth? Mathematically, this means that we take the weighted average direction

$$
u_t(x) = \int_z u_t(x|z) \mathbb{P}(z | X_t = x) \mathrm{d}z = \int_z u_t(x|z) \frac{p_t(x|z) p(z)}{p_t(x)} \mathrm{d}z
$$

It turns out that this intuitive move can actually get us back to home, well, **statistically**!

# Training - Finding The Flow (Approximately) In Practice

# The Gaussian Case

# References

