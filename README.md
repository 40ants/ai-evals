<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-40README-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

# 40ants-ai-evals — Reusable skill evaluations

<a id="40-ants-ai-evals-asdf-system-details"></a>

## 40ANTS-AI-EVALS ASDF System Details

* Version: 0.5.0
* Description: Reproducible skill evaluations through Promptfoo
* Licence: Unlicense
* Author: Alexander Artemenko
* Homepage: [https://github.com/40ants/ai-evals][40fe]
* Bug tracker: [https://github.com/40ants/ai-evals/issues][1c51]
* Source control: [GIT][40fe]
* Depends on: [asdf][c15d], [babel][3a1f], [cl-ppcre][49b9], [dexador][8347], [ironclad][90b9], [local-time][46a1], [quri][2103], [serapeum][c41d], [yason][aba2]

A reusable Common Lisp evaluation runner for agent skills. Project test cases,
fixtures, assertions and environment implementations live in the consuming repository.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-40CONFIGURATION-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

## Connect a consuming project

The library has three independent locations: its pinned source checkout,
the consuming project with evals/project.json, and the project's pinned Qlot
distribution. Results remain in the consuming project's .evals directory.

The repository provides a pinned Nix toolchain and Roswell entry point. Enter it
with a projectRoot argument pointing to the consumer, then use qlot exec ai-evals.
Use the consumer's qlfile.lock for Lisp dependencies; no global installation is needed.

A project declares defaultSuite, suiteCatalog, systems, snapshotPaths and optionally
testSystem in evals/project.json. The suite catalog gives each skillName, skillPath,
config and environmentProfile. Relative paths resolve against the consuming project,
never the library checkout. A project flag after a command selects another root.

Suite configurations contain descriptions and defaultTest.vars with checkSystems
and checks. Cases contain description, vars, file-based assertions and fixture paths.
The library injects its Promptfoo transport and native provider settings centrally.
It does not require project copies of JavaScript adapters or engine source files.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-40EXECUTION-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

## Run, inspect and replay

Commands include suites, checks, run, history, compare, replay, test and view.
Run supports suite, filter, group, repeat, agent, ablation, ref and timeout flags.
Use agent opencode, codex or all. Existing argument names and Promptfoo protocols
remain unchanged. Model calls are made only by run; replay uses archived evidence.

OpenCode defaults to a 660000 millisecond overall deadline and 630000 milliseconds
for execution. A timeout flag applies to each sample. Assertion and fixture deadlines
remain independent. Promptfoo supplies repeated execution, its `SQL`ite store and `UI`;
Common Lisp owns evidence collection, grading, history compatibility and comparison.

Each new run stores harness/engine and harness/project separately, plus the selected
skill and sample artifacts. Fingerprints include both source trees and input resources.
Old combined harness snapshots are read in place without rewriting original grades.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-40EXTENSIONS-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

## Project-owned checks and fixture environments

Register assertions and profiles through the public checks package and declare
their `ASDF` systems in checkSystems. Core common checks are available by system name
40ants-ai-evals-common-checks; project-specific systems use safe project-relative `ASD`
paths included in snapshotPaths. File parameters resolve against the archived suite.

Trusted project systems declared in systems load before cases are validated. They
can register an environment with preflight, prepare, native provider configuration,
environment variables, workspace instructions and finalize callbacks. The built-in
default environment has no skill-specific knowledge. Project fixture services and
`MCP` factories stay with the tests which need them.

See evals/docs/adapter-protocol.md and evals/docs/extending-checks.md for the transport
and extension contracts. The extraction decision is recorded in
 evals/docs/decisions/0004-reusable-library.md.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-40API-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

## API

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FAGENTS-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/AGENTS

<a id="x-28-23A-28-2822-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FAGENTS-22-29-20PACKAGE-29"></a>

#### [package](16bc) `40ants-ai-evals/agents`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FAGENTS-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FAGENTS-3APROFILE-FOR-20FUNCTION-29"></a>

##### [function](569a) `40ants-ai-evals/agents:profile-for` agent flags &optional tools

Copy `AGENT`'s profile, recording only tools relevant to that agent.

<a id="x-2840ANTS-AI-EVALS-2FAGENTS-3APROVIDER-IDENTITY-20FUNCTION-29"></a>

##### [function](5e99) `40ants-ai-evals/agents:provider-identity` label

Decode current labels and historical Codex-only labels into agent and variant.

<a id="x-2840ANTS-AI-EVALS-2FAGENTS-3APROVIDER-LABEL-20FUNCTION-29"></a>

##### [function](9b55) `40ants-ai-evals/agents:provider-label` agent variant

Return an unambiguous provider label for one agent/skill combination.

<a id="x-2840ANTS-AI-EVALS-2FAGENTS-3ARENDER-TASK-20FUNCTION-29"></a>

##### [function](3288) `40ants-ai-evals/agents:render-task` TASK AGENT &OPTIONAL (SKILL-NAME "writing-common-lisp")

Render explicit references so new suites have observable skill-read evidence.
Codex expands dollar references before `SDK` tool traces, which cannot prove a read.
Automatic routing tasks remain untouched, as does the original suite contract.

<a id="x-2840ANTS-AI-EVALS-2FAGENTS-3ASELECTED-AGENTS-20FUNCTION-29"></a>

##### [function](b874) `40ants-ai-evals/agents:selected-agents` flags

Resolve `--agent`; preserve Codex as the default for existing commands.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FAGENTS-3FVariables-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Variables

<a id="x-2840ANTS-AI-EVALS-2FAGENTS-3A-2APROFILES-2A-20-28VARIABLE-29-29"></a>

##### [variable](3211) `40ants-ai-evals/agents:*profiles*` #<hash-table :test equal :count 2 {800aee5743}>

Default agent profiles. [`profile-for`][62b3] returns a copy; callers may override one run's model.
`EFFORT` is a Codex setting and is never translated into an OpenCode reasoning option.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FCASE-RESOURCES-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/CASE-RESOURCES

<a id="x-28-23A-28-2830-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FCASE-RESOURCES-22-29-20PACKAGE-29"></a>

#### [package](70d7) `40ants-ai-evals/case-resources`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FCASE-RESOURCES-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3ABASELINE-MANIFEST-20FUNCTION-29"></a>

##### [function](d6a0) `40ants-ai-evals/case-resources:baseline-manifest` VARS &OPTIONAL (SPEC (FIELD VARS "fixtures"))

Use the frozen baseline including supervisor-added files, or normalize old vars.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3ACOPY-FIXTURES-20FUNCTION-29"></a>

##### [function](d69e) `40ants-ai-evals/case-resources:copy-fixtures` vars workspace

Copy inputs from the selected input tree without decoding or following links.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3AFILE-METADATA-20FUNCTION-29"></a>

##### [function](5b99) `40ants-ai-evals/case-resources:file-metadata` path

Describe regular-file bytes and executable bits without following symlinks.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3AFILE-REFERENCES-20FUNCTION-29"></a>

##### [function](c606) `40ants-ai-evals/case-resources:file-references` vars

Read a resource set or a historical array without expanding Promptfoo cases.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3AFIXTURE-MANIFEST-20FUNCTION-29"></a>

##### [function](ca32) `40ants-ai-evals/case-resources:fixture-manifest` VARS &OPTIONAL (SPEC (FIELD VARS "fixtures"))

Read a fixture directory, or normalize a historical inline fixture object.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3AINPUT-FINGERPRINT-20FUNCTION-29"></a>

##### [function](4a86) `40ants-ai-evals/case-resources:input-fingerprint` cases &key fixtures-only

Hash actual case resource bytes and modes from the selected input tree.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3AMANIFEST-EQUAL-P-20FUNCTION-29"></a>

##### [function](724c) `40ants-ai-evals/case-resources:manifest-equal-p` expected actual

Compare complete file sets, bytes and captured executable permissions.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3AMETADATA-EQUAL-P-20FUNCTION-29"></a>

##### [function](b96e) `40ants-ai-evals/case-resources:metadata-equal-p` expected actual

Compare byte identity and permissions when that evidence is available.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3APRODUCT-PATH-P-20FUNCTION-29"></a>

##### [function](ffca) `40ants-ai-evals/case-resources:product-path-p` path

Exclude evaluation machinery from product file comparisons.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3ARESOLVE-RESOURCE-20FUNCTION-29"></a>

##### [function](96ec) `40ants-ai-evals/case-resources:resolve-resource` vars reference &key directory

Resolve a suite-relative input, rejecting symlinks in every path component.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3ARESTORE-SAMPLE-20FUNCTION-29"></a>

##### [function](c0c2) `40ants-ai-evals/case-resources:restore-sample` sample destination

Restore regular candidate files from verified archives, including binary inputs.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3ASAMPLE-MANIFEST-20FUNCTION-29"></a>

##### [function](458b) `40ants-ai-evals/case-resources:sample-manifest` sample

Describe product evidence, retaining compatibility with text-only archives.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3AVALIDATE-FIXTURES-20FUNCTION-29"></a>

##### [function](e3dd) `40ants-ai-evals/case-resources:validate-fixtures` vars

Validate fixture inputs before any paid evaluation starts.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FCASE-RESOURCES-3FVariables-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Variables

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3A-2AINPUTS-ROOT-2A-20-28VARIABLE-29-29"></a>

##### [variable](b374) `40ants-ai-evals/case-resources:*inputs-root*` nil

Input tree for this operation; `NIL` uses the loaded harness.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3A-2ASAMPLE-DIRECTORY-2A-20-28VARIABLE-29-29"></a>

##### [variable](7e21) `40ants-ai-evals/case-resources:*sample-directory*` nil

Trusted archive directory of the sample being graded.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FCHECKS-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/CHECKS

<a id="x-28-23A-28-2822-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FCHECKS-22-29-20PACKAGE-29"></a>

#### [package](c8be) `40ants-ai-evals/checks`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FCHECKS-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FCHECKS-3ACACHED-20FUNCTION-29"></a>

##### [function](940f) `40ants-ai-evals/checks:cached` context key compute

Compute shared evidence once per sample, including a cached `NIL` result.

<a id="x-2840ANTS-AI-EVALS-2FCHECKS-3ACONTEXT-SAMPLE-20FUNCTION-29"></a>

##### [function](b563) `40ants-ai-evals/checks:context-sample` context

Return immutable-by-convention sample evidence for a check.

<a id="x-2840ANTS-AI-EVALS-2FCHECKS-3ACONTEXT-VARS-20FUNCTION-29"></a>

##### [function](251f) `40ants-ai-evals/checks:context-vars` context

Return the test variables for a check.

<a id="x-2840ANTS-AI-EVALS-2FCHECKS-3ADESCRIBE-CHECKS-20FUNCTION-29"></a>

##### [function](48c0) `40ants-ai-evals/checks:describe-checks`

Return `JSON`-compatible schemas for the checks currently registered.

<a id="x-2840ANTS-AI-EVALS-2FCHECKS-3AEXECUTE-PLAN-20FUNCTION-29"></a>

##### [function](bc06) `40ants-ai-evals/checks:execute-plan` context plan

Execute independent handlers; `NIL` skips a check, a vector emits several results.

<a id="x-2840ANTS-AI-EVALS-2FCHECKS-3ALOAD-CHECK-SYSTEMS-20FUNCTION-29"></a>

##### [function](1340) `40ants-ai-evals/checks:load-check-systems` systems

Load trusted `ASDF` extensions from explicit project paths or Qlot dependencies.

<a id="x-2840ANTS-AI-EVALS-2FCHECKS-3AMAKE-CONTEXT-20FUNCTION-29"></a>

##### [function](a1bb) `40ants-ai-evals/checks:make-context` sample vars

Create a per-sample extension context with an isolated evidence cache.

<a id="x-2840ANTS-AI-EVALS-2FCHECKS-3AMERGE-VARS-20FUNCTION-29"></a>

##### [function](4d91) `40ants-ai-evals/checks:merge-vars` defaults overrides

Copy defaults then apply explicit object fields without mutating inputs.

<a id="x-2840ANTS-AI-EVALS-2FCHECKS-3AOUTCOME-20FUNCTION-29"></a>

##### [function](7301) `40ants-ai-evals/checks:outcome` NAME PASS &KEY REASON (SCORE (IF PASS
    1.0d0
    0.0d0))

