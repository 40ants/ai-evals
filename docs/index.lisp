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
                    :ignore-words ("40A" "API" "APM" "ASDF" "ASD" "UI" "CLI" "CL" "CI"
                                   "Codex" "Common Lisp" "Git" "GitHub" "HTTP"
                                   "JSON" "MCP" "Nix" "OpenCode" "Promptfoo"
                                   "Qlot" "Quicklisp" "README" "REPL" "Roswell"
                                   "SBCL" "SDK" "UIOP" "Serapeum" "SQL" "Unlicense" "URL"
                                   "USD" "XDG" "`SQLite`" "MIT" "VPS" "CLOS"
                                   "EFFORT" "HEAD" "HTML" "ID" "ISO" "JS" "JSONL"
                                   "PATH" "SHA-256" "SSE" "SSH" "PNG"
                                   "UTF-8" "UTC" "ZAI" "`macOS`" "Ultralisp"))
  (40ants-ai-evals system)
  "A reusable Common Lisp evaluation runner for agent skills. Project test cases,
fixtures, assertions and environment implementations live in the consuming repository."
  (@configuration section) (@execution section) (@extensions section) (@api section))

(defsection @configuration (:title "Connect a consuming project")
  "The library has three independent locations: its pinned source checkout,
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
