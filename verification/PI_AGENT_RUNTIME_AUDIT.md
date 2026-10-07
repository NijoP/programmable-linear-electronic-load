# Pi Agent Runtime Audit

**Audit date:** 2026-10-07
**Host:** Windows 11 environment, Herdr/Pi session

## Configuration findings

| Item | Path / observation |
|---|---|
| Pi settings | `C:/Users/HP/.pi/agent/settings.json` |
| Durable subagent configuration | `C:/Users/HP/.pi/agent/herdr-agents/config.json` |
| Model registry | `C:/Users/HP/.pi/agent/models-store.json` |
| Authentication registry | `C:/Users/HP/.pi/agent/auth.json` |
| Extension launcher | `C:/Users/HP/.pi/agent/npm/node_modules/pi-herdr-agents/pi-extension/subagents/terminal.ts` and `launch.ts` |
| Project/global role definitions | Package-bundled roles; no project `.pi/agents` or global role override was found in the repository audit |
| Current shell environment | `COMSPEC=C:\WINDOWS\system32\cmd.exe`; Windows PowerShell is installed; Git `bash.exe` is installed at `C:\Program Files\Git\usr\bin\bash.exe` |
| MCP | Not changed; EasyEDA/MATLAB integrations are outside this runtime-routing change |

## Root cause

Before this correction, Pi settings contained:

```json
"defaultProvider": "anthropic",
"defaultModel": "claude-opus-4-8"
```

The durable Herdr model section was absent, so child model resolution inherited the parent runtime or selected the previous provider. The installed model registry contains the NVIDIA models, but explicit live tool references require the registry's fully qualified form:

```text
nvidia/nvidia/nemotron-3-super-120b-a12b
nvidia/nvidia/nemotron-3.5-lightning-30b-a3b
```

The provider catalog exposes these as provider `nvidia` with model IDs beginning `nvidia/`; the subagent tool therefore requires the double-qualified exact references. The shorter user-specified strings are rejected by the live registry.

The installed launcher in `pi-herdr-agents/pi-extension/subagents/terminal.ts` generated `.sh` files and sent an unqualified command:

```text
bash '<generated-script>'
```

That is not valid in a PowerShell pane when `bash` is not on the pane's PATH.

A second independent Windows bug was found in `launch.ts`: absolute-path detection only recognized POSIX paths beginning with `/`. A Windows path such as:

```text
C:\\Users\\HP\\Projects\\programmable-linear-electronic-load
```

was treated as relative and joined to the parent cwd, producing an invalid path such as:

```text
C:\\Users\\HP\\Projects\\programmable-linear-electronic-load\\C:\\Users\\HP\\Projects\\programmable-linear-electronic-load
```

This caused child panes to disappear even after the shell command was executable.

## Corrections applied

1. Changed Pi defaults to NVIDIA in `settings.json`.
2. Created durable `herdr-agents/config.json` with NVIDIA-only default, role, and task routing.
3. Removed the Anthropic authentication entry from `auth.json`; NVIDIA, OpenAI, and OpenRouter entries were preserved.
4. Patched the Herdr launcher to generate PowerShell-compatible scripts and invoke them with:

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -File <script>
```

5. Patched Windows Pi command generation to use PowerShell environment assignments, `Set-Location`, and `$LASTEXITCODE` completion markers.
6. Retained POSIX `bash` behavior only for non-Windows hosts.
7. Fixed Windows absolute-path detection for drive-letter paths (`C:\\...`).
8. Added a temporary `C:\\Users\\HP\\bin\\bash.cmd` compatibility shim so stale already-running sessions can still execute old generated scripts; fresh sessions use the PowerShell path and do not require the shim.

## Active-policy search

The active settings, durable subagent configuration, and authentication registry contain no Anthropic provider/model entry after the correction. The installed package documentation and model registry still contain historical/provider catalog strings mentioning Anthropic and `bash`; these are not active routing selections and were not deleted from package documentation or the catalog.

## Verification requirement

A Pi reload is required before the already-running parent process can load the changed extension and settings. Runtime smoke tests must be run after reload. The exact test results are recorded in `PI_AGENT_RUNTIME_VERDICT.md` only after child completion evidence is received.
