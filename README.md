<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-40README-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

# 40ants-ai-evals — Reusable skill evaluations

<a id="40-ants-ai-evals-asdf-system-details"></a>

## 40ANTS-AI-EVALS ASDF System Details

* Version: 0.5.1
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

For a Roswell installation into an initialized Qlot project, run
qlot exec ros install 40ants/ai-evals, then invoke .qlot/bin/ai-evals help.
The local command does not require adding .qlot/bin to the global `PATH`.
For model runs, enter the pinned Nix environment to provision the external tools.

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

#### [package](d3c0) `40ants-ai-evals/agents`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FAGENTS-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FAGENTS-3APROFILE-FOR-20FUNCTION-29"></a>

##### [function](abae) `40ants-ai-evals/agents:profile-for` agent flags &optional tools

Copy `AGENT`'s profile, recording only tools relevant to that agent.

<a id="x-2840ANTS-AI-EVALS-2FAGENTS-3APROVIDER-IDENTITY-20FUNCTION-29"></a>

##### [function](6d85) `40ants-ai-evals/agents:provider-identity` label

Decode current labels and historical Codex-only labels into agent and variant.

<a id="x-2840ANTS-AI-EVALS-2FAGENTS-3APROVIDER-LABEL-20FUNCTION-29"></a>

##### [function](2768) `40ants-ai-evals/agents:provider-label` agent variant

Return an unambiguous provider label for one agent/skill combination.

<a id="x-2840ANTS-AI-EVALS-2FAGENTS-3ARENDER-TASK-20FUNCTION-29"></a>

##### [function](2cff) `40ants-ai-evals/agents:render-task` TASK AGENT &OPTIONAL (SKILL-NAME "writing-common-lisp")

Render explicit references so new suites have observable skill-read evidence.
Codex expands dollar references before `SDK` tool traces, which cannot prove a read.
Automatic routing tasks remain untouched, as does the original suite contract.

<a id="x-2840ANTS-AI-EVALS-2FAGENTS-3ASELECTED-AGENTS-20FUNCTION-29"></a>

##### [function](da45) `40ants-ai-evals/agents:selected-agents` flags

Resolve `--agent`; preserve Codex as the default for existing commands.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FAGENTS-3FVariables-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Variables

<a id="x-2840ANTS-AI-EVALS-2FAGENTS-3A-2APROFILES-2A-20-28VARIABLE-29-29"></a>

##### [variable](fdbb) `40ants-ai-evals/agents:*profiles*` #<hash-table :test equal :count 2 {8006db0003}>

Default agent profiles. [`profile-for`][62b3] returns a copy; callers may override one run's model.
`EFFORT` is a Codex setting and is never translated into an OpenCode reasoning option.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FCASE-RESOURCES-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/CASE-RESOURCES

<a id="x-28-23A-28-2830-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FCASE-RESOURCES-22-29-20PACKAGE-29"></a>

#### [package](8b9b) `40ants-ai-evals/case-resources`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FCASE-RESOURCES-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3ABASELINE-MANIFEST-20FUNCTION-29"></a>

##### [function](8551) `40ants-ai-evals/case-resources:baseline-manifest` VARS &OPTIONAL (SPEC (FIELD VARS "fixtures"))

Use the frozen baseline including supervisor-added files, or normalize old vars.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3ACOPY-FIXTURES-20FUNCTION-29"></a>

##### [function](bd97) `40ants-ai-evals/case-resources:copy-fixtures` vars workspace

Copy inputs from the selected input tree without decoding or following links.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3AFILE-METADATA-20FUNCTION-29"></a>

##### [function](1c10) `40ants-ai-evals/case-resources:file-metadata` path

Describe regular-file bytes and executable bits without following symlinks.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3AFILE-REFERENCES-20FUNCTION-29"></a>

##### [function](aec2) `40ants-ai-evals/case-resources:file-references` vars

Read a resource set or a historical array without expanding Promptfoo cases.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3AFIXTURE-MANIFEST-20FUNCTION-29"></a>

##### [function](9af9) `40ants-ai-evals/case-resources:fixture-manifest` VARS &OPTIONAL (SPEC (FIELD VARS "fixtures"))

Read a fixture directory, or normalize a historical inline fixture object.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3AINPUT-FINGERPRINT-20FUNCTION-29"></a>

##### [function](43d2) `40ants-ai-evals/case-resources:input-fingerprint` cases &key fixtures-only