Return a mandatory pass decision and a score from 0 to 1, defaulting to 0 or 1.
A passing result may award partial credit; its reason remains available.

<a id="x-2840ANTS-AI-EVALS-2FCHECKS-3AREGISTER-CHECK-20FUNCTION-29"></a>

##### [function](03b9) `40ants-ai-evals/checks:register-check` id handler &key (parameters (dict)) (defaults (dict)) validate optional-parameters

Register `HANDLER`(context, parameters), typed parameters, defaults and optional fields.

<a id="x-2840ANTS-AI-EVALS-2FCHECKS-3AREGISTER-PROFILE-20FUNCTION-29"></a>

##### [function](9375) `40ants-ai-evals/checks:register-profile` id specifications

Register a reusable ordered plan, owned by the registering package.

<a id="x-2840ANTS-AI-EVALS-2FCHECKS-3AVALIDATE-PLAN-20FUNCTION-29"></a>

##### [function](6747) `40ants-ai-evals/checks:validate-plan` vars

Load extensions and resolve a typed plan before spending model calls.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FCLI-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/CLI

<a id="x-28-23A-28-2819-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FCLI-22-29-20PACKAGE-29"></a>

#### [package](6f19) `40ants-ai-evals/cli`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FCLI-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FCLI-3AMAIN-20FUNCTION-29"></a>

