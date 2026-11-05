<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-40README-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

# 40ants-ai-evals — Reusable skill evaluations

`AI` Evals (40ants-ai-evals) helps you measure whether changes to an agent skill
improve its behavior on real tasks. It runs coding agents in prepared workspaces,
checks their results and preserves the evidence needed to compare skill revisions.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-40OVERVIEW-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

## What AI Evals adds to Promptfoo

Promptfoo provides the evaluation engine, providers, repeated runs and results
viewer. It already supports [coding-agent evaluations][6e8c].
`AI` Evals adds a reusable workflow for testing skills: workspace preparation, evidence
collection, executable checks and archived inputs are connected for you. Projects
keep their own scenarios and assertions while sharing this infrastructure.

The benefit over assembling an evaluation directly in Promptfoo is less custom
integration work for each skill, with a consistent way to investigate failures
and compare changes across projects.

Main features:

* Evaluate the same scenarios with Codex and OpenCode, repeat samples and compare
  runs with and without the skill.
* Start each sample in an isolated workspace with text or binary fixtures and
  project-defined runtime services.
* Check generated programs, tool calls and file changes through extensible
  Common Lisp assertions, including partial scores and failure explanations.
* Archive skill snapshots, test inputs, tool versions, traces and artifacts;
  inspect history and compare revisions using recorded fingerprints.
* Regrade saved evidence with updated checks offline, without new model calls
  or overwriting original scores.
* Pin tools with Nix and Lisp dependencies with Qlot, and reuse the runner across
  repositories without copying its implementation.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-40QUICKSTART-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

## Quickstart: install and run your first skill eval

This walkthrough creates one skill, one fixture directory and one test case.
It uses built-in checks, so the first eval needs no custom assertion code. A complete
copy of the project files is included in examples/first-skill/.

<a id="1-prepare-a-new-project-and-choose-your-tools"></a>

### 1. Prepare a new project and choose your tools

A Codex account with access to the configured model is needed for the model-running
step. Run these commands in a new directory. In an existing repository, merge the
files with its configuration and retain its existing Qlot dependency declarations.

```sh
mkdir skill-eval-demo
cd skill-eval-demo
```
Create qlfile to select the Lisp distribution and `AI` Evals library:

```text
ql :all 2026-01-01
github 40ants-ai-evals 40ants/ai-evals :ref aad8c5b2da5fb5e63eadcb8075b0682e6baee7b7
```
Create .gitignore:

```gitignore
.qlot/
.evals/
.eval-cache/
```
<a id="option-a-use-nix-shell"></a>

#### Option A: Use nix-shell

Install [Nix][5510] with the nix-shell command available.
The bundled toolchain currently targets Apple Silicon `macOS` (aarch64-darwin).
It provides `SBCL`, Roswell, Qlot, Node.js, Promptfoo and the agent clients at pinned
versions. Create shell.nix to import this environment from the same library revision:

```nix
let
  revision = "aad8c5b2da5fb5e63eadcb8075b0682e6baee7b7";
  engine = builtins.fetchGit {
    url = "https://github.com/40ants/ai-evals.git";
    rev = revision;
  };
in import (engine + "/shell.nix") {
  projectRoot = toString ./.;
  engineRevision = revision;
}
```
Enter the environment and install the project-local Lisp dependencies:

```sh
nix-shell
qlot install
qlot exec ros -s 40ants-ai-evals -q
qlot exec ai-evals help
```
The first install can take several minutes. Nix provides the command-line tools;
Qlot installs the library and its Lisp dependencies inside the project. The final
command must print the `AI` Evals help. Keep this shell open for all following steps.
When returning later, enter nix-shell again.

Commit shell.nix, qlfile and the generated qlfile.lock. The commit in shell.nix pins
the runner and its toolchain; qlfile.lock fixes the Lisp distribution and library
source. The sample does not require a separate engine.lock.json. To upgrade later,
change the revision in both files, re-enter nix-shell and run qlot update.

<a id="option-b-install-the-dependencies-yourself"></a>

#### Option B: Install the dependencies yourself

Install the tools using your preferred package manager or their upstream instructions:

* [SBCL][0d88] — the Common Lisp implementation.
* [Roswell][795a] 26.10.117 — runs Roswell scripts.
* [Qlot][e3ea] 1.8.2 — project-local Lisp dependencies.
* [Node.js][a2c9] 22.22.0 or newer, with [npm][141b] — JavaScript runtime and package manager.
* [Promptfoo][5920] 0.125.1 — evaluation engine and results viewer.
* [Codex CLI and TypeScript SDK][1a57] 0.156.1 — the @openai/codex and @openai/codex-sdk packages for Codex evaluations.
* [APM][5b97] 0.31.0 — Agent Package Manager; currently required by the runner's tool-version checks.
* [Git][6a13] — source checkouts and isolated workspaces.
* [OpenSSL][9f98] — native libraries used by the Lisp `HTTP` client.
* [OpenCode][9bde] 2.2.1 — needed when selecting the OpenCode agent.

The list covers the external tools for the first example; Qlot manages the Lisp
libraries declared in qlfile. Currently, model runs also require the toolchain
environment variables and exact-version checks configured by shell.nix. Installing
the tools alone is not yet a complete manual execution setup. The remaining command
examples use Option A.

<a id="2-create-the-skill-and-fixtures"></a>

### 2. Create the skill and fixtures

Create the directories:

```sh
mkdir -p skills/greeting-note
mkdir -p evals/greeting-note/cases/smoke/fixtures
```
Create `skills/greeting-note/SKILL.md`:

```markdown
---
name: greeting-note
description: Write a greeting note for a named person in greeting.txt.
---

When asked for a greeting note, write `Hello, NAME!` to `greeting.txt`,
replacing NAME with the requested person's name. End the file with a newline.
Preserve all other workspace files.
```
Create evals/greeting-note/cases/smoke/fixtures/greeting.txt:

```text
TODO
```
Create `evals/greeting-note/cases/smoke/fixtures/KEEP.txt`:

```text
This file must remain unchanged.
```
Each sample starts from its own copy of these files. The original fixture directory
is preserved. Binary fixtures can be placed in the same directory.

<a id="3-register-the-suite-and-its-checks"></a>

### 3. Register the suite and its checks

Create evals/project.json:

```json
{
  "schemaVersion": 1,
  "defaultSuite": "greeting-note",
  "suiteCatalog": "evals/suites.json",
  "snapshotPaths": [
    "evals/",
    "qlfile",
    "qlfile.lock",
    "shell.nix"
  ]
}
```
Create evals/suites.json:

