-- Shinigami Cursed Talismans
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Ativação: Destruir -> Setar Trap no oponente -> Setar do GY inimigo
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- ====================================================================
-- Filtros e Condição de Ativação
-- ====================================================================
function s.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x304)
end

function s.condition(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsOnField() and chkc:IsControler(1 - tp) and chkc:IsType(TYPE_SPELL + TYPE_TRAP) end
    if chk == 0 then return Duel.IsExistingTarget(Card.IsType, tp, 0, LOCATION_ONFIELD, 1, nil, TYPE_SPELL + TYPE_TRAP) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, Card.IsType, tp, 0, LOCATION_ONFIELD, 1, 1, nil, TYPE_SPELL + TYPE_TRAP)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
end

-- ====================================================================
-- Resolução: Destruir e Setar (Anti-Rollback)
-- ====================================================================
function s.setfilter1(c)
    -- Simplificado para evitar crash na checagem de "Set" do oponente
    return c:IsSetCard(0x304) and c:IsType(TYPE_TRAP)
end

function s.bossfilter(c)
    return c:IsFaceup() and c:GetOriginalCode() == 777001120
end

function s.setfilter2(c)
    -- Simplificado para evitar quebra com wrappers de Necrovalley
    return c:IsType(TYPE_SPELL + TYPE_TRAP)
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    
    -- Checa se o alvo existe, ainda é válido e se a destruição ocorreu de fato (> 0)
    if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc, REASON_EFFECT) ~= 0 then
        
        -- Parte 1: Setar a Trap do déqui no campo do oponente
        if Duel.GetLocationCount(1 - tp, LOCATION_SZONE) > 0 
            and Duel.IsExistingMatchingCard(s.setfilter1, tp, LOCATION_DECK, 0, 1, nil)
            and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
            
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SET)
            local sg = Duel.SelectMatchingCard(tp, s.setfilter1, tp, LOCATION_DECK, 0, 1, 1, nil)
            local stc = sg:GetFirst()
            
            if stc then
                -- Força a carta para a zona do oponente virada para baixo, sem usar o SSet que pode dar conflito
                Duel.MoveToField(stc, tp, 1 - tp, LOCATION_SZONE, POS_FACEDOWN, true)
                -- Impede de ser ativada no mesmo turno (mecânica padrão de Set)
                stc:SetStatus(STATUS_SET_TURN, true)
            end
        end
        
        -- Parte 2: Checa o Boss e rouba recurso do GY oponente
        if Duel.IsExistingMatchingCard(s.bossfilter, tp, LOCATION_MZONE, 0, 1, nil)
            and Duel.GetLocationCount(tp, LOCATION_SZONE) > 0
            and Duel.IsExistingMatchingCard(s.setfilter2, tp, 0, LOCATION_GRAVE, 1, nil)
            and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
            
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SET)
            local bg = Duel.SelectMatchingCard(tp, s.setfilter2, tp, 0, LOCATION_GRAVE, 1, 1, nil)
            local btc = bg:GetFirst()
            
            if btc then
                -- Move para a SUa zona virada para baixo
                Duel.MoveToField(btc, tp, tp, LOCATION_SZONE, POS_FACEDOWN, true)
                btc:SetStatus(STATUS_SET_TURN, true)
            end
        end
    end
end