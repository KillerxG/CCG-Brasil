-- Shinigami Sanzu River
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Ativação Padrão da Armadilha Contínua
    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
    c:RegisterEffect(e0)

    -- Efeito 1: Todos os monstros que o controlador possui perdem 200 de ATK/DEF por cada carta no GY dele
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTargetRange(LOCATION_MZONE, 0) -- Afeta apenas o lado de quem controla a Armadilha
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)
    local e2 = e1:Clone()
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e2)

    -- Efeito 2: O controlador não pode Invocar por Invocação-Especial do próprio GY
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e3:SetRange(LOCATION_SZONE)
    e3:SetTargetRange(1, 0) -- Aplica a trava ao controlador da Armadilha
    e3:SetTarget(s.splimit)
    c:RegisterEffect(e3)

    -- Efeito 3: Se o oponente do controlador possui o "Lord of Shinigamis - Darkness", o controlador não ativa efeitos no GY
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetCode(EFFECT_CANNOT_ACTIVATE)
    e4:SetRange(LOCATION_SZONE)
    e4:SetTargetRange(1, 0)
    e4:SetCondition(s.actcon)
    e4:SetValue(s.actlimit)
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
-- Efeito 1: Perda Dinâmica de ATK/DEF
-- ====================================================================
function s.atkval(e, c)
    local tp = e:GetHandlerPlayer()
    -- Conta as cartas no Cemitério de quem está controlando esta Armadilha e multiplica
    return Duel.GetFieldGroupCount(tp, LOCATION_GRAVE, 0) * -200
end

-- ====================================================================
-- Efeito 2: Trava de Special Summon (Apenas do próprio GY)
-- ====================================================================
function s.splimit(e, c, sump, sumtype, sumpos, targetp, se)
    -- Impede que a invocação saia do Cemitério do jogador afetado
    return c:IsLocation(LOCATION_GRAVE) and c:IsControler(targetp)
end

-- ====================================================================
-- Efeito 3: Trava de Efeitos no Cemitério (Condicionada ao Boss)
-- ====================================================================
function s.darknessfilter(c)
    -- Confere o código original exatamente como me passou
    return c:IsFaceup() and c:GetOriginalCode() == 777001120
end

function s.actcon(e)
    local tp = e:GetHandlerPlayer()
    -- Confere se o Boss está do lado OPOSTO (0, LOCATION_MZONE) a quem controla a Armadilha
    return Duel.IsExistingMatchingCard(s.darknessfilter, tp, 0, LOCATION_MZONE, 1, nil)
end

function s.actlimit(e, re, tp)
    -- Trava qualquer efeito cuja ativação ocorra fisicamente dentro do Cemitério
    return re:GetActivateLocation() == LOCATION_GRAVE
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