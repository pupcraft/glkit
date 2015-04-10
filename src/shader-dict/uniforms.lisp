(in-package :kit.gl.shader)

(defmacro with-uniform-location ((var name) dict &body body)
  (once-only (name)
    `(with-slots (active-program) ,dict
       (with-slots (uniforms) active-program
         (let ((,var (if (symbolp ,name)
                         (gethash ,name uniforms)
                         (with-slots (id) active-program
                           (gl:get-uniform-location id ,name)))))
           ,@body)))))

(declaim (inline uniformi uniformf uniformfv uniform-matrix))
(defun uniformi (dict name x &optional y z w)
  "Set the value for uniform with name `NAME` in the
active program (set by sdk2.kit:use-program)."
  (with-uniform-location (u name) dict
    (cond
      (w (%gl:uniform-4i u x y z w))
      (z (%gl:uniform-3i u x y z))
      (y (%gl:uniform-2i u x y))
      (x (%gl:uniform-1i u x)))))

(defun uniformf (dict name x &optional y z w)
  "Set the value for uniform with name `NAME` in the
active program (set by sdk2.kit:use-program)."
  (with-uniform-location (u name) dict
    (cond
      (w (%gl:uniform-4f u x y z w))
      (z (%gl:uniform-3f u x y z))
      (y (%gl:uniform-2f u x y))
      (x (%gl:uniform-1f u x)))))

(defun uniformfv (dict name a)
  (with-uniform-location (u name) dict
    (gl:uniformfv u a)))

(defun uniform-matrix (dict name dim matrices &optional (transpose nil))
  (with-uniform-location (u name) dict
    (gl:uniform-matrix u dim matrices transpose)))

(defun uniform-matrix-1-sv (dict name matrix &optional (transpose nil))
  (declare (type kit.glm:matrix matrix))
  #+glkit-sv
  (let* ((sv (static-vectors:make-static-vector 16
                                                :element-type 'single-float
                                                :initial-contents matrix))
         (ptr (static-vectors:static-vector-pointer sv)))
    (with-uniform-location (u name) dict
      (%gl:uniform-matrix-4fv u 1 transpose ptr))
    (static-vectors:free-static-vector sv))
  #-glkit-sv
  (error "STATIC-VECTORS not supported by your implementation."))
