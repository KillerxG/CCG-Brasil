-- Warforged Companion
local s,id=GetID()
function s.initial_effect(c)
    -- 1) Ativação da Carta (Rotas 1 e 2: Alvo ou Invocar)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_EQUIP+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id) -- HARD ONCE PER TURN
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- 2) Limite de Equipamento Universal
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_EQUIP_LIMIT)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetValue(s.eqlimit)
    c:RegisterEffect(e2)

    -- 3) Altera Tipo para Machine
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_EQUIP)
    e3:SetCode(EFFECT_CHANGE_RACE)
    e3:SetValue(RACE_MACHINE)
    c:RegisterEffect(e3)

    -- 4) Adiciona SetCode Warforged
    local e4=e3:Clone()
    e4:SetCode(EFFECT_ADD_SETCODE)
    e4:SetValue(0x311)
    c:RegisterEffect(e4)

    -- 5) EFEITO RÁPIDO NATIVO NA PRÓPRIA MAGIA DE EQUIPAMENTO
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,2))
    e5:SetCategory(CATEGORY_EQUIP)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_SZONE)
    e5:SetCountLimit(1) -- SOFT ONCE PER TURN
    e5:SetTarget(s.exctg)
    e5:SetOperation(s.excop)
    c:RegisterEffect(e5)

    -- 6) Rota 3: Equipar do Cemitério
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,3))
    e6:SetCategory(CATEGORY_EQUIP)
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e6:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e6:SetCode(EVENT_SUMMON_SUCCESS)
    e6:SetRange(LOCATION_GRAVE)
    e6:SetCountLimit(1,id) -- HARD ONCE PER TURN (Partilhado)
    e6:SetCondition(s.gycon)
    e6:SetTarget(s.gytg)
    e6:SetOperation(s.gyop)
    c:RegisterEffect(e6)
    local e7=e6:Clone()
    e7:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e7)
end

local SETCODE_WARFORGED = 0x311

-- ==========================================
-- LIMITADOR DE EQUIPAMENTO
-- ==========================================
function s.eqlimit(e,c)
    return c:IsAttribute(ATTRIBUTE_FIRE) or c:IsSetCard(SETCODE_WARFORGED)
end

-- ==========================================
-- EFEITO 1: ATIVAÇÃO (Duas Rotas)
-- ==========================================
function s.eqfilter(c)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE)
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(SETCODE_WARFORGED) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local b1 = Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil)
    local b2 = Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
               and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
               
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
    if chk==0 then return b1 or b2 end
    
    local op = 0
    if b1 and b2 then
        op = Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
    elseif b1 then
        op = 0
    else
        op = 1
    end
    
    e:SetLabel(op)
    
    if op==0 then
        e:SetProperty(EFFECT_FLAG_CARD_TARGET)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
        Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
        Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
    else
        e:SetProperty(0)
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
        Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
    end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    
    local op=e:GetLabel()
    if op==0 then
        local tc=Duel.GetFirstTarget()
        if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
            Duel.Equip(tp,c,tc)
        end
    else
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
        local tc=g:GetFirst()
        if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
            Duel.SpecialSummonComplete()
            Duel.Equip(tp,c,tc)
        end
    end
end

-- ==========================================
-- EFEITO RÁPIDO NATIVO (Escavar)
-- ==========================================
function s.excfilter(c,tc,tp)
    if c:IsType(TYPE_EQUIP) then return c:CheckEquipTarget(tc) end
    if c:IsType(TYPE_MONSTER) then return true end
    return false
end

function s.exctg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local ec=c:GetEquipTarget() -- Precisamos saber em quem a magia está equipada
    local ct=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_SZONE,0,nil,TYPE_EQUIP)
    
    -- Exige que esteja equipada, que haja equips no campo, e cartas no deck suficientes
    if chk==0 then return ec and ct>0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=ct 
        and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end

function s.excop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler() 
    local ec=c:GetEquipTarget()
    if not c:IsRelateToEffect(e) or not ec then return end
    
    local ct=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_SZONE,0,nil,TYPE_EQUIP)
    if ct<=0 or Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<ct then return end
    
    Duel.ConfirmDecktop(tp,ct)
    local g=Duel.GetDecktopGroup(tp,ct)
    
    if #g>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
        -- Tenta equipar a nova carta no monstro principal (ec)
        local sg=g:FilterSelect(tp,s.excfilter,1,1,nil,ec,tp)
        
        if #sg>0 then
            local eq_card=sg:GetFirst()
            
            if eq_card:IsOriginalType(TYPE_MONSTER) then
                local eqlimit=Effect.CreateEffect(c)
                eqlimit:SetType(EFFECT_TYPE_SINGLE)
                eqlimit:SetCode(EFFECT_EQUIP_LIMIT)
                eqlimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                eqlimit:SetValue(s.dyn_eqlimit)
                eqlimit:SetLabelObject(ec)
                eqlimit:SetReset(RESET_EVENT+RESETS_STANDARD)
                eq_card:RegisterEffect(eqlimit)
            end
            
            if Duel.Equip(tp,eq_card,ec) and eq_card:IsOriginalType(TYPE_MONSTER) and eq_card:GetLevel()>0 then
                local val = eq_card:GetLevel() * 100 
                
                local atk=Effect.CreateEffect(c)
                atk:SetType(EFFECT_TYPE_EQUIP)
                atk:SetCode(EFFECT_UPDATE_ATTACK)
                atk:SetValue(val)
                atk:SetReset(RESET_EVENT+RESETS_STANDARD)
                eq_card:RegisterEffect(atk)
                
                local def=atk:Clone()
                def:SetCode(EFFECT_UPDATE_DEFENSE)
                eq_card:RegisterEffect(def)
            end
        end
    end
    Duel.ShuffleDeck(tp)
end
function s.dyn_eqlimit(e,c)
    return c==e:GetLabelObject()
end

-- ==========================================
-- EFEITO CEMITÉRIO (Reciclar Equipamento)
-- ==========================================
function s.cfilter_sum(c,tp)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsType(TYPE_NORMAL) and c:IsControler(tp)
end
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter_sum,1,nil,tp)
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return eg:IsContains(chkc) and s.cfilter_sum(chkc,tp) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingTarget(s.cfilter_sum,tp,LOCATION_MZONE,0,1,nil,tp) end
        
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    Duel.SelectTarget(tp,s.cfilter_sum,tp,LOCATION_MZONE,0,1,1,nil,tp)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        Duel.Equip(tp,c,tc)
    end
end