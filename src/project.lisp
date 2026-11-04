(uiop:define-package #:40ants-ai-evals/project
  (:use #:cl)
  (:import-from #:serapeum #:->)
  (:import-from #:40ants-ai-evals/util #:root #:field #:project-config)
  (:import-from #:40ants-ai-evals/checks #:load-check-systems)
  (:export #:load-extensions))
(in-package #:40ants-ai-evals/project)

(-> load-extensions () t)
(defun load-extensions ()
  "Load explicit project-owned ASDF systems before resolving environments or cases."
  (load-check-systems (field (project-config) "systems")))