```json
[
  {
    "id": "greeting-note",
    "skillName": "greeting-note",
    "skillPath": "skills/greeting-note/",
    "environmentProfile": "default",
    "config": "evals/greeting-note/promptfooconfig.json"
  }
]
```
The skillName must match the name in the skill's front matter. The runner installs
this skill into the agent's workspace automatically. The default environment needs
no project-specific services. Paths in the catalog are relative to the project root.

Create evals/greeting-note/promptfooconfig.json:

```json
{
  "description": "First greeting-note skill evaluation",
  "defaultTest": {
    "vars": {
      "checkSystems": [
        {
          "system": "40ants-ai-evals-common-checks"
        }
      ],
      "checks": [
        {
          "check": "agent/skill-read",
          "params": {
            "expected": true
          }
        },
        {
          "check": "files/text-contains",
          "params": {
            "file": {
              "$var": "outputFile"
            },
            "contains": {
              "$var": "expectedText"
            }
          }
        },
        {
          "check": "files/preserved",
          "params": {
            "protected": "KEEP.txt",
            "fixtures": {
              "$var": "fixtures"
            }
          }
        },
        {
          "check": "source/scope",
          "params": {
            "file": {
              "$var": "outputFile"
            },
            "fixtures": {
              "$var": "fixtures"
            }
          }
        }
      ]
    }
  },
  "evaluateOptions": {
    "maxConcurrency": 1
  },
  "tests": "file://cases.json"
}
```
These checks require observable skill-read evidence, the expected greeting in the
output file, an unchanged `KEEP.txt` and no new product files outside the declared
output. The protected harness instructions are checked too. Parameter objects with
$var read values from the selected case.

<a id="4-define-the-first-test-case"></a>

### 4. Define the first test case

Create evals/greeting-note/cases.json:

```json
[
  {
    "description": "smoke: greeting for Ada",
    "vars": {
      "id": "smoke",
      "group": "development",
      "task": "Use $greeting-note. Write a greeting note for Ada in greeting.txt. Preserve the other files.",
      "fixtures": "cases/smoke/fixtures/",
      "outputFile": "greeting.txt",
      "expectedText": "Hello, Ada!"
    }
  }
]
```
The id identifies archived samples. The description is matched by `--filter`.
The development group runs by default; use holdout for scenarios kept out of routine
iteration. The task is sent to the agent, while expectedText is used by the grader.
Fixture paths are relative to the suite directory, evals/greeting-note/.

Check that the project and its rules are discoverable:

```sh
qlot exec ai-evals suites
qlot exec ai-evals checks --suite greeting-note
```
The first command must list greeting-note with one case. The second must include
agent/skill-read, files/text-contains, files/preserved and source/scope. These commands
make no model calls. The run command additionally validates case parameters and
fixture resources before starting the agent.

<a id="5-sign-in-and-run-one-sample"></a>

### 5. Sign in and run one sample

Use an ignored project-local Codex credential directory:

```sh
export CODEX_HOME="$PWD/.evals/login/codex"
codex -c 'cli_auth_credentials_store="file"' login
codex -c 'cli_auth_credentials_store="file"' login status
test -s "$CODEX_HOME/auth.json"
```
Complete the interactive sign-in yourself. `AI` Evals reads auth.json from `CODEX_HOME`
and makes it available to an isolated agent configuration. The file storage setting
is necessary because the runner imports a file rather than the operating system's
credential store. See the [official Codex authentication documentation][6d3a].
An agent following this guide should have the account owner complete sign-in before continuing.

The next command contacts the model and consumes the account's usage allowance:

```sh
qlot exec ai-evals run --suite greeting-note --filter smoke --agent codex --repeat 1 --label baseline
```
The pinned default Codex profile uses gpt-6-sol with medium effort. Use `--model` to
select a model available to your account and keep the setting fixed across comparisons.
One case, one agent, one repeat and no ablation produce one sample. A passing result
must contain the requested greeting and satisfy the other declared checks. A model
or skill failure is recorded as an eval result; inspect its evidence before changing
the test. Exit code 0 means the run completed with all samples passing; failures or
infrastructure problems produce a nonzero code.

<a id="6-inspect-failures-and-compare-changes"></a>

### 6. Inspect failures and compare changes

```sh
qlot exec ai-evals history --suite greeting-note
qlot exec ai-evals view
```
Open http://127.0.0.1:15500, select the run and open the result cell's details to see
the grading reason. The final run summary prints the run id.
Raw evidence is retained under .evals/runs/: manifest.json describes the inputs,
summary.json contains the aggregate result, and each samples/ subdirectory contains
sample.json, grading.json and the captured files. The generated greeting is archived
as `.evals/runs/<run-id>/samples/<sample-id>/files/greeting.txt`. In grading.json, inspect
the checks array for each check's name, checkId, pass, score and failure reason.

Stop the viewer with Ctrl-C before continuing in the same terminal. Modify only
the skill, then run the same case with the same model and settings:

```sh
qlot exec ai-evals run --suite greeting-note --filter smoke --agent codex --repeat 1 --label candidate
qlot exec ai-evals compare previous latest --suite greeting-note --agent codex
qlot exec ai-evals replay latest
```
Comparison requires two runs. It rejects incompatible inputs or environments;
review the named differences before explicitly using `--allow-mismatch`. Replay uses
archived agent evidence and inputs with the current checks, writes replay-lisp.json
beside the run and preserves its original grades. Replay makes no model calls.

After the first smoke case works, add more cases with stable ids, reserve holdout
cases and run `--group` all when ready. Use `--repeat` 3 on both baseline and candidate
to compare three attempts per case; `--ablation` adds a without-skill control and doubles
the samples. One passing smoke result alone does not demonstrate a statistical improvement.

To evaluate your own skill, change the catalog's skillName and skillPath, edit the
task and fixtures, and declare checks for the behavior you want to preserve. Custom
checks and fixture environments are described in the extension section below.

<a id="40-ants-ai-evals-asdf-system-details"></a>

## 40ANTS-AI-EVALS ASDF System Details

