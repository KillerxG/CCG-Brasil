-- Warforged Gear Core
local s,id=GetID()
local SETCODE_WARFORGED = 0x311 

function s.initial_effect(c)
    -- 1) Ativação, Equipamento e Busca Opcional
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_EQUIP+CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- Limite de Equipamento
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_EQUIP_LIMIT)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetValue(s.eqlimit)
    c:RegisterEffect(e2)

    -- 2) Altera a Raça para Machine
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_EQUIP)
    e3:SetCode(EFFECT_CHANGE_RACE)
    e3:SetValue(RACE_MACHINE)
    c:RegisterEffect(e3)

    -- 3) Adiciona SetCode Warforged
    local e4=e3:Clone()
    e4:SetCode(EFFECT_ADD_SETCODE)
    e4:SetValue(SETCODE_WARFORGED)
    c:RegisterEffect(e4)

    -- 4) Ativa os Efeitos Gemini do monstro equipado
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_EQUIP)
    e5:SetCode(EFFECT_GEMINI_STATUS)
    c:RegisterEffect(e5)

    -- 5) Invocação Normal Ativada (ESCALA COM AS MAGIAS DE EQUIPAMENTO)
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,2))
    e6:SetCategory(CATEGORY_SUMMON)
    e6:SetType(EFFECT_TYPE_IGNITION)
    e6:SetRange(LOCATION_SZONE)
    -- Não usamos SetCountLimit fixo aqui. O limite é dinâmico!
    e6:SetTarget(s.sumtg)
    e6:SetOperation(s.sumop)
    c:RegisterEffect(e6)

    -- 6) Recuperar do Cemitério após Invocação Xyz
    local e7=Effect.CreateEffect(c)
    e7:SetDescription(aux.Stringid(id,1))
    e7:SetCategory(CATEGORY_TOHAND)
    e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e7:SetCode(EVENT_TO_GRAVE)
    e7:SetProperty(EFFECT_FLAG_DELAY)
    e7:SetCondition(s.gycon)
    e7:SetTarget(s.gytg)
    e7:SetOperation(s.gyop)
    c:RegisterEffect(e7)
end

-- ==========================================
-- EFEITOS DE EQUIPAMENTO E BUSCA
-- ==========================================
function s.eqlimit(e,c)
    return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsControler(e:GetHandlerPlayer())
end
function s.eqfilter(c)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.thfilter(c)
    return c:IsSetCard(SETCODE_WARFORGED) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        Duel.Equip(tp,c,tc)
        local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
        if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local sg=g:Select(tp,1,1,nil)
            if #sg>0 then
                Duel.SendtoHand(sg,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,sg)
            end
        end
    end
end

-- ==========================================
-- INVOCACÃO NORMAL ATIVADA (DINÂMICA)
-- ==========================================
function s.sumfilter(c)
    return c:IsType(TYPE_GEMINI) and c:IsSummonable(true,nil)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
    -- Conta quantas Magias de Equipamento viradas para cima você controla
    local eq_count = Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsType,TYPE_EQUIP),tp,LOCATION_SZONE,0,nil)
    -- Verifica quantas vezes a Flag deste efeito já foi registrada neste turno
    local used_count = Duel.GetFlagEffect(tp,id)
    
    if chk==0 then return used_count < eq_count 
        and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    
    -- Dupla checagem por segurança na resolução
    local eq_count = Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsType,TYPE_EQUIP),tp,LOCATION_SZONE,0,nil)
    local used_count = Duel.GetFlagEffect(tp,id)
    if used_count >= eq_count then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
    local g=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
    local tc=g:GetFirst()
    if tc then
        -- Registra +1 uso deste efeito na memória do turno para não bugar
        Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
        -- Realiza a Invocação Normal extra
        Duel.Summon(tp,tc,true,nil) 
    end
end

-- ==========================================
-- EFEITO CEMITÉRIO (XYZ RECOVER)
-- ==========================================
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsReason(REASON_LOST_TARGET) then return false end
    local ec=c:GetPreviousEquipTarget()
    
    return ec and ec:IsReason(REASON_XYZ)
        and ec:GetReasonCard() and ec:GetReasonCard():IsSetCard(SETCODE_WARFORGED)
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToHand() end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SendtoHand(c,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,c)
    end
end