---
id: basic-concepts
title: Basic Concepts
author: Break Yang
date: 2026-01-19
---

# Vector Field [id=vector-field]

A vector field on the space $\mathbb{R}^d$ is a function $v: \mathbb{R}^d \rightarrow \mathbb{R}^d$, which assigns a vector to each point in the space. Think of it as placing a little arrow at every location—the arrow tells you both a direction and a magnitude at that point.

Below is an example vector field on the plane ($\mathbb{R}^2$), defined by $v(x, y) = (-y, x)$. Notice how the arrows form a counterclockwise rotation around the origin:

![Vector field example](vector_field.png)

Vector fields are commonly used to model things like fluid velocity (the arrow at each point shows which way the fluid is moving and how fast) or force fields (e.g., gravitational or electromagnetic fields).

# Flow [id=flow]

A flow on the space $\mathbb{R}^d$ is a function $u: \mathbb{R}^d \times \mathbb{R} \rightarrow \mathbb{R}^d$. It defines a [#section:vector-field] at each time $t$. In other words, a flow is a time-varying vector field—at each moment, you have a complete vector field, but that field itself evolves as time progresses.

We often write $u_t(x)$ instead of $u(x, t)$ to emphasize that for a fixed $t$, we get a vector field $u_t$.

Below is an example flow defined by $u_t(x, y) = ((1-t)(-y), (1-t)(x))$. As $t$ increases from 0 toward 1, the rotational velocity gradually decreases:

![Flow at t=0.0](flow_t0.png)
![Flow at t=0.5](flow_t05.png)
![Flow at t=0.9](flow_t09.png)

Physically, flows can model scenarios like fluid velocity that changes over time—imagine a whirlpool that gradually slows down.
