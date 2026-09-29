--West Royal Dragon Chronicler
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
    --(1)Foolish
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.tgcost)
    e1:SetTarget(s.tgtg)
    e1:SetOperation(s.tgop)
    c:RegisterEffect(e1)
    --(2)Self Special 
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1, id)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end
--(1)Foolish
function s.tgcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsDiscardable() end
    Duel.SendtoGrave(c, REASON_COST | REASON_DISCARD)
end
function s.tgfilter(c)
    return c:IsSetCard(0x288) and not c:IsCode(id) and c:IsAbleToGrave()
end
function s.tgtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.tgfilter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_DECK)
end
function s.tgop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, s.tgfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoGrave(g, REASON_EFFECT)
    end
end
--(2)Self Special then Synchro Summon
function s.spfilter(c)
    return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_RITUAL) 
        and c:HasLevel() and c:GetLevel() >= 4
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.spfilter(chkc) end    
    local c = e:GetHandler()
    if chk == 0 then 
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
            and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
            and Duel.IsExistingTarget(s.spfilter, tp, LOCATION_MZONE, 0, 1, nil)     end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local g = Duel.SelectTarget(tp, s.spfilter, tp, LOCATION_MZONE, 0, 1, 1, nil)    
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    local c = e:GetHandler()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
        -- 1. Reduz o nível em 3
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_LEVEL)
        e1:SetValue(-3)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(e1)
        if c:IsRelateToEffect(e) and Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 then            
            -- 2. Aplica o banimento quando sair de campo
            local e2 = Effect.CreateEffect(c)
            e2:SetDescription(3300) -- String global para "Banish it when it leaves the field"
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CLIENT_HINT)
            e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
            e2:SetValue(LOCATION_REMOVED)
            e2:SetReset(RESET_EVENT + RESETS_REDIRECT)
            c:RegisterEffect(e2, true)            
            -- 3. "...then you can change this card's Level to 4."
            if c:HasLevel() and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
                Duel.BreakEffect()                
                local e3 = Effect.CreateEffect(c)
                e3:SetType(EFFECT_TYPE_SINGLE)
                e3:SetCode(EFFECT_CHANGE_LEVEL)
                e3:SetValue(4)
                e3:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
                c:RegisterEffect(e3)
            end
        end
    end
end