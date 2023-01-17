(in-package :web3)


;;; ------------------------------------
;;; Provider
;;; ------------------------------------

;;; Base provider
(defclass BaseProvider ()
  ((uri :initarg :uri
        :accessor provider-uri)))

(defmethod print-object ((provider BaseProvider) stream)
  (print-unreadable-object (provider stream :type t :identity t)
    (format stream ":uri ~S" (slot-value provider 'uri))))

(defgeneric make-request (provider method params)
  (:documentation ""))

(defgeneric handle-response (provider response)
  (:documentation ""))

(defgeneric construct-body (provider method params)

  (:documentation ""))

(defgeneric destructure-response (provider response)
  (:documentation ""))


(defclass JSONBaseProvider (BaseProvider)
  ())

(defmethod construct-body ((provider JSONBaseProvider) method params)
  (cl-json:encode-json-to-string `(("jsonrpc" . "2.0")
                                   ("method" . ,method)
                                   ("params" . ,params)
                                   ("id" . 1))))  ;; TODO assume id 1 here, but will be moved to JSONbaseprovider and set auto

(defmethod construct-batch-body ((provider JSONBaseProvider) methods params-list)
  (cl-json:encode-json-to-string
   (mapcar #'(lambda (method params id)
               `(("jsonrpc" . "2.0")
                 ("method" . ,method)
                 ("params" . ,params)
                 ("id" . ,id)))
           methods
           params-list
           (loop for i from 0 below (length methods) collect i))))

(defmethod destructure-response ((provider JSONBaseProvider) (response string))
  (cl-json:decode-json-from-string response))

(defmethod destructure-response ((provider JSONBaseProvider) (response vector)) ;; todo unsigned-byte
  (cl-json:decode-json-from-string (flexi-streams:octets-to-string response)))
