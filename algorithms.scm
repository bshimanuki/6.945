;;;; Adapted from gjs
(define (sort-by object property)
  (sort object (lambda (a b) (< (property a) (property b)))))
(define (shortest-path-tree source sink)
  (let ((done (make-eq-hash-table))
        (answer (make-eq-hash-table)))
    (define (done? vertex)
      (hash-table/get done vertex #f))
    (define (pending? vertex)
      (hash-table/get answer vertex #f))
    (define (distance vertex)
      (car (hash-table/get answer vertex #f)))
    (define (predecessor vertex)
      (cdr (hash-table/get answer vertex #f)))
    (define (clobber! vertex new-data)
      (hash-table/put! answer vertex new-data))
    (define (merge-distance! vertex new-distance predecessor)
      (cond ((done? vertex) 'ok)
            ((pending? vertex)
             (if (< new-distance (distance vertex))
               (clobber! vertex (cons new-distance predecessor))
               'ok))
            (else
              (clobber! vertex (cons new-distance predecessor)))))
    (define (process! vertex)
      (let ((distance (distance vertex)))
        (define (relax! edge)
          (let ((length (edge-weight edge)))
            (if (not length)
              ;; Edge not allowed
              'ok
              (merge-distance! (edge-head edge)
                               (+ distance length)
                               (edge-tail edge)))))
        (assert distance)
        (for-each relax! (stream->list (vertex-edges-stream vertex)))
        (hash-table/put! done vertex #t)))
    (define (next-vertex)
      (let ((candidates (filter (lambda (v)
                                  (not (done? v)))
                                (hash-table/key-list answer))))
        (if (null? candidates)
          #f
          (car (sort-by candidates distance)))))
    (clobber! source (cons 0 #f))
    (let loop ()
      (let ((next (next-vertex)))
        (if (and next (not (done? sink)))
          (begin (process! (next-vertex))
                 (loop)))))
    answer))
(define (shortest-path source sink)
  (hash-table/get (shortest-path-tree source sink) sink #f))
