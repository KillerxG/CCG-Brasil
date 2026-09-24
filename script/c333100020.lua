-- Proto Warforged
local s,id=GetID()
function s.initial_effect(c)
    -- 1) Procedimento Padrão de Gemini
    Gemini.AddProcedure(c)
    
    -- 2) Tratada como Magia de Equipamento na Mão
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

    -- 3) Efeito Central Gemini (Invocar Normal Monster e Mudar Nível)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE+LOCATION_SZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(s.effcon)
    e3:SetCost(s.spcost)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

-- Configurações de Arquétipo e IDs
local SETCODE_WARFORGED = 0x311
local CARD_FESTOS = 333100000 -- O ID Alias correto descoberto!
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
-- EFEITO GEMINI (Custo: Enviar Magia, Declarar Nível)
-- ==========================================
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return (c:IsLocation(LOCATION_MZONE) and Gemini.EffectStatusCondition(e))
        or (c:IsLocation(LOCATION_SZONE) and c:GetEquipTarget()~=nil)
end
function s.cfilter(c)
    -- Aceita qualquer Equip Spell na mão (incluindo Warforged tratados como tal)
    return c:IsType(TYPE_EQUIP) and c:IsAbleToGraveAsCost()
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
    
    -- 1. Pagar Custo (Enviar Equip da Mão para o GY)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
    
    -- 2. Declarar Nível entre 1 e 10
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
    local lv=Duel.AnnounceLevel(tp,1,10)
    e:SetLabel(lv) -- Salva o nível declarado para usar na resolução
end

function s.spfilter(c,e,tp)
    return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    
    -- Invoca e altera o Nível para o valor declarado
    if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
        local lv=e:GetLabel()
        
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_LEVEL)
        e1:SetValue(lv)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        
        Duel.SpecialSummonComplete()
    end
end