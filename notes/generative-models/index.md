---
id: generative-models
title: Notes on Generative Models
author: Break Yang
date: 2026-01-20
---

# Learning Distribution ⇨ Learning Generation [id=learning-distribution-leads-to-learning-generation]

A generative model, for example [Nano Banana](https://gemini.google/overview/image-generation/), can "generate" images. You, as a human being, can "paint" images. In these notes, we'll explore the view that "generate" and "paint" are not so different.

**Note**: We are using image generation as an example here, but there are other types of generative models that can generate text, robotic actions, self driving plans, etc.

## Probabilistic View of Painting

Let's say I want to paint a 1920×1080 picture. That's about 2 million pixels. Assuming each pixel can take one of about 16 million ($256 \times 256 \times 256$) different colors, the total number of possible images at this resolution is 

$$
16 \textrm{ millions}^{2 \textrm{ millions}}
$$

different possible images, forming an "image universe". Not all of these images are meaningful—and some are more "meaningful" than others, at least to me. We can think of this as a distribution over the "image universe": when I paint an image, I effectively "sample" from the distribution of "meaningful (to me) images". This distribution should naturally be smooth—in the "image universe", the nearby points around a "cat image" are also likely to look like cats, with similar chances of being sampled.

## Probabilistic View of Learning Generation

This intuition transfers easily to the concept of "learning generation". If we can design an algorithm that learns such a distribution, the resulting model can generate images simply by sampling from it!

More precisely, the algorithm doesn't even need to learn the probability density function (pdf) of the underlying distribution. As long as it learns how to sample from the distribution, it can perform "image generation".

That said, learning the actual pdf is usually very hard. Distributions over such high-dimensional spaces are typically very complicated—they don't have analytical forms and cannot be approximated by simple ones. Learning the sampling procedure faces similar challenges, but researchers have found clever approaches to make it work.

# Naive Distribution Modeling — Gaussian Mixture Model [id=gmm]

## Learn Mixture of Gaussian by Maximum Likelihood Estimation

What is the "raw material" for learning a distribution? A sufficiently large set of samples $\{x_i\}$ drawn from the underlying distribution.

For distributions that are simple enough, a Gaussian Mixture is usually an effective model. We assume the underlying distribution has the following parametric form:

$$
X \sim \sum_{k=1}^K a_k \cdot \mathcal{N}(\mu_k, \Sigma_k), \textrm{ where} \sum_k a_k = 1
$$

Here $\theta = \{a_{1..K}, \mu_{1..K}, \Sigma_{1..K}\}$ is the set of parameters to optimize. Under Maximum Likelihood Estimation (MLE), we find the optimal values by solving

$$
\begin{aligned}
&\argmax_\theta \prod_i p(x_i) \\
=\, &\argmax_\theta \sum_i \log p(x_i) \\
=\, &\argmax_\theta \sum_i \log \left( \sum_{k=1}^K a_k \cdot \mathcal{N}(x_i \mid \mu_k, \Sigma_k)\right)
\end{aligned}
$$

This is typically solved approximately using the EM algorithm, and the resulting model is called a Gaussian Mixture Model (GMM).

## Sampling from Learned Gaussian Mixture Model

Sampling from a Gaussian mixture is straightforward—one reason this method is so popular. First, sample the component index $k$ from the categorical distribution defined by $\{a_{1..K}\}$, then sample from the corresponding Gaussian $\mathcal{N}(\mu_k, \Sigma_k)$. 

## When Gaussian Mixture Models Fail

When the underlying distribution has a complex structure, it may require a very large number of Gaussian components (large $K$) to capture its fine-grained details. This often makes learning impractical. The problem is compounded by high dimensionality—as in our image space example.


# Variational Autoencoder (VAE) [id=vae]

Sampling from a Gaussian is simple (as simple as calling `torch.normal`). One way to think about VAE is this: we want to find a mapping $f: \mathbb{R}^k \rightarrow \mathbb{R}^d$ from a $k$-dimensional latent space to the target space $\mathbb{R}^d$ where our data lives, such that when we push a standard Gaussian through $f$, the resulting distribution approximates $p(x)$:

$$
z \sim \mathcal{N}(0, I) \implies f(z) \sim p(x)
$$

In other words, if we can find such an $f$, then sampling $x$ becomes straightforward: sample $z$ from a standard Gaussian, then transform it via $f$ to get a data point.

VAE proposes a way to learn such an $f$ using neural networks. The mathematical details can be found [here](https://www.breakds.org/the-intuitive-vae/).

# Other Types of Distribution Modeling

As a human being, when I "sample" (i.e., paint) an image, it doesn't magically appear all at once—the process unfolds step by step. It's natural, then, that some distribution modeling methods also design their sampling process to be iterative. 

1. **Flow matching and diffusion models** are examples: they gradually transform noise into a coherent sample over many steps. 
2. **Large language models** (the typical decoder-only transformer-based ones) take a different iterative approach—they sample from the text space token by token, using next-token prediction to build up the output sequentially.