##### [function](4fc4) `40ants-ai-evals/cli:main` arguments

Run the `CLI`, keeping machine-readable stdout clean for protocol commands.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FCOLLECTOR-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/COLLECTOR

<a id="x-28-23A-28-2825-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FCOLLECTOR-22-29-20PACKAGE-29"></a>

#### [package](2816) `40ants-ai-evals/collector`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FCOLLECTOR-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FCOLLECTOR-3ACOLLECT-AND-GRADE-20FUNCTION-29"></a>

##### [function](09bd) `40ants-ai-evals/collector:collect-and-grade` request

Archive provider evidence before grading, preserving agent identity and raw traces.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FENVIRONMENTS-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/ENVIRONMENTS

<a id="x-28-23A-28-2828-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FENVIRONMENTS-22-29-20PACKAGE-29"></a>

#### [package](a433) `40ants-ai-evals/environments`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FENVIRONMENTS-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FENVIRONMENTS-3ACODEX-CONFIG-20FUNCTION-29"></a>

##### [function](2583) `40ants-ai-evals/environments:codex-config` descriptor

Return project-specific native Codex configuration.

<a id="x-2840ANTS-AI-EVALS-2FENVIRONMENTS-3AENVIRONMENT-VARIABLES-20FUNCTION-29"></a>