* Description: Reproducible skill evaluations through Promptfoo
* Licence: Unlicense
* Author: Alexander Artemenko
* Homepage: [https://github.com/40ants/ai-evals][40fe]
* Bug tracker: [https://github.com/40ants/ai-evals/issues][1c51]
* Source control: [GIT][40fe]
* Depends on: [asdf][c15d], [babel][3a1f], [cl-ppcre][49b9], [dexador][8347], [ironclad][90b9], [local-time][46a1], [quri][2103], [serapeum][c41d], [yason][aba2]

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

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-40CONTINUOUS-INTEGRATION-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

## Continuous integration

The separate package-inferred system 40ants-ai-evals-ci follows the same layout
as the other 40ants libraries: 40ants-ai-evals-ci.asd loads src/ci.lisp, which defines
the workflows through 40ants-ci. Regenerate the checked-in workflow files with:

```sh
nix-shell
qlot install
qlot exec ros -s 40ants-ai-evals-ci -q
```
Loading this system writes .github/workflows/ci.yml, docs.yml and linter.yml.
Edit the Lisp definitions and regenerate these files together. The workflows run
on pushes to master, pull requests and the weekly Monday schedule. Offline tests
use the pinned Nix environment on a macos-15 Apple Silicon runner with read-only
repository permissions. Documentation and linting use the standard build-docs and
linter jobs from 40ants-ci with dependency caching and the repository's existing
permission policy. Strict documentation warning checks remain enabled. The workflows
make no model calls. The production system does not load the `CI` system or depend
on 40ants-ci.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-40API-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

## API

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FAGENTS-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/AGENTS

<a id="x-28-23A-28-2822-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FAGENTS-22-29-20PACKAGE-29"></a>

#### [package](7be0) `40ants-ai-evals/agents`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FAGENTS-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FAGENTS-3APROFILE-FOR-20FUNCTION-29"></a>

##### [function](9db4) `40ants-ai-evals/agents:profile-for` agent flags &optional tools

Copy `AGENT`'s profile, recording only tools relevant to that agent.

<a id="x-2840ANTS-AI-EVALS-2FAGENTS-3APROVIDER-IDENTITY-20FUNCTION-29"></a>

##### [function](b9b3) `40ants-ai-evals/agents:provider-identity` label

Decode current labels and historical Codex-only labels into agent and variant.

<a id="x-2840ANTS-AI-EVALS-2FAGENTS-3APROVIDER-LABEL-20FUNCTION-29"></a>

##### [function](5279) `40ants-ai-evals/agents:provider-label` agent variant

Return an unambiguous provider label for one agent/skill combination.

<a id="x-2840ANTS-AI-EVALS-2FAGENTS-3ARENDER-TASK-20FUNCTION-29"></a>

##### [function](f183) `40ants-ai-evals/agents:render-task` TASK AGENT &OPTIONAL (SKILL-NAME "writing-common-lisp")

Render explicit references so new suites have observable skill-read evidence.
Codex expands dollar references before `SDK` tool traces, which cannot prove a read.
Automatic routing tasks remain untouched, as does the original suite contract.

<a id="x-2840ANTS-AI-EVALS-2FAGENTS-3ASELECTED-AGENTS-20FUNCTION-29"></a>

##### [function](01c4) `40ants-ai-evals/agents:selected-agents` flags

Resolve `--agent`; preserve Codex as the default for existing commands.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FAGENTS-3FVariables-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Variables

<a id="x-2840ANTS-AI-EVALS-2FAGENTS-3A-2APROFILES-2A-20-28VARIABLE-29-29"></a>

##### [variable](1112) `40ants-ai-evals/agents:*profiles*` #<hash-table :test equal :count 2 {1203185c83}>

Default agent profiles. [`profile-for`][dea8] returns a copy; callers may override one run's model.
`EFFORT` is a Codex setting and is never translated into an OpenCode reasoning option.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FCASE-RESOURCES-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/CASE-RESOURCES

<a id="x-28-23A-28-2830-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FCASE-RESOURCES-22-29-20PACKAGE-29"></a>

#### [package](372d) `40ants-ai-evals/case-resources`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FCASE-RESOURCES-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3ABASELINE-MANIFEST-20FUNCTION-29"></a>

##### [function](1ff9) `40ants-ai-evals/case-resources:baseline-manifest` VARS &OPTIONAL (SPEC (FIELD VARS "fixtures"))

Use the frozen baseline including supervisor-added files, or normalize old vars.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3ACOPY-FIXTURES-20FUNCTION-29"></a>

##### [function](603a) `40ants-ai-evals/case-resources:copy-fixtures` vars workspace

Copy inputs from the selected input tree without decoding or following links.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3AFILE-METADATA-20FUNCTION-29"></a>

##### [function](4e57) `40ants-ai-evals/case-resources:file-metadata` path

Describe regular-file bytes and executable bits without following symlinks.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3AFILE-REFERENCES-20FUNCTION-29"></a>

##### [function](4f69) `40ants-ai-evals/case-resources:file-references` vars

Read a resource set or a historical array without expanding Promptfoo cases.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3AFIXTURE-MANIFEST-20FUNCTION-29"></a>

##### [function](36e6) `40ants-ai-evals/case-resources:fixture-manifest` VARS &OPTIONAL (SPEC (FIELD VARS "fixtures"))

Read a fixture directory, or normalize a historical inline fixture object.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3AINPUT-FINGERPRINT-20FUNCTION-29"></a>

##### [function](2707) `40ants-ai-evals/case-resources:input-fingerprint` cases &key fixtures-only

Hash actual case resource bytes and modes from the selected input tree.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3AMANIFEST-EQUAL-P-20FUNCTION-29"></a>

##### [function](dceb) `40ants-ai-evals/case-resources:manifest-equal-p` expected actual

Compare complete file sets, bytes and captured executable permissions.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3AMETADATA-EQUAL-P-20FUNCTION-29"></a>

##### [function](ec50) `40ants-ai-evals/case-resources:metadata-equal-p` expected actual

Compare byte identity and permissions when that evidence is available.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3APRODUCT-PATH-P-20FUNCTION-29"></a>

##### [function](94a0) `40ants-ai-evals/case-resources:product-path-p` path

Exclude evaluation machinery from product file comparisons.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3ARESOLVE-RESOURCE-20FUNCTION-29"></a>

##### [function](72c3) `40ants-ai-evals/case-resources:resolve-resource` vars reference &key directory

Resolve a suite-relative input, rejecting symlinks in every path component.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3ARESTORE-SAMPLE-20FUNCTION-29"></a>

##### [function](608a) `40ants-ai-evals/case-resources:restore-sample` sample destination

Restore regular candidate files from verified archives, including binary inputs.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3ASAMPLE-MANIFEST-20FUNCTION-29"></a>

##### [function](14fd) `40ants-ai-evals/case-resources:sample-manifest` sample

Describe product evidence, retaining compatibility with text-only archives.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3AVALIDATE-FIXTURES-20FUNCTION-29"></a>

##### [function](f122) `40ants-ai-evals/case-resources:validate-fixtures` vars

Validate fixture inputs before any paid evaluation starts.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FCASE-RESOURCES-3FVariables-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Variables

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3A-2AINPUTS-ROOT-2A-20-28VARIABLE-29-29"></a>

##### [variable](e7fd) `40ants-ai-evals/case-resources:*inputs-root*` nil

Input tree for this operation; `NIL` uses the loaded harness.

<a id="x-2840ANTS-AI-EVALS-2FCASE-RESOURCES-3A-2ASAMPLE-DIRECTORY-2A-20-28VARIABLE-29-29"></a>

##### [variable](8ce1) `40ants-ai-evals/case-resources:*sample-directory*` nil

Trusted archive directory of the sample being graded.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FCHECKS-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/CHECKS

<a id="x-28-23A-28-2822-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FCHECKS-22-29-20PACKAGE-29"></a>

#### [package](3f6b) `40ants-ai-evals/checks`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FCHECKS-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FCHECKS-3ACACHED-20FUNCTION-29"></a>

##### [function](816f) `40ants-ai-evals/checks:cached` context key compute

Compute shared evidence once per sample, including a cached `NIL` result.

<a id="x-2840ANTS-AI-EVALS-2FCHECKS-3ACONTEXT-SAMPLE-20FUNCTION-29"></a>

##### [function](56b2) `40ants-ai-evals/checks:context-sample` context

Return immutable-by-convention sample evidence for a check.

<a id="x-2840ANTS-AI-EVALS-2FCHECKS-3ACONTEXT-VARS-20FUNCTION-29"></a>

##### [function](fe04) `40ants-ai-evals/checks:context-vars` context

Return the test variables for a check.

<a id="x-2840ANTS-AI-EVALS-2FCHECKS-3ADESCRIBE-CHECKS-20FUNCTION-29"></a>

##### [function](e73d) `40ants-ai-evals/checks:describe-checks`

Return `JSON`-compatible schemas for the checks currently registered.

<a id="x-2840ANTS-AI-EVALS-2FCHECKS-3AEXECUTE-PLAN-20FUNCTION-29"></a>

##### [function](4d31) `40ants-ai-evals/checks:execute-plan` context plan

Execute independent handlers; `NIL` skips a check, a vector emits several results.

<a id="x-2840ANTS-AI-EVALS-2FCHECKS-3ALOAD-CHECK-SYSTEMS-20FUNCTION-29"></a>

##### [function](3d06) `40ants-ai-evals/checks:load-check-systems` systems

Load trusted `ASDF` extensions from explicit project paths or Qlot dependencies.

<a id="x-2840ANTS-AI-EVALS-2FCHECKS-3AMAKE-CONTEXT-20FUNCTION-29"></a>

##### [function](db43) `40ants-ai-evals/checks:make-context` sample vars

Create a per-sample extension context with an isolated evidence cache.

<a id="x-2840ANTS-AI-EVALS-2FCHECKS-3AMERGE-VARS-20FUNCTION-29"></a>

##### [function](d79c) `40ants-ai-evals/checks:merge-vars` defaults overrides

Copy defaults then apply explicit object fields without mutating inputs.

<a id="x-2840ANTS-AI-EVALS-2FCHECKS-3AOUTCOME-20FUNCTION-29"></a>

##### [function](8655) `40ants-ai-evals/checks:outcome` NAME PASS &KEY REASON (SCORE (IF PASS
    1.0d0
    0.0d0))

