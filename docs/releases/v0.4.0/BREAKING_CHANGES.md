# v0.4.0 Breaking Changes

No breaking changes in this release.

The auditor tool restriction (`edit` and `execute` removed) is a behavioral hardening fix. If
any workflow was relying on auditor to modify files, that workflow was using the agent outside
its documented purpose — auditor has always stated "Does not modify files."