##### [function](c322) `40ants-ai-evals/environments:environment-variables` descriptor &optional workspace

Return environment variables for the fixture process.

<a id="x-2840ANTS-AI-EVALS-2FENVIRONMENTS-3AFINALIZE-20FUNCTION-29"></a>

##### [function](c7c6) `40ants-ai-evals/environments:finalize` workspace &key vars archive-directory

Collect project-owned fixture evidence after success, error or timeout.

<a id="x-2840ANTS-AI-EVALS-2FENVIRONMENTS-3AOPENCODE-CONFIG-20FUNCTION-29"></a>

##### [function](83b7) `40ants-ai-evals/environments:opencode-config` descriptor

Return project-specific native OpenCode configuration.

<a id="x-2840ANTS-AI-EVALS-2FENVIRONMENTS-3APREFLIGHT-20FUNCTION-29"></a>

##### [function](d401) `40ants-ai-evals/environments:preflight` profile &key (check-tools t)

Validate project-provided prerequisites before any model call.

<a id="x-2840ANTS-AI-EVALS-2FENVIRONMENTS-3APREPARE-20FUNCTION-29"></a>

##### [function](b6b2) `40ants-ai-evals/environments:prepare` workspace vars

Prepare one isolated workspace through the registered project callback.

<a id="x-2840ANTS-AI-EVALS-2FENVIRONMENTS-3APROFILE-NAME-20FUNCTION-29"></a>

##### [function](9999) `40ants-ai-evals/environments:profile-name` profile

Normalize a declared environment identifier.

<a id="x-2840ANTS-AI-EVALS-2FENVIRONMENTS-3AREGISTER-ENVIRONMENT-20FUNCTION-29"></a>

##### [function](7cc2) `40ants-ai-evals/environments:register-environment` name &rest callbacks

Register a trusted project's [`prepare`][7749], [`preflight`][2a5c] and evidence callbacks.

<a id="x-2840ANTS-AI-EVALS-2FENVIRONMENTS-3AWORKSPACE-INSTRUCTIONS-20FUNCTION-29"></a>

##### [function](4257) `40ants-ai-evals/environments:workspace-instructions` &optional profile

Describe the prepared runtime without exposing assertion requirements.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FGRADING-2FCONTRACTS-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/GRADING/CONTRACTS

<a id="x-28-23A-28-2833-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FGRADING-2FCONTRACTS-22-29-20PACKAGE-29"></a>

#### [package](d7f6) `40ants-ai-evals/grading/contracts`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FGRADING-2FCONTRACTS-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FGRADING-2FCONTRACTS-3AGRADE-20FUNCTION-29"></a>

##### [function](6b90) `40ants-ai-evals/grading/contracts:grade` output vars &key sample-directory

Run the case's registered checks; infrastructure errors propagate to the collector.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FHISTORY-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/HISTORY

<a id="x-28-23A-28-2823-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FHISTORY-22-29-20PACKAGE-29"></a>

#### [package](8399) `40ants-ai-evals/history`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FHISTORY-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FHISTORY-3ACOMPARE-RUNS-20FUNCTION-29"></a>

##### [function](f7eb) `40ants-ai-evals/history:compare-runs` before after &key allow-mismatch agent before-agent after-agent suite

Compare runs for `AGENT`, or select each side with `BEFORE-AGENT` and `AFTER-AGENT`.
Different agent selectors produce an agent/model comparison, not a skill regression.
`ALLOW-MISMATCH` prints fingerprint or same-agent profile differences instead of rejecting them.
Different suite identities are always rejected; `SUITE` restricts both selected runs.

<a id="x-2840ANTS-AI-EVALS-2FHISTORY-3AFIND-RUN-20FUNCTION-29"></a>

##### [function](b01d) `40ants-ai-evals/history:find-run` id &rest options

Resolve `ID`s, labels and relative selectors, optionally restricted with `:SUITE`.
An optional positional history list preserves the original reader `API`. Exact `ID`s
remain selectable across suites so comparison can report a clear identity error.

<a id="x-2840ANTS-AI-EVALS-2FHISTORY-3AHISTORIES-20FUNCTION-29"></a>

##### [function](9f6e) `40ants-ai-evals/history:histories` &OPTIONAL (RUNS-ROOT (AT (ROOT) ".evals/runs/"))

Read accumulated summaries in run `ID` order, including pre-migration runs.

<a id="x-2840ANTS-AI-EVALS-2FHISTORY-3AMAKE-SUMMARY-20FUNCTION-29"></a>

##### [function](263b) `40ants-ai-evals/history:make-summary` manifest exported status &optional (signal :null)

Build a summary from either supported Promptfoo export shape.

