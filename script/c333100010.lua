-- Proto Warforged
local s,id=GetID()

-- Configurações de Arquétipo
local SETCODE_WARFORGED = 0x311
local CARD_FESTOS = 333100000
s.listed_names={CARD_FESTOS}

function s.initial_effect(c)
    -- 1) Procedimento Padrão de Gemini
    Gemini.AddProcedure(c)

    -- 2) Tratada como Magia de Equipamento na mão
    -- apenas enquanto controlar Festos
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_SET_AVAILABLE
        +EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCode(EFFECT_ADD_TYPE)
    e1:SetCondition(s.equiptypecon)
    e1:SetValue(TYPE_SPELL+TYPE_EQUIP)
    c:RegisterEffect(e1)

    -- Limite de Equipamento
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_EQUIP_LIMIT)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- 3) Efeito Central
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE+LOCATION_SZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(s.effcon)
    e3:SetCost(s.effcost)
    e3:SetTarget(s.efftg)
    e3:SetOperation(s.effop)
    c:RegisterEffect(e3)
end

-- Configurações de Arquétipo
local SETCODE_WARFORGED = 0x311
local CARD_FESTOS = 333100000 -- ID do Festos
s.listed_names={CARD_FESTOS}

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
-- EFEITO CENTRAL
-- ==========================================
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return (c:IsLocation(LOCATION_MZONE) and Gemini.EffectStatusCondition(e))
        or (c:IsLocation(LOCATION_SZONE) and c:GetEquipTarget()~=nil)
end

function s.costfilter(c,e,tp)
    -- Aceita qualquer Equip Spell ou monstros Warforged nativos
    local is_equip = (c:IsType(TYPE_EQUIP))
    return is_equip and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,c,e,tp)
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
    Duel.ConfirmCards(1-tp,g)
    Duel.ShuffleHand(tp)
    e:SetLabelObject(g:GetFirst())
    g:GetFirst():CreateEffectRelation(e)
end

function s.spfilter(c,e,tp)
    return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end

function s.effop(e,tp,eg,ep,ev,re,r,rp)
    local eqc=e:GetLabelObject()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,eqc,e,tp)
    local tc=g:GetFirst()
    
    if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
        
        -- Altera a Raça para Machine
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_RACE)
        e1:SetValue(RACE_MACHINE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        
        -- Adiciona o SetCode Warforged
        local e2=e1:Clone()
        e2:SetCode(EFFECT_ADD_SETCODE)
        e2:SetValue(SETCODE_WARFORGED)
        tc:RegisterEffect(e2)
        
        Duel.SpecialSummonComplete()
        
        -- Processo de Equipar
        if eqc and eqc:IsRelateToEffect(e) and eqc:IsLocation(LOCATION_HAND) then
            if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
                if eqc:IsOriginalType(TYPE_MONSTER) then
                    local eqlimit=Effect.CreateEffect(e:GetHandler())
                    eqlimit:SetType(EFFECT_TYPE_SINGLE)
                    eqlimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                    eqlimit:SetCode(EFFECT_EQUIP_LIMIT)
                    eqlimit:SetValue(s.dyn_eqlimit)
                    eqlimit:SetLabelObject(tc)
                    eqlimit:SetReset(RESET_EVENT+RESETS_STANDARD)
                    eqc:RegisterEffect(eqlimit)
                end
                Duel.Equip(tp,eqc,tc)
            end
        end
    end
end
function s.dyn_eqlimit(e,c)
    return c==e:GetLabelObject()
end