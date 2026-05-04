========================================
NAME vid-tag.test
    Test vid-tag

SYNOPSIS
        vid-tag.test [-h] [-h pStyle]
        vid-tag.test -T list [-v] [-d]
        vid-tag.test -T all [-v] [-d]
        vid-tag.test -T fast [-v] [-d]
        vid-tag.test -T cli [-v] [-d]
        vid-tag.test -T not-cli [-v] [-d]
        vid-tag.test -T com [-v] [-d]
        vid-tag.test -T "pTest pTest..." [-v] [-d]

DESCRIPTION
    Run unit and integration tests against vid-tag and vid-tag.inc.

    The test data archive "vid-tag-test-input.zip" must exist in the current
    directory; it is unzipped during oneTimeSetUp and supplies three video
    files plus a sample "vid-tag.conf".
