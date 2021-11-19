# TODO

* Update bin/bash-com.inc from gitproj/git-core/gitproj-com.inc
  - First save bin/bash-com.inc to bin/bash-com-v1.inc
  - Remove positional fLog and fError functions, rename fLog2 and fError2
  - Update scripts using old bin/bash-com.inc, to include bin/bash-com-v1.inc
  - Update all other scripts using bin/bash-com.inc

* Update bin/bash-com.test from gitproj/doc/test/test-com.sh

* Update template.sh to use the updated: bin/bash-com.inc
