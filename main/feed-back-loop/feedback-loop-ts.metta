;; Main loop with Thompson Sampling

(= (psi-agent-loop-ts $state $kb $ruleSpace $demandSpace)
    (let* (
        
        ($currDemand (fetchLeastSatisfiedDemand $kb))
        ($_ (println! (Current Demand: $currDemand)))
        ((demand $demandName $minVal $maxVal $demandValue) $currDemand)
        ($goalObj (goalSelector $demandName))
        ((Goal $goalName $gV1 $gV2) $goalObj)
        ($_ (println! (Selected Goal: $goalName goalObj $goalObj)))
        
        ($applicableGoalRules (matchGoal ($goalName $gV1 $gV2) $ruleSpace))
        ($_ (println! (Rules matching goal: $applicableGoalRules)))
        
        ($applicableRules (matchContexts $applicableGoalRules $state $ruleSpace))
        ($_ (println! (Rules matching context $state : $applicableRules)))

        ;; Sample a rule
        (($chosenRuleId $score) (thompsonSample $applicableRules $ruleSpace))
        ($_ (println! (Chosen Rule ID: $chosenRuleId Score: $score)))

        ;; Perform Action and Update
    )
        (if (== $chosenRuleId -1)
            (println! (No rule selected))
            (let* (
                ($action (getAction $chosenRuleId $ruleSpace))
                ($_ (println! (Executing Action: $action)))
                
                ($isSuccess (result-check $action $goalObj)) 
                ($_ (println! (Action Success: $isSuccess)))
                
                ($_ (updateRule $chosenRuleId $isSuccess $ruleSpace))
                
                ;; Update Demand if success
                ($_ (if (== $isSuccess 1)
                    (let* (
                       ($newDemValue (+ $demandValue (* (- 1 $demandValue) 0.5)))
                       ($_ (updateDemandValue $demandSpace $demandName $newDemValue))
                       ; ($_ (update-all demand $demandSpace $kb))
                    ) ()
                    )
                    ()
                ))

            ) 
             (happinessValue 0.5 sadnessValue 0.1 angerValue 0.1 fearValue 0.1 gratitudeValue 0.1) ;; please use proper modulators later
            )
        )
    )
)


(: result-check (-> Expression Expression Number))
(= (result-check $action (Goal $gName $v1 $v2))
    (if (or 
            (and (== $action found_target) (== $gName found_target))
            (or 
                (and (== $action approach) (== $gName near_target))
                (or 
                    (and (== $action interact) (== $gName task_done))
                    (or 
                        (or (and (== $action report) (== $gName mission_complete))
                            (and (== $action email) (== $gName mission_complete)) ;; New Action
                        )
                        (or 
                            (and (== $action analyze) (== $gName analyze_data))
                            (or 
                                (and (== $action upload) (== $gName upload_results))
                                (and (== $action reboot) (== $gName reset_system))
                            )
                        )
                    )
                )
            )
        )
        1
        0
    )
)

