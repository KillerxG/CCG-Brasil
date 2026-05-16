-- Thunder Force Skill
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- [Skill Activation]
    aux.AddSkillProcedure(c, 1, false, s.flipcon, s.flipop)
end

-- Filtro para identificar as cartas "Thunder Force" (0x301) e Idrakian (0x313)
function s.restrict_filter(c)
    return c:IsSetCard(0x301) or c:IsSetCard(0x313)
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
    -- Verifica se a Skill pode ser ativada
    if not aux.CanActivateSkill(tp) then return false end
    
    local hand = Duel.GetFieldGroup(tp, LOCATION_HAND, 0)
    -- "min. 1 card in your hand"
    if #hand == 0 then return false end
    
    -- "If you do not have a "Thunder Force" or "Idrakian" card in your hand, field, GY or banishment:"
    if Duel.IsExistingMatchingCard(s.restrict_filter, tp, LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED, 0, 1, nil) then
        return false
    end
    
    return true
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1<<32))
    Duel.Hint(HINT_CARD, tp, id)
    
    -- SUBSTITUA ESSES NÚMEROS PELOS IDs DOS SEUS 4 MONSTROS Xyz "Thunder Force"
    local extra_deck_ids = {
        777001690, 777001710, 777001680, 777001680
    }
    
    -- SUBSTITUA ESSES NÚMEROS PELOS IDs DAS SUAS 20 CARTAS NON-Xyz "Thunder Force"
    local main_deck_ids = {
        777001670, 777001670, 777001800, 777001800, 777001800,
        777001720, 777001720, 777001720, 777001750, 777001750,
        777001750, 777001370, 777001370, 777001370, 777001760,
        777001760, 777001760, 777001790, 777001790, 777001790
    }

    local hand = Duel.GetFieldGroup(tp, LOCATION_HAND, 0)
    
    -- "Send to the GY all cards from your hand (min. 1)..."
    if Duel.SendtoGrave(hand, REASON_EFFECT) > 0 then
        
        -- "...add 4 "Thunder Force" Xyz Monsters from outside of the Duélo to your Extra Deck"
        for _, ed_id in ipairs(extra_deck_ids) do
            local token = Duel.CreateToken(tp, ed_id)
            Duel.SendtoDeck(token, tp, SEQ_DECKTOP, REASON_EFFECT)
        end
        
        -- "...then banish face-down your entire Deck"
        local deck = Duel.GetFieldGroup(tp, LOCATION_DECK, 0)
        Duel.DisableShuffleCheck()
        Duel.Remove(deck, POS_FACEDOWN, REASON_EFFECT)
        
        -- "...then add 20 non-Xyz "Thunder Force" cards outside of the Duélo to your Deck"
        for _, md_id in ipairs(main_deck_ids) do
            local token = Duel.CreateToken(tp, md_id)
            Duel.SendtoDeck(token, tp, SEQ_DECKBOTTOM, REASON_EFFECT)
        end
        
        -- "...and shuffle it"
        Duel.ShuffleDeck(tp)
        
        -- "...then, add 1 "Idrakian Force" outside of the Duélo to your hand"
        Duel.BreakEffect()
        local idr_token = Duel.CreateToken(tp, 777000000) -- ID da Idrakian Force
        Duel.SendtoHand(idr_token, tp, REASON_EFFECT)
        
        if idr_token:IsLocation(LOCATION_HAND) then
            Duel.ConfirmCards(1-tp, idr_token)
        end
        
        -- "...then if your LP is 3000 or lower, draw cards until you have 5 cards in your hand."
        if Duel.GetLP(tp) <= 3000 then
            local current_hand_count = Duel.GetFieldGroupCount(tp, LOCATION_HAND, 0)
            local draw_amount = 5 - current_hand_count
            
            if draw_amount > 0 and Duel.IsPlayerCanDraw(tp, draw_amount) then
                Duel.BreakEffect()
                Duel.Draw(tp, draw_amount, REASON_EFFECT)
            end
        end
    end
end