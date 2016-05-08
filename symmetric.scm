;;;; Circle Graphs
(define (make-circle n)
  (define-memoized (circle k)
                   (make-vertex
                     (edges (circle k)
                            ((circle (modulo (1+ k) n)))
                            ((circle (modulo (-1+ k) n))))
                     k))
  (circle 0))

(vertex-edges-list (make-circle 5))
;Value: (#[edge (-- 0 1)] #[edge (-- 0 4)])
(vertex-edges-list (edge-head (cadr (vertex-edges-list (make-circle 5)))))
;Value: (#[edge (-- 4 0)] #[edge (-- 4 3)])

;;;; Complete Graphs
(define (make-complete n)
  (define-memoized (complete k)
                   (make-vertex
                     (make-edges
                       (stream-map
                         (lambda (head) (make-edge (complete k) (complete head)))
                         (stream-filter (lambda (x) (not (eq? x k)))
                                        (stream-iota n))))
                     k))
  (complete 0))

(vertex-edges-list (make-complete 5))
;Value: (#[edge (-- 0 1)] #[edge (-- 0 2)] #[edge (-- 0 3)] #[edge (-- 0 4)])
(vertex-edges-list (edge-head (caddr (vertex-edges-list (make-complete 5)))))
;Value: (#[edge (-- 3 0)] #[edge (-- 3 1)] #[edge (-- 3 2)] #[edge (-- 3 4)])

(stream-head (vertex-edges (make-complete #f)) 5)
;Value: (edges #[edge (-- 0 1)] #[edge (-- 0 2)] #[edge (-- 0 3)] #[edge (-- 0 4)])
(stream-tail (vertex-edges (make-complete #f)) 5)
;Value: (#[edge (-- 0 5)] . #[promise])

;;;; Platonic Solids
(define phi 2)
(define (list-shift-left list #!optional k)
  (let ((k (if (default-object? k) 1 k)))
    (append (list-tail list k) (list-head list k))))

(define tetrahedron (make-complete 4))

(define octahedron
  (let ()
    (define-memoized (vertex coords)
                     (make-vertex
                       (edges (vertex coords)
                         ((vertex (list-shift-left coords)))
                         ((vertex (map - (list-shift-left coords))))
                         ((vertex (list-shift-left coords 2)))
                         ((vertex (map - (list-shift-left coords 2)))))
                       coords))
    (vertex '(1 0 0))))

(define cube
  (let ()
    (define-memoized (vertex coords)
                     (let ((x (first coords))
                           (y (second coords))
                           (z (third coords)))
                       (make-vertex
                         (edges (vertex coords)
                                ((vertex (list (- x) y z)))
                                ((vertex (list x (- y) z)))
                                ((vertex (list x y (- z)))))
                         coords)))
    (vertex '(1 1 1))))

(define icosahedron
  (let ()
    (define-memoized (vertex coords)
                     (let ((x (first coords))
                           (y (second coords))
                           (z (third coords)))
                       (make-vertex
                         (edges (vertex coords)
                                ((vertex (map (lambda (q) (case (abs q) ((1) (- q)) (else q))) coords)))
                                ((vertex (map (lambda (q) (case (abs q) ((0) phi) ((1) 0) (else (sgn q)))) coords)))
                                ((vertex (map (lambda (q) (case (abs q) ((0) -1) ((1) (* phi q)) (else 0))) coords)))
                                ((vertex (map (lambda (q) (case (abs q) ((0) 1) ((1) (* phi q)) (else 0))) coords))))
                         coords)))
    (vertex '(0 1 2))))

(define dodecahedron
  (let ()
    (define-memoized (vertex coords)
                     (let ((x (first coords))
                           (y (second coords))
                           (z (third coords)))
                       (make-vertex
                         (if (eqv? 1 (abs x))
                           (edges (vertex coords)
                                  ((vertex (list 0 (/ y phi) (* z phi))))
                                  ((vertex (list (* x phi) 0 (/ z phi))))
                                  ((vertex (list (/ x phi) (* y phi) 0))))
                           (edges (vertex coords)
                                  ((vertex (map (lambda (q) (case q ((0) 1) (else (sgn q)))) coords)))
                                  ((vertex (map (lambda (q) (case q ((0) -1) (else (sgn q)))) coords)))
                                  ((vertex (map (lambda (q) (case (abs q) ((/ phi) (- q)) (else q))) coords)))))
                         coords)))
    (vertex '(1 1 1))))

(count-graph-vertices tetrahedron)
;Value: 4
(count-graph-edges tetrahedron)
;Value: 12
(count-graph-vertices octahedron)
;Value: 6
(count-graph-edges octahedron)
;Value: 24
(count-graph-vertices cube)
;Value: 8
(count-graph-edges cube)
;Value: 24
(count-graph-vertices icosahedron)
;Value: 12
(count-graph-edges icosahedron)
;Value: 48
(count-graph-vertices dodecahedron)
;Value: 20
(count-graph-edges dodecahedron)
;Value: 60