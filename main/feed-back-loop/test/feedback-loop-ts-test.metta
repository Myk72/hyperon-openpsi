!(register-module! ../../../../hyperon-openpsi)
!(import! &self hyperon-openpsi:main:modulator:modulator)
!(import! &self hyperon-openpsi:main:mind-agents:modulator-updater:modulator-updaters)
!(import! &self hyperon-openpsi:main:mind-agents:modulator-updater:tests:modulator-updater-test-helpers)


!(import! &self hyperon-openpsi:main:mind-agents:action-planner:action-planner-v1)
!(import! &self hyperon-openpsi:main:mind-agents:action-planner:action-planner-v2)
!(import! &self hyperon-openpsi:main:mind-agents:feeling-updater:feeling-updaters)
!(import! &self hyperon-openpsi:psi-utilities:normalization)

!(import! &self hyperon-openpsi:main:feed-back-loop:feedback-loop-ts)
!(import! &self hyperon-openpsi:main:demand:demand)
!(import! &self hyperon-openpsi:main:feed-back-loop:feed-back-helpers)
!(import! &self hyperon-openpsi:main:mind-agents:action-planner:thompson-sampling:util)
!(import! &self hyperon-openpsi:main:mind-agents:action-planner:thompson-sampling:math)

!(register-module! ../../../utilities-module)
!(import! &self utilities-module:utils)
!(import! &self hyperon-openpsi:psi-utilities:psi_utils)

!(bind! &kb (new-space))
!(bind! &demandSpace (new-space))
!(bind! &modulatorSpace (new-space))

!(insert-modulators &modulatorSpace)

; !(get-atoms &modulatorSpace)
(= (random $x $y) (
    (py-atom random.randint) $x $y
))

;; Add Demands
!(addDemand &demandSpace affiliation -10 10 5)
!(addDemand &demandSpace competence -10 10 0)
!(addDemand &demandSpace energy -10 10 -15)

; !(get-atoms &demandSpace)

;; Add Rules using TS format: (: Rule $id 
;;                              (TTV $ttv)
;;                              (STV $strength $confidence)
;;                              (Complexity $comp)
;;                              (Context $context)
;;                              (Action $action)
;;                              (Goal ($goalName $gV1 $gV2)))

;; Rule 1: Context `init` -> Action `report` -> Goal `mission_complete` (Correct for affiliation)
!(add-atom &ruleSpace (: Rule 1
                        (TTV 1) 
                        (STV 0.5 0.002)  
                        (Complexity 1)
                        (Context init)
                        (Action report) 
                        (Goal (mission_complete 1.0 1.0))))

;; Rule 3: Context `init` -> Action `email` -> Goal `mission_complete` (Alternative action)
!(add-atom &ruleSpace (: Rule 3
                        (TTV 1) 
                        (STV 0.5 0.002)  
                        (Complexity 1)
                        (Context init)
                        (Action email) 
                        (Goal (mission_complete 1.0 1.0))))

;; Rule 2: Context `init` -> Action `idle` -> Goal `low_energy` (Wrong for affiliation target)
!(add-atom &ruleSpace (: Rule 2
                        (TTV 1) 
                        (STV 0.5 0.002)  
                        (Complexity 1)
                        (Context init)
                        (Action idle) 
                        (Goal (low_energy 1.0 1.0))))

!(add-atoms &kb (get-atoms &demandSpace))

; !(get-atoms &ruleSpace)


!(println! "Running 1st loop ...")

; !(get-atoms &demandSpace)
!(psi-agent-loop-ts init &kb &ruleSpace &demandSpace &modulatorSpace)
; !(get-atoms &demandSpace)