Return a mandatory pass decision and a score from 0 to 1, defaulting to 0 or 1.
A passing result may award partial credit; its reason remains available.

<a id="x-2840ANTS-AI-EVALS-2FCHECKS-3AREGISTER-CHECK-20FUNCTION-29"></a>

##### [function](7c2e) `40ants-ai-evals/checks:register-check` id handler &key (parameters (dict)) (defaults (dict)) validate optional-parameters

Register `HANDLER`(context, parameters), typed parameters, defaults and optional fields.

<a id="x-2840ANTS-AI-EVALS-2FCHECKS-3AREGISTER-PROFILE-20FUNCTION-29"></a>

##### [function](138e) `40ants-ai-evals/checks:register-profile` id specifications

Register a reusable ordered plan, owned by the registering package.

<a id="x-2840ANTS-AI-EVALS-2FCHECKS-3AVALIDATE-PLAN-20FUNCTION-29"></a>

##### [function](439c) `40ants-ai-evals/checks:validate-plan` vars

Load extensions and resolve a typed plan before spending model calls.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FCLI-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/CLI

<a id="x-28-23A-28-2819-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FCLI-22-29-20PACKAGE-29"></a>

#### [package](4140) `40ants-ai-evals/cli`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FCLI-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FCLI-3AMAIN-20FUNCTION-29"></a>

##### [function](35c3) `40ants-ai-evals/cli:main` arguments

Run the `CLI`, keeping machine-readable stdout clean for protocol commands.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FCOLLECTOR-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/COLLECTOR

<a id="x-28-23A-28-2825-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FCOLLECTOR-22-29-20PACKAGE-29"></a>

#### [package](47e2) `40ants-ai-evals/collector`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FCOLLECTOR-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FCOLLECTOR-3ACOLLECT-AND-GRADE-20FUNCTION-29"></a>

##### [function](d56a) `40ants-ai-evals/collector:collect-and-grade` request

Archive provider evidence before grading, preserving agent identity and raw traces.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FENVIRONMENTS-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/ENVIRONMENTS

<a id="x-28-23A-28-2828-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FENVIRONMENTS-22-29-20PACKAGE-29"></a>

#### [package](d236) `40ants-ai-evals/environments`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FENVIRONMENTS-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FENVIRONMENTS-3ACODEX-CONFIG-20FUNCTION-29"></a>

##### [function](e495) `40ants-ai-evals/environments:codex-config` descriptor

Return project-specific native Codex configuration.

<a id="x-2840ANTS-AI-EVALS-2FENVIRONMENTS-3AENVIRONMENT-VARIABLES-20FUNCTION-29"></a>

