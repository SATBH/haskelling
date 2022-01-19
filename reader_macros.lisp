(set-dispatch-macro-character
  #\# #\!
  (lambda (stream char _)
    (declare (ignore char))
    (declare (ignore _))
    (if (equal #\) (peek-char t))
      (error "Found ')' instead of the start of a list, \ make sure there is an expression after #!"))
    (let ((form (read stream)))
      (cond ((not (listp form)) '(error "Malformed input in partial application"))
            ((= (length form) 1) '(error "No initial arguments were provided"))
            (t (destructuring-bind (&rest initial-arguments) form
                 `(lambda (&rest args#)
                    (eval  (append ',initial-arguments args#)))))))))

(defun __lambda_helper__ (&rest body)
  (if (member '-> body)
      (let* ((pos (position '-> body))
             (args (subseq body 0 pos))
             (body (subseq body (+ 1 pos))))
        `(lambda ,args ,(apply '__lambda_helper__ body)))
      `(progn ,@body)))

(set-macro-character
  #\$
  (lambda (stream char)
    (declare (ignore char))
    (let ((args-body-list (read stream)))
      (if (and (listp args-body-list)
               (member '-> args-body-list))
          (apply '__lambda_helper__ args-body-list)
        `(lambda () ,args-body-list)))))

(print (apply #'__lambda_helper__ '(x -> y -> (list x y))))

(defun test-lambda-macro ()
  (assert (equal '(lambda () 1)
                 '$1))
  (assert (equal '(lambda () (fun args))
                 '$(fun args)))
  (assert (equal '(lambda (x) (lambda (y) (progn (+ x y))))
                 '$(x -> y ->  (+ x y))))
  (assert (equal '(lambda (a b c) (progn (+ a b c)))
                 '$(a b c -> (+ a b c)))))

(test-lambda-macro)
;(defun test-partial-macro ()
;  (assert (equal '(lambda (&rest args#)
;                    (eval (append '(or t) args#))
;                 '#!(or t))
;  (assert (equal '(lambda (&rest args#)
;                    (eval (append '((lambda () nil) t) args#))
;                 '#!((lambda () nil) t))
;  (assert (equal '(error "Malformed input in partial application")
;                 '#!car)
;  (assert (equal '(error "Found ')' instead of the start of a list, \
;                         make sure there is an expression after #!")
;                 '#!)
;  (assert (equal '(error "No initial arguments were provided")
;                 '#!(car)))

