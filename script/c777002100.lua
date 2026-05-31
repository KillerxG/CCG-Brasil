-- Rockslash Ancient Inscription
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Ativação Padrão de Magia Contínua
    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    -- Condição: Controlar apenas 1 "Rockslash Ancient Inscription"
    c:SetUniqueOnField(1, 0, id)

    -- Efeito 1: Qualquer ganho de LP do oponente vira Dano (Efeito Simochi)
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_REVERSE_RECOVER)
    e1:SetRange(LOCATION_SZONE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(0, 1) -- Afeta apenas o oponente
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- Efeito 2: Você não toma dano de efeito
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CHANGE_DAMAGE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetTargetRange(1, 0) -- Afeta apenas você
    e2:SetValue(s.damval)
    c:RegisterEffect(e2)
    local e3 = e2:Clone()
    e3:SetCode(EFFECT_NO_EFFECT_DAMAGE)
    c:RegisterEffect(e3)

    -- Efeito 3: Gatilho - Oponente toma dano de efeito -> Causar mais dano
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetCategory(CATEGORY_DAMAGE)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DAMAGE_STEP)
    e4:SetCode(EVENT_DAMAGE)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCondition(s.trigcon)
    e4:SetTarget(s.trigtg)
    e4:SetOperation(s.trigop)
    c:RegisterEffect(e4)
end

-- ====================================================================
-- Efeito 2: Zera o dano se for de Efeito
-- ====================================================================
function s.damval(e, re, val, r, rp, rc)
    if (r & REASON_EFFECT) ~= 0 then return 0 end
    return val
end

-- ====================================================================
-- Efeito 3: Gatilho de Dano Secundário
-- ====================================================================
function s.harunafilter(c)
    -- Confere se a "Master of Rockslash - Haruna" está no campo
    return c:IsFaceup() and c:GetOriginalCode() == 777002010
end

function s.trigcon(e, tp, eg, ep, ev, re, r, rp)
    -- Checa se o dano foi no oponente, se foi de efeito, e garante que NÃO foi ativado por esta carta
    return ep == 1 - tp and (r & REASON_EFFECT) ~= 0 and (not re or re:GetHandler() ~= e:GetHandler())
        and Duel.IsExistingMatchingCard(s.harunafilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.tgfilter(c)
    -- Tem que ser um "Rockslash", virado para cima, e possuir Nível (monstros Link e Xyz não passam)
    return c:IsFaceup() and c:IsSetCard(0x309) and c:HasLevel()
end

function s.trigtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.tgfilter, tp, LOCATION_MZONE, 0, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local g = Duel.SelectTarget(tp, s.tgfilter, tp, LOCATION_MZONE, 0, 1, 1, nil)
    
    -- Calcula a projeção do dano para o sistema registrar corretamente
    local tc = g:GetFirst()
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, tc:GetLevel() * 100)
end

function s.trigop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    -- Na resolução, confirma se o monstro alvejado ainda está no campo e virado para cima
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        Duel.Damage(1 - tp, tc:GetLevel() * 100, REASON_EFFECT)
    end
end