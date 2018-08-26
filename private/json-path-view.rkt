#lang racket/gui

(provide json-path-view%)

(define json-path-view%
  (class editor-canvas%
    (init-field parent callback)

    (define editor (new text%))
    
    ;; Private methods
    (define/private (add-path-button label-and-path)
      (define label (car label-and-path))
      (define path  (cdr label-and-path))
      (define start (send editor last-position))
      (send editor insert label)
      (send editor set-clickback start (send editor last-position)
            (λ (t s e) (callback path))))
    
    (define/private (insert-path-separator)
      (send editor insert " ▶ "))
    
    ;; Public methods
    (define/public (set-path! path)
      (define first #t)
      (send editor erase)
      (for ([elt path])
           (if first
               (set! first #f)
               (insert-path-separator))
           (send editor insert (~a elt))))
    
    ;; New
    (super-new [parent parent]
               [editor editor]
               [style '(no-border no-focus no-vscroll no-hscroll)]
               [vertical-inset 0]
               [line-count 1]
               [stretchable-height #f])
    (send editor set-cursor (make-object cursor% 'arrow))))