##### [function](9aa0) `40ants-ai-evals/environments:environment-variables` descriptor &optional workspace

Return environment variables for the fixture process.

<a id="x-2840ANTS-AI-EVALS-2FENVIRONMENTS-3AFINALIZE-20FUNCTION-29"></a>

##### [function](16f0) `40ants-ai-evals/environments:finalize` workspace &key vars archive-directory

Collect project-owned fixture evidence after success, error or timeout.

<a id="x-2840ANTS-AI-EVALS-2FENVIRONMENTS-3AOPENCODE-CONFIG-20FUNCTION-29"></a>

##### [function](a7f4) `40ants-ai-evals/environments:opencode-config` descriptor

Return project-specific native OpenCode configuration.

<a id="x-2840ANTS-AI-EVALS-2FENVIRONMENTS-3APREFLIGHT-20FUNCTION-29"></a>

##### [function](8788) `40ants-ai-evals/environments:preflight` profile &key (check-tools t)

Validate project-provided prerequisites before any model call.

<a id="x-2840ANTS-AI-EVALS-2FENVIRONMENTS-3APREPARE-20FUNCTION-29"></a>

##### [function](2bb3) `40ants-ai-evals/environments:prepare` workspace vars

Prepare one isolated workspace through the registered project callback.

<a id="x-2840ANTS-AI-EVALS-2FENVIRONMENTS-3APROFILE-NAME-20FUNCTION-29"></a>

##### [function](eb2b) `40ants-ai-evals/environments:profile-name` profile

Normalize a declared environment identifier.

<a id="x-2840ANTS-AI-EVALS-2FENVIRONMENTS-3AREGISTER-ENVIRONMENT-20FUNCTION-29"></a>

##### [function](b274) `40ants-ai-evals/environments:register-environment` name &rest callbacks

Register a trusted project's [`prepare`][1496], [`preflight`][dcb9] and evidence callbacks.

<a id="x-2840ANTS-AI-EVALS-2FENVIRONMENTS-3AWORKSPACE-INSTRUCTIONS-20FUNCTION-29"></a>

##### [function](8407) `40ants-ai-evals/environments:workspace-instructions` &optional profile

Describe the prepared runtime without exposing assertion requirements.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FGRADING-2FCONTRACTS-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/GRADING/CONTRACTS

<a id="x-28-23A-28-2833-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FGRADING-2FCONTRACTS-22-29-20PACKAGE-29"></a>

#### [package](6d46) `40ants-ai-evals/grading/contracts`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FGRADING-2FCONTRACTS-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FGRADING-2FCONTRACTS-3AGRADE-20FUNCTION-29"></a>

##### [function](26b5) `40ants-ai-evals/grading/contracts:grade` output vars &key sample-directory

Run the case's registered checks; infrastructure errors propagate to the collector.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FHISTORY-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/HISTORY

<a id="x-28-23A-28-2823-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FHISTORY-22-29-20PACKAGE-29"></a>

#### [package](976b) `40ants-ai-evals/history`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FHISTORY-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FHISTORY-3ACOMPARE-RUNS-20FUNCTION-29"></a>

##### [function](d509) `40ants-ai-evals/history:compare-runs` before after &key allow-mismatch agent before-agent after-agent suite

Compare runs for `AGENT`, or select each side with `BEFORE-AGENT` and `AFTER-AGENT`.
Different agent selectors produce an agent/model comparison, not a skill regression.
`ALLOW-MISMATCH` prints fingerprint or same-agent profile differences instead of rejecting them.
Different suite identities are always rejected; `SUITE` restricts both selected runs.

<a id="x-2840ANTS-AI-EVALS-2FHISTORY-3AFIND-RUN-20FUNCTION-29"></a>

##### [function](105c) `40ants-ai-evals/history:find-run` id &rest options

Resolve `ID`s, labels and relative selectors, optionally restricted with `:SUITE`.
An optional positional history list preserves the original reader `API`. Exact `ID`s
remain selectable across suites so comparison can report a clear identity error.

<a id="x-2840ANTS-AI-EVALS-2FHISTORY-3AHISTORIES-20FUNCTION-29"></a>

##### [function](fae9) `40ants-ai-evals/history:histories` &OPTIONAL (RUNS-ROOT (AT (ROOT) ".evals/runs/"))

Read accumulated summaries in run `ID` order, including pre-migration runs.

<a id="x-2840ANTS-AI-EVALS-2FHISTORY-3AMAKE-SUMMARY-20FUNCTION-29"></a>

##### [function](06e8) `40ants-ai-evals/history:make-summary` manifest exported status &optional (signal :null)

Build a summary from either supported Promptfoo export shape.

<a id="x-2840ANTS-AI-EVALS-2FHISTORY-3APRINT-HISTORY-20FUNCTION-29"></a>

##### [function](fe24) `40ants-ai-evals/history:print-history` &key agent suite

List accumulated runs, optionally selecting `SUITE` and counting `AGENT` only.

<a id="x-2840ANTS-AI-EVALS-2FHISTORY-3APRINT-SUMMARY-20FUNCTION-29"></a>

##### [function](640f) `40ants-ai-evals/history:print-summary` summary

Print scores and failures with artifact location.

<a id="x-2840ANTS-AI-EVALS-2FHISTORY-3ASUMMARIZE-20FUNCTION-29"></a>

##### [function](e140) `40ants-ai-evals/history:summarize` run-dir manifest status

Write a summary beside the original export; leave the database untouched.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FPROJECT-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/PROJECT

<a id="x-28-23A-28-2823-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FPROJECT-22-29-20PACKAGE-29"></a>

#### [package](9e0f) `40ants-ai-evals/project`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FPROJECT-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FPROJECT-3ALOAD-EXTENSIONS-20FUNCTION-29"></a>

##### [function](1f65) `40ants-ai-evals/project:load-extensions`

Load explicit project-owned `ASDF` systems before resolving environments or cases.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FPROVIDERS-2FOPENCODE-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/PROVIDERS/OPENCODE

<a id="x-28-23A-28-2834-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FPROVIDERS-2FOPENCODE-22-29-20PACKAGE-29"></a>

#### [package](a9b4) `40ants-ai-evals/providers/opencode`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FPROVIDERS-2FOPENCODE-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FPROVIDERS-2FOPENCODE-3ACALL-AGENT-20FUNCTION-29"></a>

##### [function](edce) `40ants-ai-evals/providers/opencode:call-agent` request