Hash actual case resource bytes and modes from the selected input tree.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3AMANIFEST-EQUAL-P-20FUNCTION-29"></a>

##### [function](94f7) `40ants-ai-evals/case-resources:manifest-equal-p` expected actual

Compare complete file sets, bytes and captured executable permissions.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3AMETADATA-EQUAL-P-20FUNCTION-29"></a>

##### [function](f115) `40ants-ai-evals/case-resources:metadata-equal-p` expected actual

Compare byte identity and permissions when that evidence is available.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3APRODUCT-PATH-P-20FUNCTION-29"></a>

##### [function](e741) `40ants-ai-evals/case-resources:product-path-p` path

Exclude evaluation machinery from product file comparisons.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3ARESOLVE-RESOURCE-20FUNCTION-29"></a>

##### [function](3861) `40ants-ai-evals/case-resources:resolve-resource` vars reference &key directory

Resolve a suite-relative input, rejecting symlinks in every path component.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3ARESTORE-SAMPLE-20FUNCTION-29"></a>

##### [function](375c) `40ants-ai-evals/case-resources:restore-sample` sample destination

Restore regular candidate files from verified archives, including binary inputs.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3ASAMPLE-MANIFEST-20FUNCTION-29"></a>

##### [function](d8b1) `40ants-ai-evals/case-resources:sample-manifest` sample

Describe product evidence, retaining compatibility with text-only archives.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3AVALIDATE-FIXTURES-20FUNCTION-29"></a>

##### [function](de92) `40ants-ai-evals/case-resources:validate-fixtures` vars

Validate fixture inputs before any paid evaluation starts.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FCASE-RESOURCES-3FVariables-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Variables

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3A-2AINPUTS-ROOT-2A-20-28VARIABLE-29-29"></a>

##### [variable](eeba) `40ants-ai-evals/case-resources:*inputs-root*` nil

Input tree for this operation; `NIL` uses the loaded harness.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3A-2ASAMPLE-DIRECTORY-2A-20-28VARIABLE-29-29"></a>

##### [variable](7c2f) `40ants-ai-evals/case-resources:*sample-directory*` nil

Trusted archive directory of the sample being graded.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FCHECKS-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/CHECKS

<a id="x-28-23A-28-2822-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FCHECKS-22-29-20PACKAGE-29"></a>

#### [package](ef88) `40ants-ai-evals/checks`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FCHECKS-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FCHECKS-3ACACHED-20FUNCTION-29"></a>

##### [function](b6d5) `40ants-ai-evals/checks:cached` context key compute

Compute shared evidence once per sample, including a cached `NIL` result.

<a id="x-2840ANTS-AI-EVALS-2FCHECKS-3ACONTEXT-SAMPLE-20FUNCTION-29"></a>

##### [function](cd39) `40ants-ai-evals/checks:context-sample` context

Return immutable-by-convention sample evidence for a check.

<a id="x-2840ANTS-AI-EVALS-2FCHECKS-3ACONTEXT-VARS-20FUNCTION-29"></a>

##### [function](4e70) `40ants-ai-evals/checks:context-vars` context

Return the test variables for a check.

<a id="x-2840ANTS-AI-EVALS-2FCHECKS-3ADESCRIBE-CHECKS-20FUNCTION-29"></a>

##### [function](e19d) `40ants-ai-evals/checks:describe-checks`

Return `JSON`-compatible schemas for the checks currently registered.

<a id="x-2840ANTS-AI-EVALS-2FCHECKS-3AEXECUTE-PLAN-20FUNCTION-29"></a>

##### [function](2905) `40ants-ai-evals/checks:execute-plan` context plan

Execute independent handlers; `NIL` skips a check, a vector emits several results.

<a id="x-2840ANTS-AI-EVALS-2FCHECKS-3ALOAD-CHECK-SYSTEMS-20FUNCTION-29"></a>

##### [function](58f1) `40ants-ai-evals/checks:load-check-systems` systems

Load trusted `ASDF` extensions from explicit project paths or Qlot dependencies.

<a id="x-2840ANTS-AI-EVALS-2FCHECKS-3AMAKE-CONTEXT-20FUNCTION-29"></a>

##### [function](9540) `40ants-ai-evals/checks:make-context` sample vars

Create a per-sample extension context with an isolated evidence cache.

<a id="x-2840ANTS-AI-EVALS-2FCHECKS-3AMERGE-VARS-20FUNCTION-29"></a>

