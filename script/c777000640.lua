-- Ruler of Timerx - Chronos
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Restrição Absoluta: Nomi ("Cannot be Normal Summoned/Set. Must be Special Summoned...")
    c:EnableReviveLimit()
    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    c:RegisterEffect(e0)

    -- "You can only Special Summon 'Ruler of Timerx - Chronos(s)' once per turn."
    c:SetSPSummonOnce(id)

    -- Efeito 1: Special Summon Inerente (Da mão) 
    -- 3+ "Timerx" monstros com nomes diferentes no campo/GY
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)

    -- Efeito 2: Gatilho -> Sp. Summon do Déqui -> Alvejar 1 -> Declarar Nome
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_MZONE)
    -- (Sem HOPT no texto para este efeito específico)
    e2:SetCondition(s.dkcon)
    e2:SetTarget(s.dktg)
    e2:SetOperation(s.dkop)
    c:RegisterEffect(e2)

    -- Efeito 3: Gatilho -> Sp. Summon do Extra Deck -> Voltar Fusão pro ED e Reviver ignorando condições
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_TOEXTRA + CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CARD_TARGET)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, id) -- HOPT ("You can only use this effect... once per turn.")
    e3:SetCondition(s.excon)
    e3:SetTarget(s.extg)
    e3:SetOperation(s.exop)
    c:RegisterEffect(e3)

    -- Efeito 4: Substituição de Destruição -> Embaralhar "Timerx" do GY no Déqui
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EFFECT_DESTROY_REPLACE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTarget(s.reptg)
    e4:SetOperation(s.repop)
    c:RegisterEffect(e4)
end

-- ====================================================================
-- Efeito 1: Condição de Invocação-Especial da Mão
-- ====================================================================
function s.spcfilter(c)
    -- Puxa monstros "Timerx" originais visíveis (Face-up no campo ou em qualquer estado no GY)
    return c:IsSetCard(0x305) and c:IsOriginalType(TYPE_MONSTER) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end

function s.spcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return false end
    
    local g = Duel.GetMatchingGroup(s.spcfilter, tp, LOCATION_ONFIELD + LOCATION_GRAVE, 0, nil)
    -- Filtra nativamente nomes originais distintos
    return g:GetClassCount(Card.GetOriginalCode) >= 3
end

-- ====================================================================
-- Efeito 2: Gatilho do Déqui (Declarar Nome)
-- ====================================================================
function s.dkfilter(c)
    return c:IsPreviousLocation(LOCATION_DECK)
end

function s.dkcon(e, tp, eg, ep, ev, re, r, rp)
    return not (Duel.GetCurrentPhase() == PHASE_DAMAGE or Duel.GetCurrentPhase() == PHASE_DAMAGE_CALC)
        and eg:IsExists(s.dkfilter, 1, nil)
end

function s.dktg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc ~= c end
    if chk == 0 then return Duel.IsExistingTarget(Card.IsFaceup, tp, LOCATION_MZONE, LOCATION_MZONE, 1, c) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    Duel.SelectTarget(tp, Card.IsFaceup, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, c)
    Duel.SetOperationInfo(0, CATEGORY_ANNOUNCE, nil, 0, tp, ANNOUNCE_CARD)
end

function s.dkop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        -- Abre o menu de busca de nome (teclado do jogo)
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CODE)
        local code = Duel.AnnounceCard(tp)
        
        -- Troca o nome permanentemente enquanto estiver no campo
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_CODE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetValue(code)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(e1)
    end
end

-- ====================================================================
-- Efeito 3: Gatilho do Extra Deck (Reciclar e Reviver Fusão Opcionalmente)
-- ====================================================================
function s.exspfilter(c)
    return c:IsSummonLocation(LOCATION_EXTRA)
end

function s.excon(e, tp, eg, ep, ev, re, r, rp)
    return not (Duel.GetCurrentPhase() == PHASE_DAMAGE or Duel.GetCurrentPhase() == PHASE_DAMAGE_CALC)
        and eg:IsExists(s.exspfilter, 1, nil)
end

function s.tgfilter(c, e, tp)
    -- Para ativar, o alvo só precisa obrigatoriamente ser uma Fusão e poder voltar pro Extra Deck
    return c:IsType(TYPE_FUSION) and c:IsAbleToExtra()
end

function s.extg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tgfilter(chkc, e, tp) end
    if chk == 0 then return Duel.IsExistingTarget(s.tgfilter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp) end
        
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectTarget(tp, s.tgfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
    Duel.SetOperationInfo(0, CATEGORY_TOEXTRA, g, 1, 0, 0)
    -- Como a invocação é opcional ("you can..."), declaramos apenas como possibilidade para o sistema
    Duel.SetPossibleOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, tp, LOCATION_EXTRA)
end

function s.exop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        -- Retorna para o Extra Deck
        if Duel.SendtoDeck(tc, nil, SEQ_DECKSHUFFLE, REASON_EFFECT) > 0 and tc:IsLocation(LOCATION_EXTRA) then
            
            -- Checa se a carta pode ser invocada e se há espaço válido de Extra Deck
            if tc:IsCanBeSpecialSummoned(e, 0, tp, true, false) and Duel.GetLocationCountFromEx(tp, tp, nil, tc) > 0 then
                
                -- Pergunta ao jogador se ele deseja aplicar a segunda parte do efeito
                if Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
                    Duel.BreakEffect()
                    -- Invoca a carta ignorando as condições (true)
                    Duel.SpecialSummon(tc, 0, tp, tp, true, false, POS_FACEUP)
                end
            end
        end
    end
end

-- ====================================================================
-- Efeito 4: Proteção (Embaralhar no lugar de ser destruído)
-- ====================================================================
function s.repfilter(c)
    return c:IsSetCard(0x305) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end

function s.reptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    -- Garante que ele está sendo destruído (batalha ou efeito) e que a substituição ainda não ocorreu
    if chk == 0 then return c:IsReason(REASON_BATTLE + REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
        and Duel.IsExistingMatchingCard(s.repfilter, tp, LOCATION_GRAVE, 0, 1, nil) end
        
    if Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
        return true
    end
    return false
end

function s.repop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectMatchingCard(tp, s.repfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    -- Envia como Custo/Substituição para o motor registrar perfeitamente a proteção
    Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_EFFECT + REASON_REPLACE)
end