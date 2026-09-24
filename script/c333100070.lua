-- Warforged Refined Tool
local s,id=GetID()
local SETCODE_WARFORGED = 0x311 

function s.initial_effect(c)
    -- 1) Ativação da Mão (Rota 1: Alvo normal | Rota 2: Sem monstros)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_EQUIP+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target1)
    e1:SetOperation(s.op1)
    c:RegisterEffect(e1)

    -- 2) Ativação do Cemitério (Rota 3: Sem monstros)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_EQUIP+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH) 
    e2:SetCondition(s.gycon)
    e2:SetTarget(s.target2)
    e2:SetOperation(s.op2)
    c:RegisterEffect(e2)

    -- Limite de Equipamento Padrão
    local e_limit=Effect.CreateEffect(c)
    e_limit:SetType(EFFECT_TYPE_SINGLE)
    e_limit:SetCode(EFFECT_EQUIP_LIMIT)
    e_limit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e_limit:SetValue(s.eqlimit)
    c:RegisterEffect(e_limit)

    -- 3) Ganho de ATK/DEF Passivo
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_EQUIP)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
    e3:SetValue(s.atkval)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e4)

    -- 4) Gatilho: Saiu do Campo
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,5))
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCode(EVENT_TO_GRAVE)
    e5:SetCountLimit(1,id+1)
    e5:SetCondition(s.lvcon)
    e5:SetCost(s.lvcost)
    e5:SetTarget(s.lvtg)
    e5:SetOperation(s.lvop)
    c:RegisterEffect(e5)
end

-- ==========================================
-- LIMITADOR E ATK
-- ==========================================
function s.eqlimit(e,c)
    return c:IsAttribute(ATTRIBUTE_FIRE) or c:IsSetCard(SETCODE_WARFORGED)
end
function s.atkval(e,c)
    return Duel.GetMatchingGroupCount(Card.IsType,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil,TYPE_EQUIP)*200
end

-- ==========================================
-- EFEITO 1 E 2: ATIVAÇÃO (Mão e GY)
-- ==========================================
function s.eqfilter(c)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE)
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(SETCODE_WARFORGED) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local b1 = Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil)
    local b2 = Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
               and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
               
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
    if chk==0 then return b1 or b2 end
    
    local op = 0
    if b1 and b2 then
        op = Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
    elseif b1 then op = 0
    else op = 1 end
    e:SetLabel(op)
    
    if op==0 then
        e:SetProperty(EFFECT_FLAG_CARD_TARGET)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
        Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
        Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
    else
        e:SetProperty(0)
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
        Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
    end
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    
    if e:GetLabel()==0 then
        local tc=Duel.GetFirstTarget()
        if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
            Duel.Equip(tp,c,tc)
        end
    else
        s.resolve_combo(c,e,tp)
    end
end

function s.gycon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        s.resolve_combo(c,e,tp)
    end
end

-- ==========================================
-- A LÓGICA DE COMBO E INJEÇÃO NA CARTA
-- ==========================================
function s.thfilter(c,lvl)
    return c:IsSetCard(SETCODE_WARFORGED) and c:IsType(TYPE_MONSTER) and c:GetLevel()==lvl and c:IsAbleToHand()
end

