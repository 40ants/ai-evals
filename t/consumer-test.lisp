(uiop:define-package #:40ants-ai-evals-tests/consumer-test
  (:use #:cl)
  (:import-from #:serapeum #:dict)
  (:import-from #:rove #:deftest #:ok #:signals)
  (:import-from #:40ants-ai-evals/util
                #:*project-root* #:root #:framework-root #:archive-project-root
                #:archive-framework-root #:at #:field #:write-json #:write-text
                #:read-json #:temporary-directory #:remove-directory #:run-command)
  (:import-from #:40ants-ai-evals/suites #:catalog #:find-suite)
  (:import-from #:40ants-ai-evals/runner #:grading-vars #:validate-options)
  (:import-from #:40ants-ai-evals/checks #:load-check-systems)
  (:import-from #:40ants-ai-evals/grading/contracts #:grade)
  (:export #:with-consumer))
(in-package #:40ants-ai-evals-tests/consumer-test)

(defmacro with-consumer ((project) &body body)
  `(let* ((,project (temporary-directory "independent-consumer"))
          (*project-root* ,project))
     (unwind-protect
          (progn
            (write-json (at ,project "evals/project.json")
                        (dict "defaultSuite" "echo" "snapshotPaths" #("evals/")
                              "suiteCatalog" "evals/suites.json"))
            (write-json (at ,project "evals/suites.json")
                        (vector (dict "id" "echo" "skillName" "echo"
                                      "skillPath" "skills/echo/" "environmentProfile" "default"
                                      "config" "evals/echo/promptfooconfig.json")))
            (write-text (at ,project "skills/echo/SKILL.md")
                        "---
name: echo
description: Write a requested note.
---
Write the requested note.")
            (write-text (at ,project "evals/checks/probe/consumer-probe-checks.asd")
                        "(asdf:defsystem \"consumer-probe-checks\" :class :package-inferred-system :depends-on (\"consumer-probe-checks/checks\"))")
            (write-text (at ,project "evals/checks/probe/checks.lisp")
                        "(uiop:define-package #:consumer-probe-checks/checks
  (:use #:cl)
  (:import-from #:40ants-ai-evals/checks #:register-check #:context-sample #:outcome)
  (:import-from #:40ants-ai-evals/util #:field))
(in-package #:consumer-probe-checks/checks)
(defun ready (context params)
  (declare (ignore params))
  (outcome \"consumer-ready\" (equal \"ready\" (field (context-sample context) \"files\" \"note.txt\"))))
(register-check \"consumer/ready\" 'ready)")
            (write-json (at ,project "evals/echo/promptfooconfig.json")
                        (dict "description" "Independent note skill"
                              "defaultTest" (dict "vars" (dict "checkSystems"
                                (vector (dict "system" "40ants-ai-evals-common-checks")
                                        (dict "system" "consumer-probe-checks" "asd" "evals/checks/probe/consumer-probe-checks.asd"))
                                "checks" (vector (dict "check" "files/text-contains"
                                                       "params" (dict "file" "note.txt" "contains" "ready"))
                                                  (dict "check" "consumer/ready"))))))
            (write-json (at ,project "evals/echo/cases.json")
                        (vector (dict "description" "smoke"
                                      "vars" (dict "suite" "echo" "id" "smoke"
                                                   "group" "development" "task" "Write ready"))))
            ,@body)
       (remove-directory ,project))))

(deftest independent-consumer-catalog-and-checks
  (with-consumer (project)
    (ok (equal project (root)))
    (ok (not (equal (root) (framework-root))))
    (ok (= 1 (length (catalog))))
    (ok (equal "echo" (field (find-suite) "id")))
    (let ((vars (grading-vars (dict "suite" "echo"))))
      (load-check-systems (field vars "checkSystems"))
      (ok (eq 'yason:true (field (grade (dict "files" (dict "note.txt" "ready")
                                             "skillRead" 'yason:false) vars) "pass")))
      (ok (eq 'yason:false (field (grade (dict "files" (dict "note.txt" "wrong")
                                              "skillRead" 'yason:false) vars) "pass"))))
    (ok (signals (find-suite "writing-common-lisp")))))

(deftest separate-snapshots-and-standalone-entry
  (with-consumer (project)
    (let ((run (temporary-directory "consumer-snapshot")))
      (unwind-protect
           (progn
             (40ants-ai-evals/runner::snapshot run (dict))
             (ok (probe-file (at (archive-framework-root run) "src/cli.lisp")))
             (ok (probe-file (at (archive-framework-root run) "checks/common/checks.lisp")))
             (ok (probe-file (at (archive-project-root run) "evals/echo/cases.json")))
             (ok (not (probe-file (at (archive-project-root run) "src/cli.lisp"))))
             (ok (not (probe-file (at (archive-framework-root run) "evals/echo/cases.json"))))
             (multiple-value-bind (out err status)
                 (run-command
                  (list "qlot" "exec" "ros" (namestring (at (framework-root) "roswell/ai-evals.ros"))
                        "suites" "--project" (namestring project))
                  :timeout 60 :allow-failure t)
               (ok (zerop status) err)
               (ok (search "\"echo\"" out))
               (ok (not (search "writing-common-lisp" out))))
             (multiple-value-bind (out err status)
                 (run-command
                  (list "env"
                        (format nil "SKILL_EVAL_PROJECT_ROOT=~A" (archive-project-root run))
                        (format nil "SKILL_EVAL_ENGINE_ROOT=~A" (archive-framework-root run))
                        "qlot" "exec" "ros"
                        (namestring (at (archive-framework-root run) "roswell/ai-evals.ros"))
                        "checks" "--suite" "echo")
                  :directory (archive-project-root run) :timeout 60 :allow-failure t)
               (ok (zerop status) err)
               (ok (search "files/text-contains" out))
               (ok (search "consumer/ready" out))))
        (remove-directory run)))))