##### [function](dbe9) `40ants-ai-evals/checks:merge-vars` defaults overrides

Copy defaults then apply explicit object fields without mutating inputs.

<a id="x-2840ANTS-AI-EVALS-2FCHECKS-3AOUTCOME-20FUNCTION-29"></a>

##### [function](aa60) `40ants-ai-evals/checks:outcome` NAME PASS &KEY REASON (SCORE (IF PASS
    1.0d0
    0.0d0))

Return a mandatory pass decision and a score from 0 to 1, defaulting to 0 or 1.
A passing result may award partial credit; its reason remains available.

<a id="x-2840ANTS-AI-EVALS-2FCHECKS-3AREGISTER-CHECK-20FUNCTION-29"></a>

##### [function](11d0) `40ants-ai-evals/checks:register-check` id handler &key (parameters (dict)) (defaults (dict)) validate optional-parameters

Register `HANDLER`(context, parameters), typed parameters, defaults and optional fields.

<a id="x-2840ANTS-AI-EVALS-2FCHECKS-3AREGISTER-PROFILE-20FUNCTION-29"></a>

##### [function](d1dc) `40ants-ai-evals/checks:register-profile` id specifications

Register a reusable ordered plan, owned by the registering package.

<a id="x-2840ANTS-AI-EVALS-2FCHECKS-3AVALIDATE-PLAN-20FUNCTION-29"></a>

##### [function](c962) `40ants-ai-evals/checks:validate-plan` vars

Load extensions and resolve a typed plan before spending model calls.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FCLI-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/CLI

<a id="x-28-23A-28-2819-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FCLI-22-29-20PACKAGE-29"></a>

#### [package](abaef) `40ants-ai-evals/cli`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FCLI-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FCLI-3AMAIN-20FUNCTION-29"></a>

##### [function](e652) `40ants-ai-evals/cli:main` arguments

Run the `CLI`, keeping machine-readable stdout clean for protocol commands.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FCOLLECTOR-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/COLLECTOR

<a id="x-28-23A-28-2825-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FCOLLECTOR-22-29-20PACKAGE-29"></a>

#### [package](23cd) `40ants-ai-evals/collector`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FCOLLECTOR-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FCOLLECTOR-3ACOLLECT-AND-GRADE-20FUNCTION-29"></a>

##### [function](952d) `40ants-ai-evals/collector:collect-and-grade` request

Archive provider evidence before grading, preserving agent identity and raw traces.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FENVIRONMENTS-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/ENVIRONMENTS

<a id="x-28-23A-28-2828-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FENVIRONMENTS-22-29-20PACKAGE-29"></a>

#### [package](fb1a) `40ants-ai-evals/environments`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FENVIRONMENTS-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FENVIRONMENTS-3ACODEX-CONFIG-20FUNCTION-29"></a>

##### [function](a948) `40ants-ai-evals/environments:codex-config` descriptor

Return project-specific native Codex configuration.

<a id="x-2840ANTS-AI-EVALS-2FENVIRONMENTS-3AENVIRONMENT-VARIABLES-20FUNCTION-29"></a>

##### [function](82e3) `40ants-ai-evals/environments:environment-variables` descriptor &optional workspace

Return environment variables for the fixture process.

<a id="x-2840ANTS-AI-EVALS-2FENVIRONMENTS-3AFINALIZE-20FUNCTION-29"></a>

##### [function](8e61) `40ants-ai-evals/environments:finalize` workspace &key vars archive-directory

Collect project-owned fixture evidence after success, error or timeout.

<a id="x-2840ANTS-AI-EVALS-2FENVIRONMENTS-3AOPENCODE-CONFIG-20FUNCTION-29"></a>

##### [function](f406) `40ants-ai-evals/environments:opencode-config` descriptor

Return project-specific native OpenCode configuration.

<a id="x-2840ANTS-AI-EVALS-2FENVIRONMENTS-3APREFLIGHT-20FUNCTION-29"></a>

##### [function](f28c) `40ants-ai-evals/environments:preflight` profile &key (check-tools t)

Validate project-provided prerequisites before any model call.

<a id="x-2840ANTS-AI-EVALS-2FENVIRONMENTS-3APREPARE-20FUNCTION-29"></a>

##### [function](e74d) `40ants-ai-evals/environments:prepare` workspace vars

Prepare one isolated workspace through the registered project callback.

