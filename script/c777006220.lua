-- Corrupted Okami - Gekigami
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Special Summon da mão e virar monstros do oponente (Quick Effect)
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_POSITION)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id)
    e1:SetHintTiming(0, TIMINGS_CHECK_MONSTER_E + TIMING_MAIN_END)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Efeito 2: Pode atacar todos os monstros do oponente, uma vez cada
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_ATTACK_ALL)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- Efeito 3: Dano Perfurante 
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e3)
end

-- ====================================================================
-- Efeito 1: Invocação e "Book of Eclipse" Opcional
-- ====================================================================
function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    -- Checa se é a Main Phase (1 ou 2) e se o oponente controla 3 ou mais monstros
    local ph = Duel.GetCurrentPhase()
    return (ph == PHASE_MAIN1 or ph == PHASE_MAIN2) 
        and Duel.GetFieldGroupCount(tp, 0, LOCATION_MZONE) >= 3
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end

function s.setfilter(c)
    -- Garante que está face-up e QUE PODE SER SETADO (ignora Links, Tokens, etc.)
    return c:IsFaceup() and c:IsCanTurnSet()
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        
        -- Procura por alvos válidos para o efeito de virar para baixo
        local g = Duel.GetMatchingGroup(s.setfilter, tp, 0, LOCATION_MZONE, nil)
        
        -- "...and if you do, you CAN change" (Efeito Opcional)
        if #g > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
            Duel.BreakEffect() -- Insere o intervalo correto na Chain
            Duel.ChangePosition(g, POS_FACEDOWN_DEFENSE)
        end
    end
end