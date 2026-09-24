--Warforged Enforce
local s,id=GetID()
function s.initial_effect(c)
    -- 1) Procedimento Padrão de Gemini
    Gemini.AddProcedure(c)
    
    -- 2) Tratada como Magia de Equipamento na Mão (Forçado para a Engine)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCode(EFFECT_ADD_TYPE)
    e1:SetCondition(s.equiptypecon)
    e1:SetValue(TYPE_SPELL+TYPE_EQUIP)
    c:RegisterEffect(e1)
    
    -- Limite de Equipamento de Segurança
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_EQUIP_LIMIT)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- 3) Efeito de Substituição Contínuo (Protege de Destruição)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EFFECT_DESTROY_REPLACE)
    e3:SetRange(LOCATION_MZONE+LOCATION_SZONE)
    e3:SetCondition(s.repcon)
    e3:SetTarget(s.reptg)
    e3:SetValue(s.repval)
    e3:SetOperation(s.repop)
    e3:SetCountLimit(1,id)
    c:RegisterEffect(e3)
    
    -- 4) Efeito de Substituição Contínuo (Protege de Banimento - CONSTANTE CORRIGIDA)
    local e4=e3:Clone()
    e4:SetCode(EFFECT_SEND_REPLACE)
    e4:SetTarget(s.rmreptg)
    e4:SetValue(s.rmrepval)
    c:RegisterEffect(e4)
end

-- Configurações
local SETCODE_WARFORGED = 0x311
local CARD_FESTOS = 333100000 -- O teu Alias
s.listed_names={CARD_FESTOS}

-- ==========================================
-- A TUA LÓGICA DO FESTOS
-- ==========================================
-- Festos precisa estar face-up na MZONE
function s.festos_exists(tp)
    return Duel.IsExistingMatchingCard(
        aux.FaceupFilter(Card.IsCode,CARD_FESTOS),
        tp,LOCATION_MZONE,0,1,nil
    )
end

-- Só ganha TYPE_SPELL + TYPE_EQUIP na mão com Festos
function s.equiptypecon(e)
    return s.festos_exists(e:GetHandlerPlayer())
end


-- ==========================================
-- CONDIÇÃO GERAL DO EFEITO GEMINI
-- ==========================================
function s.repcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- Ativo se for Monstro Gemini ativado na MZONE OU se for Magia equipada na SZONE
    return (c:IsLocation(LOCATION_MZONE) and Gemini.EffectStatusCondition(e))
        or (c:IsLocation(LOCATION_SZONE) and c:GetEquipTarget()~=nil)
end

-- ==========================================
-- SUBSTITUIÇÃO PARA DESTRUIÇÃO (e3)
-- ==========================================
function s.repcostfilter(c)
    return c:IsType(TYPE_EQUIP) and c:IsAbleToGrave()
end
function s.repfilter(c,tp)
    return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(SETCODE_WARFORGED)
        and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
        and Duel.IsExistingMatchingCard(s.repcostfilter,tp,LOCATION_HAND,0,1,nil)
        and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
        
    -- Pergunta ao jogador se ele quer aplicar a substituição
    if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        -- Envia a Magia de Equipamento
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local g=Duel.SelectMatchingCard(tp,s.repcostfilter,tp,LOCATION_HAND,0,1,1,nil)
        Duel.SendtoGrave(g,REASON_EFFECT+REASON_REPLACE)
        
        -- Seleciona a carta no campo para baralhar (sem dar alvo)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
        e:SetLabelObject(sg:GetFirst())
        sg:GetFirst():CreateEffectRelation(e)
        return true
    end
    return false
end
function s.repval(e,c)
    return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_REPLACE)
    end
end

-- ==========================================
-- SUBSTITUIÇÃO PARA BANIMENTO (e4)
-- ==========================================
function s.rmrepfilter(c,tp)
    return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(SETCODE_WARFORGED)
        and c:GetDestination()==LOCATION_REMOVED and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.rmreptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return eg:IsExists(s.rmrepfilter,1,nil,tp)
        and Duel.IsExistingMatchingCard(s.repcostfilter,tp,LOCATION_HAND,0,1,nil)
        and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
        
    if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local g=Duel.SelectMatchingCard(tp,s.repcostfilter,tp,LOCATION_HAND,0,1,1,nil)
        Duel.SendtoGrave(g,REASON_EFFECT+REASON_REPLACE)
        
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
        e:SetLabelObject(sg:GetFirst())
        sg:GetFirst():CreateEffectRelation(e)
        return true
    end
    return false
end
function s.rmrepval(e,c)
    return s.rmrepfilter(c,e:GetHandlerPlayer())
end