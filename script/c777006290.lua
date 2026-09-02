-- Corrupted Okami - Ninetails
local s, id = GetID()
function s.initial_effect(c)
    -- Efeito 1: Destruir Magia/Armadilha e Invocar por Invocação-Especial (Mão ou Cemitério)
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_DESTROY + CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_HAND + LOCATION_GRAVE)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Efeito 2: Ganho de ATK Contínuo
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(s.atkval)
    c:RegisterEffect(e2)

    -- Efeito 3: Imunidade a Efeitos de Monstro
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_IMMUNE_EFFECT)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(s.efilter)
    c:RegisterEffect(e3)
end

-- Funções do Efeito 1 (Invocação-Especial)
function s.desfilter(c)
    return c:IsSpellTrap()
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chkc then return chkc:IsOnField() and s.desfilter(chkc) end
    if chk == 0 then 
        return Duel.IsExistingTarget(s.desfilter, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil)
        and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) 
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, s.desfilter, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    local c = e:GetHandler()
    if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc, REASON_EFFECT) > 0 then
        if c:IsRelateToEffect(e) then
            Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
        end
    end
end

-- Funções do Efeito 2 (Cálculo de ATK)
function s.atkfilter(c)
    return c:IsMonster()
end
function s.atkval(e, c)
    return Duel.GetMatchingGroupCount(s.atkfilter, c:GetControler(), LOCATION_GRAVE, 0, nil) * 200
end

-- Funções do Efeito 3 (Filtro de Imunidade)
function s.efilter(e, te)
    return te:IsActiveType(TYPE_MONSTER) and te:GetOwnerPlayer() ~= e:GetHandlerPlayer()
end