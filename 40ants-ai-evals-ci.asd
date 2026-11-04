(asdf:defsystem "40ants-ai-evals-ci"
  :author "Alexander Artemenko <svetlyak.40wt@gmail.com>"
  :license "Unlicense"
  :homepage "https://github.com/40ants/ai-evals"
  :class :package-inferred-system
  :description "Provides CI settings for 40ants-ai-evals."
  :source-control (:git "https://github.com/40ants/ai-evals")
  :bug-tracker "https://github.com/40ants/ai-evals/issues"
  :pathname "src"
  :depends-on ("40ants-ci"
               "40ants-ai-evals-ci/ci"))
