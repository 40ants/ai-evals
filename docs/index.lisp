(uiop:define-package #:40ants-ai-evals-docs/index
  (:use #:cl)
  (:import-from #:40ants-doc #:defsection #:defsection-copy)
  (:import-from #:40ants-doc/autodoc #:defautodoc)
  (:import-from #:docs-config #:docs-config)
  (:import-from #:40ants-ai-evals-docs/changelog #:@changelog)
  (:export #:@index #:@readme #:@changelog))
(in-package #:40ants-ai-evals-docs/index)
(defmethod docs-config ((system (eql (asdf:find-system "40ants-ai-evals-docs"))))
  (asdf:load-system "40ants-doc-theme-40ants")
  (list :theme (find-symbol "40ANTS-THEME" "40ANTS-DOC-THEME-40ANTS")))

(defsection @index (:title "40ants-ai-evals — Reusable skill evaluations"
                    :ignore-words ("40A" "AI" "API" "APM" "ASDF" "ASD" "UI" "CLI" "CL" "CI"
                                   "Codex" "Common Lisp" "Git" "GitHub" "HTTP"
                                   "JSON" "MCP" "Nix" "OpenCode" "Promptfoo"
                                   "Qlot" "Quicklisp" "README" "REPL" "Roswell"
                                   "SBCL" "SDK" "UIOP" "Serapeum" "SQL" "Unlicense" "URL"
                                   "USD" "XDG" "`SQLite`" "MIT" "VPS" "CLOS"
                                   "EFFORT" "HEAD" "HTML" "ID" "ISO" "JS" "JSONL"
                                   "PATH" "SHA-256" "SSE" "SSH" "PNG"
                                   "UTF-8" "UTC" "ZAI" "`macOS`" "Ultralisp"))
  "AI Evals (40ants-ai-evals) helps you measure whether changes to an agent skill
improve its behavior on real tasks. It runs coding agents in prepared workspaces,
checks their results and preserves the evidence needed to compare skill revisions."
  (@overview section)
  (@quickstart section)
  (40ants-ai-evals system)
  (@configuration section) (@execution section) (@extensions section) (@api section))

(defsection @overview (:title "What AI Evals adds to Promptfoo")
  "Promptfoo provides the evaluation engine, providers, repeated runs and results
viewer. It already supports [coding-agent evaluations](https://www.promptfoo.dev/docs/guides/evaluate-coding-agents/).
AI Evals adds a reusable workflow for testing skills: workspace preparation, evidence
collection, executable checks and archived inputs are connected for you. Projects
keep their own scenarios and assertions while sharing this infrastructure.

The benefit over assembling an evaluation directly in Promptfoo is less custom
integration work for each skill, with a consistent way to investigate failures
and compare changes across projects.

Main features:

- Evaluate the same scenarios with Codex and OpenCode, repeat samples and compare
  runs with and without the skill.
- Start each sample in an isolated workspace with text or binary fixtures and
  project-defined runtime services.
- Check generated programs, tool calls and file changes through extensible
  Common Lisp assertions, including partial scores and failure explanations.
- Archive skill snapshots, test inputs, tool versions, traces and artifacts;
  inspect history and compare revisions using recorded fingerprints.
- Regrade saved evidence with updated checks offline, without new model calls
  or overwriting original scores.
- Pin tools with Nix and Lisp dependencies with Qlot, and reuse the runner across
  repositories without copying its implementation.")

(defsection @quickstart (:title "Quickstart: install and run your first skill eval")
  "This walkthrough creates one skill, one fixture directory and one test case.
It uses built-in checks, so the first eval needs no custom assertion code. A complete
copy of the project files is included in examples/first-skill/.

### 1. Prepare a new project and choose your tools

A Codex account with access to the configured model is needed for the model-running
step. Run these commands in a new directory. In an existing repository, merge the
files with its configuration and retain its existing Qlot dependency declarations.

```sh
mkdir skill-eval-demo
cd skill-eval-demo
```

Create qlfile to select the Lisp distribution and AI Evals library:

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

#### Option A: Use nix-shell

Install [Nix](https://github.com/NixOS/nix) with the nix-shell command available.
The bundled toolchain currently targets Apple Silicon `macOS` (aarch64-darwin).
It provides SBCL, Roswell, Qlot, Node.js, Promptfoo and the agent clients at pinned
versions. Create shell.nix to import this environment from the same library revision:

```nix
let
  revision = \"aad8c5b2da5fb5e63eadcb8075b0682e6baee7b7\";
  engine = builtins.fetchGit {
    url = \"https://github.com/40ants/ai-evals.git\";
    rev = revision;
  };
in import (engine + \"/shell.nix\") {
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
command must print the AI Evals help. Keep this shell open for all following steps.
When returning later, enter nix-shell again.

Commit shell.nix, qlfile and the generated qlfile.lock. The commit in shell.nix pins
the runner and its toolchain; qlfile.lock fixes the Lisp distribution and library
source. The sample does not require a separate engine.lock.json. To upgrade later,
change the revision in both files, re-enter nix-shell and run qlot update.

#### Option B: Install the dependencies yourself

Install the tools using your preferred package manager or their upstream instructions:

- [SBCL](https://github.com/sbcl/sbcl) — the Common Lisp implementation.
- [Roswell](https://github.com/roswell/roswell) 26.10.117 — runs Roswell scripts.
- [Qlot](https://github.com/fukamachi/qlot) 1.8.2 — project-local Lisp dependencies.
- [Node.js](https://github.com/nodejs/node) 22.22.0 or newer, with [npm](https://github.com/npm/cli) — JavaScript runtime and package manager.
- [Promptfoo](https://github.com/promptfoo/promptfoo) 0.125.1 — evaluation engine and results viewer.
- [Codex CLI and TypeScript SDK](https://github.com/openai/codex) 0.156.1 — the @openai/codex and @openai/codex-sdk packages for Codex evaluations.
- [APM](https://github.com/microsoft/apm) 0.31.0 — Agent Package Manager; currently required by the runner's tool-version checks.
- [Git](https://github.com/git/git) — source checkouts and isolated workspaces.
- [OpenSSL](https://github.com/openssl/openssl) — native libraries used by the Lisp HTTP client.
- [OpenCode](https://github.com/anomalyco/opencode) 2.2.1 — needed when selecting the OpenCode agent.

The list covers the external tools for the first example; Qlot manages the Lisp
libraries declared in qlfile. Currently, model runs also require the toolchain
environment variables and exact-version checks configured by shell.nix. Installing
the tools alone is not yet a complete manual execution setup. The remaining command
examples use Option A.

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

### 3. Register the suite and its checks

Create evals/project.json:

```json
{
  \"schemaVersion\": 1,
  \"defaultSuite\": \"greeting-note\",
  \"suiteCatalog\": \"evals/suites.json\",
  \"snapshotPaths\": [
    \"evals/\",
    \"qlfile\",
    \"qlfile.lock\",
    \"shell.nix\"
  ]
}
```

Create evals/suites.json:

```json
[
  {
    \"id\": \"greeting-note\",
    \"skillName\": \"greeting-note\",
    \"skillPath\": \"skills/greeting-note/\",
    \"environmentProfile\": \"default\",
    \"config\": \"evals/greeting-note/promptfooconfig.json\"
  }
]
```

The skillName must match the name in the skill's front matter. The runner installs
this skill into the agent's workspace automatically. The default environment needs
no project-specific services. Paths in the catalog are relative to the project root.

Create evals/greeting-note/promptfooconfig.json:

```json
{
  \"description\": \"First greeting-note skill evaluation\",
  \"defaultTest\": {
    \"vars\": {
      \"checkSystems\": [
        {
          \"system\": \"40ants-ai-evals-common-checks\"
        }
      ],
      \"checks\": [
        {
          \"check\": \"agent/skill-read\",
          \"params\": {
            \"expected\": true
          }
        },
        {
          \"check\": \"files/text-contains\",
          \"params\": {
            \"file\": {
              \"$var\": \"outputFile\"
            },
            \"contains\": {
              \"$var\": \"expectedText\"
            }
          }
        },
        {
          \"check\": \"files/preserved\",
          \"params\": {
            \"protected\": \"KEEP.txt\",
            \"fixtures\": {
              \"$var\": \"fixtures\"
            }
          }
        },
        {
          \"check\": \"source/scope\",
          \"params\": {
            \"file\": {
              \"$var\": \"outputFile\"
            },
            \"fixtures\": {
              \"$var\": \"fixtures\"
            }
          }
        }
      ]
    }
  },
  \"evaluateOptions\": {
    \"maxConcurrency\": 1
  },
  \"tests\": \"file://cases.json\"
}
```

These checks require observable skill-read evidence, the expected greeting in the
output file, an unchanged `KEEP.txt` and no new product files outside the declared
output. The protected harness instructions are checked too. Parameter objects with
$var read values from the selected case.

### 4. Define the first test case

Create evals/greeting-note/cases.json:

```json
[
  {
    \"description\": \"smoke: greeting for Ada\",
    \"vars\": {
      \"id\": \"smoke\",
      \"group\": \"development\",
      \"task\": \"Use $greeting-note. Write a greeting note for Ada in greeting.txt. Preserve the other files.\",
      \"fixtures\": \"cases/smoke/fixtures/\",
      \"outputFile\": \"greeting.txt\",
      \"expectedText\": \"Hello, Ada!\"
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

### 5. Sign in and run one sample

Use an ignored project-local Codex credential directory:

```sh
export CODEX_HOME=\"$PWD/.evals/login/codex\"
codex -c 'cli_auth_credentials_store=\"file\"' login
codex -c 'cli_auth_credentials_store=\"file\"' login status
test -s \"$CODEX_HOME/auth.json\"
```

Complete the interactive sign-in yourself. AI Evals reads auth.json from `CODEX_HOME`
and makes it available to an isolated agent configuration. The file storage setting
is necessary because the runner imports a file rather than the operating system's
credential store. See the [official Codex authentication documentation](https://developers.openai.com/codex/auth).
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
")

(defsection @configuration (:title "Connect a consuming project")
  "The library has three independent locations: its pinned source checkout,
the consuming project with evals/project.json, and the project's pinned Qlot
distribution. Results remain in the consuming project's .evals directory.

The repository provides a pinned Nix toolchain and Roswell entry point. Enter it
with a projectRoot argument pointing to the consumer, then use qlot exec ai-evals.
Use the consumer's qlfile.lock for Lisp dependencies; no global installation is needed.

For a Roswell installation into an initialized Qlot project, run
qlot exec ros install 40ants/ai-evals, then invoke .qlot/bin/ai-evals help.
The local command does not require adding .qlot/bin to the global PATH.
For model runs, enter the pinned Nix environment to provision the external tools.

A project declares defaultSuite, suiteCatalog, systems, snapshotPaths and optionally
testSystem in evals/project.json. The suite catalog gives each skillName, skillPath,
config and environmentProfile. Relative paths resolve against the consuming project,
never the library checkout. A project flag after a command selects another root.

Suite configurations contain descriptions and defaultTest.vars with checkSystems
and checks. Cases contain description, vars, file-based assertions and fixture paths.
The library injects its Promptfoo transport and native provider settings centrally.
It does not require project copies of JavaScript adapters or engine source files.")

(defsection @execution (:title "Run, inspect and replay")
  "Commands include suites, checks, run, history, compare, replay, test and view.
Run supports suite, filter, group, repeat, agent, ablation, ref and timeout flags.
Use agent opencode, codex or all. Existing argument names and Promptfoo protocols
remain unchanged. Model calls are made only by run; replay uses archived evidence.

OpenCode defaults to a 660000 millisecond overall deadline and 630000 milliseconds
for execution. A timeout flag applies to each sample. Assertion and fixture deadlines
remain independent. Promptfoo supplies repeated execution, its SQLite store and UI;
Common Lisp owns evidence collection, grading, history compatibility and comparison.

Each new run stores harness/engine and harness/project separately, plus the selected
skill and sample artifacts. Fingerprints include both source trees and input resources.
Old combined harness snapshots are read in place without rewriting original grades.")

(defsection @extensions (:title "Project-owned checks and fixture environments")
  "Register assertions and profiles through the public checks package and declare
their ASDF systems in checkSystems. Core common checks are available by system name
40ants-ai-evals-common-checks; project-specific systems use safe project-relative ASD
paths included in snapshotPaths. File parameters resolve against the archived suite.

Trusted project systems declared in systems load before cases are validated. They
can register an environment with preflight, prepare, native provider configuration,
environment variables, workspace instructions and finalize callbacks. The built-in
default environment has no skill-specific knowledge. Project fixture services and
MCP factories stay with the tests which need them.

See evals/docs/adapter-protocol.md and evals/docs/extending-checks.md for the transport
and extension contracts. The extraction decision is recorded in
 evals/docs/decisions/0004-reusable-library.md.")

(defsection-copy @readme @index)
(defautodoc @api (:system "40ants-ai-evals"))
