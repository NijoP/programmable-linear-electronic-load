# Pi Agent Runtime Verdict

**Date:** 2026-10-07
**Current status:** PARTIAL PASS — one direct NVIDIA smoke execution succeeded; full fresh-session parallel verification remains pending

The supplied screenshot shows a child launch from the old in-memory extension:

```text
PS C:\Users\HP> bash '...runtime-test...sh'
bash : The term 'bash' is not recognized
```

That launch occurred before the runtime extension was reloaded. The launcher source on disk is now patched, but an already-running Pi process retains the old imported module until `/reload` or a fresh Pi session.

| Check | Status | Evidence |
|---|---|---|
| `MODEL_ROUTING` | PASS* | Durable NVIDIA-only routing is written; reload required for current process. |
| `NVIDIA_API` | PASS | NVIDIA credentials and live provider registry are present; exact live refs are `nvidia/nvidia/...`. |
| `NEMOTRON_120B` | PASS* | Exact model reference accepted by the live registry and smoke launch was acknowledged; completion must be rerun after reload. |
| `NEMOTRON_30B` | PASS | Direct execution with `nvidia/nvidia/nemotron-3.5-lightning-30b-a3b` returned the repository values: 15 V maximum input and 2 A maximum load current. |
| `WINDOWS_SHELL` | PASS* | On-disk launcher now invokes PowerShell `-File`; current pane must reload it. |
| `SUBAGENT_LAUNCH` | PASS* | Direct Windows compatibility launch completed with `__SUBAGENT_DONE_0__`; fresh parent-process launcher verification remains pending. |
| `PARALLEL_AGENTS` | FAIL | Final five-agent test has not been run after reload. |
| `REPOSITORY_ACCESS` | PASS | The successful NVIDIA smoke child read `docs/PRODUCT_REQUIREMENTS_R1.md` and returned correct repository values. |
| `ANTHROPIC_USAGE` | PASS | Anthropic auth entry removed and no active routing config references Anthropic. Historical package/catalog text remains non-active. |
| `BASH_DEPENDENCY` | PASS* | Fresh Windows code no longer sends `bash`; compatibility shims in `C:\\Users\\HP\\bin` and `C:\\Users\\HP\\.pi\\agent\\bin` also permit stale scripts to execute. |

`*` means corrected on disk but not yet validated by a fresh Pi process.

## Required operator action

Run:

```text
/reload
```

or restart Pi from Herdr. Then rerun the two smoke children and the five-agent parallel test. The screenshot itself showed both stale `bash` emission and the independent Windows absolute-path duplication bug. The path bug has now been patched in `launch.ts`; it was not merely a provider failure. A temporary `C:\\Users\\HP\\bin\\bash.cmd` shim also protects stale sessions, while fresh sessions use PowerShell directly.
