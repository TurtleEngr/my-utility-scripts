# NAME

    stack-que.inc  - bash stack and queue functions
    stack-que.test - test the stack and queue functions

# SYNOPSIS

    ./stack-que.test -h - full help

    fsqNew [pName]
    fsqPush pElement [pName]
    fsqPop [pName]
        See: sqReturn
    fsqSize [pName]
        See: sqReturn
    fsqClear [pName]
    fsqExists [pName]

# DESCRIPTION

This is a simple implemention of a stack (FILO) and queue (FIFO).

To see this usage text formatted, run:

    ./stack-que.test -h

## fsqNew pType \[pName\]

This must be called before any of the other fsq functions.

if pType is "que", then push/pop will behave as a queue.
Order: First In First Out

if pType is "stack", then push/pop will behave as a stack.
Order: Last In First Out

If pName is defined, that will set the name of the que or stack.  That
way multiple queues and stacks can be used.  Default: sqList

## fsqClear \[pName\]

Empty the stack or queue.

## fsqPush pElement \[pName\]

Push pElement into queue or stack.

    sqReturn = pElement
    Return = 0

If there is no pElement

    sqReturn = ""
    Return = 1

## fsqPop \[pName\]

Pop and element from a que or stack.

    sqReturn = first element put in queue
    Return = 0

If there are no elements in the queue

    sqReturn = ""
    Return = 1

## sqSize \[pName\]

Return the number of elements in the queue or stack.

    sqReturn = number of elements
    Return = 0

# RETURN VALUE

    0 - if OK
    1 - if Error

# ERRORS

If fsqNew is not called first, then all the other functions will
return non-zero.

# EXAMPLES

      cBin=~/bin
      . $cBin/stack-que.inc

      fsqNew stack
      fsqPush one
      fsqPush two
      fsqPush three
      fsqSize
      echo $sqReturn
    3
      fsqPop
      echo $sqReturn
    three

      fsqNew que Input
      fsqPush one Input
      fsqPush two Input
      fsqPush three Input

      fsqNew que Output
      while fsqPop Input; do
          fsqPush "Processed-$sqReturn" Output
      done
      while fsqPop Output; do
          echo $sqReturn
      done
    Processed-one
    Processed-two
    Processed-three

# ENVIRONMENT

sqReturn, sqType, sqList, sq\[pName\]

# SEE ALSO

shunit2.1

# NOTES

## Initial version

This is what Chat-GPT generated with this input: "In bash, write queue
management functions. Push a string, pop a string, and list the size
of the queue."

    queue=()

    function push_string() {
      local string=$1
      queue=("${queue[@]}" "$string")
    }

    function pop_string() {
      local front=${queue[0]}
      queue=("${queue[@]:1}")
      echo $front
    }

    function list_size() {
      echo ${#queue[@]}
    }

Nice and simple, but no error handling.

## Enhancemnts

Make this ready for producion use.

    * Put results in sgReturn rather than echo. Makes testing easier.
    * Renamed functions and prefix with "fsq"
    * Rename global vars and prefix them with "sq"
    * Wrote tests. See stack-que.test
    * Modified fsqPush to be a stack or queue
    * Added error handling
    * Added ability to have more than one stack or queue
    * Added fsqClear, fsqExists

## To test

shunit2.1 is used to run the unit tests for the stack-que.inc
functions.

For this help:

    ./stack-que.test

Run tests

    ./stack-que.test all
    ./stack-que.test [testName,testName,...]

# CAVEATS

The elements to be pushed cannot contain spaces.

# HISTORY

$Revision: 1.1 $ $Date: 2023/02/15 00:19:16 $ GMT
