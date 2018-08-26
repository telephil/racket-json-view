#lang racket/gui

(require mrlib/hierlist)

(provide json-hierlist-item-mixin)
  
(define (get-color-from-preference name)
  (define key (string->symbol
               (string-append "plt:framework-pref:color-scheme-entry:framework:syntax-color:scheme:"
                              (symbol->string name))))
  (define pref (get-preference key))
  (apply make-object (cons color%
                           (seventh (hash-ref pref 'classic)))))

(define (make-style-delta style)
  (define delta (new style-delta%))
  (send* delta
    (set-delta-foreground (get-color-from-preference style))
    (set-face (get-preference 'plt:framework-pref:framework:standard-style-list:font-name))
    (set-size-add (vector-ref
                   (get-preference 'plt:framework-pref:framework:standard-style-list:font-size) 1))
    (set-size-mult 0))
  delta)

(define json-hierlist-item-mixin
  (mixin (hierarchical-list-item<%>)
    ((interface () insert-styled-text insert-value))
    (inherit get-editor)
    (define key-delta (make-style-delta 'symbol))
    (define index-delta (make-style-delta 'comment))
    (define string-delta (make-style-delta 'string))
    (define constant-delta (make-style-delta 'constant))

    (define/private (get-style-delta style)
      (case style
        ((key) key-delta)
        ((index) index-delta)
        (else (error "invalid style" style))))

    (define/private (get-value-style-delta value)
      (cond
        ((boolean? value) constant-delta)
        ((number? value) constant-delta)
        ((string? value) string-delta)
        (else key-delta)))

    (define/public (insert-styled-text style str)
      (define ed (get-editor))
      (send* ed
        (change-style (get-style-delta style))
        (insert str)))

    (define/public (insert-value value)
      (define t (get-editor))
      (send* t
        (change-style (get-value-style-delta value))
        (insert (~v value))))

    (super-new)))
