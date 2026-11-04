# Separate reusable library and consuming projects

The library owns execution protocols, agent providers, file resource handling,
common evidence checks, snapshots, history, replay, pinned tooling and UI adapters.
A consuming project owns its skill catalog, scenarios, fixture files, assertions,
calibrations and fixture environment services. Trusted extension systems register
checks and environment callbacks; the library contains no project-specific profile
implementations or implicit default skill.

Framework source, consumer source, dependencies and results are separate roots.
New snapshots persist engine and project independently. Legacy combined archives
remain readable. The existing project keeps a thin Roswell compatibility entry.
The library is pinned by a local Git revision through Nix; publishing is a separate
user decision. Promptfoo remains the execution/UI backend in this extraction.

Initial source: 40ants/ai at cfeba00, including its pre-extraction changelog history.
No external model calls are needed to validate the structural migration.
