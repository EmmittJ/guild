# Security Policy

## Supported Versions

Only the current `main` branch is supported. No backports are made to older releases.

## Reporting a Vulnerability

**Do not open a public issue for security vulnerabilities.**

Report privately using GitHub's built-in advisory tool:
[https://github.com/EmmittJ/guild/security/advisories/new](https://github.com/EmmittJ/guild/security/advisories/new)

### What to include

- A clear description of the vulnerability
- Steps to reproduce (as minimal as possible)
- Potential impact assessment (what an attacker could achieve)

### What to expect

- **Acknowledgment** within 7 days of submission
- **Fix timeline** based on severity:
  - Critical / High: patch targeted within 14 days
  - Medium: patch targeted within 30 days
  - Low: addressed in the next regular release

You'll be credited in the advisory unless you prefer to remain anonymous.

## Out of Scope

The following are **not** in scope for this project:

- Social engineering attacks
- Physical attacks
- Vulnerabilities in dependencies — please report those to their respective maintainers
- Issues in AI models or hosting platforms used to run agents

## Notes

Guild is a files-only framework (MIT licensed, no runtime). Most security concerns will involve prompt injection or privilege escalation in agent instructions rather than traditional software vulnerabilities.
