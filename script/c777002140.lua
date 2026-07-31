-- Shinigami Death Sentence
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Ativação Padrão
    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
    c:RegisterEffect(e0)

    -- Efeito 1: Todos os monstros virados para cima do controlador se tornam DARK
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTargetRange(LOCATION_MZONE, 0)
    e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    e1:SetValue(ATTRIBUTE_DARK)
    c:RegisterEffect(e1)

    -- Efeito 2: Reduz o Nível de todos os monstros do controlador em 2
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(LOCATION_MZONE, 0)
    e2:SetCode(EFFECT_UPDATE_LEVEL)
    e2:SetValue(-2)
    c:RegisterEffect(e2)

    -- Efeito 3: Condicionado ao Boss - Forçar Posição de Ataque
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_SET_POSITION)
    e3:SetRange(LOCATION_SZONE)
    e3:SetTargetRange(LOCATION_MZONE, 0)
    e3:SetCondition(s.poscon)
    e3:SetTarget(s.postg)
    e3:SetValue(POS_FACEUP_ATTACK)
    c:RegisterEffect(e3)

    -- Efeito 4: Condicionado ao Boss - Impedir mudança de posição
    local e4 = e3:Clone()
    e4:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
    c:RegisterEffect(e4)
	
	-- Efeito Rápido/Ignição na Mão: Revelar e Colocar no Oponente
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 0))
    e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
    e5:SetRange(LOCATION_HAND)
    e5:SetCountLimit(1, id)
    e5:SetCondition(s.placecon)
    e5:SetCost(s.placecost)
    e5:SetTarget(s.placetg)
    e5:SetOperation(s.placeop)
    c:RegisterEffect(e5)
end

-- ====================================================================
-- Filtros do Efeito 3 e 4 (Trava de Posição de Batalha)
-- ====================================================================
function s.bossfilter(c)
    -- Confere se o oponente do controlador possui o Boss na mesa
    return c:IsFaceup() and c:GetOriginalCode() == 777001120
end

function s.poscon(e)
    local tp = e:GetHandlerPlayer()
    return Duel.IsExistingMatchingCard(s.bossfilter, tp, 0, LOCATION_MZONE, 1, nil)
end

function s.postg(e, c)
    -- Afeta estritamente "all face-up monsters on the field"
    return c:IsFaceup()
end

-- ====================================================================
-- Efeito na Mão: Revelar e Colocar na Zona do Oponente
-- ====================================================================
function s.bossfilter(c)
    -- Confere se você controla o Lorde
    return c:IsFaceup() and c:GetOriginalCode() == 777001120
end

function s.placecon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.bossfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.placecost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    -- Confere se a carta não está pública (revelada por outro efeito) e revela como Custo
    if chk == 0 then return not c:IsPublic() end
    Duel.ConfirmCards(1 - tp, c)
end

function s.placetg(e, tp, eg, ep, ev, re, r, rp, chk)
    -- O único alvo necessário é ter espaço na Zona de S/T do oponente
    if chk == 0 then return Duel.GetLocationCount(1 - tp, LOCATION_SZONE) > 0 end
end

function s.placeop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    
    -- Coloca a carta diretamente virada para cima na zona do inimigo (1 - tp)
    if Duel.GetLocationCount(1 - tp, LOCATION_SZONE) > 0 then
        Duel.MoveToField(c, tp, 1 - tp, LOCATION_SZONE, POS_FACEUP, true)
    end
end