<a id="x-2840ANTS-AI-EVALS-2FENVIRONMENTS-3APROFILE-NAME-20FUNCTION-29"></a>

##### [function](9375) `40ants-ai-evals/environments:profile-name` profile

Normalize a declared environment identifier.

<a id="x-2840ANTS-AI-EVALS-2FENVIRONMENTS-3AREGISTER-ENVIRONMENT-20FUNCTION-29"></a>

##### [function](314d) `40ants-ai-evals/environments:register-environment` name &rest callbacks

Register a trusted project's [`prepare`][7749], [`preflight`][2a5c] and evidence callbacks.

<a id="x-2840ANTS-AI-EVALS-2FENVIRONMENTS-3AWORKSPACE-INSTRUCTIONS-20FUNCTION-29"></a>

##### [function](4ba7) `40ants-ai-evals/environments:workspace-instructions` &optional profile

Describe the prepared runtime without exposing assertion requirements.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FGRADING-2FCONTRACTS-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/GRADING/CONTRACTS

<a id="x-28-23A-28-2833-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FGRADING-2FCONTRACTS-22-29-20PACKAGE-29"></a>

#### [package](fdf9) `40ants-ai-evals/grading/contracts`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FGRADING-2FCONTRACTS-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FGRADING-2FCONTRACTS-3AGRADE-20FUNCTION-29"></a>

##### [function](7fe7) `40ants-ai-evals/grading/contracts:grade` output vars &key sample-directory

Run the case's registered checks; infrastructure errors propagate to the collector.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FHISTORY-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/HISTORY

<a id="x-28-23A-28-2823-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FHISTORY-22-29-20PACKAGE-29"></a>

#### [package](8fe0) `40ants-ai-evals/history`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FHISTORY-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FHISTORY-3ACOMPARE-RUNS-20FUNCTION-29"></a>

##### [function](968a) `40ants-ai-evals/history:compare-runs` before after &key allow-mismatch agent before-agent after-agent suite

Compare runs for `AGENT`, or select each side with `BEFORE-AGENT` and `AFTER-AGENT`.
Different agent selectors produce an agent/model comparison, not a skill regression.
`ALLOW-MISMATCH` prints fingerprint or same-agent profile differences instead of rejecting them.
Different suite identities are always rejected; `SUITE` restricts both selected runs.

<a id="x-2840ANTS-AI-EVALS-2FHISTORY-3AFIND-RUN-20FUNCTION-29"></a>

##### [function](8d49) `40ants-ai-evals/history:find-run` id &rest options

Resolve `ID`s, labels and relative selectors, optionally restricted with `:SUITE`.
An optional positional history list preserves the original reader `API`. Exact `ID`s
remain selectable across suites so comparison can report a clear identity error.

<a id="x-2840ANTS-AI-EVALS-2FHISTORY-3AHISTORIES-20FUNCTION-29"></a>

##### [function](3f85) `40ants-ai-evals/history:histories` &OPTIONAL (RUNS-ROOT (AT (ROOT) ".evals/runs/"))

Read accumulated summaries in run `ID` order, including pre-migration runs.

<a id="x-2840ANTS-AI-EVALS-2FHISTORY-3AMAKE-SUMMARY-20FUNCTION-29"></a>

##### [function](f622) `40ants-ai-evals/history:make-summary` manifest exported status &optional (signal :null)

Build a summary from either supported Promptfoo export shape.

<a id="x-2840ANTS-AI-EVALS-2FHISTORY-3APRINT-HISTORY-20FUNCTION-29"></a>

##### [function](4c6b) `40ants-ai-evals/history:print-history` &key agent suite

List accumulated runs, optionally selecting `SUITE` and counting `AGENT` only.

<a id="x-2840ANTS-AI-EVALS-2FHISTORY-3APRINT-SUMMARY-20FUNCTION-29"></a>

##### [function](3f47) `40ants-ai-evals/history:print-summary` summary

Print scores and failures with artifact location.

<a id="x-2840ANTS-AI-EVALS-2FHISTORY-3ASUMMARIZE-20FUNCTION-29"></a>

##### [function](48a8) `40ants-ai-evals/history:summarize` run-dir manifest status

Write a summary beside the original export; leave the database untouched.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FPROJECT-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/PROJECT

<a id="x-28-23A-28-2823-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FPROJECT-22-29-20PACKAGE-29"></a>

