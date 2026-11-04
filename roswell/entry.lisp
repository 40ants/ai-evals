(require :asdf)
(load (merge-pathnames "bootstrap.lisp"
        (uiop:pathname-directory-pathname (or *load-truename* *compile-file-truename*))))
(uiop:define-package #:40ants-ai-evals/roswell/ai-evals (:use #:cl))
(in-package #:40ants-ai-evals/roswell/ai-evals)
(serapeum:-> main (&rest string) t)
(defun main (&rest arguments)
  (uiop:quit (40ants-ai-evals/cli:main arguments)))
