-- Cute Shinob Beast - Panda
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Habilita Invocação-Fusão
    c:EnableReviveLimit()
    -- Procedimento de Fusão exato baseado na Dinomorphia Kentregina
    Fusion.AddProcMixN(c, true, true, s.ffilter, 3)

    -- Efeito 1: Negar Invocação Normal/Especial, Destruir e Adicionar do GY
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_DISABLE_SUMMON | CATEGORY_DESTROY | CATEGORY_TOHAND | CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EVENT_SUMMON)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCondition(s.discon)
    e1:SetTarget(s.distg)
    e1:SetOperation(s.disop)
    c:RegisterEffect(e1)
    
    -- Clone do Efeito 1 para abranger também Invocações-Especiais
    local e1b = e1:Clone()
    e1b:SetCode(EVENT_SPSUMMON)
    c:RegisterEffect(e1b)

    -- Efeito 2: Destruir monstro Invocado por Invocação-Especial do GY/Banimento no início da Damage Step
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_SINGLE | EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BATTLE_START)
    e2:SetCountLimit(1, {id, 2})
    e2:SetCondition(s.descon)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)

    -- Efeito 3: Se for enviado do campo para o GY, reciclar carta do arquétipo ou magia de Fusão
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_SINGLE | EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET | EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetCountLimit(1, {id, 3})
    e3:SetCondition(s.thcon)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
end

s.listed_series = {0x267, 0x46}

-- ==========================================================
-- Filtro de Fusão (Checagem de arquétipo e nomes diferentes)
-- ==========================================================
function s.ffilter(c, fc, sumtype, tp, sub, mg, sg)
    -- Verifica se a carta é do arquétipo e, caso um grupo (sg) já esteja sendo formado na seleção, 
    -- garante que a carta atual 'c' não possua o mesmo código de nenhuma carta já dentro do grupo.
    return c:IsSetCard(0x267, fc, sumtype, tp) and (not sg or not sg:IsExists(Card.IsCode, 1, c, c:GetCode()))
end

-- ==========================================================
-- Efeito 1: Negar Invocação
-- ==========================================================
function s.discon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetCurrentChain() == 0
end

function s.distg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_DISABLE_SUMMON, eg, #eg, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, #eg, 0, 0)
end

function s.thfilter1(c)
    return c:IsSetCard(0x267) and c:IsAbleToHand()
end

function s.disop(e, tp, eg, ep, ev, re, r, rp)
    Duel.NegateSummon(eg)
    if Duel.Destroy(eg, REASON_EFFECT) > 0 then
        local g = Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter1), tp, LOCATION_GRAVE, 0, nil)
        if #g > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
            local sg = g:Select(tp, 1, 1, nil)
            Duel.SendtoHand(sg, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, sg)
        end
    end
end

-- ==========================================================
-- Efeito 2: Destruir Monstro do GY/Banimento em Batalha
-- ==========================================================
function s.descon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local bc = c:GetBattleTarget()
    return bc and bc:IsSummonLocation(LOCATION_GRAVE | LOCATION_REMOVED)
end

function s.destg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    local bc = e:GetHandler():GetBattleTarget()
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, bc, 1, 0, 0)
end

function s.desop(e, tp, eg, ep, ev, re, r, rp)
    local bc = e:GetHandler():GetBattleTarget()
    if bc and bc:IsRelateToBattle() then
        Duel.Destroy(bc, REASON_EFFECT)
    end
end

-- ==========================================================
-- Efeito 3: Reciclar ao ir do Campo para o Cemitério
-- ==========================================================
function s.thcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end

function s.thfilter2(c, e_c)
    return c ~= e_c and c:IsAbleToHand() and (c:IsSetCard(0x267) or (c:IsSetCard(0x46) and c:IsSpell()))
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter2(chkc, c) end
    if chk == 0 then return Duel.IsExistingTarget(s.thfilter2, tp, LOCATION_GRAVE, 0, 1, c, c) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectTarget(tp, s.thfilter2, tp, LOCATION_GRAVE, 0, 1, 1, c, c)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, 1, 0, 0)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, tc)
    end
end