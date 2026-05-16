-- Phantom Gunners Skill
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- [Skill Activation]
    aux.AddSkillProcedure(c, 1, false, s.flipcon, s.flipop)
end

-- Filtro para identificar as cartas Phantom Gunners (0x302) e Idrakian (0x313)
function s.restrict_filter(c)
    return c:IsSetCard(0x302) or c:IsSetCard(0x313)
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
    -- Verifica se a Skill pode ser ativada usando as regras nativas
    if not aux.CanActivateSkill(tp) then return false end
    
    local hand = Duel.GetFieldGroup(tp, LOCATION_HAND, 0)
    -- "min. 1 card in your hand"
    if #hand == 0 then return false end
    
    -- "If you do not have a "Phantom Gunners" or "Idrakian" card in your hand, field, GY or banishment:"
    -- Verifica se EXISTE alguma carta desses arquétipos nessas zonas. Se existir, a Skill é bloqueada.
    if Duel.IsExistingMatchingCard(s.restrict_filter, tp, LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED, 0, 1, nil) then
        return false
    end
    
    return true
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1<<32))
    Duel.Hint(HINT_CARD, tp, id)
    
    -- SUBSTITUA ESSES NÚMEROS PELOS IDs DAS SUAS 20 CARTAS Phantom Gunners
    local main_deck_ids = {
        777000960, 777000960, 777000980, 777000980, 777001030,
        777001030, 777001030, 777000970, 777001040, 777001040,
        777001020, 777001020, 777001020, 777000540, 777000540,
        777000540, 777001090, 777001090, 777001100, 777001100
    }

    local hand = Duel.GetFieldGroup(tp, LOCATION_HAND, 0)
    
    -- "Send to the GY all cards from your hand (min. 1)..."
    if Duel.SendtoGrave(hand, REASON_EFFECT) > 0 then
        
        -- "...and if you do, banish face-down your entire Deck"
        local deck = Duel.GetFieldGroup(tp, LOCATION_DECK, 0)
        Duel.DisableShuffleCheck()
        Duel.Remove(deck, POS_FACEDOWN, REASON_EFFECT)
        
        -- "...then add 20 "Phantom Gunners" cards outside of the Duel to your Deck"
        for _, md_id in ipairs(main_deck_ids) do
            local token = Duel.CreateToken(tp, md_id)
            Duel.SendtoDeck(token, tp, SEQ_DECKBOTTOM, REASON_EFFECT)
        end
        
        -- "...and shuffle it"
        Duel.ShuffleDeck(tp)
        
        -- "...then, add 1 "Idrakian Force" outside of the Duel to your hand"
        Duel.BreakEffect()
        local idr_token = Duel.CreateToken(tp, 777000000) -- ID da sua Idrakian Force
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