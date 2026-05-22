-- Warbeast Catastrophe
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Destruir cartas descartando "Warbeast"
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.condition)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)

    -- Efeito 2: Setar do GY quando houver descarte
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_HANDES) -- Categoria de Descarte
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id + 1)
    e2:SetCondition(s.setcon)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)
    -- Proteção caso as cartas sejam banidas ao serem descartadas (Macro Cosmos)
    local e3 = e2:Clone()
    e3:SetCode(EVENT_REMOVE)
    c:RegisterEffect(e3)
end

-- ====================================================================
-- Efeito 1: Ativação (Destruição)
-- ====================================================================
function s.confilter(c)
    -- Checa se existe um Warbeast face para cima
    return c:IsFaceup() and c:IsSetCard(0x308)
end

function s.condition(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.confilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.cfilter(c)
    -- Filtra "cartas" (monstro, magia ou armadilha) Warbeast que possam ser descartadas
    return c:IsSetCard(0x308) and c:IsDiscardable()
end

function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    -- Calcula o limite máximo baseado em quantas cartas o oponente tem E quantas você tem na mão
    local max = math.min(Duel.GetFieldGroupCount(tp, 0, LOCATION_ONFIELD), Duel.GetMatchingGroupCount(s.cfilter, tp, LOCATION_HAND, 0, e:GetHandler()))
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DISCARD)
    local cg = Duel.SelectMatchingCard(tp, s.cfilter, tp, LOCATION_HAND, 0, 1, max, e:GetHandler())
    Duel.SendtoGrave(cg, REASON_COST + REASON_DISCARD)
    -- Salva o número de cartas descartadas na memória temporária do efeito
    e:SetLabel(#cg)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsControler(1 - tp) and chkc:IsOnField() end
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_HAND, 0, 1, e:GetHandler()) 
            and Duel.IsExistingMatchingCard(aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, nil)
    end
    -- Puxa a memória de quantas cartas foram descartadas
    local ct = e:GetLabel()
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    -- Força a selecionar exatamente o mesmo número de alvos
    local g = Duel.SelectTarget(tp, aux.TRUE, tp, 0, LOCATION_ONFIELD, ct, ct, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, ct, 0, 0)
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local tg = Duel.GetTargetCards(e)
    if #tg > 0 then
        Duel.Destroy(tg, REASON_EFFECT)
    end
end

-- ====================================================================
-- Efeito 2: Setar do Cemitério e Brenda
-- ====================================================================
function s.setcon(e, tp, eg, ep, ev, re, r, rp)
    -- O gatilho roda se qualquer uma das cartas movidas foi por descarte
    return eg:IsExists(Card.IsReason, 1, nil, REASON_DISCARD)
end

function s.settg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsSSetable() end
    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, e:GetHandler(), 1, 0, 0)
end

function s.brfilter(c)
    -- Puxa o ID original da Brenda 
    return c:IsFaceup() and c:GetOriginalCode() == 777001840
end

function s.setop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsSSetable() then
        Duel.SSet(tp, c)
        
        -- Regra: Banir quando deixar o campo
        local e1 = Effect.CreateEffect(c)
        e1:SetDescription(3300)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CLIENT_HINT)
        e1:SetReset(RESET_EVENT + RESETS_REDIRECT)
        e1:SetValue(LOCATION_REMOVED)
        c:RegisterEffect(e1)
        
        -- Efeito Opcional bônus da Brenda (Janela de Yes/No)
        if Duel.IsExistingMatchingCard(s.brfilter, tp, LOCATION_MZONE, 0, 1, nil) 
            and Duel.GetFieldGroupCount(1 - tp, LOCATION_HAND, 0) > 0 
            and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
            Duel.BreakEffect()
            Duel.DiscardHand(1 - tp, nil, 1, 1, REASON_EFFECT + REASON_DISCARD)
        end
    end
end