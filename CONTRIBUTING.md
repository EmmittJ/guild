# Contributing

## Formatting

This repo uses [Prettier](https://prettier.io) to format Markdown, YAML, and JSON. CI will fail on unformatted files.

**Check before pushing:**

```sh
npx prettier@3.8.1 --check .
```

**Fix everything at once:**

```sh
npx prettier@3.8.1 --write .
```

No install required — `npx` handles it. Node.js 18+ required.
