#|
  This file is a part of cl-cuda project.
  Copyright (c) 2014 Masayuki Takagi (kamonama@gmail.com)
|#


(in-package :cl-cuda.driver-api)


;;;
;;; DEFCUFUN macro
;;;

(defmacro defcufun ((name c-name) return-type &rest arguments)
  (let ((%name (format-symbol (symbol-package name) "%~A" name))
        (argument-vars (mapcar #'car arguments)))
    (if (not *sdk-not-found*)
        `(progn
           (defun ,name ,argument-vars
             (check-cuda-error ',name (,%name ,@argument-vars)))
           (cffi:defcfun (,%name ,c-name) ,return-type ,@arguments))
        `(defun ,name ,argument-vars
           (error 'sdk-not-found-error)))))


;;;
;;; Functions
;;;

;; cuInit
(defcufun (cu-init "cuInit") cu-result
  (flags :unsigned-int))

;; cuDeviceGet
(defcufun (cu-device-get "cuDeviceGet") cu-result
  (device (:pointer cu-device))
  (ordinal :int))

;; cuDeviceGetCount
(defcufun (cu-device-get-count "cuDeviceGetCount") cu-result
  (count (:pointer :int)))

;; cuDeviceComputeCapability
(defcufun (cu-device-compute-capability "cuDeviceComputeCapability") cu-result
  (major (:pointer :int))
  (minor (:pointer :int))
  (dev cu-device))

;; cuDeviceGetName
(defcufun (cu-device-get-name "cuDeviceGetName") cu-result
  (name :string)
  (len :int)
  (dev cu-device))

;; cuCtxCreate
(defcufun (cu-ctx-create "cuCtxCreate_v2") cu-result
  (pctx (:pointer cu-context))
  (flags :unsigned-int)
  (dev cu-device))

;; cuCtxDestroy
(defcufun (cu-ctx-destroy "cuCtxDestroy_v2") cu-result
  (ctx cu-context))

;; cuCtxSynchronize
(defcufun (cu-ctx-synchronize "cuCtxSynchronize") cu-result)

;; cuMemAlloc
(defcufun (cu-mem-alloc "cuMemAlloc_v2") cu-result
  (dptr (:pointer cu-device-ptr))
  (bytesize size-t))

;; cuMemFree
(defcufun (cu-mem-free "cuMemFree_v2") cu-result
  (dptr cu-device-ptr))

;; cuMemcpyHtoD
(defcufun (cu-memcpy-host-to-device "cuMemcpyHtoD_v2") cu-result
  (dst-device cu-device-ptr)
  (src-host :pointer)
  (byte-count size-t))

;; cuMemcpyDtoH
(defcufun (cu-memcpy-device-to-host "cuMemcpyDtoH_v2") cu-result
  (dst-host :pointer)
  (src-device cu-device-ptr)
  (byte-count size-t))

;; cuModuleLoad
(defcufun (cu-module-load "cuModuleLoad") cu-result
  (module (:pointer cu-module))
  (fname :string))

;; cuModuleUnload
(defcufun (cu-module-unload "cuModuleUnload") cu-result
  (module cu-module))

;; cuModuleGetFunction
(defcufun (cu-module-get-function "cuModuleGetFunction") cu-result
  (hfunc (:pointer cu-function))
  (hmod cu-module)
  (name :string))

;; cuLaunchKernel
(defcufun (cu-launch-kernel "cuLaunchKernel") cu-result
  (f cu-function)
  (grid-dim-x :unsigned-int)
  (grid-dim-y :unsigned-int)
  (grid-dim-z :unsigned-int)
  (block-dim-x :unsigned-int)
  (block-dim-y :unsigned-int)
  (block-dim-z :unsigned-int)
  (shared-mem-bytes :unsigned-int)
  (hstream cu-stream)
  (kernel-params (:pointer :pointer))
  (extra (:pointer :pointer)))

;; cuEventCreate
(defcufun (cu-event-create "cuEventCreate") cu-result
  (phevent (:pointer cu-event))
  (flags :unsigned-int))

;; cuEventDestroy
(defcufun (cu-event-destroy "cuEventDestroy_v2") cu-result
  (h-event cu-event))

;; cuEventElapsedTime
(defcufun (cu-event-elapsed-time "cuEventElapsedTime") cu-result
  (pmilliseconds (:pointer :float))
  (hstart cu-event)
  (hend cu-event))

;; cuEventRecord
(defcufun (cu-event-record "cuEventRecord") cu-result
  (hevent cu-event)
  (hstream cu-stream))

;; cuEventSynchronize
(defcufun (cu-event-synchronize "cuEventSynchronize") cu-result
  (hevent cu-event))


;;;
;;; CHECK-CUDA-ERROR function
;;;

(defparameter +cuda-success+ 0)

(defvar *show-messages* t)

(defun check-cuda-error (name return-code)
  (unless (= return-code +cuda-success+)
    (error "~A failed with driver API error No. ~A.~%~A"
           name return-code (get-error-string return-code)))
  (when *show-messages*
    (format t "Invoking ~A succeded.~%" name)))
