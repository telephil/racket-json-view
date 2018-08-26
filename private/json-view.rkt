#lang racket/gui

(require "json-hierlist.rkt"
         "json-path-view.rkt")

(provide json-view%)

(define json-view%
  (class vertical-panel%
    (define path-bar null)
    (define json-hierlist null)

    (define/public (set-json! jsexpr)
      (send json-hierlist set-json! jsexpr))

    (super-new)
    (set! path-bar (new json-path-view% [parent this] [callback identity]))
    (set! json-hierlist (new json-hierlist% [parent this]
                             [on-item-select (lambda (path)
                                               (send path-bar set-path! path))]))))
