#lang racket/gui

(require "private/json-view.rkt")
(provide (all-from-out "private/json-view.rkt"))

#|
(require json
         mrlib/hierlist
         "private/json-view.rkt")

(define (load-json filename)
  (with-input-from-file filename
    (lambda () (read-json))))

(define j (load-json
           ;"colors.json"
           "/Users/mehdi/Downloads/reddit-racket.json"
           ;"/Users/mehdi/src/ATTIC/scm/apricot/db2.json"
           ))

(define f (new frame% [label "JSON Viewer"] [width 600] [height 800]))
(define hl (new json-view% [parent f]))
(send hl set-json! j)
(send f show #t)
|#