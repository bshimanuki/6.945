;;;; Linear algebra
(define ((v-op op) . vecs)
  (if (eq? 1 (length vecs))
    (map op (car vecs))
    (let ((u (first vecs))
          (v (second vecs)))
      (cond
        ((every list? (list u v)) (map op u v))
        ((list? u) (map (lambda (x) (op v x)) u))
        ((list? v) (map (lambda (x) (op u x)) v))
        (else (op u v))))))
(define v:+ (v-op +))
(define v:- (v-op -))
(define v:* (v-op *))
(define v:/ (v-op /))

(define (dot u v)
  (if (every list? (list u v))
    (apply + (v:* u v))
    (v:* u v)))
(define (cross u v)
  (let ((u1 (first u))
        (u2 (second u))
        (u3 (third u))
        (v1 (first v))
        (v2 (second v))
        (v3 (third v)))
    (list (- (* u2 v3) (* u3 v2))
          (- (* u3 v1) (* u1 v3))
          (- (* u1 v2) (* u2 v1)))))

(define (sqr-norm u) (apply + (map square u)))
(define norm (compose sqrt sqr-norm))
(define (normalized u) (dot (/ (norm u)) u))
(define (proj u v) (v:* (/ (dot u v) (sqr-norm u)) u))

(define ((rotate-x theta) v)
  (list (first v)
        (+ (* (cos theta) (second v)) (* (- (sin theta)) (third v)))
        (+ (* (sin theta) (second v)) (* (cos theta) (third v)))))
(define ((rotate-y theta) v)
  (list (+ (* (cos theta) (first v)) (* (sin theta) (third v)))
        (second v)
        (+ (* (- (sin theta)) (first v)) (* (cos theta) (third v)))))
(define ((rotate-z theta) v)
  (list (+ (* (cos theta) (first v)) (* (- (sin theta)) (second v)))
        (+ (* (sin theta) (first v)) (* (cos theta) (second v)))
        (third v)))

(define (random-point #!optional k n)
  (let ((k (if (default-object? k) 3 k))
        (n (if (default-object? n) 1. n)))
    (make-initialized-list k (lambda (i)
                               (* (if (eq? 0 (random 2)) -1 1)
                                  (random n))))))

;;;; Camera
(define (camera forward up #!optional scale)
  (let* ((z (v:- forward))
         (y (v:- up (proj z up)))
         (scale (if (default-object? scale)
                  (/ (norm y)
                     (norm z))
                  scale))
         (y (v:* scale (normalized y)))
         (x (cross y (normalized z))))
    (lambda (v) (list (dot x v) (dot y v)))))

(define (camera-vertex . args)
  (compose* (apply camera args) actual-coord vertex-name))
(define (camera-vertex-transform transform . args)
  (compose* (apply camera args) transform actual-coord vertex-name))

(define (camera-vertex-random #!optional scale)
  (let ((scale (if (default-object? scale) 1 scale)))
    (camera-vertex (random-point) (random-point) scale)))
(define (camera-vertex-transform-random transform #!optional scale)
  (let ((scale (if (default-object? scale) 1 scale)))
    (camera-vertex-transform transform (random-point) (random-point) scale)))

;;;; Graphics
(define (make-graphics)
  (make-graphics-device (car (enumerate-graphics-types))))

(define (draw-graph vertex proj #!optional device)
  (let ((device (if (default-object? device) (make-graphics) device)))
    ((graph-dfs (lambda (v)
                  (stream-for-each (lambda (edge)
                                     (apply graphics-draw-line
                                            (cons device (append (proj (edge-tail edge))
                                                                 (proj (edge-head edge))))))
                                   (vertex-edges-stream v))
                  0))
     vertex)))

(define (draw-3d-graph-rotate vertex rate #!optional scale device)
  (let ((device (if (default-object? device) (make-graphics) device))
        (scale (if (default-object? scale) 1 scale))
        (forward (random-point))
        (up (random-point)))
    (let iter ((t 0))
      (let ((r (rotate-y t)))
        (graphics-clear device)
        (draw-graph vertex (camera-vertex-transform r forward up scale) device)
        (sleep-current-thread 50)
        (iter (+ t rate))))))


#|
(draw-graph tetrahedron (camera-vertex '(0 3 -1) '(9 1 2) 0.5))
(draw-graph octahedron (camera-vertex '(0 0 -1) '(0 1 0)))
(draw-graph icosahedron (camera-vertex '(0 0 -1) '(0 1 0) 0.5))
(draw-graph icosahedron (camera-vertex-random 0.3))
(draw-graph dodecahedron (camera-vertex-random 0.3))
(draw-3d-graph-rotate octahedron 0.1 0.3)
(draw-3d-graph-rotate dodecahedron 0.1 0.3)
|#