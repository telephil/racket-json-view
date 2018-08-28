#lang racket/gui

(require mrlib/hierlist
         "json-hierlist-item-mixin.rkt"
         "node-data.rkt")

(provide json-hierlist%)

(define json-hierlist%
  (class hierarchical-list%
    (init-field on-item-select)
    (define node-cache (make-hash))
    (define root #f)
    
    (define/private (new-item-node parent)
      (send parent new-item json-hierlist-item-mixin))

    (define/private (new-list-node parent parent-path value kind style)
      (define node (send parent new-list json-hierlist-item-mixin))
      (define path (reverse (cons value parent-path)))
      (send* node
        (insert-styled-text style (~a " " value))
        (user-data (node-data kind value #f path)))
      (hash-set! node-cache path node)
      node)

    (define/private (atom? value)
      (not (or (hash? value) (list? value))))

    (define/private (get-value-type value)
      (cond
        ((hash? value) 'hash)
        ((list? value) 'list)
        (else 'value)))

    (define/private (create-key-value-tree parent parent-path key value kind style)
      (if (atom? value)
          (let ((node (new-item-node parent))
                (path (reverse (cons key parent-path))))
            (send* node
              (insert-styled-text style (~a " " key))
              (insert-styled-text 'index " : ")
              (insert-value value)
              (user-data (node-data kind key value path)))
            (hash-set! node-cache path node))
          (let ((node (new-list-node parent parent-path key kind style))
                (path (cons key parent-path)))
            (create-tree value node path))))

    (define/private (create-tree jsexpr parent path)
      (cond
        ((hash? jsexpr)
         (for (((key value) (in-hash jsexpr)))
              (create-key-value-tree parent path key value (get-value-type value) 'key)))
        ((list? jsexpr)
         (for (((value index) (in-indexed jsexpr)))
              (create-key-value-tree parent path index value (get-value-type value) 'index)))
        (else
         (let ((node (new-item-node parent))
               (path (reverse (cons jsexpr path))))
           (send* node
             (insert-value jsexpr)
             (user-data (node-data 'value jsexpr #f path)))
           (hash-set! node-cache path node)))))

    (define/override (on-select item)
      (when item
        (on-item-select (send item user-data))))

    (define/private (get-json-helper node [skip? #f])
      (define data (send node user-data))
      (define name (node-data-name data))
      (define value (node-data-value data))
      (define type (node-data-type data))
      (case type
        ((hash)
         (for/hasheq ((item (send node get-items)))
                     (values
                      (node-data-name (send item user-data))
                      (get-json-helper item))))
        ((list)
         (for/list ((item (send node get-items)))
                   (get-json-helper item #t)))
        ((value) value)))

    (define/public (get-json)
      (unless root
        (error "no JSON loaded"))
      (get-json-helper root #t))

    (define/public (set-json! jsexpr)
      (set! root (new-list-node this '() "object" (get-value-type jsexpr) 'index))
      (create-tree jsexpr root '("object")))

    (define/public (select-path path)
      (define node (hash-ref node-cache path))
      (send this select node))
    
    (super-new [style '(no-hscroll auto-vscroll)])))

