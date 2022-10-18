(in-package :web3)


(define-condition web3-error (error)
  ((code
    :initarg :code
    :initform (error "code required")
    :type (or null integer)
    :reader code)
   (message
    :initarg :message
    :initform nil
    :type (or null string)
    :reader message)
   (response
    :initarg :response
    :initform nil
    :type (or null string)
    :reader response))
  (:report (lambda (error stream)
             (format stream "web3-error :code ~S :message ~S :response ~S"
                     (code error)
                     (message error)
                     (response error)))))

(defmethod print-object ((web3-error web3-error) stream)
  (print-unreadable-object (web3-error stream :type t :identity t)
    (format stream "web3-error :code ~S :message ~S :response ~S"
            (code web3-error)
            (message web3-error)
            (response web3-error))))
