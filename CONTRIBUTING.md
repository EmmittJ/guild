# Contributing

Thanks for taking the time to contribute.

## Reporting Bugs and Requesting Features

Open an issue — describe what you expected, what happened instead, and the agent/skill involved. The Guild Master will triage and route it.

## Making Changes

1. **Fork** the repository and clone your fork
2. **Create a branch** from `main`:
   ```sh
   git checkout -b fix/my-bug-fix
   # or
   git checkout -b feat/my-feature
   ```
3. **Make your changes** — keep commits focused and atomic
4. **Format** before pushing (see below)
5. **Open a pull request** targeting `main` with a clear description of what changed and why

PRs are reviewed by the maintainer. Expect feedback within a few days.

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
