---
title: "Fixing Portainer After a Raspberry Pi Update: Docker 29 vs. Portainer API Compatibility"
published: 2025-11-20
draft: false
description: 'A recent Raspberry Pi update installed Docker 29.0.0, which raised the minimum API version and broke compatibility with Portainer. This article explains why Portainer suddenly showed the local environment as unreachable and shows the simple fix: lowering Docker’s minimum API version via daemon.json so Portainer can connect again.'
tags: ['docker', 'portainer', 'api-version', 'raspi', ]
---

After updating my Raspberry Pi (DietPi) system, everything seemed fine—except Portainer.
All my containers were running, but Portainer showed this error:

> **“Failed loading environment. The environment named ‘local’ is unreachable.”**

Even after recreating the Portainer container, the local Docker environment stayed red and unreachable.
Here’s what happened and how I fixed it.

---

## The Root Cause: Docker 29 Raised the Minimum API Version

With Docker **29.0.0**, the Docker Engine introduced a breaking change:

* **Minimum supported API version is now 1.44**
* Portainer CE/LTS still uses a Docker client that expects **API version 1.24**

This means Portainer tries to talk to Docker using an older API version that Docker no longer accepts.
The result: Portainer can’t connect to the Docker socket, even though everything looks fine.

This issue is actively discussed in the [Portainer GitHub community](https://github.com/orgs/portainer/discussions/12926) and affects many Raspberry Pi and Debian users.

---

## Symptoms

* Portainer container is running normally.
* `/var/run/docker.sock` exists and is mounted correctly.
* Portainer UI shows the **local environment as unreachable**.
* Restarting Portainer or recreating the container doesn’t help.
* `docker logs portainer` may show nothing (because many installations use journald logging).

---

## The Fix: Lower Docker’s Minimum API Version

Since Docker increased the minimum API version, the workaround is to explicitly tell Docker to accept older API versions again.

This is done by adding a single line to `daemon.json`.

### Step 1: Edit Docker daemon config

Create or edit:

```
/etc/docker/daemon.json
```

Insert:

```json
{
  "min-api-version": "1.24"
}
```

If the file already contains other config values, simply add the new line without removing existing ones.

### Step 2: Restart Docker

```bash
sudo systemctl restart docker
```

### Step 3: Restart Portainer

```bash
docker restart portainer
```

After that, reload Portainer in the browser — the **local environment should turn green again**.

---

## Why This Works

By setting:

```json
"min-api-version": "1.24"
```

Docker is instructed to accept older API versions again, restoring compatibility with current Portainer releases.

It’s a safe workaround until Portainer updates their Docker client to match Docker 29’s new requirements.

---

## Alternative Solutions

If you prefer not to change Docker’s API policy, there are two alternatives:

1. **Downgrade Docker to 28.x**
   This restores the old minimum API version.

2. **Use an older Portainer release**
   (not recommended by Portainer, but some users report success)

---

## Conclusion

If Portainer suddenly becomes “unreachable” after a system update, and you’re running Docker 29.0.0, you’re likely running into this API compatibility issue.

Adding `"min-api-version": "1.24"` to Docker’s `daemon.json` is the quickest and cleanest fix for now.
