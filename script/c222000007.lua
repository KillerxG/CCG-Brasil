-- Silver Fangs Skill
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- [Skill Activation]
    aux.AddSkillProcedure(c, 1, false, s.flipcon, s.flipop)
end

-- Filtro para identificar as cartas "Silver Fangs" (0x307) e Idrakian (0x313)
function s.restrict_filter(c)
    return c:IsSetCard(0x307) or c:IsSetCard(0x313)
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
    -- Verifica se a Skill pode ser ativada
    if not aux.CanActivateSkill(tp) then return false end
    
    local hand = Duel.GetFieldGroup(tp, LOCATION_HAND, 0)
    -- "min. 1 card in your hand"
    if #hand == 0 then return false end
    
    -- "If you do not have a "Silver Fangs" or "Idrakian" card in your hand, field, GY or banishment:"
    if Duel.IsExistingMatchingCard(s.restrict_filter, tp, LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED, 0, 1, nil) then
        return false
    end
    
    return true
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1<<32))
    Duel.Hint(HINT_CARD, tp, id)
    
    -- SUBSTITUA ESSES NÚMEROS PELOS IDs DOS SEUS 4 MONSTROS LINK "SILVER FANGS"
    local extra_deck_ids = {
        777001330, 777001330, 777001340, 777001340
    }
    
    -- SUBSTITUA ESSES NÚMEROS PELOS IDs DAS SUAS 20 CARTAS NON-LINK "SILVER FANGS"
    local main_deck_ids = {
        777001320, 777001320, 777001380, 777001380, 777001380,
        777001420, 777001420, 777001420, 777001430, 777001430,
        777001430, 777001390, 777001390, 777001390, 777001450,
        777001450, 777001460, 777001460, 777001440, 777001440
    }

    local hand = Duel.GetFieldGroup(tp, LOCATION_HAND, 0)
    
    -- "Send to the GY all cards from your hand (min. 1)..."
    if Duel.SendtoGrave(hand, REASON_EFFECT) > 0 then
        
        -- "...add 4 "Silver Fangs" Link Monsters from outside of the Duélo to your Extra Deck"
        for _, ed_id in ipairs(extra_deck_ids) do
            local token = Duel.CreateToken(tp, ed_id)
            Duel.SendtoDeck(token, tp, SEQ_DECKTOP, REASON_EFFECT)
        end
        
        -- "...then banish face-down your entire Deck"
        local deck = Duel.GetFieldGroup(tp, LOCATION_DECK, 0)
        Duel.DisableShuffleCheck()
        Duel.Remove(deck, POS_FACEDOWN, REASON_EFFECT)
        
        -- "...then add 20 non-Link "Silver Fangs" cards outside of the Duélo to your Deck"
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