Run one prompt in a fresh workspace/session; retain full and partial raw evidence.
`CONFIG` requires runDir, server and working_dir (or `VARS`.workspaces.opencode.`VARIANT`).
Timeouts interrupt execution before collecting the projected export and durable `SSE` log.

<a id="x-2840ANTS-AI-EVALS-2FPROVIDERS-2FOPENCODE-3AMODEL-REFERENCE-20FUNCTION-29"></a>

##### [function](f740) `40ants-ai-evals/providers/opencode:model-reference` model

Parse the v2 provider/model`#variant` reference without changing its model name.

<a id="x-2840ANTS-AI-EVALS-2FPROVIDERS-2FOPENCODE-3ANORMALIZE-TRANSCRIPT-20FUNCTION-29"></a>

##### [function](facb) `40ants-ai-evals/providers/opencode:normalize-transcript` TRANSCRIPT &OPTIONAL (SKILL-NAME "writing-common-lisp")

Normalize complete v2 export data, deduplicating message and tool identifiers.
Token counts include compaction calls; only completed target skill reads count.

<a id="x-2840ANTS-AI-EVALS-2FPROVIDERS-2FOPENCODE-3ASTART-SERVER-20FUNCTION-29"></a>

##### [function](aa8b) `40ants-ai-evals/providers/opencode:start-server` RUN-DIR &KEY (EXECUTABLE (OR (UIOP/OS:GETENV "SKILL\_EVAL\_OPENCODE\_BIN") "opencode"))

Start a private loopback OpenCode v2 server and import only the `ZAI` `API` key.
The serializable descriptor references private temporary state; [`stop-server`][cea9] erases it.

<a id="x-2840ANTS-AI-EVALS-2FPROVIDERS-2FOPENCODE-3ASTOP-SERVER-20FUNCTION-29"></a>

##### [function](6a31) `40ants-ai-evals/providers/opencode:stop-server` server

Stop the owned server and remove its private configuration, database and credentials.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FPROVIDERS-2FOPENCODE-3FVariables-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Variables

<a id="x-2840ANTS-AI-EVALS-2FPROVIDERS-2FOPENCODE-3A-2AHTTP-REQUEST-2A-20-28VARIABLE-29-29"></a>

##### [variable](fc19) `40ants-ai-evals/providers/opencode:*http-request*` nil

Optional `HTTP` test hook receiving descriptor, method, path, body, timeout and raw-p.
The hook must return an already decoded `JSON` value, or text when `RAW-P` is true.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FRECOVERY-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/RECOVERY

<a id="x-28-23A-28-2824-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FRECOVERY-22-29-20PACKAGE-29"></a>

#### [package](885d) `40ants-ai-evals/recovery`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FRECOVERY-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FRECOVERY-3ACAPTURE-20FUNCTION-29"></a>

##### [function](d463) `40ants-ai-evals/recovery:capture` workspace provider-dir vars normalized trace-path failure

Archive one native provider workspace independently of Promptfoo's deadline.
`VARS` must contain its exact `ID` and variant. Credentials and server state are never
copied: only the sample workspace and an already saved confined provider trace.

<a id="x-2840ANTS-AI-EVALS-2FRECOVERY-3ARECOVER-20FUNCTION-29"></a>

##### [function](1a1f) `40ants-ai-evals/recovery:recover` run-dir

Enrich local failed export rows from exact, unambiguous provider snapshots.
Original scores, success flags and Promptfoo's database are never modified.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FRUNNER-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/RUNNER

<a id="x-28-23A-28-2822-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FRUNNER-22-29-20PACKAGE-29"></a>

#### [package](65c0) `40ants-ai-evals/runner`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FRUNNER-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FRUNNER-3AGRADING-VARS-20FUNCTION-29"></a>

##### [function](f9c0) `40ants-ai-evals/runner:grading-vars` vars

Apply this suite's declared check defaults, keeping historical expectations intact.

<a id="x-2840ANTS-AI-EVALS-2FRUNNER-3AREPLAY-RUN-20FUNCTION-29"></a>

##### [function](9d59) `40ants-ai-evals/runner:replay-run` run-dir

Regrade archived samples offline and save a report without changing old scores.

<a id="x-2840ANTS-AI-EVALS-2FRUNNER-3ARUN-EVAL-20FUNCTION-29"></a>

##### [function](f7aa) `40ants-ai-evals/runner:run-eval` flags

Evaluate suites separately; retain a durable index for multi-suite batches.

<a id="x-2840ANTS-AI-EVALS-2FRUNNER-3AVALIDATE-OPTIONS-20FUNCTION-29"></a>

##### [function](95f8) `40ants-ai-evals/runner:validate-options` flags

Reject invalid options before creating any run or contacting the model.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FSUITES-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/SUITES

<a id="x-28-23A-28-2822-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FSUITES-22-29-20PACKAGE-29"></a>

#### [package](3ba2) `40ants-ai-evals/suites`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FSUITES-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FSUITES-3ACATALOG-20FUNCTION-29"></a>

##### [function](cccf) `40ants-ai-evals/suites:catalog`

Read the project catalog, accepting old snapshots without a catalog.

<a id="x-2840ANTS-AI-EVALS-2FSUITES-3ADESCRIBE-SUITES-20FUNCTION-29"></a>

##### [function](8d1c) `40ants-ai-evals/suites:describe-suites`

Describe case counts without evaluating tools or contacting a model.

<a id="x-2840ANTS-AI-EVALS-2FSUITES-3AFIND-SUITE-20FUNCTION-29"></a>

##### [function](c07d) `40ants-ai-evals/suites:find-suite` &optional id

Resolve a suite, using the configured project default or the first catalog entry.

<a id="x-2840ANTS-AI-EVALS-2FSUITES-3ASELECTED-SUITES-20FUNCTION-29"></a>

##### [function](5d3f) `40ants-ai-evals/suites:selected-suites` flags

<a id="x-2840ANTS-AI-EVALS-2FSUITES-3ASUITE-PATH-20FUNCTION-29"></a>

##### [function](f6ae) `40ants-ai-evals/suites:suite-path` &optional id

Return the suite configuration's relative directory.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-4040ANTS-AI-EVALS-2FUTIL-3FPACKAGE-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

### 40ANTS-AI-EVALS/UTIL

<a id="x-28-23A-28-2820-29-20BASE-CHAR-20-2E-20-2240ANTS-AI-EVALS-2FUTIL-22-29-20PACKAGE-29"></a>

