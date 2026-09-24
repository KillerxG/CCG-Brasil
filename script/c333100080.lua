-- Warforged Furnace
local s,id=GetID()
function s.initial_effect(c)
    -- Invocação Xyz Padrão (2 Monstros Level 4 "Warforged")
    c:EnableReviveLimit()
    Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x311),4,2)
    
    -- Invocação Xyz Alternativa (2 Equip Spells "Warforged" da Mão/SZone)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCondition(s.altxyzcon)
    e1:SetTarget(s.altxyztg)
    e1:SetOperation(s.altxyzop)
    e1:SetValue(SUMMON_TYPE_XYZ)
    c:RegisterEffect(e1)
    
    -- Tratada como Monstro Normal (Remove o Tipo Efeito dinamicamente)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
    e2:SetCode(EFFECT_ADD_TYPE)
    e2:SetCondition(s.normcon)
    e2:SetValue(TYPE_NORMAL)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EFFECT_REMOVE_TYPE)
    e3:SetValue(TYPE_EFFECT)
    c:RegisterEffect(e3)

    -- ==========================================
    -- EFEITOS DE MONSTRO DE EFEITO
    -- ==========================================
    
    -- Efeito 1: Detach e Buscar Equipamento
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,id)
    e4:SetCondition(s.effcon)
    e4:SetCost(Cost.DetachFromSelf(1))
    e4:SetTarget(s.thtg)
    e4:SetOperation(s.thop)
    c:RegisterEffect(e4)
    
    -- Efeito 2a: Bounce Equip e Roubar carta (Ignition - Festos ausente)
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,2))
    e5:SetCategory(CATEGORY_TOHAND)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1,id+1)
    e5:SetCondition(s.igcon)
    e5:SetTarget(s.atctg)
    e5:SetOperation(s.atcop)
    c:RegisterEffect(e5)
    
    -- Efeito 2b: Bounce Equip e Roubar carta (Quick Effect - Festos presente)
    local e6=e5:Clone()
    e6:SetType(EFFECT_TYPE_QUICK_O)
    e6:SetCode(EVENT_FREE_CHAIN)
    e6:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e6:SetCondition(s.quickcon)
    c:RegisterEffect(e6)
end

local SETCODE_WARFORGED = 0x311
local CARD_FESTOS = 333100000

-- ==========================================
-- INVOCAÇÃO XYZ ALTERNATIVA
-- ==========================================
function s.altxyzfilter(c)
    return c:IsType(TYPE_EQUIP) and c:IsSetCard(SETCODE_WARFORGED) 
        and (c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_SZONE) and c:IsFaceup()))
end
function s.altxyzcon(e,c,og,min,max)
    if c==nil then return true end
    local tp=c:GetControler()
    local mg=Duel.GetMatchingGroup(s.altxyzfilter,tp,LOCATION_HAND+LOCATION_SZONE,0,nil)
    return #mg>=2 and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.altxyztg(e,tp,eg,ep,ev,re,r,rp,chk,c,og,min,max)
    local mg=Duel.GetMatchingGroup(s.altxyzfilter,tp,LOCATION_HAND+LOCATION_SZONE,0,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local sg=mg:Select(tp,2,2,nil)
    if sg then
        sg:KeepAlive()
        e:SetLabelObject(sg)
        return true
    end
    return false
end
function s.altxyzop(e,tp,eg,ep,ev,re,r,rp,c,og,min,max)
    local mg=e:GetLabelObject()
    if not mg then return end
    c:SetMaterial(mg)
    Duel.Overlay(c,mg)
    mg:DeleteGroup()
end

-- ==========================================
-- CONTROLO DE STATUS E CONDIÇÕES
-- ==========================================
function s.has_equip(c)
    local has_eq = c:GetEquipGroup():IsExists(Card.IsType,1,nil,TYPE_EQUIP)
    local has_mat = c:GetOverlayGroup():IsExists(Card.IsType,1,nil,TYPE_EQUIP)
    return has_eq or has_mat
end
function s.normcon(e)
    return not s.has_equip(e:GetHandler())
end

-- Condição Efeito 1 (Buscar)
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
    return s.has_equip(e:GetHandler())
end

-- Validação de Festos no Campo
function s.festos_filter(c)
    return c:IsFaceup() and c:IsCode(CARD_FESTOS)
end

-- Condição Efeito 2a (Ignição: Sem Festos)
function s.igcon(e,tp,eg,ep,ev,re,r,rp)
    return s.has_equip(e:GetHandler()) and not Duel.IsExistingMatchingCard(s.festos_filter,tp,LOCATION_MZONE,0,1,nil)
end

-- Condição Efeito 2b (Rápido: Com Festos)
function s.quickcon(e,tp,eg,ep,ev,re,r,rp)
    return s.has_equip(e:GetHandler()) and Duel.IsExistingMatchingCard(s.festos_filter,tp,LOCATION_MZONE,0,1,nil)
end

-- ==========================================
-- EFEITO 1: BUSCA DE EQUIP SPELL
-- ==========================================
function s.thfilter(c)
    return c:IsType(TYPE_EQUIP) and c:IsSetCard(SETCODE_WARFORGED) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- ==========================================
-- EFEITO 2: BOUNCE + ROUBAR PARA MATÉRIA XYZ
-- ==========================================
function s.eqtargetfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
function s.oppfilter(c)
    return c:IsFaceup() and not c:IsType(TYPE_TOKEN)
end
function s.atctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    if chk==0 then return Duel.IsExistingTarget(s.eqtargetfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
        and Duel.IsExistingTarget(s.oppfilter,tp,0,LOCATION_ONFIELD,1,nil) end
        
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g1=Duel.SelectTarget(tp,s.eqtargetfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local g2=Duel.SelectTarget(tp,s.oppfilter,tp,0,LOCATION_ONFIELD,1,1,g1:GetFirst())
    
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,1,0,0)
end
function s.atcop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ex, tg = Duel.GetOperationInfo(0,CATEGORY_TOHAND)
    local tc_eq = tg:GetFirst()
    
    local g = Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    local tc_opp = g:Filter(aux.TRUE, tc_eq):GetFirst()
    
    if tc_eq and tc_eq:IsRelateToEffect(e) then
        if Duel.SendtoHand(tc_eq,nil,REASON_EFFECT)>0 and tc_eq:IsLocation(LOCATION_HAND) then
            if tc_opp and tc_opp:IsRelateToEffect(e) and not tc_opp:IsImmuneToEffect(e) and c:IsRelateToEffect(e) and c:IsType(TYPE_XYZ) then
                Duel.Overlay(c,tc_opp)
            end
        end
    end
end