(uiop:define-package #:40ants-ai-evals-ci/ci
  (:use #:cl)
  (:import-from #:serapeum #:->)
  (:import-from #:40ants-ci/jobs/job #:job)
  (:import-from #:40ants-ci/steps/action #:action)
  (:import-from #:40ants-ci/steps/sh #:sh)
  (:import-from #:40ants-ci/workflow #:defworkflow))
(in-package #:40ants-ai-evals-ci/ci)

(-> nix-job (string string &optional (or null string))
    job)
(defun nix-job (name command &optional prepare)
  ;; The runner and its offline transport tests require the pinned toolchain.
  ;; macos-15 is an Apple Silicon runner; CCL is not supported by this codebase.
  (make-instance 'job
                 :name name
                 :os "macos-15"
                 :permissions '(:contents "read")
                 :steps (append
                         (list (action "Checkout" "actions/checkout@v5")
                               (action "Install Nix" "cachix/install-nix-action@v31")
                               (sh "Install Lisp dependencies" "nix-shell --run 'qlot install'"))
                         (when prepare
                           (list (sh "Prepare job dependencies"
                                     (format nil "nix-shell --run '~A'" prepare))))
                         (list (sh name (format nil "nix-shell --run '~A'" command))))))

(defworkflow ci
  :on-push-to "master"
  :by-cron "0 10 * * 1"
  :on-pull-request t
  :jobs ((nix-job "tests" "qlot exec ai-evals test")))

(defworkflow docs
  :on-push-to "master"
  :by-cron "0 10 * * 1"
  :on-pull-request t
  :jobs ((nix-job "docs" "qlot exec ros roswell/build-docs.ros")))

(defworkflow linter
  :on-push-to "master"
  :by-cron "0 10 * * 1"
  :on-pull-request t
  :jobs ((nix-job "linter"
                 "qlot exec 40ants-linter --system 40ants-ai-evals,40ants-ai-evals-common-checks,40ants-ai-evals-docs,40ants-ai-evals-tests,40ants-ai-evals-ci"
                 "qlot exec ros -s 40ants-linter/main -q")))