#### [package](34c7) `40ants-ai-evals/project`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FPROJECT-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FPROJECT-3ALOAD-EXTENSIONS-20FUNCTION-29"></a>

##### [function](d677) `40ants-ai-evals/project:load-extensions`

Load explicit project-owned `ASDF` systems before resolving environments or cases.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FPROVIDERS-2FOPENCODE-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/PROVIDERS/OPENCODE

<a id="x-28-23A-28-2834-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FPROVIDERS-2FOPENCODE-22-29-20PACKAGE-29"></a>

#### [package](9149) `40ants-ai-evals/providers/opencode`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FPROVIDERS-2FOPENCODE-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FPROVIDERS-2FOPENCODE-3ACALL-AGENT-20FUNCTION-29"></a>

##### [function](935b) `40ants-ai-evals/providers/opencode:call-agent` request

Run one prompt in a fresh workspace/session; retain full and partial raw evidence.
`CONFIG` requires runDir, server and working_dir (or `VARS`.workspaces.opencode.`VARIANT`).
Timeouts interrupt execution before collecting the projected export and durable `SSE` log.

<a id="x-2840ANTS-AI-EVALS-2FPROVIDERS-2FOPENCODE-3AMODEL-REFERENCE-20FUNCTION-29"></a>

##### [function](4acb) `40ants-ai-evals/providers/opencode:model-reference` model

Parse the v2 provider/model`#variant` reference without changing its model name.

<a id="x-2840ANTS-AI-EVALS-2FPROVIDERS-2FOPENCODE-3ANORMALIZE-TRANSCRIPT-20FUNCTION-29"></a>

##### [function](c29f) `40ants-ai-evals/providers/opencode:normalize-transcript` TRANSCRIPT &OPTIONAL (SKILL-NAME "writing-common-lisp")

Normalize complete v2 export data, deduplicating message and tool identifiers.
Token counts include compaction calls; only completed target skill reads count.

<a id="x-2840ANTS-AI-EVALS-2FPROVIDERS-2FOPENCODE-3ASTART-SERVER-20FUNCTION-29"></a>

##### [function](b4e9) `40ants-ai-evals/providers/opencode:start-server` RUN-DIR &KEY (EXECUTABLE (OR (UIOP/OS:GETENV "SKILL\_EVAL\_OPENCODE\_BIN") "opencode"))

Start a private loopback OpenCode v2 server and import only the `ZAI` `API` key.
The serializable descriptor references private temporary state; [`stop-server`][7ed9] erases it.

<a id="x-2840ANTS-AI-EVALS-2FPROVIDERS-2FOPENCODE-3ASTOP-SERVER-20FUNCTION-29"></a>

##### [function](12c2) `40ants-ai-evals/providers/opencode:stop-server` server

Stop the owned server and remove its private configuration, database and credentials.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FPROVIDERS-2FOPENCODE-3FVariables-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Variables

<a id="x-2840ANTS-AI-EVALS-2FPROVIDERS-2FOPENCODE-3A-2AHTTP-REQUEST-2A-20-28VARIABLE-29-29"></a>

##### [variable](58ef) `40ants-ai-evals/providers/opencode:*http-request*` nil

Optional `HTTP` test hook receiving descriptor, method, path, body, timeout and raw-p.
The hook must return an already decoded `JSON` value, or text when `RAW-P` is true.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FRECOVERY-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/RECOVERY

<a id="x-28-23A-28-2824-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FRECOVERY-22-29-20PACKAGE-29"></a>

#### [package](7188) `40ants-ai-evals/recovery`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FRECOVERY-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FRECOVERY-3ACAPTURE-20FUNCTION-29"></a>

##### [function](7119) `40ants-ai-evals/recovery:capture` workspace provider-dir vars normalized trace-path failure

Archive one native provider workspace independently of Promptfoo's deadline.
`VARS` must contain its exact `ID` and variant. Credentials and server state are never
copied: only the sample workspace and an already saved confined provider trace.

<a id="x-2840ANTS-AI-EVALS-2FRECOVERY-3ARECOVER-20FUNCTION-29"></a>

##### [function](a404) `40ants-ai-evals/recovery:recover` run-dir

Enrich local failed export rows from exact, unambiguous provider snapshots.
Original scores, success flags and Promptfoo's database are never modified.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FRUNNER-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/RUNNER

<a id="x-28-23A-28-2822-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FRUNNER-22-29-20PACKAGE-29"></a>

