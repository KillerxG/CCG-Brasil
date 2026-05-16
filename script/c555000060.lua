-- Cute Shinob Reptile - Snake
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Revelar esta carta e 1 outro "Cute Shinob" para Invocar ambos
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Efeito 2: Destruir 1 Magia/Armadilha do oponente se usado como material de Fusão/Link
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_SINGLE | EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY | EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_BE_MATERIAL)
    e2:SetCountLimit(1, {id, 2})
    e2:SetCondition(s.descon)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
end

s.listed_series = {0x267}

-- ==========================================================
-- Efeito 1: Revelar e Invocar Especialmente
-- ==========================================================
function s.cfilter(c, e, tp)
    return c:IsSetCard(0x267) and c:IsMonster() and not c:IsPublic()
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return not c:IsPublic() and Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_HAND, 0, 1, c, e, tp) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    local g = Duel.SelectMatchingCard(tp, s.cfilter, tp, LOCATION_HAND, 0, 1, 1, c, e, tp)
    -- Salva a referência do outro monstro selecionado para garantir que ele seja o invocado
    e:SetLabelObject(g:GetFirst()) 
    
    g:AddCard(c)
    Duel.ConfirmCards(1 - tp, g)
    Duel.ShuffleHand(tp)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then 
        return not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT)
            and Duel.GetLocationCount(tp, LOCATION_MZONE) > 1
            and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
            -- A verificação do outro monstro também deve ser confirmada caso seja a primeira vez que o simulador avalie
            and Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_HAND, 0, 1, c, e, tp)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 2, tp, LOCATION_HAND)
end

function s.splimit(e, c)
    return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x267)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = e:GetLabelObject()
    
    -- Bloqueios contra mudanças ilegais de status e falta de espaço
    if not c:IsRelateToEffect(e) or not tc then return end
    if Duel.GetLocationCount(tp, LOCATION_MZONE) < 2 or Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then return end
    
    local sg = Group.FromCards(c, tc)
    -- Certifica-se estritamente que ambas as cartas reveladas continuam seguras na Mão
    if sg:FilterCount(Card.IsLocation, nil, LOCATION_HAND) ~= 2 then return end
    
    if Duel.SpecialSummon(sg, 0, tp, tp, false, false, POS_FACEUP) == 2 then
        for sc in aux.Next(sg) do
            -- Prende a trava do Extra Deck individualmente a cada um dos monstros enquanto estiverem virados para cima
            local e1 = Effect.CreateEffect(c)
            e1:SetDescription(aux.Stringid(id, 2)) -- String local: "Cannot Special Summon from Extra Deck except 'Cute Shinob' monsters"
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
            e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET | EFFECT_FLAG_CLIENT_HINT)
            e1:SetRange(LOCATION_MZONE)
            e1:SetTargetRange(1, 0)
            e1:SetTarget(s.splimit)
            e1:SetReset(RESET_EVENT | RESETS_STANDARD)
            sc:RegisterEffect(e1, true)
        end
    end
end

-- ==========================================================
-- Efeito 2: Destruir Magia/Armadilha do Oponente
-- ==========================================================
function s.descon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = c:GetReasonCard()
    return c:IsLocation(LOCATION_GRAVE) and (r & (REASON_FUSION | REASON_LINK) ~= 0)
        and rc and rc:IsSetCard(0x267)
end

function s.desfilter(c)
    -- IsSpellTrap() varre qualquer Magia/Armadilha de forma unificada e limpa
    return c:IsSpellTrap()
end

function s.destg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsControler(1 - tp) and chkc:IsOnField() and s.desfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.desfilter, tp, 0, LOCATION_ONFIELD, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, s.desfilter, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
end

function s.desop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Destroy(tc, REASON_EFFECT)
    end
end