<a id="x-2840ANTS-AI-EVALS-2FHISTORY-3APRINT-HISTORY-20FUNCTION-29"></a>

##### [function](f5fc) `40ants-ai-evals/history:print-history` &key agent suite

List accumulated runs, optionally selecting `SUITE` and counting `AGENT` only.

<a id="x-2840ANTS-AI-EVALS-2FHISTORY-3APRINT-SUMMARY-20FUNCTION-29"></a>

##### [function](281a) `40ants-ai-evals/history:print-summary` summary

Print scores and failures with artifact location.

<a id="x-2840ANTS-AI-EVALS-2FHISTORY-3ASUMMARIZE-20FUNCTION-29"></a>

##### [function](c5bf) `40ants-ai-evals/history:summarize` run-dir manifest status

Write a summary beside the original export; leave the database untouched.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FPROJECT-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/PROJECT

<a id="x-28-23A-28-2823-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FPROJECT-22-29-20PACKAGE-29"></a>

#### [package](a751) `40ants-ai-evals/project`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FPROJECT-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FPROJECT-3ALOAD-EXTENSIONS-20FUNCTION-29"></a>

##### [function](8f73) `40ants-ai-evals/project:load-extensions`

Load explicit project-owned `ASDF` systems before resolving environments or cases.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FPROVIDERS-2FOPENCODE-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/PROVIDERS/OPENCODE

<a id="x-28-23A-28-2834-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FPROVIDERS-2FOPENCODE-22-29-20PACKAGE-29"></a>

#### [package](ac37) `40ants-ai-evals/providers/opencode`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FPROVIDERS-2FOPENCODE-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FPROVIDERS-2FOPENCODE-3ACALL-AGENT-20FUNCTION-29"></a>

##### [function](8777) `40ants-ai-evals/providers/opencode:call-agent` request

Run one prompt in a fresh workspace/session; retain full and partial raw evidence.
`CONFIG` requires runDir, server and working_dir (or `VARS`.workspaces.opencode.`VARIANT`).
Timeouts interrupt execution before collecting the projected export and durable `SSE` log.

<a id="x-2840ANTS-AI-EVALS-2FPROVIDERS-2FOPENCODE-3AMODEL-REFERENCE-20FUNCTION-29"></a>

##### [function](5681) `40ants-ai-evals/providers/opencode:model-reference` model

Parse the v2 provider/model`#variant` reference without changing its model name.

<a id="x-2840ANTS-AI-EVALS-2FPROVIDERS-2FOPENCODE-3ANORMALIZE-TRANSCRIPT-20FUNCTION-29"></a>

##### [function](bef6) `40ants-ai-evals/providers/opencode:normalize-transcript` TRANSCRIPT &OPTIONAL (SKILL-NAME "writing-common-lisp")

Normalize complete v2 export data, deduplicating message and tool identifiers.
Token counts include compaction calls; only completed target skill reads count.

<a id="x-2840ANTS-AI-EVALS-2FPROVIDERS-2FOPENCODE-3ASTART-SERVER-20FUNCTION-29"></a>

##### [function](4db0) `40ants-ai-evals/providers/opencode:start-server` RUN-DIR &KEY (EXECUTABLE (OR (UIOP/OS:GETENV "SKILL\_EVAL\_OPENCODE\_BIN") "opencode"))

Start a private loopback OpenCode v2 server and import only the `ZAI` `API` key.
The serializable descriptor references private temporary state; [`stop-server`][7ed9] erases it.

<a id="x-2840ANTS-AI-EVALS-2FPROVIDERS-2FOPENCODE-3ASTOP-SERVER-20FUNCTION-29"></a>

##### [function](5c3f) `40ants-ai-evals/providers/opencode:stop-server` server

Stop the owned server and remove its private configuration, database and credentials.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FPROVIDERS-2FOPENCODE-3FVariables-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Variables

<a id="x-2840ANTS-AI-EVALS-2FPROVIDERS-2FOPENCODE-3A-2AHTTP-REQUEST-2A-20-28VARIABLE-29-29"></a>

##### [variable](8021) `40ants-ai-evals/providers/opencode:*http-request*` nil

Optional `HTTP` test hook receiving descriptor, method, path, body, timeout and raw-p.
The hook must return an already decoded `JSON` value, or text when `RAW-P` is true.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FRECOVERY-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/RECOVERY

<a id="x-28-23A-28-2824-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FRECOVERY-22-29-20PACKAGE-29"></a>

#### [package](6526) `40ants-ai-evals/recovery`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FRECOVERY-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FRECOVERY-3ACAPTURE-20FUNCTION-29"></a>

##### [function](e559) `40ants-ai-evals/recovery:capture` workspace provider-dir vars normalized trace-path failure

Archive one native provider workspace independently of Promptfoo's deadline.
`VARS` must contain its exact `ID` and variant. Credentials and server state are never
copied: only the sample workspace and an already saved confined provider trace.

