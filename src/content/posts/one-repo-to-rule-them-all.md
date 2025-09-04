---
title: 'One repo to rule them all'
published: 2025-09-04
draft: false
description: 'A look at how to manage multiple projects in a single repository.'
tags: ['moodle', 'markdown', 'git']
---

## Problem & Solution: Embedding Markdown in Moodle

So, my problem was: I had to manually copy markup code into a Moodle LMS course, which is really cumbersome and a pain to maintain. Also, Moodle doesn’t support Markdown format at all, so I needed additional time to make everything look decent. I know there are plugins for this, but this LMS is hosted on MoodleCloud, which doesn’t allow plugin installations.

Instead of maintaining both the GitHub repo and the Moodle course, I thought it would be a better idea to follow the principle of a "single source of truth". So GitHub it is! Thanks to version control, this decision was a no-brainer.

After some research, I came up with a way to get my .md files into Moodle LMS and keep them auto-updated whenever changes are made to the repo. I use Astro Docs to convert the Markdown content into HTML and plan to embed the result into Moodle via an `<iframe>`. Here’s the workflow: when I push changes to the Markdown files on GitHub, Netlify automatically redeploys the site, and the updated content is instantly reflected inside the Moodle books or lessons.

Here’s an example `<iframe>` snippet I used for testing:

```html
<iframe style="border: none;"
    src="https://docs.astro.build/de/basics/project-structure/"
    width="100%" height="600px">
</iframe>
```

It worked — kind of. The problem: the full Astro Docs layout (header, sidebar, footer) was also embedded, which obviously didn’t work for Moodle. I only needed the actual content.

## Dynamic Routing with Astro

After some back-and-forth with ChatGPT, I found a way to use `getStaticPaths()` to define all possible documentation routes based on the URL slug. Thanks to Astro, I can use the `[...slug]` syntax to look up corresponding entries in the `/docs` collection. If a match is found, it renders the Markdown content as HTML.

Example:

```shell
/databases/01-intro-to-sql → loads `src/content/docs/databases/01-intro-to-sql.md`
```

Here’s the final version of the `[...slug].astro` file. I added `console.log()` for debugging, simple HTML markup, and some basic CSS styling:

```astro title="[...slug].astro"
import { getCollection } from 'astro:content';
import '../../styles/custom.css';

export async function getStaticPaths() {
  const docs = await getCollection('docs');
  return docs.map((entry) => ({
    params: { slug: entry.slug },
  }));
}

const fullSlug = Astro.params.slug;
const allDocs = await getCollection('docs');
const entry = allDocs.find((e) => e.slug === fullSlug);

console.log("FullSlug:", fullSlug);
console.log("All slugs:", allDocs.map(e => e.slug));
console.log("Found entry:", entry);

if (!entry) {
  throw new Error(`Entry not found: ${fullSlug}`);
}

const { Content } = await entry.render();
---
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>{entry.data.title}</title>
    <style>
      body {
        margin: 0;
        padding: 0;
        font-family: sans-serif;
        background: white;
        color: black;
        display: flex;
      }

      main {
        box-sizing: border-box;
        width: 100%;
      }

      img {
        width: 100% !important;
        max-width: 100% !important;
        height: auto !important;
        display: block;
      }
    </style>
  </head>
  <body>
    <main>
      <Content />
    </main>
  </body>
</html>
```

## Styling & Layout Issues

This setup worked almost out of the box. But after testing multiple .md files, I noticed that some images were way too large for the Moodle viewport. To fix this, I increased the content width of the Boost theme in Moodle to 1280px via custom SCSS.

Another issue: inconsistent image sizes across the .md files — never a problem in Astro Docs, but problematic now. After some trial and error, I created a custom.css file that forces images to stay within defined limits:

```css
p > img {
  max-width: 1024px;
  width: 100%;
  height: auto;
  display: block;
}
```
To apply this, I referenced the CSS file in astro.config.mjs:

```js
export default defineConfig({
  integrations: [
    starlight({
      customCss: ['./src/styles/custom.css']
    })
  ]
});
```

## Access Restriction with Token

So what do we have now? I can embed a simple `<iframe>` into a Moodle book or lesson, and it displays the content and images of a specific .md file. Any changes in the repo are auto-deployed and instantly visible. Sounds done? Almost.

I still needed to restrict access to the docs but allow access via an iframe — for obvious reasons. After more experimentation with ChatGPT, I implemented access control using Astro middleware and URL tokens.

For example:

```shell
?token=abc123 gets compared to the .env variable PUBLIC_MOODLE_TOKEN=abc123.
```
Here’s the relevant middleware.ts:

```ts title="middleware.ts"
import type { MiddlewareHandler } from 'astro';

export const onRequest: MiddlewareHandler = async ({ url }, next) => {
  const protect = import.meta.env.PROTECT === 'true';

  if (!protect) {
    console.log('🟢 PROTECT=false → access protection disabled');
    return next();
  }

  const token = url.searchParams.get('token');
  const validToken = import.meta.env.PUBLIC_MOODLE_TOKEN;
  const path = url.pathname;

  const isStaticAsset =
    path.startsWith('/_image') ||
    path.startsWith('/favicon.ico') ||
    path.startsWith('/robots.txt') ||
    path.startsWith('/.well-known') ||
    path.match(/\.(png|jpe?g|svg|gif|webp|ico|css|js|woff2?|ttf|map)$/);

  if (isStaticAsset) return next();

  console.log('📥 Token from URL:', token);
  console.log('🔐 Valid token from .env:', validToken);

  if (token !== validToken) {
    console.log('⛔ Invalid or missing token!');
    return new Response('Access denied', { status: 403 });
  }

  console.log('✅ Access granted!');
  return next();
};
To make this work on Netlify, I added the SSR adapter and set the output to 'server':

export default defineConfig({
  output: 'server',
  adapter: netlify(),
});
```

I also included a developer/maintenance toggle using `PROTECT=false` in the `.env` file to temporarily disable access control when needed.

## Conclusion

Now the feature is complete. I can set a token in `.env`, use it via the URL, and access is granted. Otherwise: restricted. All needs — single source of truth, automated updates and access control — are met.

The learning curve was steep, but I’m really happy with the result. Now I can move on developing additional features — maybe support for `.mdx` to take it even further.

Definition of Done: ✅
Good job, Sam.