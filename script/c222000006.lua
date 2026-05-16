local s, id = GetID()

function s.initial_effect(c)
    -- [Skill Activation]
    aux.AddSkillProcedure(c, 1, false, s.flipcon, s.flipop)
end

-- Filtro para identificar as restrições da Skill
function s.restrict_filter(c)
    -- Checa se a carta pertence a um dos dois arquétipos diretamente pelos IDs (0x306 = Sky Wind, 0x313 = Idrakian)
    local is_archetype = c:IsSetCard(0x306) or c:IsSetCard(0x313)
    if not is_archetype then return false end
    
    -- Se a carta estiver no Extra Deck, só bloqueia se ela estiver Face-Up
    if c:IsLocation(LOCATION_EXTRA) then
        return c:IsFaceup()
    end
    
    -- Se estiver em qualquer outra zona (Hand, Field, GY, Banishment), bloqueia
    return true
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
    if not aux.CanActivateSkill(tp) then return false end
    
    local hand = Duel.GetFieldGroup(tp, LOCATION_HAND, 0)
    -- "min. 1 card in your hand"
    if #hand == 0 then return false end
    
    -- "If you do not have a Sky Wind or Idrakian card in your hand, field, GY or banishment or face-up Extra Deck"
    if Duel.IsExistingMatchingCard(s.restrict_filter, tp, LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA, 0, 1, nil) then
        return false
    end
    
    return true
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1<<32))
    Duel.Hint(HINT_CARD, tp, id)
    
    local pendulum_ids = {777001500, 777001510, 777001520} -- IDs dos 3 Pendulums
    
    local main_deck_ids = {
        777001490, 777001490, 777001540, 777001540, 777001540, -- IDs para as 20 cartas do déqui
        777001550, 777001550, 777001560, 777001560, 777001560,
        777001580, 777001580, 777001580, 777001590, 777001590,
        777001590, 777001550, 777001600, 777001600, 777001600
    }

    local hand = Duel.GetFieldGroup(tp, LOCATION_HAND, 0)
    
    -- "Send to the GY all cards from your hand..."
    if Duel.SendtoGrave(hand, REASON_EFFECT) > 0 then
        
        -- "...add 3 "Sky Wind" Pendulum monsters from outside of the Duel to your Extra Deck"
        for _, pend_id in ipairs(pendulum_ids) do
            local token = Duel.CreateToken(tp, pend_id)
            
            -- O EDOPro envia os monstros de Extra Deck Face-Down quando usamos SendtoDeck
            Duel.SendtoDeck(token, tp, SEQ_DECKTOP, REASON_EFFECT)
        end
        
        -- "...then banish face-down your entire Deck"
        local deck = Duel.GetFieldGroup(tp, LOCATION_DECK, 0)
        Duel.DisableShuffleCheck()
        Duel.Remove(deck, POS_FACEDOWN, REASON_EFFECT)
        
        -- "...then add 20 "Sky Wind" cards outside of the Duel to your Deck"
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
            
            if draw_amount > 0 and Duel.IsPlayerCanDraw(tp, draw_amount) then
                Duel.BreakEffect()
                Duel.Draw(tp, draw_amount, REASON_EFFECT)
            end
        end
    end
end