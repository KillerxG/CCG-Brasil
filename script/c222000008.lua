local s, id = GetID()

function s.initial_effect(c)
    -- [Skill Activation]
    aux.AddSkillProcedure(c, 1, false, s.flipcon, s.flipop)
end

-- Filtro para identificar as cartas do arquétipo Warbeast (0x308)
function s.warbeast_filter(c)
    return c:IsSetCard(0x308) or c:IsSetCard(0x313)
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
    -- Checa se a chain está vazia e está na Main Phase
    if not aux.CanActivateSkill(tp) then return false end
    
    local hand = Duel.GetFieldGroup(tp, LOCATION_HAND, 0)
    -- "min. 1 card in your hand"
    if #hand == 0 then return false end
    
    -- "...and you do not have a "Warbeast" card in your hand, field, GY or banishment"
    if Duel.IsExistingMatchingCard(s.warbeast_filter, tp, LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED, 0, 1, nil) then
        return false
    end
    
    return true
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1<<32))
    Duel.Hint(HINT_CARD, tp, id)
    
    local synchros_ids = {777001900, 777001900, 777001870, 777001870}
    
    local main_deck_ids = {
        777001840, 777001840, 777001860, 777001860, 777001890,
        777001890, 777001890, 777001920, 777001920, 777001920,
        777001880, 777001880, 777001880, 777001960, 777001960,
        777001960, 777001950, 777001950, 777001950, 777001980
    }

    local hand = Duel.GetFieldGroup(tp, LOCATION_HAND, 0)
    
    -- "Send to the GY all cards from your hand..."
    if Duel.SendtoGrave(hand, REASON_EFFECT) > 0 then
        
        -- "...add 4 "Warbeast" Synchro monsters from outside of the Duel to your Extra Deck"
        for _, syn_id in ipairs(synchros_ids) do
            local token = Duel.CreateToken(tp, syn_id)
            Duel.SendtoDeck(token, tp, SEQ_DECKTOP, REASON_EFFECT) 
        end
        
        -- "...then banish face-down your entire Deck"
        local deck = Duel.GetFieldGroup(tp, LOCATION_DECK, 0)
        Duel.DisableShuffleCheck()
        Duel.Remove(deck, POS_FACEDOWN, REASON_EFFECT)
        
        -- "...then add 20 non-Synchro "Warbeast" cards outside of the Duel to your Deck"
        for _, md_id in ipairs(main_deck_ids) do
            local token = Duel.CreateToken(tp, md_id)
            Duel.SendtoDeck(token, tp, SEQ_DECKBOTTOM, REASON_EFFECT)
        end
        
        -- "...and shuffle it"
        Duel.ShuffleDeck(tp)
        
        -- "...then, add 1 "Idrakian Force" outside of the Duel to your hand"
        Duel.BreakEffect()
        local idr_token = Duel.CreateToken(tp, 777000000)
        Duel.SendtoHand(idr_token, tp, REASON_EFFECT)
        
        if idr_token:IsLocation(LOCATION_HAND) then
            Duel.ConfirmCards(1-tp, idr_token)
        end
        
        -- "...then if your LP is 3000 or lower, draw cards until you have 5 cards in your hand."
        if Duel.GetLP(tp) <= 3000 then
            local current_hand_count = Duel.GetFieldGroupCount(tp, LOCATION_HAND, 0)
            local draw_amount = 5 - current_hand_count
            
            -- Só tenta comprar se faltar carta para chegar em 5 e se for possível
            if draw_amount > 0 and Duel.IsPlayerCanDraw(tp, draw_amount) then
                Duel.BreakEffect()
                Duel.Draw(tp, draw_amount, REASON_EFFECT)
            end
        end
    end
end