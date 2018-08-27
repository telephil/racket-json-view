#lang racket/gui

(require mrlib/hierlist
         "json-hierlist-item-mixin.rkt"
         "node-data.rkt")

(provide json-hierlist%)

(define json-hierlist%
  (class hierarchical-list%
    (init-field on-item-select)
    (define node-cache (make-hash))
    
    (define/private (new-item-node parent)
      (send parent new-item json-hierlist-item-mixin))

    (define/private (new-list-node parent parent-path value kind)
      (define node (send parent new-list json-hierlist-item-mixin))
      (define path (reverse (cons value parent-path)))
      (send* node
        (insert-styled-text kind (~a " " value))
        (user-data (node-data kind value path)))
      (hash-set! node-cache path node)
      node)

    (define/private (atom? value)
      (not (or (hash? value) (list? value))))

    (define/private (create-key-value-tree parent parent-path key value kind)
      (if (atom? value)
          (let ((node (new-item-node parent))
                (path (reverse (cons key parent-path))))
            (send* node
              (insert-styled-text kind (~a " " key))
              (insert-styled-text 'index " : ")
              (insert-value value)
              (user-data (node-data kind key path)))
            (hash-set! node-cache path node))
          (let ((node (new-list-node parent parent-path key kind))
                (path (cons key parent-path)))
            (create-tree value node path))))
    
    (define/private (create-tree jsexpr parent path)
      (cond
        ((hash? jsexpr)
         (for (((key value) (in-hash jsexpr)))
              (create-key-value-tree parent path key value 'key)))
        ((list? jsexpr)
         (for (((value index) (in-indexed jsexpr)))
              (create-key-value-tree parent path index value 'index)))
        (else
         (let ((node (new-item-node parent))
               (path (reverse (cons jsexpr path))))
           (send* node
             (insert-value jsexpr)
             (user-data (node-data 'value jsexpr path)))
           (hash-set! node-cache path node)))))

    (define/override (on-select item)
      (when item
        (on-item-select (send item user-data))))

    (define/public (set-json! jsexpr)
      (define node (new-list-node this '() "object" 'index))
      (create-tree jsexpr node '("object")))

    (define/public (select-path path)
      (define node (hash-ref node-cache path))
      (send this select node))
    
    (super-new [style '(no-hscroll auto-vscroll)])))

