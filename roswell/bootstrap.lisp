;;;; Load the pinned library with the consuming project's Qlot distribution.
(require :asdf)
(let* ((engine (uiop:pathname-parent-directory-pathname
                (uiop:pathname-directory-pathname (or *load-truename* *compile-file-truename*))))
       (project (uiop:ensure-directory-pathname
                 (or (uiop:getenv "SKILL_EVAL_PROJECT_ROOT") (uiop:getcwd))))
       (dependencies (uiop:ensure-directory-pathname
                      (or (uiop:getenv "SKILL_EVAL_DEPENDENCY_ROOT") project))))
  (let ((*standard-output* *error-output*) (*trace-output* *error-output*))
    (load (merge-pathnames ".qlot/setup.lisp" dependencies) :verbose nil :print nil)
    (asdf:initialize-source-registry
     `(:source-registry (:directory ,engine) (:directory ,project)
                       :ignore-inherited-configuration))
    (asdf:load-asd (merge-pathnames "40ants-ai-evals.asd" engine))
    (asdf:load-system "40ants-ai-evals")))