#### [package](e307) `40ants-ai-evals/runner`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FRUNNER-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FRUNNER-3AGRADING-VARS-20FUNCTION-29"></a>

##### [function](1e9e) `40ants-ai-evals/runner:grading-vars` vars

Apply this suite's declared check defaults, keeping historical expectations intact.

<a id="x-2840ANTS-AI-EVALS-2FRUNNER-3AREPLAY-RUN-20FUNCTION-29"></a>

##### [function](865c) `40ants-ai-evals/runner:replay-run` run-dir

Regrade archived samples offline and save a report without changing old scores.

<a id="x-2840ANTS-AI-EVALS-2FRUNNER-3ARUN-EVAL-20FUNCTION-29"></a>

##### [function](cd6a) `40ants-ai-evals/runner:run-eval` flags

Evaluate suites separately; retain a durable index for multi-suite batches.

<a id="x-2840ANTS-AI-EVALS-2FRUNNER-3AVALIDATE-OPTIONS-20FUNCTION-29"></a>

##### [function](c8ed) `40ants-ai-evals/runner:validate-options` flags

Reject invalid options before creating any run or contacting the model.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FSUITES-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/SUITES

<a id="x-28-23A-28-2822-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FSUITES-22-29-20PACKAGE-29"></a>

#### [package](3356) `40ants-ai-evals/suites`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FSUITES-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FSUITES-3ACATALOG-20FUNCTION-29"></a>

##### [function](dc67) `40ants-ai-evals/suites:catalog`

Read the project catalog, accepting old snapshots without a catalog.

<a id="x-2840ANTS-AI-EVALS-2FSUITES-3ADESCRIBE-SUITES-20FUNCTION-29"></a>

##### [function](e11c) `40ants-ai-evals/suites:describe-suites`

Describe case counts without evaluating tools or contacting a model.

<a id="x-2840ANTS-AI-EVALS-2FSUITES-3AFIND-SUITE-20FUNCTION-29"></a>

##### [function](653f) `40ants-ai-evals/suites:find-suite` &optional id

Resolve a suite, using the configured project default or the first catalog entry.

<a id="x-2840ANTS-AI-EVALS-2FSUITES-3ASELECTED-SUITES-20FUNCTION-29"></a>

##### [function](3b3c) `40ants-ai-evals/suites:selected-suites` flags

<a id="x-2840ANTS-AI-EVALS-2FSUITES-3ASUITE-PATH-20FUNCTION-29"></a>

##### [function](2951) `40ants-ai-evals/suites:suite-path` &optional id

Return the suite configuration's relative directory.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FUTIL-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/UTIL

<a id="x-28-23A-28-2820-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FUTIL-22-29-20PACKAGE-29"></a>

#### [package](2e08) `40ants-ai-evals/util`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FUTIL-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AARCHIVE-FRAMEWORK-ROOT-20FUNCTION-29"></a>

##### [function](a1b1) `40ants-ai-evals/util:archive-framework-root` run-dir

Locate framework code in either snapshot layout.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AARCHIVE-PROJECT-ROOT-20FUNCTION-29"></a>

##### [function](bb51) `40ants-ai-evals/util:archive-project-root` run-dir

Locate new split archives, retaining old combined snapshots unchanged.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AAT-20FUNCTION-29"></a>

##### [function](f272) `40ants-ai-evals/util:at` directory relative

Resolve `RELATIVE` inside `DIRECTORY`.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3ABOOL-20FUNCTION-29"></a>

##### [function](010d) `40ants-ai-evals/util:bool` value

Represent a Lisp predicate as an unambiguous `JSON` boolean.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3ACOPY-DIRECTORY-20FUNCTION-29"></a>

##### [function](d563) `40ants-ai-evals/util:copy-directory` source destination &key ignore-editor-locks

Copy a plain tree without following symbolic links.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3ADECODE-20FUNCTION-29"></a>

##### [function](7d27) `40ants-ai-evals/util:decode` input

Decode `JSON` with distinct arrays, booleans and null values.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3ADIGEST-FILE-20FUNCTION-29"></a>

##### [function](df1b) `40ants-ai-evals/util:digest-file` file

Return a file's `SHA-256` digest.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3ADIGEST-TREE-20FUNCTION-29"></a>

##### [function](ac4e) `40ants-ai-evals/util:digest-tree` directory

Hash sorted relative paths and bytes using the legacy runner's format.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AENCODE-20FUNCTION-29"></a>

