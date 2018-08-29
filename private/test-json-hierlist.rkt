#lang racket/gui

(require rackunit
         json
         "json-hierlist.rkt")

(define (check-get-json name jsexpr-str)
  (define jsexpr (string->jsexpr jsexpr-str))
  (define h (new json-hierlist% [parent (new frame% [label ""])]))
  (send h set-json! jsexpr)
  (check-equal? jsexpr
                (send h get-json)
                name))

(check-get-json "single value" "42")
(check-get-json "empty list" "[]")
(check-get-json "empty hash" "{}")
(check-get-json "list of empty hash" "[{}]")
(check-get-json "list of values" "[1, 2, 3, true, null]")
(check-get-json "list of hash" "[{\"foo\": 1}, {\"foo\": 2}]")
(check-get-json "simple hash" "{\"foo\": \"bar\" }")
(check-get-json "hash" "{\"foo\": 1, \"bar\": 2}")
