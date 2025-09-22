---
title: "Build & run your own Password Vault and access it from anywhere"
published: 2025-09-04
draft: false
series: 'self-hosted passwd manager'
description: 'Explore how Go uses interfaces to achieve polymorphism.'
tags: ['docker', 'vault', 'password-manager', 'raspi-zero', ]
---

## My Self-Hosted Password Manager on the Raspberry Pi Zero 2 W

For a long time, I wanted to stop trusting external services with my passwords and instead take full control over my data. That’s why I decided to build my own setup using a **Raspberry Pi Zero 2 W** and [**Vaultwarden**](https://noted.lol/vaultwarden/) (the lightweight, unofficial Bitwarden server implementation).  

### Accessible from Anywhere – with Cloudflare Tunnel

It wasn’t enough for me to only access the manager within my home Wi-Fi. I wanted full access from anywhere. To achieve this, I’m using a **Cloudflare Tunnel**.  
With it, my self-hosted instance is reachable globally from any device – PC, laptop, or smartphone – without exposing my Pi directly to the internet. The Pi remains safely behind my firewall, while Cloudflare takes care of the secure connection.  

### Usage on All Devices

- **On the smartphone**: I found an Android app that supports **self-hosted Vaultwarden instances** out of the box. This way, I can sync and access my password vault while on the go, exactly like with any commercial solution.  
- **On the PC**: Things are even easier. The **Bitwarden browser extension** can be configured to use a self-hosted server. I simply log in with my account, and everything works the same as if I were using Bitwarden’s official cloud service – except that the data lives on my Pi.  

### Pitfalls and Workarounds

Of course, not everything went smoothly from the start.  
The biggest issue I ran into was that the **frontend container of Vaultwarden** had the nasty habit of crashing every now and then. Not constantly, but regularly enough to be annoying.  

My solution: I wrote a **cron job** that automatically restarts the container at intervals – just in case it crashes. Since implementing that, the problem has been a non-issue. A simple but effective hack.  

### Backup & Reliability

No system is complete without proper backups. Here’s how I handle it:  

- **Backup strategy**: I perform a daily backup with a **7-day rotation**. That way, even if something breaks or I screw up a config, I can always roll back to a known good state.  
- **Operating system**: The base system is running on **DietPi OS**, a lightweight Debian-based distro specifically designed for single-board computers like the Raspberry Pi. DietPi has been extremely resource-efficient and very reliable in my setup.  

To give you an idea of how stable this little setup is, here’s a quick uptime snapshot straight from the Pi:  

```shell

20:53:01 up 40 days,  3:23,  1 user,  load average: 1.08, 1.04, 1.01

```

That’s a **40-day uptime** on a Pi Zero 2 W running multiple services in Docker – not bad for a $15 piece of hardware.  

---
