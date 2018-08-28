#lang racket/base

(provide (struct-out node-data))

(struct node-data (type name value path) #:transparent)