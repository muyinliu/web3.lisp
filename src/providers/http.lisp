(in-package :web3)


;;; Http Provider
(defclass HTTPProvider (JSONBaseProvider)
  ((proxy
    :type (or null string)
    :initarg :proxy
    :initform nil
    :accessor proxy)))

(defmethod print-object ((provider HTTPProvider) stream)
  (print-unreadable-object (provider stream :type t :identity t)
    (format stream ":uri ~S :proxy ~S"
            (slot-value provider 'uri)
            (slot-value provider 'proxy))))

(defmethod make-request ((provider HTTPProvider) method params)
  ;; (format t "~%request by http, params:~a ~%" params)

  (let ((raw-body (construct-body provider method params)))

    (drakma:http-request (provider-uri provider)
                         :method :post
                         :content-type "application/json"
                         :content raw-body
                         :proxy (proxy provider))))

(defmethod handle-response ((provider HTTPProvider) response)
  (let ((decoded-response (destructure-response provider response)))
    ;; check for errors
    (if (response-error decoded-response)
        (let ((response-error (response-error decoded-response)))
          (error 'web3-error
                 :code (error-code response-error)
                 :message (error-message response-error)
                 :response (json:encode-json-to-string decoded-response)))
        ;; ignore the rest of the response and return the result
        (cdr (assoc :result decoded-response)))))

(defmethod handle-batch-response ((provider HTTPProvider) response)
  (let ((decoded-response-list (destructure-response provider response)))
    ;; check for errors
    (if (response-error decoded-response-list)
        (error (response-error decoded-response-list))
        ;; ignore the rest of the response and return the result
        (mapcar #'(lambda (decoded-response)
                    (cdr (assoc :result decoded-response)))
                decoded-response-list))))
