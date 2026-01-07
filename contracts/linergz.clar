
(define-constant DEFAULT-TARGET-DIFFICULTY u50000000000)
(define-constant VESTED-AMOUNT u1000000)

(define-constant ERR-NOT-OWNER (err u100))
(define-constant ERR-NOT-BENEFICIARY (err u101))
(define-constant ERR-DIFFICULTY-LOW (err u102))
(define-constant ERR-ALREADY-CLAIMED (err u103))
(define-constant ERR-PAUSED (err u104))
(define-constant ERR-DIFFICULTY-NOT-SET (err u105))
(define-constant ERR-NOT-ORACLE (err u106))
(define-constant ERR-DIFFICULTY-REGRESSION (err u107))
(define-constant ERR-BURN-HEIGHT-REGRESSION (err u108))
(define-constant ERR-UNLOCK-HEIGHT-NOT-REACHED (err u109))

(define-data-var owner principal tx-sender)
(define-data-var oracle principal tx-sender)
(define-data-var beneficiary principal tx-sender)
(define-data-var target-difficulty uint DEFAULT-TARGET-DIFFICULTY)
(define-data-var current-difficulty uint u0)
(define-data-var last-difficulty-burn-height uint u0)
(define-data-var unlock-burn-height uint u0)
(define-data-var claimed bool false)
(define-data-var paused bool false)

(define-read-only (get-current-difficulty)
    (let ((difficulty (var-get current-difficulty)))
        (if (is-eq difficulty u0)
            ERR-DIFFICULTY-NOT-SET
            (ok difficulty)
        )
    )
)

(define-read-only (get-owner)
    (var-get owner)
)

(define-read-only (get-beneficiary)
    (var-get beneficiary)
)

(define-read-only (get-oracle)
    (var-get oracle)
)

(define-read-only (get-target-difficulty)
    (var-get target-difficulty)
)

(define-read-only (get-last-difficulty-burn-height)
    (var-get last-difficulty-burn-height)
)

(define-read-only (get-unlock-burn-height)
    (var-get unlock-burn-height)
)

(define-read-only (is-claimed)
    (var-get claimed)
)

(define-read-only (is-paused)
    (var-get paused)
)

(define-public (set-beneficiary (new-beneficiary principal))
    (begin
        (asserts! (is-eq tx-sender (var-get owner)) ERR-NOT-OWNER)
        (var-set beneficiary new-beneficiary)
        (ok true)
    )
)

(define-public (set-target-difficulty (new-target uint))
    (begin
        (asserts! (is-eq tx-sender (var-get owner)) ERR-NOT-OWNER)
        (var-set target-difficulty new-target)
        (ok true)
    )
)

(define-public (set-oracle (new-oracle principal))
    (begin
        (asserts! (is-eq tx-sender (var-get owner)) ERR-NOT-OWNER)
        (var-set oracle new-oracle)
        (ok true)
    )
)

(define-public (submit-difficulty (difficulty uint) (burn-height uint))
    (begin
        (asserts! (is-eq tx-sender (var-get oracle)) ERR-NOT-ORACLE)
        (asserts! (>= difficulty (var-get current-difficulty)) ERR-DIFFICULTY-REGRESSION)
        (asserts! (>= burn-height (var-get last-difficulty-burn-height)) ERR-BURN-HEIGHT-REGRESSION)
        (var-set current-difficulty difficulty)
        (var-set last-difficulty-burn-height burn-height)
        (ok true)
    )
)

(define-public (set-unlock-burn-height (new-height uint))
    (begin
        (asserts! (is-eq tx-sender (var-get owner)) ERR-NOT-OWNER)
        (var-set unlock-burn-height new-height)
        (ok true)
    )
)

(define-public (set-paused (new-paused bool))
    (begin
        (asserts! (is-eq tx-sender (var-get owner)) ERR-NOT-OWNER)
        (var-set paused new-paused)
        (ok true)
    )
)

(define-public (transfer-ownership (new-owner principal))
    (begin
        (asserts! (is-eq tx-sender (var-get owner)) ERR-NOT-OWNER)
        (var-set owner new-owner)
        (ok true)
    )
)

(define-public (claim-vested-tokens)
    (let ((current-diff (try! (get-current-difficulty))))
        (asserts! (not (var-get paused)) ERR-PAUSED)
        (asserts! (not (var-get claimed)) ERR-ALREADY-CLAIMED)
        (asserts! (>= burn-block-height (var-get unlock-burn-height)) ERR-UNLOCK-HEIGHT-NOT-REACHED)
        (asserts! (>= current-diff (var-get target-difficulty)) ERR-DIFFICULTY-LOW)
        (asserts! (is-eq tx-sender (var-get beneficiary)) ERR-NOT-BENEFICIARY)
        (try! (as-contract (stx-transfer? VESTED-AMOUNT tx-sender (var-get beneficiary))))
        (var-set claimed true)
        (ok true)
    )
)
