;; We need this structure as a workaround because, when installing from GitHub
;; with ros install 40ants/ai-evals, Roswell searches for the ASDF system ai-evals.
;; Our ASDF system is 40ants-ai-evals.asd, which does not match the repository name.
;; Issue: https://github.com/roswell/roswell/issues/614
(nil
 ((nil
   (nil
    (("asd" "40ants-ai-evals"))))))
