;;;; Project-local eval orchestration, with dependencies inferred from packages.
;; Roswell probes QL:WHERE-IS-SYSTEM before QL:QUICKLOAD, so the class
;; dependency must already be discoverable while it reads this definition.
#+ros.init
(unless (find-class 'asdf::40ants-asdf-system nil)
  ;; Quicklisp must finish discovery before starting a fresh ASDF load. Sharing
  ;; Roswell's active session caches a missing system before its release is installed.
  (handler-case
      (let ((asdf/session:*asdf-session* nil))
        (uiop:symbol-call :ql :quickload "40ants-asdf-system" :silent t))
    (error (condition)
      ;; Roswell's project.lisp lookup otherwise hides this exception.
      (format *error-output* "~&Cannot prepare 40ants-ai-evals installation: ~A~%" condition)
      (error condition))))

(asdf:defsystem "40ants-ai-evals"
  :description "Reproducible skill evaluations through Promptfoo"
  :author "Alexander Artemenko"
  :license "Unlicense"
  :homepage "https://github.com/40ants/ai-evals"
  :source-control (:git "https://github.com/40ants/ai-evals")
  :bug-tracker "https://github.com/40ants/ai-evals/issues"
  :class :40ants-asdf-system
  :defsystem-depends-on ("40ants-asdf-system")
  :pathname "src"
  :depends-on ("40ants-ai-evals/cli")
  :in-order-to ((asdf:test-op (asdf:test-op "40ants-ai-evals-tests"))))