function s.resolve_combo(c,e,tp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    
    if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
        if c:IsLocation(LOCATION_SZONE) then
            c:CancelToGrave()
        end

        Duel.SpecialSummonComplete()
        Duel.Equip(tp,c,tc)
        
        local thg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,tc:GetLevel())
        if #thg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local sg=thg:Select(tp,1,1,nil)
            local add_card=sg:GetFirst()
            
            if Duel.SendtoHand(add_card,nil,REASON_EFFECT)>0 and add_card:IsLocation(LOCATION_HAND) then
                Duel.ConfirmCards(1-tp,add_card)
                
                local e_type=Effect.CreateEffect(c)
                e_type:SetType(EFFECT_TYPE_SINGLE)
                e_type:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
                e_type:SetCode(EFFECT_ADD_TYPE)
                e_type:SetValue(TYPE_SPELL+TYPE_EQUIP)
                e_type:SetReset(RESET_EVENT+RESETS_STANDARD)
                add_card:RegisterEffect(e_type)
                
                local e_ign=Effect.CreateEffect(c)
                e_ign:SetDescription(aux.Stringid(id,3))
                e_ign:SetCategory(CATEGORY_EQUIP)
                e_ign:SetType(EFFECT_TYPE_IGNITION)
                e_ign:SetRange(LOCATION_HAND)
                e_ign:SetProperty(EFFECT_FLAG_CARD_TARGET)
                e_ign:SetTarget(s.addeqtg)
                e_ign:SetOperation(s.addeqop)
                e_ign:SetReset(RESET_EVENT+RESETS_STANDARD)
                add_card:RegisterEffect(e_ign)
                
                local e_race=Effect.CreateEffect(c)
                e_race:SetType(EFFECT_TYPE_EQUIP)
                e_race:SetCode(EFFECT_CHANGE_RACE)
                e_race:SetValue(RACE_MACHINE)
                e_race:SetReset(RESET_EVENT+RESETS_STANDARD)
                add_card:RegisterEffect(e_race)
                
                local e_set=e_race:Clone()
                e_set:SetCode(EFFECT_ADD_SETCODE)
                e_set:SetValue(SETCODE_WARFORGED)
                add_card:RegisterEffect(e_set)
            end
        end
    else
        c:CancelToGrave(false)
    end
end

function s.eqfilter_added(c)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE)
end
function s.addeqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter_added(chkc) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 
        and Duel.IsExistingTarget(s.eqfilter_added,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    Duel.SelectTarget(tp,s.eqfilter_added,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.addeqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local tc=Duel.GetFirstTarget()
    if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        local eqlimit=Effect.CreateEffect(c)
        eqlimit:SetType(EFFECT_TYPE_SINGLE)
        eqlimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        eqlimit:SetCode(EFFECT_EQUIP_LIMIT)
        eqlimit:SetValue(s.dyn_eqlimit)
        eqlimit:SetLabelObject(tc)
        eqlimit:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(eqlimit)
        Duel.Equip(tp,c,tc)
    end
end
function s.dyn_eqlimit(e,c)
    return c==e:GetLabelObject()
end

-- ==========================================
-- EFEITO CEMITÉRIO (SAIU DO CAMPO)
-- ==========================================
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ec=c:GetPreviousEquipTarget()
    -- Segurança adicionada: Apenas se for para o GY ou Banido face-up! Ignora Deck, Mão e Banido face-down.
    return c:IsReason(REASON_LOST_TARGET) and ec 
        and ec:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and not ec:IsFacedown()
end
function s.lvcostfilter(c)
    return c:IsType(TYPE_EQUIP) and not c:IsPublic()
end
function s.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.lvcostfilter,tp,LOCATION_HAND,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(tp,s.lvcostfilter,tp,LOCATION_HAND,0,1,1,nil)
    Duel.ConfirmCards(1-tp,g)
    e:SetLabelObject(g:GetFirst()) 
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ec=e:GetHandler():GetPreviousEquipTarget()
    if chk==0 then return ec and ec:IsCanBeSpecialSummoned(e,0,tp,false,false)
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,ec,1,0,0)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
    local ec=e:GetHandler():GetPreviousEquipTarget()
    local eq_card=e:GetLabelObject()
    if not ec or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    
    if Duel.SpecialSummon(ec,0,tp,tp,false,false,POS_FACEUP)>0 then
        if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and eq_card and eq_card:IsLocation(LOCATION_HAND) then
            if eq_card:IsOriginalType(TYPE_MONSTER) then
                local eqlimit=Effect.CreateEffect(e:GetHandler())
                eqlimit:SetType(EFFECT_TYPE_SINGLE)
                eqlimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                eqlimit:SetCode(EFFECT_EQUIP_LIMIT)
                eqlimit:SetValue(s.dyn_eqlimit)
                eqlimit:SetLabelObject(ec)
                eqlimit:SetReset(RESET_EVENT+RESETS_STANDARD)
                eq_card:RegisterEffect(eqlimit)
            end
            Duel.Equip(tp,eq_card,ec)
        end
    end
end