##### [function](9a82) `40ants-ai-evals/util:encode` value

Encode a `JSON` value into a `UTF-8` compatible Lisp string.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AFIELD-20FUNCTION-29"></a>

##### [function](1f58) `40ants-ai-evals/util:field` object &rest keys

Read nested `JSON` object fields, returning `NIL` for missing keys.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AFRAMEWORK-ROOT-20FUNCTION-29"></a>

##### [function](ac82) `40ants-ai-evals/util:framework-root`

Return the immutable library checkout, independently of the consuming project.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AJSON-EQUAL-P-20FUNCTION-29"></a>

##### [function](6dd7) `40ants-ai-evals/util:json-equal-p` left right

Compare `JSON` values independently of object key order.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3ANOW-20FUNCTION-29"></a>

##### [function](e0b7) `40ants-ai-evals/util:now`

Return an `ISO` timestamp in `UTC`.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3APROJECT-CONFIG-20FUNCTION-29"></a>

##### [function](fb9c) `40ants-ai-evals/util:project-config`

Read trusted project settings; help and library-only commands need no config.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AREAD-JSON-20FUNCTION-29"></a>

##### [function](653b) `40ants-ai-evals/util:read-json` file

Read `JSON` from `FILE`.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AREMOVE-DIRECTORY-20FUNCTION-29"></a>

##### [function](139b) `40ants-ai-evals/util:remove-directory` directory

Remove a directory created or owned by the harness.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AROOT-20FUNCTION-29"></a>

##### [function](8867) `40ants-ai-evals/util:root`

Return the consuming project, or a bound archived project during replay.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3ARUN-COMMAND-20FUNCTION-29"></a>

##### [function](ab79) `40ants-ai-evals/util:run-command` argv &key (directory (root)) input (timeout 120) log-prefix allow-failure

Run `ARGV` without a shell; capture logs and kill timed-out subprocesses.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3ASAFE-RELATIVE-P-20FUNCTION-29"></a>

##### [function](8b00) `40ants-ai-evals/util:safe-relative-p` relative

Recognize portable fixture paths confined to a workspace.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3ASEQUENCE-LIST-20FUNCTION-29"></a>

##### [function](7ddc) `40ants-ai-evals/util:sequence-list` value

Convert a `JSON` array to a list; treat absent/null arrays as empty.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3ATEMPORARY-DIRECTORY-20FUNCTION-29"></a>

##### [function](edd2) `40ants-ai-evals/util:temporary-directory` &OPTIONAL (PREFIX "ai-evals")

Allocate a private directory under the operating system's temporary root.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3ATREE-FILES-20FUNCTION-29"></a>

##### [function](0bed) `40ants-ai-evals/util:tree-files` directory &key exclude ignore-editor-locks

Return sorted relative files; reject symlinks before following directories.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3ATRUE-P-20FUNCTION-29"></a>

##### [function](fe9b) `40ants-ai-evals/util:true-p` value

Recognize Lisp T or a decoded `JSON` true.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AUNIQUE-ID-20FUNCTION-29"></a>

##### [function](71d1) `40ants-ai-evals/util:unique-id`

Return a fresh identifier allocated by the operating system.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AWRITE-JSON-20FUNCTION-29"></a>

##### [function](c22e) `40ants-ai-evals/util:write-json` file value

Persist a `JSON` document with a trailing newline.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AWRITE-TEXT-20FUNCTION-29"></a>

##### [function](9e90) `40ants-ai-evals/util:write-text` file text

Write `UTF-8` `TEXT`, creating parent directories.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FUTIL-3FVariables-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Variables

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3A-2APROJECT-ROOT-2A-20-28VARIABLE-29-29"></a>

##### [variable](cfd8) `40ants-ai-evals/util:*project-root*` nil

Dynamically selected consumer root, distinct from the framework checkout.


