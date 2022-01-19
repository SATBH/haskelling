(load "reader_macros.lisp")

(defclass monad ()
  ((_return
     :initarg  :return
     :accessor _return
     :initform (error "not implemented"))
  (_bind
     :initarg  :bind
     :accessor _bind
     :initform (error "not implemented"))))

(defvar *list-monad*
  (make-instance 'monad
    :return #'list
    :bind (lambda (functor object)
            (apply 'append (mapcar functor object)))))

(defvar *maybe-monad*
  (make-instance 'monad
    :return #'identity
    :bind (lambda (functor object)
            (when object (funcall functor object)))))

(defvar *parser-monad*
  (make-instance 'monad
    :return $(arg -> $(s -> (list arg s)))
    :bind (lambda (functor parser)
            $(s -> (destructuring-bind (result tail) (funcall parser s)
                     (funcall (funcall functor result) tail))))))

(defun compose (&rest functions)
  (if (= (length functions) 1)
      (car functions)
      (lambda (&rest args)
        (funcall (first functions)
                 (apply (apply #'compose (rest functions))
                        args)))))

(defvar *monads* (make-hash-table))
(setf (gethash 'list-monad *monads*) *list-monad*)
(setf (gethash 'parser-monad *monads*) *parser-monad*)
(setf (gethash 'maybe-monad *monads*) *maybe-monad*)

(defmacro with-monad (monad &rest body)
  `(labels ((unit (arg)
              (funcall (_return (gethash ,monad *monads*))
                       arg))
            (bind (functor obj)
              (funcall (_bind (gethash ,monad *monads*))
                       functor
                       obj)))
     ,@body))

(defun __do__helper__no_destructuring (&rest body)
  (let ((head (car body))
        (tail (cdr body)))
      (when head
        (if (equal (car tail) '<-)
            `((bind $(,head -> ,@(apply '__do__helper__ (cdr (cdr tail))))
                    ,(cadr tail)))
            `(,head ,@(apply '__do__helper__ tail))))))

(defun __do__helper__ (&rest body)
  (let ((head (car body))
        (tail (cdr body)))
       (when head
         (if (equal (car tail) '<-)
             (let ((args (gensym)))
               `((bind (lambda (&rest ,args)
                         (destructuring-bind (,head) ,args
                             ,@(apply '__do__helper__ (cdr (cdr tail)))))
                       ,(cadr tail))))
             `(,head ,@(apply '__do__helper__ tail))))))

(defmacro -do- (&rest body)
  `(progn ,@(apply '__do__helper__ body)))

(defun lift-m2 (monad fun)
  (lambda (x y)
    (with-monad monad
      (-do-
        a <- x
        b <- y
        (unit (funcall fun a b))))))

(macroexpand '(-do-  a <- x 5))

