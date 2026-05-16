-- East Wings Shaman
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Habilita o limite de invocação oficial para Monstros de Ritual
    c:EnableReviveLimit()
    
    -- Efeito 1: Se Invocado por Invocação-Ritual, colocar até 2 monstros do GY na S&T Zone
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetType(EFFECT_TYPE_SINGLE | EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCondition(s.plcon)
    e1:SetTarget(s.pltg)
    e1:SetOperation(s.plop)
    c:RegisterEffect(e1)
    
    -- Efeito 2: (Efeito Rápido) Enviar 1 S&T "East Wings" para o GY; Colocar monstro inimigo na S&T dele
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0, TIMINGS_CHECK_MONSTER_E | TIMING_MAIN_END)
    e2:SetCountLimit(1, {id, 2})
    e2:SetCost(s.tgcost)
    e2:SetTarget(s.tgtg)
    e2:SetOperation(s.tgop)
    c:RegisterEffect(e2)
end

s.listed_series = {0x314}
-- Registra que essa carta menciona especificamente a magia de ritual "East Wings Awakening"
s.listed_names = {777004880} 

-- ==========================================================
-- Efeito 1: Colocar do Cemitério na Zona S&T
-- ==========================================================
function s.plcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end

function s.plfilter(c)
    return c:IsSetCard(0x314) and c:IsMonster() and not c:IsForbidden()
end

function s.pltg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_SZONE) > 0
            and Duel.IsExistingMatchingCard(s.plfilter, tp, LOCATION_GRAVE, 0, 1, nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, nil, 1, tp, LOCATION_GRAVE)
end

function s.plop(e, tp, eg, ep, ev, re, r, rp)
    local ft = Duel.GetLocationCount(tp, LOCATION_SZONE)
    if ft <= 0 then return end
    -- Limita em no máximo 2 alvos como determina o texto da carta
    if ft > 2 then ft = 2 end 
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOFIELD)
    -- O filtro NecroValley previne problemas sistêmicos ao mover cartas do cemitério 
    local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.plfilter), tp, LOCATION_GRAVE, 0, 1, ft, nil)
    
    if #g > 0 then
        -- O iterador aux.Next desdobra a tabela para lidar de forma confiável com seleções múltiplas
        for tc in aux.Next(g) do
            if Duel.MoveToField(tc, tp, tp, LOCATION_SZONE, POS_FACEUP, true) then
                local e1 = Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_CHANGE_TYPE)
                e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                e1:SetValue(TYPE_SPELL | TYPE_CONTINUOUS)
                e1:SetReset(RESET_EVENT | RESETS_STANDARD - RESET_TURN_SET)
                tc:RegisterEffect(e1)
            end
        end
    end
end

-- ==========================================================
-- Efeito 2: Enviar Magia/Monstro como Custo e Capturar Inimigo
-- ==========================================================
function s.cfilter(c)
    -- Usando sua recomendação: c:IsContinuousSpell() facilita a vida e checa se é Magia Contínua legalmente!
    return c:IsFaceup() and c:IsSetCard(0x314) and c:IsOriginalType(TYPE_MONSTER)
        and c:IsContinuousSpell() and c:IsAbleToGraveAsCost()
end

function s.tgcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_SZONE, 0, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, s.cfilter, tp, LOCATION_SZONE, 0, 1, 1, nil)
    Duel.SendtoGrave(g, REASON_COST)
end

function s.tgfilter(c)
    return c:IsFaceup() and not c:IsForbidden() 
end

function s.tgtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1 - tp) and s.tgfilter(chkc) end
    -- Confirma previamente se há espaço topológico na retaguarda inimiga (1 - tp)
    if chk == 0 then return Duel.GetLocationCount(1 - tp, LOCATION_SZONE) > 0
        and Duel.IsExistingTarget(s.tgfilter, tp, 0, LOCATION_MZONE, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    Duel.SelectTarget(tp, s.tgfilter, tp, 0, LOCATION_MZONE, 1, 1, nil)
end

function s.tgop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
        -- Se o oponente preencheu a zona no meio da Chain e não há espaço na resolução, manda para o GY por regra
        if Duel.GetLocationCount(1 - tp, LOCATION_SZONE) <= 0 then
            Duel.SendtoGrave(tc, REASON_RULE)
            return
        end
        
        -- Aloca a carta especificamente para as coordenadas do adversário com o parâmetro 'target_player' (1 - tp)
        if Duel.MoveToField(tc, tp, 1 - tp, LOCATION_SZONE, POS_FACEUP, true) then
            local e1 = Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CHANGE_TYPE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetValue(TYPE_SPELL | TYPE_CONTINUOUS)
            e1:SetReset(RESET_EVENT | RESETS_STANDARD - RESET_TURN_SET)
            tc:RegisterEffect(e1)
        end
    end
end