<a id="x-2840ANTS-AI-EVALS-2FRECOVERY-3ARECOVER-20FUNCTION-29"></a>

##### [function](28ab) `40ants-ai-evals/recovery:recover` run-dir

Enrich local failed export rows from exact, unambiguous provider snapshots.
Original scores, success flags and Promptfoo's database are never modified.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FRUNNER-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/RUNNER

<a id="x-28-23A-28-2822-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FRUNNER-22-29-20PACKAGE-29"></a>

#### [package](c113) `40ants-ai-evals/runner`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FRUNNER-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FRUNNER-3AGRADING-VARS-20FUNCTION-29"></a>

##### [function](dbe5) `40ants-ai-evals/runner:grading-vars` vars

Apply this suite's declared check defaults, keeping historical expectations intact.

<a id="x-2840ANTS-AI-EVALS-2FRUNNER-3AREPLAY-RUN-20FUNCTION-29"></a>

##### [function](fd9d) `40ants-ai-evals/runner:replay-run` run-dir

Regrade archived samples offline and save a report without changing old scores.

<a id="x-2840ANTS-AI-EVALS-2FRUNNER-3ARUN-EVAL-20FUNCTION-29"></a>

##### [function](e97e) `40ants-ai-evals/runner:run-eval` flags

Evaluate suites separately; retain a durable index for multi-suite batches.

<a id="x-2840ANTS-AI-EVALS-2FRUNNER-3AVALIDATE-OPTIONS-20FUNCTION-29"></a>

##### [function](af7e) `40ants-ai-evals/runner:validate-options` flags

Reject invalid options before creating any run or contacting the model.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FSUITES-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/SUITES

<a id="x-28-23A-28-2822-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FSUITES-22-29-20PACKAGE-29"></a>

#### [package](4033) `40ants-ai-evals/suites`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FSUITES-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FSUITES-3ACATALOG-20FUNCTION-29"></a>

##### [function](5d80) `40ants-ai-evals/suites:catalog`

Read the project catalog, accepting old snapshots without a catalog.

<a id="x-2840ANTS-AI-EVALS-2FSUITES-3ADESCRIBE-SUITES-20FUNCTION-29"></a>

##### [function](3175) `40ants-ai-evals/suites:describe-suites`

Describe case counts without evaluating tools or contacting a model.

<a id="x-2840ANTS-AI-EVALS-2FSUITES-3AFIND-SUITE-20FUNCTION-29"></a>

##### [function](c6f0) `40ants-ai-evals/suites:find-suite` &optional id

Resolve a suite, using the configured project default or the first catalog entry.

<a id="x-2840ANTS-AI-EVALS-2FSUITES-3ASELECTED-SUITES-20FUNCTION-29"></a>

##### [function](408f) `40ants-ai-evals/suites:selected-suites` flags

<a id="x-2840ANTS-AI-EVALS-2FSUITES-3ASUITE-PATH-20FUNCTION-29"></a>

##### [function](a2ea) `40ants-ai-evals/suites:suite-path` &optional id

Return the suite configuration's relative directory.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FUTIL-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/UTIL

<a id="x-28-23A-28-2820-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FUTIL-22-29-20PACKAGE-29"></a>

#### [package](278c) `40ants-ai-evals/util`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FUTIL-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AARCHIVE-FRAMEWORK-ROOT-20FUNCTION-29"></a>

##### [function](8b50) `40ants-ai-evals/util:archive-framework-root` run-dir

Locate framework code in either snapshot layout.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AARCHIVE-PROJECT-ROOT-20FUNCTION-29"></a>

##### [function](99cb) `40ants-ai-evals/util:archive-project-root` run-dir

Locate new split archives, retaining old combined snapshots unchanged.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AAT-20FUNCTION-29"></a>

##### [function](fb95) `40ants-ai-evals/util:at` directory relative

Resolve `RELATIVE` inside `DIRECTORY`.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3ABOOL-20FUNCTION-29"></a>

##### [function](d433) `40ants-ai-evals/util:bool` value

Represent a Lisp predicate as an unambiguous `JSON` boolean.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3ACOPY-DIRECTORY-20FUNCTION-29"></a>

##### [function](3390) `40ants-ai-evals/util:copy-directory` source destination &key ignore-editor-locks

Copy a plain tree without following symbolic links.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3ADECODE-20FUNCTION-29"></a>

##### [function](3e17) `40ants-ai-evals/util:decode` input

Decode `JSON` with distinct arrays, booleans and null values.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3ADIGEST-FILE-20FUNCTION-29"></a>

##### [function](9f95) `40ants-ai-evals/util:digest-file` file

Return a file's `SHA-256` digest.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3ADIGEST-TREE-20FUNCTION-29"></a>

##### [function](198f) `40ants-ai-evals/util:digest-tree` directory

Hash sorted relative paths and bytes using the legacy runner's format.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AENCODE-20FUNCTION-29"></a>

##### [function](683b) `40ants-ai-evals/util:encode` value

