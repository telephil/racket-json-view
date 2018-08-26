#lang racket/gui

(require mrlib/hierlist
         "json-hierlist-item-mixin.rkt")

(provide json-hierlist%)

(define json-hierlist%
  (class hierarchical-list%
    (init-field on-item-select)
    
    (define/private (new-item-node parent)
      (send parent new-item json-hierlist-item-mixin))

    (define/private (new-list-node parent path value kind)
      (define node (send parent new-list json-hierlist-item-mixin))
      (send* node
        (insert-styled-text kind (~a " " value))
        (user-data (cons value path)))
      node)

    (define/private (atom? value)
      (not (or (hash? value) (list? value))))

    (define/private (create-key-value-tree parent path key value kind)
      (if (atom? value)
          (let ((node (new-item-node parent)))
            (send* node
              (insert-styled-text kind (~a " " key))
              (insert-styled-text 'index " : ")
              (insert-value value)
              (user-data (cons key path))))
          (let ((node (new-list-node parent path key kind)))
            (create-tree value node (cons key path)))))
    
    (define/private (create-tree jsexpr parent path)
      (cond
        ((hash? jsexpr)
         (for (((key value) (in-hash jsexpr)))
              (create-key-value-tree parent path key value 'key)))
        ((list? jsexpr)
         (for (((value index) (in-indexed jsexpr)))
              (create-key-value-tree parent path index value 'index)))
        (else
         (let ((node (new-item-node parent)))
           (send* node
             (insert-value jsexpr)
             (user-data (cons jsexpr path)))))))

    (define/override (on-select item)
      (when item
        (on-item-select (reverse (send item user-data)))))

    (define/public (set-json! jsexpr)
      (define node (new-list-node this '() "object" 'index))
      (create-tree jsexpr node '("object")))
    
    (super-new [style '(no-hscroll auto-vscroll)])))

