import { type ReactNode, useEffect } from 'react';

export function Modal({
  title,
  children,
  onClose,
  open,
  closeAriaLabel = 'Close',
}: {
  open: boolean;
  title: string;
  children: ReactNode;
  onClose: () => void;
  closeAriaLabel?: string;
}) {
  useEffect(() => {
    const h = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose();
    };
    if (open) window.addEventListener('keydown', h);
    return () => window.removeEventListener('keydown', h);
  }, [open, onClose]);

  if (!open) return null;

  return (
    <div className="modal-backdrop" role="presentation" onClick={onClose}>
      <div
        className="modal-panel"
        role="dialog"
        aria-modal="true"
        aria-labelledby="modal-title"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="modal-head">
          <h3 id="modal-title">{title}</h3>
          <button type="button" className="btn btn-ghost" onClick={onClose} aria-label={closeAriaLabel}>
            ×
          </button>
        </div>
        <div className="modal-body">{children}</div>
      </div>
    </div>
  );
}
