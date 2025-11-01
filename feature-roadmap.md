
# MacSimPE / SimKit — Feature Roadmap (Clean 0.77 Line, sans Hatch content)

> Scope: Mac‑native port in Objective‑C, translating C# logic without adding new helper classes. Consistent camelCase. Preserve file/class/method names; rename only to disambiguate C# overloads.

## Legend
- [ ] = Planned
- [~] = In progress
- [x] = Complete (read-only)
- [✓] = Complete (read/write)

## Milestone A — Core Foundations (stabilize basics)
- [~] PathProvider (Aspyr Super Collection maps)
  - Deterministic EP/SP roots
  - Mac container paths & Downloads
  - Public API: `expandPath:`, `allPathsForPath:` (moved from FileTable where needed)
- [~] FileTable (pure resolution, no heuristics)
  - One-pass, fixed EP/SP order
  - No state mutation during scanning
  - Fails loudly on missing roots
- [ ] TXTR / TXMT / MMAT end-to-end
  - View TXTR (with mip info)
  - Edit TXTR (DDS/PNG import-export)
  - Bind TXMT/MMAT links
- [ ] GroupCache (read-only, sandboxed cache file)
  - Deterministic build & invalidation
  - Feeds Catalog & Object Workshop

## Milestone B — Models & Viewers
- [ ] GMDC (read-only) + export
- [ ] SDSC (Sim Description) read-only
- [ ] NGBH Memory read-only
- [ ] SLOT viewer
- [ ] Maxis Catalog UI backed by GroupCache

## Milestone C — Safe, Minimal Edits
- [ ] SDSC minimal fields (validated writes)
- [ ] Memory constrained edits (undo/backups)
- [ ] Neighborhood decor: position/rotation only (limits + backups)

## Milestone D — Advanced/Optional
- [ ] Road/terrain overlays (advanced toggle, backups)
- [ ] Bidou Career Editor (modular)

## Explicitly Out of Scope / Excluded
- Hatch adult/closed content, stats, private EPs
- Unstable catalog hacks, Windows-only behaviors
- Wide-scope NGBH writes without full schema coverage
- Binary patching dependent on Windows file-lock semantics