#### [package](1a5a) `40ants-ai-evals/util`

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FUTIL-3FFunctions-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Functions

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AARCHIVE-FRAMEWORK-ROOT-20FUNCTION-29"></a>

##### [function](cf03) `40ants-ai-evals/util:archive-framework-root` run-dir

Locate framework code in either snapshot layout.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AARCHIVE-PROJECT-ROOT-20FUNCTION-29"></a>

##### [function](295b) `40ants-ai-evals/util:archive-project-root` run-dir

Locate new split archives, retaining old combined snapshots unchanged.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AAT-20FUNCTION-29"></a>

##### [function](5fc9) `40ants-ai-evals/util:at` directory relative

Resolve `RELATIVE` inside `DIRECTORY`.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3ABOOL-20FUNCTION-29"></a>

##### [function](3285) `40ants-ai-evals/util:bool` value

Represent a Lisp predicate as an unambiguous `JSON` boolean.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3ACOPY-DIRECTORY-20FUNCTION-29"></a>

##### [function](40d9) `40ants-ai-evals/util:copy-directory` source destination &key ignore-editor-locks

Copy a plain tree without following symbolic links.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3ADECODE-20FUNCTION-29"></a>

##### [function](7184) `40ants-ai-evals/util:decode` input

Decode `JSON` with distinct arrays, booleans and null values.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3ADIGEST-FILE-20FUNCTION-29"></a>

##### [function](7004) `40ants-ai-evals/util:digest-file` file

Return a file's `SHA-256` digest.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3ADIGEST-TREE-20FUNCTION-29"></a>

##### [function](3911) `40ants-ai-evals/util:digest-tree` directory

Hash sorted relative paths and bytes using the legacy runner's format.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AENCODE-20FUNCTION-29"></a>

##### [function](8afc) `40ants-ai-evals/util:encode` value

Encode a `JSON` value into a `UTF-8` compatible Lisp string.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AFIELD-20FUNCTION-29"></a>

##### [function](40d1) `40ants-ai-evals/util:field` object &rest keys

Read nested `JSON` object fields, returning `NIL` for missing keys.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AFRAMEWORK-ROOT-20FUNCTION-29"></a>

##### [function](eb97) `40ants-ai-evals/util:framework-root`

Return the immutable library checkout, independently of the consuming project.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AJSON-EQUAL-P-20FUNCTION-29"></a>

##### [function](5f13) `40ants-ai-evals/util:json-equal-p` left right

Compare `JSON` values independently of object key order.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3ANOW-20FUNCTION-29"></a>

##### [function](634e) `40ants-ai-evals/util:now`

Return an `ISO` timestamp in `UTC`.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3APROJECT-CONFIG-20FUNCTION-29"></a>

##### [function](d53e) `40ants-ai-evals/util:project-config`

Read trusted project settings; help and library-only commands need no config.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AREAD-JSON-20FUNCTION-29"></a>

##### [function](cb6a) `40ants-ai-evals/util:read-json` file

Read `JSON` from `FILE`.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AREMOVE-DIRECTORY-20FUNCTION-29"></a>

##### [function](e7b9) `40ants-ai-evals/util:remove-directory` directory

Remove a directory created or owned by the harness.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AROOT-20FUNCTION-29"></a>

##### [function](fa4b) `40ants-ai-evals/util:root`

Return the consuming project, or a bound archived project during replay.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3ARUN-COMMAND-20FUNCTION-29"></a>

##### [function](c0ae) `40ants-ai-evals/util:run-command` argv &key (directory (root)) input (timeout 120) log-prefix allow-failure

Run `ARGV` without a shell; capture logs and kill timed-out subprocesses.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3ASAFE-RELATIVE-P-20FUNCTION-29"></a>

##### [function](a687) `40ants-ai-evals/util:safe-relative-p` relative

Recognize portable fixture paths confined to a workspace.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3ASEQUENCE-LIST-20FUNCTION-29"></a>

##### [function](08b4) `40ants-ai-evals/util:sequence-list` value

Convert a `JSON` array to a list; treat absent/null arrays as empty.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3ATEMPORARY-DIRECTORY-20FUNCTION-29"></a>

##### [function](beae) `40ants-ai-evals/util:temporary-directory` &OPTIONAL (PREFIX "ai-evals")

Allocate a private directory under the operating system's temporary root.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3ATREE-FILES-20FUNCTION-29"></a>

##### [function](e6b0) `40ants-ai-evals/util:tree-files` directory &key exclude ignore-editor-locks

Return sorted relative files; reject symlinks before following directories.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3ATRUE-P-20FUNCTION-29"></a>

##### [function](1c0b) `40ants-ai-evals/util:true-p` value

Recognize Lisp T or a decoded `JSON` true.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AUNIQUE-ID-20FUNCTION-29"></a>

##### [function](b297) `40ants-ai-evals/util:unique-id`

Return a fresh identifier allocated by the operating system.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AWRITE-JSON-20FUNCTION-29"></a>

##### [function](8f7b) `40ants-ai-evals/util:write-json` file value

Persist a `JSON` document with a trailing newline.

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3AWRITE-TEXT-20FUNCTION-29"></a>

##### [function](02e2) `40ants-ai-evals/util:write-text` file text

Write `UTF-8` `TEXT`, creating parent directories.

<a id="x-2840ANTS-AI-EVALS-DOCS-2FINDEX-3A-3A-7C-4040ANTS-AI-EVALS-2FUTIL-3FVariables-SECTION-7C-2040ANTS-DOC-2FLOCATIVES-3ASECTION-29"></a>

#### Variables

<a id="x-2840ANTS-AI-EVALS-2FUTIL-3A-2APROJECT-ROOT-2A-20-28VARIABLE-29-29"></a>

##### [variable](fe1a) `40ants-ai-evals/util:*project-root*` nil

Dynamically selected consumer root, distinct from the framework checkout.


