(uiop:define-package #:40ants-ai-evals-tests/suite
  (:use #:cl)
  (:import-from #:rove #:run)
  (:import-from #:serapeum #:->)
  (:import-from #:40ants-ai-evals-tests/consumer-test)
  (:import-from #:40ants-ai-evals-tests/history-test)
  (:import-from #:40ants-ai-evals-tests/opencode-test)
  (:import-from #:40ants-ai-evals-tests/agents-test)
  (:export #:run-tests))
(in-package #:40ants-ai-evals-tests/suite)
(-> run-tests (t) boolean)
(defun run-tests (system)
  "Run library protocols and a separate consumer without calling a model."
  (declare (ignore system))
  (run '("40ants-ai-evals-tests/consumer-test" "40ants-ai-evals-tests/history-test"
         "40ants-ai-evals-tests/opencode-test" "40ants-ai-evals-tests/agents-test")))
