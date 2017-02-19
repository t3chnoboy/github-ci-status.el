(require 'magithub-ci)

(defvar ci-last-status nil
  "Last ci status")

(defface ci-status-failure-face '((t :inherit error))
  "Face for failure status"
  :group 'ci-status)

(defface ci-status-success-face '((t :inherit success))
  "Face for success status."
  :group 'ci-status)

(defface ci-status-pending-face '((t :inherit warning))
  "Face for pending status."
  :group 'ci-status)

(defun ci-status-face (ci-status)
  "Returns face for ci status"
  (pcase ci-status
    ('success 'ci-status-success-face)
    ('pending 'ci-status-pending-face)
    ('failure 'ci-status-failure-face)
    ('error   'ci-status-failure-face)
    (_        'bold)))

(defun ci-status-message (ci-status)
  "Returns face for ci status"
  (pcase ci-status
    ('success "✔")
    ('pending "●")
    ('failure "✖")
    ('error   "✖")
    (_        "-")))

(defun ci-status-applicable (ci-status)
  (member ci-status '(success pending error failure)))

(defun ci-status-update ()
  "Update ci-status"
  (when (and (magithub-ci-enabled-p)
             (magithub-usable-p)))
  (let* ((checks (magithub-ci-status))
         (status (if (consp checks) (plist-get (car checks) :status) checks)))
    (setq ci-last-status
          (if (ci-status-applicable status) status nil))))

(spaceline-define-segment ci-status
  "Displays current commit ci status"
  (when ci-last-status
    (let* ((status-message (ci-status-message ci-last-status))
           (status-face (ci-status-face ci-last-status)))
      (propertize
       (concat "ci:" status-message) 'face status-face))))

(spaceline-spacemacs-theme 'ci-status)

(run-with-timer 0 30 'ci-status-update)