Encode a `JSON` value into a `UTF-8` compatible Lisp string.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AFIELD-20FUNCTION-29"></a>

##### [function](a01c) `40ants-ai-evals/util:field` object &rest keys

Read nested `JSON` object fields, returning `NIL` for missing keys.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AFRAMEWORK-ROOT-20FUNCTION-29"></a>

##### [function](c353) `40ants-ai-evals/util:framework-root`

Return the immutable library checkout, independently of the consuming project.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AJSON-EQUAL-P-20FUNCTION-29"></a>

##### [function](768d) `40ants-ai-evals/util:json-equal-p` left right

Compare `JSON` values independently of object key order.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3ANOW-20FUNCTION-29"></a>

##### [function](4a88) `40ants-ai-evals/util:now`

Return an `ISO` timestamp in `UTC`.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3APROJECT-CONFIG-20FUNCTION-29"></a>

##### [function](ab7d) `40ants-ai-evals/util:project-config`

Read trusted project settings; help and library-only commands need no config.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AREAD-JSON-20FUNCTION-29"></a>

##### [function](9fec) `40ants-ai-evals/util:read-json` file

Read `JSON` from `FILE`.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AREMOVE-DIRECTORY-20FUNCTION-29"></a>

##### [function](7634) `40ants-ai-evals/util:remove-directory` directory

Remove a directory created or owned by the harness.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AROOT-20FUNCTION-29"></a>

##### [function](6214) `40ants-ai-evals/util:root`

Return the consuming project, or a bound archived project during replay.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3ARUN-COMMAND-20FUNCTION-29"></a>

##### [function](9242) `40ants-ai-evals/util:run-command` argv &key (directory (root)) input (timeout 120) log-prefix allow-failure

Run `ARGV` without a shell; capture logs and kill timed-out subprocesses.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3ASAFE-RELATIVE-P-20FUNCTION-29"></a>

##### [function](947c) `40ants-ai-evals/util:safe-relative-p` relative

Recognize portable fixture paths confined to a workspace.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3ASEQUENCE-LIST-20FUNCTION-29"></a>

##### [function](a189) `40ants-ai-evals/util:sequence-list` value

Convert a `JSON` array to a list; treat absent/null arrays as empty.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3ATEMPORARY-DIRECTORY-20FUNCTION-29"></a>

##### [function](cb36) `40ants-ai-evals/util:temporary-directory` &OPTIONAL (PREFIX "ai-evals")

Allocate a private directory under the operating system's temporary root.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3ATREE-FILES-20FUNCTION-29"></a>

##### [function](6fe9) `40ants-ai-evals/util:tree-files` directory &key exclude ignore-editor-locks

Return sorted relative files; reject symlinks before following directories.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3ATRUE-P-20FUNCTION-29"></a>

##### [function](03d3) `40ants-ai-evals/util:true-p` value

Recognize Lisp T or a decoded `JSON` true.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AUNIQUE-ID-20FUNCTION-29"></a>

##### [function](3578) `40ants-ai-evals/util:unique-id`

Return a fresh identifier allocated by the operating system.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AWRITE-JSON-20FUNCTION-29"></a>

##### [function](e56d) `40ants-ai-evals/util:write-json` file value

Persist a `JSON` document with a trailing newline.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AWRITE-TEXT-20FUNCTION-29"></a>

##### [function](0a93) `40ants-ai-evals/util:write-text` file text

Write `UTF-8` `TEXT`, creating parent directories.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FUTIL-3FVariables-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Variables

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3A-2APROJECT-ROOT-2A-20-28VARIABLE-29-29"></a>

##### [variable](41a4) `40ants-ai-evals/util:*project-root*` nil

Dynamically selected consumer root, distinct from the framework checkout.


