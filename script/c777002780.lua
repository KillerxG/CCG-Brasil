-- Pyroland Guardian - Wulkan
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Habilita Invocação-Fusão (2 "Pyroland" + 1 FIRE)
    c:EnableReviveLimit()
    Fusion.AddProcMix(c, true, true, s.matfilter1, s.matfilter1, s.matfilter2)

    -- Condição: Só pode ser Invocado por Invocação-Fusão 1 vez por turno (Molde de Registro Manual)
    local e0=Effect.CreateEffect(c)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e0:SetCode(EVENT_SPSUMMON_SUCCESS)
    e0:SetCondition(s.regcon)
    e0:SetOperation(s.regop)
    c:RegisterEffect(e0)

    -- Efeito 1: Oponente não pode dar alvo nesta carta se Invocada por Fusão
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.tgcon)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)

    -- Efeito 2: Ganha 100 de ATK por cada carta em ambos os Cemitérios
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(s.atkval)
    c:RegisterEffect(e2)

    -- Efeito 3: Se Invocado por Fusão: Enviar do topo do Deck ao GY baseado no Nível de outro FIRE
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_DECKDES)
    e3:SetType(EFFECT_TYPE_SINGLE | EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET | EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetCondition(s.millcon)
    e3:SetTarget(s.milltg)
    e3:SetOperation(s.millop)
    c:RegisterEffect(e3)

    -- Efeito 4: Uma vez enquanto estiver com a face para cima (Main Phase): Trocar GY com o Deck
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_TODECK | CATEGORY_TOGRAVE)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1, EFFECT_COUNT_CODE_SINGLE)
    e4:SetCondition(s.swapcon)
    e4:SetTarget(s.swaptg)
    e4:SetOperation(s.swapop)
    c:RegisterEffect(e4)

    -- Efeito 5: Durante a End Phase: Setar 1 "Pyroland" Spell/Trap do GY
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 2))
    e5:SetType(EFFECT_TYPE_FIELD | EFFECT_TYPE_TRIGGER_O)
    e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e5:SetCode(EVENT_PHASE | PHASE_END)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1, {id, 1})
    e5:SetCondition(s.setcon)
    e5:SetTarget(s.settg)
    e5:SetOperation(s.setop)
    c:RegisterEffect(e5)
end

s.listed_series = {0x278}

-- ==========================================================
-- Filtros de Fusão
-- ==========================================================
function s.matfilter1(c, fc, sumtype, tp)
    return c:IsSetCard(0x278, fc, sumtype, tp) and c:IsMonster()
end

function s.matfilter2(c, fc, sumtype, tp)
    return c:IsAttribute(ATTRIBUTE_FIRE, fc, sumtype, tp)
end

-- ==========================================================
-- Trava de Invocação (Seu molde)
-- ==========================================================
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetReset(RESET_PHASE|PHASE_END)
    e1:SetTarget(s.splimit)
    Duel.RegisterEffect(e1,tp)
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    return c:IsCode(id) and (sumtype&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end

-- ==========================================================
-- Efeito 1: Proteção de Alvo
-- ==========================================================
function s.tgcon(e)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

-- ==========================================================
-- Efeito 2: Ganho de ATK pelos GYs
-- ==========================================================
function s.atkval(e, c)
    -- As variáveis LOCATION_GRAVE nas posições 2 e 3 instruem a varredura em ambos os Cemitérios
    return Duel.GetFieldGroupCount(c:GetControler(), LOCATION_GRAVE, LOCATION_GRAVE) * 100
end

-- ==========================================================
-- Efeito 3: Mill por Nível
-- ==========================================================
function s.millcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

function s.millfilter(c, ec)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE) and c:HasLevel() and c ~= ec
end

function s.milltg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.millfilter(chkc, c) end
    if chk == 0 then return Duel.IsPlayerCanDiscardDeck(tp, 1) 
        and Duel.IsExistingTarget(s.millfilter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, c, c) end
        
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local g = Duel.SelectTarget(tp, s.millfilter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, c, c)
    Duel.SetOperationInfo(0, CATEGORY_DECKDES, nil, 0, tp, g:GetFirst():GetLevel())
end

function s.millop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        Duel.DiscardDeck(tp, tc:GetLevel(), REASON_EFFECT)
    end
end

-- ==========================================================
-- Efeito 4: Troca de GY com o Deck
-- ==========================================================
function s.swapcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsMainPhase() and Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)>=25
end

function s.swaptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then 
        return Duel.GetFieldGroupCount(tp, LOCATION_DECK | LOCATION_GRAVE, LOCATION_DECK | LOCATION_GRAVE) > 0
    end
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, PLAYER_ALL, LOCATION_DECK)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, PLAYER_ALL, LOCATION_GRAVE)
end

function s.swapop(e, tp, eg, ep, ev, re, r, rp)
    -- Captura o inventário atual para realizar a troca segura
    local gy = Duel.GetFieldGroup(tp, LOCATION_GRAVE, LOCATION_GRAVE)
    local deck = Duel.GetFieldGroup(tp, LOCATION_DECK, LOCATION_DECK)
    
    -- Envia o Cemitério de volta ao Deck e os embaralha
    if #gy > 0 then
        Duel.SendtoDeck(gy, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
    end
    -- Envia as cartas estritas do Deck original para os respectivos Cemitérios
    if #deck > 0 then
        Duel.SendtoGrave(deck, REASON_EFFECT)
    end
end

-- ==========================================================
-- Efeito 5: Setar Spell/Trap na End Phase
-- ==========================================================
function s.setcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() == tp
end

function s.setfilter(c)
    return c:IsSetCard(0x278) and c:IsSpellTrap() and c:IsSSetable()
end

function s.settg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.setfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.setfilter, tp, LOCATION_GRAVE, 0, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SET)
    local g = Duel.SelectTarget(tp, s.setfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, g, 1, 0, 0)
end

function s.setop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsSSetable() then
        Duel.SSet(tp, tc)
    end
end