[6d3a]: https://developers.openai.com/codex/auth
[40fe]: https://github.com/40ants/ai-evals
[dea8]: https://github.com/40ants/ai-evals/#x-2840ANTS-AI-EVALS-2FAGENTS-3APROFILE-FOR-20FUNCTION-29
[dcb9]: https://github.com/40ants/ai-evals/#x-2840ANTS-AI-EVALS-2FENVIRONMENTS-3APREFLIGHT-20FUNCTION-29
[1496]: https://github.com/40ants/ai-evals/#x-2840ANTS-AI-EVALS-2FENVIRONMENTS-3APREPARE-20FUNCTION-29
[cea9]: https://github.com/40ants/ai-evals/#x-2840ANTS-AI-EVALS-2FPROVIDERS-2FOPENCODE-3ASTOP-SERVER-20FUNCTION-29
[1112]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/agents.lisp#L11
[7be0]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/agents.lisp#L2
[01c4]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/agents.lisp#L20
[9db4]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/agents.lisp#L29
[5279]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/agents.lisp#L49
[b9b3]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/agents.lisp#L55
[f183]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/agents.lisp#L65
[f122]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/case-resources.lisp#L113
[603a]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/case-resources.lisp#L128
[1ff9]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/case-resources.lisp#L143
[94a0]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/case-resources.lisp#L154
[14fd]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/case-resources.lisp#L166
[ec50]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/case-resources.lisp#L181
[e7fd]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/case-resources.lisp#L19
[dceb]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/case-resources.lisp#L193
[372d]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/case-resources.lisp#L2
[8ce1]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/case-resources.lisp#L20
[608a]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/case-resources.lisp#L201
[4f69]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/case-resources.lisp#L240
[2707]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/case-resources.lisp#L249
[72c3]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/case-resources.lisp#L31
[4e57]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/case-resources.lisp#L56
[36e6]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/case-resources.lisp#L90
[439c]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/checks.lisp#L197
[3f6b]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/checks.lisp#L2
[db43]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/checks.lisp#L209
[56b2]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/checks.lisp#L215
[d79c]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/checks.lisp#L22
[fe04]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/checks.lisp#L221
[816f]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/checks.lisp#L227
[8655]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/checks.lisp#L235
[4d31]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/checks.lisp#L247
[e73d]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/checks.lisp#L271
[7c2e]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/checks.lisp#L33
[138e]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/checks.lisp#L52
[3d06]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/checks.lisp#L62
[35c3]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/cli.lisp#L140
[4140]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/cli.lisp#L2
[47e2]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/collector.lisp#L2
[d56a]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/collector.lisp#L217
[b274]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/environments.lisp#L13
[d236]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/environments.lisp#L2
[eb2b]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/environments.lisp#L25
[8788]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/environments.lisp#L38
[2bb3]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/environments.lisp#L44
[e495]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/environments.lisp#L54
[a7f4]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/environments.lisp#L59
[9aa0]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/environments.lisp#L64
[8407]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/environments.lisp#L69
[16f0]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/environments.lisp#L75
[26b5]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/grading/contracts.lisp#L14
[6d46]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/grading/contracts.lisp#L2
[06e8]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/history.lisp#L158
[976b]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/history.lisp#L2
[e140]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/history.lisp#L220
[640f]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/history.lisp#L229
[fe24]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/history.lisp#L307
[d509]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/history.lisp#L326
[fae9]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/history.lisp#L69
[105c]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/history.lisp#L78
[9e0f]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/project.lisp#L1
[1f65]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/project.lisp#L10
[6a31]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/providers/opencode.lisp#L132
[f740]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/providers/opencode.lisp#L146
[fc19]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/providers/opencode.lisp#L19
[facb]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/providers/opencode.lisp#L191
[a9b4]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/providers/opencode.lisp#L2
[edce]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/providers/opencode.lisp#L364
[aa8b]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/providers/opencode.lisp#L87
[1a1f]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/recovery.lisp#L153
[d463]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/recovery.lisp#L17
[885d]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/recovery.lisp#L2
[65c0]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/runner.lisp#L2
[9d59]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/runner.lisp#L656
[95f8]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/runner.lisp#L66
[f7aa]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/runner.lisp#L720
[f9c0]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/runner.lisp#L96
[cccf]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/suites.lisp#L12
[3ba2]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/suites.lisp#L2
[c07d]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/suites.lisp#L34
[f6ae]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/suites.lisp#L42
[5d3f]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/suites.lisp#L48
[8d1c]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/suites.lisp#L54
[cf03]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/util.lisp#L101
[5fc9]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/util.lisp#L109
[b297]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/util.lisp#L115
[634e]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/util.lisp#L122
[beae]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/util.lisp#L129
[e7b9]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/util.lisp#L139
[c0ae]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/util.lisp#L147
[e6b0]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/util.lisp#L183
[1a5a]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/util.lisp#L2
[40d9]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/util.lisp#L206
[40d1]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/util.lisp#L21
[7004]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/util.lisp#L220
[3911]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/util.lisp#L234
[08b4]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/util.lisp#L248
[5f13]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/util.lisp#L254
[a687]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/util.lisp#L265
[1c0b]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/util.lisp#L28
[3285]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/util.lisp#L34
[7184]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/util.lisp#L40
[8afc]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/util.lisp#L47
[cb6a]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/util.lisp#L53
[02e2]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/util.lisp#L59
[8f7b]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/util.lisp#L69
[fe1a]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/util.lisp#L73
[eb97]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/util.lisp#L77
[fa4b]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/util.lisp#L82
[d53e]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/util.lisp#L88
[295b]: https://github.com/40ants/ai-evals/blob/60fb093dede43f79f14ec66b947a2fef0b5a3d92/src/util.lisp#L94
[1c51]: https://github.com/40ants/ai-evals/issues
[5510]: https://github.com/NixOS/nix
[9bde]: https://github.com/anomalyco/opencode
[e3ea]: https://github.com/fukamachi/qlot
[6a13]: https://github.com/git/git
[5b97]: https://github.com/microsoft/apm
[a2c9]: https://github.com/nodejs/node
[141b]: https://github.com/npm/cli
[1a57]: https://github.com/openai/codex
[9f98]: https://github.com/openssl/openssl
[5920]: https://github.com/promptfoo/promptfoo
[795a]: https://github.com/roswell/roswell
[0d88]: https://github.com/sbcl/sbcl
[c15d]: https://quickdocs.org/asdf
[3a1f]: https://quickdocs.org/babel
[49b9]: https://quickdocs.org/cl-ppcre
[8347]: https://quickdocs.org/dexador
[90b9]: https://quickdocs.org/ironclad
[46a1]: https://quickdocs.org/local-time
[2103]: https://quickdocs.org/quri
[c41d]: https://quickdocs.org/serapeum
[aba2]: https://quickdocs.org/yason
[6e8c]: https://www.promptfoo.dev/docs/guides/evaluate-coding-agents/

* * *
###### [generated by [40ANTS-DOC](https://40ants.com/doc/)]
