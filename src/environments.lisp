;;;; Environment protocols; scenario implementations are trusted project extensions.
(uiop:define-package #:40ants-ai-evals/environments
  (:use #:cl)
  (:import-from #:serapeum #:dict #:->)
  (:import-from #:40ants-ai-evals/util #:field #:write-json #:at)
  (:export #:register-environment #:preflight #:prepare #:codex-config #:opencode-config
           #:finalize #:profile-name #:environment-variables #:workspace-instructions))
(in-package #:40ants-ai-evals/environments)

(defvar *environments* (dict))

(-> register-environment (string &rest t) string)
(defun register-environment (name &rest callbacks)
  "Register a trusted project's PREPARE, PREFLIGHT and evidence callbacks."
  (let ((entry (dict)))
    (loop for (key function) on callbacks by #'cddr
          do (unless (member key '(:preflight :prepare :codex-config :opencode-config
                                   :finalize :environment-variables :workspace-instructions))
               (error "Unknown environment callback: ~A" key))
             (setf (gethash (string-downcase key) entry) function))
    (setf (gethash name *environments*) entry)
    name))

(-> profile-name (t) string)
(defun profile-name (profile)
  "Normalize a declared environment identifier."
  (string-downcase (or profile "default")))

(-> invoke (t string &rest t) t)
(defun invoke (profile callback &rest arguments)
  (let* ((name (profile-name profile)) (entry (gethash name *environments*))
         (function (field entry callback)))
    (unless (or entry (equal name "default"))
      (error "Environment ~S is not registered by the project" name))
    (when function (apply function arguments))))

(-> preflight (t &key (:check-tools t)) hash-table)
(defun preflight (profile &key (check-tools t))
  "Validate project-provided prerequisites before any model call."
  (or (invoke profile "preflight" profile :check-tools check-tools)
      (dict "schemaVersion" 1 "profile" (profile-name profile) "versions" (dict))))

(-> prepare (t t) hash-table)
(defun prepare (workspace vars)
  "Prepare one isolated workspace through the registered project callback."
  (let* ((profile (field vars "environmentProfile"))
         (descriptor (or (invoke profile "prepare" workspace vars)
                         (preflight profile :check-tools nil))))
    (write-json (at workspace ".eval-fixture.json") descriptor)
    (setf (gethash "fixtureEnvironment" vars) descriptor)
    descriptor))

(-> codex-config (t) hash-table)
(defun codex-config (descriptor)
  "Return project-specific native Codex configuration."
  (or (invoke (field descriptor "profile") "codex-config" descriptor) (dict)))

(-> opencode-config (t) hash-table)
(defun opencode-config (descriptor)
  "Return project-specific native OpenCode configuration."
  (or (invoke (field descriptor "profile") "opencode-config" descriptor) (dict)))

(-> environment-variables (t &optional t) hash-table)
(defun environment-variables (descriptor &optional workspace)
  "Return environment variables for the fixture process."
  (or (invoke (field descriptor "profile") "environment-variables" descriptor workspace) (dict)))

(-> workspace-instructions (&optional t) string)
(defun workspace-instructions (&optional profile)
  "Describe the prepared runtime without exposing assertion requirements."
  (or (invoke profile "workspace-instructions")
      "Use this isolated workspace and the tools provisioned by the project."))

(-> finalize (t &key (:vars t) (:archive-directory t)) hash-table)
(defun finalize (workspace &key vars archive-directory)
  "Collect project-owned fixture evidence after success, error or timeout."
  (or (invoke (field vars "environmentProfile") "finalize" workspace
              :vars vars :archive-directory archive-directory) (dict)))
