-- Draconic Soulstealer - Raven
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Special Summon Inerente do GY (Se controlar "Draconic")
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_GRAVE)
    -- O "once per turn this way" exige a flag OATH
    e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Efeito 2: Redução de ATK do Oponente (Condição: Blaze)
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0, LOCATION_MZONE) -- Afeta apenas os monstros do oponente
    e2:SetCondition(s.atkcon)
    e2:SetValue(s.atkval)
    c:RegisterEffect(e2)

    -- Efeito 3: Banir Dragão do ED -> Equipar monstro do Oponente (Max 1)
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_EQUIP)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, id + 1)
    e3:SetCondition(s.eqcon)
    e3:SetCost(s.eqcost)
    e3:SetTarget(s.eqtg)
    e3:SetOperation(s.eqop)
    c:RegisterEffect(e3)

    -- Efeito 4: Proteção Substitutiva (Banir o Equipamento)
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_DESTROY_REPLACE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTarget(s.reptg)
    e4:SetOperation(s.repop)
    c:RegisterEffect(e4)
end

-- ====================================================================
-- Filtro Global do Blaze e dos Draconics
-- ====================================================================
function s.draconicfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x300)
end

function s.blazefilter(c)
    return c:IsFaceup() and c:GetOriginalCode() == 777000680
end

-- ====================================================================
-- Efeito 1: Special Summon do GY (Com Restrição de Banir)
-- ====================================================================
function s.spcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and Duel.IsExistingMatchingCard(s.draconicfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, c)
    return true
end

function s.spop(e, tp, eg, ep, ev, re, r, rp, c)
    -- Adiciona a restrição de "banish when it leaves the field" assim que é invocado
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(3300) -- Mensagem visual no EDOPro
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CLIENT_HINT)
    e1:SetReset(RESET_EVENT + RESETS_REDIRECT)
    e1:SetValue(LOCATION_REMOVED)
    c:RegisterEffect(e1, true)
end

-- ====================================================================
-- Efeito 2: Debuff Baseado em Cartas Banidas
-- ====================================================================
function s.atkcon(e)
    return Duel.IsExistingMatchingCard(s.blazefilter, e:GetHandlerPlayer(), LOCATION_MZONE, 0, 1, nil)
end

function s.atkval(e, c)
    -- Conta todas as cartas banidas em ambos os campos e multiplica por -100
    local ct = Duel.GetFieldGroupCount(e:GetHandlerPlayer(), LOCATION_REMOVED, LOCATION_REMOVED)
    return ct * -100
end

-- ====================================================================
-- Efeito 3: Equipar Monstro do Oponente (Max 1)
-- ====================================================================
function s.has_equip_filter(c)
    -- Verifica se já possui uma carta equipada através deste efeito
    return c:GetFlagEffect(id) > 0
end

function s.eqcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    -- Só permite ativar se não houver um equipamento deste efeito ativo
    return not c:GetEquipGroup():IsExists(s.has_equip_filter, 1, nil)
end

function s.cfilter(c)
    return c:IsRace(RACE_DRAGON) and c:IsAbleToRemoveAsCost()
end

function s.eqcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_EXTRA, 0, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectMatchingCard(tp, s.cfilter, tp, LOCATION_EXTRA, 0, 1, 1, nil)
    Duel.Remove(g, POS_FACEUP, REASON_COST)
end

function s.tgfilter(c)
    return c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end

function s.eqtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE + LOCATION_GRAVE) and chkc:IsControler(1 - tp) and s.tgfilter(chkc) end
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_SZONE) > 0
        and Duel.IsExistingTarget(s.tgfilter, tp, 0, LOCATION_MZONE + LOCATION_GRAVE, 1, nil) end
        
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
    local g = Duel.SelectTarget(tp, s.tgfilter, tp, 0, LOCATION_MZONE + LOCATION_GRAVE, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_EQUIP, g, 1, 0, 0)
    -- Informa à engine a mudança de zona (Cemitério -> Magia/Armadilha) caso seja escolhido do GY
    if g:GetFirst():IsLocation(LOCATION_GRAVE) then
        Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, g, 1, 0, 0)
    end
end

function s.eqlimit(e, c)
    return c == e:GetLabelObject()
end

function s.eqop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    
    if Duel.GetLocationCount(tp, LOCATION_SZONE) <= 0 then return end
    
    if c:IsFaceup() and c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) then
        if Duel.Equip(tp, tc, c) then
            -- Marca o monstro com a flag deste efeito
            tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD, 0, 1)
            
            -- Aplica a regra oficial do equipamento
            local e1 = Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_EQUIP_LIMIT)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetReset(RESET_EVENT + RESETS_STANDARD)
            e1:SetValue(s.eqlimit)
            e1:SetLabelObject(c)
            tc:RegisterEffect(e1)
        end
    end
end

-- ====================================================================
-- Efeito 4: Substituição de Destruição (Banir o Equipado)
-- ====================================================================
function s.repfilter(c)
    -- Procura a carta que possui a nossa Flag e que pode ser banida
    return c:GetFlagEffect(id) > 0 and c:IsAbleToRemove()
end

function s.reptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        -- Checa se ele seria destruído e se tem o equipamento disponível para o sacrifício
        return not c:IsReason(REASON_REPLACE)
            and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT))
            and c:GetEquipGroup():IsExists(s.repfilter, 1, nil)
    end
    -- Abre a janela de confirmação para o jogador (String 96 é padrão de sistema "Deseja usar o efeito?")
    if Duel.SelectEffectYesNo(tp, c, 96) then
        return true
    else
        return false
    end
end

function s.repop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = c:GetEquipGroup():Filter(s.repfilter, nil)
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local sg = g:Select(tp, 1, 1, nil)
    -- Bane a carta ao invés de destruir o Raven
    Duel.Remove(sg, POS_FACEUP, REASON_EFFECT + REASON_REPLACE)
end