[40fe]: https://github.com/40ants/ai-evals
[fdbb]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/agents.lisp#L11
[d3c0]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/agents.lisp#L2
[da45]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/agents.lisp#L20
[abae]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/agents.lisp#L29
[2768]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/agents.lisp#L49
[6d85]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/agents.lisp#L55
[2cff]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/agents.lisp#L65
[de92]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/case-resources.lisp#L113
[bd97]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/case-resources.lisp#L128
[8551]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/case-resources.lisp#L143
[e741]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/case-resources.lisp#L154
[d8b1]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/case-resources.lisp#L166
[f115]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/case-resources.lisp#L181
[eeba]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/case-resources.lisp#L19
[94f7]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/case-resources.lisp#L193
[8b9b]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/case-resources.lisp#L2
[7c2f]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/case-resources.lisp#L20
[375c]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/case-resources.lisp#L201
[aec2]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/case-resources.lisp#L240
[43d2]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/case-resources.lisp#L249
[3861]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/case-resources.lisp#L31
[1c10]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/case-resources.lisp#L56
[9af9]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/case-resources.lisp#L90
[c962]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/checks.lisp#L197
[ef88]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/checks.lisp#L2
[9540]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/checks.lisp#L209
[cd39]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/checks.lisp#L215
[dbe9]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/checks.lisp#L22
[4e70]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/checks.lisp#L221
[b6d5]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/checks.lisp#L227
[aa60]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/checks.lisp#L235
[2905]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/checks.lisp#L247
[e19d]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/checks.lisp#L271
[11d0]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/checks.lisp#L33
[d1dc]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/checks.lisp#L52
[58f1]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/checks.lisp#L62
[e652]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/cli.lisp#L140
[abaef]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/cli.lisp#L2
[23cd]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/collector.lisp#L2
[952d]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/collector.lisp#L217
[314d]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/environments.lisp#L13
[fb1a]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/environments.lisp#L2
[9375]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/environments.lisp#L25
[f28c]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/environments.lisp#L38
[e74d]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/environments.lisp#L44
[a948]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/environments.lisp#L54
[f406]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/environments.lisp#L59
[82e3]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/environments.lisp#L64
[4ba7]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/environments.lisp#L69
[8e61]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/environments.lisp#L75
[7fe7]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/grading/contracts.lisp#L14
[fdf9]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/grading/contracts.lisp#L2
[f622]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/history.lisp#L158
[8fe0]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/history.lisp#L2
[48a8]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/history.lisp#L220
[3f47]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/history.lisp#L229
[4c6b]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/history.lisp#L307
[968a]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/history.lisp#L326
[3f85]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/history.lisp#L69
[8d49]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/history.lisp#L78
[34c7]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/project.lisp#L1
[d677]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/project.lisp#L10
[12c2]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/providers/opencode.lisp#L132
[4acb]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/providers/opencode.lisp#L146
[58ef]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/providers/opencode.lisp#L19
[c29f]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/providers/opencode.lisp#L191
[9149]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/providers/opencode.lisp#L2
[935b]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/providers/opencode.lisp#L364
[b4e9]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/providers/opencode.lisp#L87
[a404]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/recovery.lisp#L153
[7119]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/recovery.lisp#L17
[7188]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/recovery.lisp#L2
[e307]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/runner.lisp#L2
[865c]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/runner.lisp#L656
[c8ed]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/runner.lisp#L66
[cd6a]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/runner.lisp#L720
[1e9e]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/runner.lisp#L96
[dc67]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/suites.lisp#L12
[3356]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/suites.lisp#L2
[653f]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/suites.lisp#L34
[2951]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/suites.lisp#L42
[3b3c]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/suites.lisp#L48
[e11c]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/suites.lisp#L54
[a1b1]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/util.lisp#L101
[f272]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/util.lisp#L109
[71d1]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/util.lisp#L115
[e0b7]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/util.lisp#L122
[edd2]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/util.lisp#L129
[139b]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/util.lisp#L139
[ab79]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/util.lisp#L147
[0bed]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/util.lisp#L183
[2e08]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/util.lisp#L2
[d563]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/util.lisp#L206
[1f58]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/util.lisp#L21
[df1b]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/util.lisp#L220
[ac4e]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/util.lisp#L234
[7ddc]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/util.lisp#L248
[6dd7]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/util.lisp#L254
[8b00]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/util.lisp#L265
[fe9b]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/util.lisp#L28
[010d]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/util.lisp#L34
[7d27]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/util.lisp#L40
[9a82]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/util.lisp#L47
[653b]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/util.lisp#L53
[9e90]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/util.lisp#L59
[c22e]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/util.lisp#L69
[cfd8]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/util.lisp#L73
[ac82]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/util.lisp#L77
[8867]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/util.lisp#L82
[fb9c]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/util.lisp#L88
[bb51]: https://github.com/40ants/ai-evals/blob/0940c5369eb40cf77b6ec94464e2cc22b301c929/src/util.lisp#L94
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
