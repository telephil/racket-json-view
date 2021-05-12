#lang racket/gui

(require breadcrumb
         "json-hierlist.rkt"
         "node-data.rkt")

(provide json-view%
         json-hierlist%
         (struct-out node-data))

(define json-view%
  (class vertical-panel%
    (super-new)
    (init-field [hier-class% json-hierlist%])

    (field [path-bar (new breadcrumb%
                          [parent this]
                          [callback (lambda (path)
                                      (send json-hierlist select-path path))])])

    (field [json-hierlist (new hier-class%
                               [parent this]
                               [on-item-select (lambda (data)
                                                 (send path-bar set-path!
                                                       (node-data-path data)))])])

    (define/public (get-json)
      (send json-hierlist get-json))
    
    (define/public (set-json! jsexpr)
      (send json-hierlist set-json! jsexpr))))