[40fe]: https://github.com/40ants/ai-evals
[3211]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/agents.lisp#L11
[16bc]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/agents.lisp#L2
[b874]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/agents.lisp#L20
[569a]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/agents.lisp#L29
[9b55]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/agents.lisp#L49
[5e99]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/agents.lisp#L55
[3288]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/agents.lisp#L65
[e3dd]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/case-resources.lisp#L113
[d69e]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/case-resources.lisp#L128
[d6a0]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/case-resources.lisp#L143
[ffca]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/case-resources.lisp#L154
[458b]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/case-resources.lisp#L166
[b96e]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/case-resources.lisp#L181
[b374]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/case-resources.lisp#L19
[724c]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/case-resources.lisp#L193
[70d7]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/case-resources.lisp#L2
[7e21]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/case-resources.lisp#L20
[c0c2]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/case-resources.lisp#L201
[c606]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/case-resources.lisp#L240
[4a86]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/case-resources.lisp#L249
[96ec]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/case-resources.lisp#L31
[5b99]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/case-resources.lisp#L56
[ca32]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/case-resources.lisp#L90
[6747]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/checks.lisp#L197
[c8be]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/checks.lisp#L2
[a1bb]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/checks.lisp#L209
[b563]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/checks.lisp#L215
[4d91]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/checks.lisp#L22
[251f]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/checks.lisp#L221
[940f]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/checks.lisp#L227
[7301]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/checks.lisp#L235
[bc06]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/checks.lisp#L247
[48c0]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/checks.lisp#L271
[03b9]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/checks.lisp#L33
[9375]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/checks.lisp#L52
[1340]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/checks.lisp#L62
[4fc4]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/cli.lisp#L139
[6f19]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/cli.lisp#L2
[2816]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/collector.lisp#L2
[09bd]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/collector.lisp#L217
[7cc2]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/environments.lisp#L13
[a433]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/environments.lisp#L2
[9999]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/environments.lisp#L25
[d401]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/environments.lisp#L38
[b6b2]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/environments.lisp#L44
[2583]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/environments.lisp#L54
[83b7]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/environments.lisp#L59
[c322]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/environments.lisp#L64
[4257]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/environments.lisp#L69
[c7c6]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/environments.lisp#L75
[6b90]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/grading/contracts.lisp#L14
[d7f6]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/grading/contracts.lisp#L2
[263b]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/history.lisp#L158
[8399]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/history.lisp#L2
[c5bf]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/history.lisp#L220
[281a]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/history.lisp#L229
[f5fc]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/history.lisp#L307
[f7eb]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/history.lisp#L326
[9f6e]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/history.lisp#L69
[b01d]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/history.lisp#L78
[a751]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/project.lisp#L1
[8f73]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/project.lisp#L10
[5c3f]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/providers/opencode.lisp#L132
[5681]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/providers/opencode.lisp#L146
[8021]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/providers/opencode.lisp#L19
[bef6]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/providers/opencode.lisp#L191
[ac37]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/providers/opencode.lisp#L2
[8777]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/providers/opencode.lisp#L364
[4db0]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/providers/opencode.lisp#L87
[28ab]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/recovery.lisp#L153
[e559]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/recovery.lisp#L17
[6526]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/recovery.lisp#L2
[c113]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/runner.lisp#L2
[fd9d]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/runner.lisp#L656
[af7e]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/runner.lisp#L66
[e97e]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/runner.lisp#L720
[dbe5]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/runner.lisp#L96
[5d80]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/suites.lisp#L12
[4033]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/suites.lisp#L2
[c6f0]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/suites.lisp#L34
[a2ea]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/suites.lisp#L42
[408f]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/suites.lisp#L48
[3175]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/suites.lisp#L54
[8b50]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/util.lisp#L101
[fb95]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/util.lisp#L109
[3578]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/util.lisp#L115
[4a88]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/util.lisp#L122
[cb36]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/util.lisp#L129
[7634]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/util.lisp#L139
[9242]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/util.lisp#L147
[6fe9]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/util.lisp#L183
[278c]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/util.lisp#L2
[3390]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/util.lisp#L206
[a01c]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/util.lisp#L21
[9f95]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/util.lisp#L220
[198f]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/util.lisp#L234
[a189]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/util.lisp#L248
[768d]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/util.lisp#L254
[947c]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/util.lisp#L265
[03d3]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/util.lisp#L28
[d433]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/util.lisp#L34
[3e17]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/util.lisp#L40
[683b]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/util.lisp#L47
[9fec]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/util.lisp#L53
[0a93]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/util.lisp#L59
[e56d]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/util.lisp#L69
[41a4]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/util.lisp#L73
[c353]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/util.lisp#L77
[6214]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/util.lisp#L82
[ab7d]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/util.lisp#L88
[99cb]: https://github.com/40ants/ai-evals/blob/4b88bc405a248090a500adb4cb1a7b897dbc7a11/src/util.lisp#L94
[1c51]: https://github.com/40ants/ai-evals/issues
[c15d]: https://quickdocs.org/asdf
[3a1f]: https://quickdocs.org/babel
[49b9]: https://quickdocs.org/cl-ppcre
[8347]: https://quickdocs.org/dexador
[90b9]: https://quickdocs.org/ironclad
[46a1]: https://quickdocs.org/local-time
[2103]: https://quickdocs.org/quri
[c41d]: https://quickdocs.org/serapeum
[aba2]: https://quickdocs.org/yason
[62b3]: index.html#x-2840ANTS-AI-EVALS-2FAGENTS-3APROFILE-FOR-20FUNCTION-29
[2a5c]: index.html#x-2840ANTS-AI-EVALS-2FENVIRONMENTS-3APREFLIGHT-20FUNCTION-29
[7749]: index.html#x-2840ANTS-AI-EVALS-2FENVIRONMENTS-3APREPARE-20FUNCTION-29
[7ed9]: index.html#x-2840ANTS-AI-EVALS-2FPROVIDERS-2FOPENCODE-3ASTOP-SERVER-20FUNCTION-29

* * *
###### [generated by [40ANTS-DOC](https://40ants.com/doc/)]
