# The Clojure impl is a deps.edn project with its own clojure.test runner.
# Use `clojure`, not `clj`: `clj` is the interactive rlwrap wrapper and prints
# an "install rlwrap / use clojure instead" notice when run non-interactively.
cd lambda-core && clojure -M:test
