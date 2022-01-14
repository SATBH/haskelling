(set-dispatch-macro-character
  #\# #\!
  (lambda (stream char _)
    (declare (ignore char))
    (declare (ignore _))
    (let ((form (read stream)))
      (cond ((not (listp form)) '(error "Malformed input in partial application"))
            ((= (length form) 1) '(error "No initial arguments were provided"))
            (t (destructuring-bind (&rest initial-arguments) form
                 `(lambda (&rest args#)
                    (eval  (append ',initial-arguments args#)))))))))

(set-macro-character
  #\$
  (lambda (stream char)
    (declare (ignore char))
    (let ((args-body-list (read stream)))
      (if (and (listp args-body-list)
               (member '-> args-body-list))
        (let* ((pos (position '-> args-body-list))
               (args (subseq args-body-list 0 pos))
               (body (subseq args-body-list (+ 1 pos))))
          `(lambda ,args ,@body))
        `(lambda () ,args-body-list)))))

(defun test-lambda-macro ()
  (assert (equal '(lambda () 1)
                 '$1))
  (assert (equal '(lambda () (fun args))
                 '$(fun args)))
  (assert (equal '(lambda (a b c) (+ a b c))
                 '$(a b c -> (+ a b c)))))


(defun test-partial-macro ()
  (assert (equal '(lambda (&rest args#)
                    (eval (append '(or t) args#)))
                 '#!(or t)))
  (assert (equal '(lambda (&rest args#)
                    (eval (append '((lambda () nil) t) args#)))
                 '#!((lambda () nil) t)))
  (assert (equal '(error "Malformed input in partial application")
                 '#!car))
  (assert (equal '(error "No initial arguments were provided")
                 '#!(car))))

