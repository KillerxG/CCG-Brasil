Duel.LoadScript("VampireHunter.lua")
local s,id=GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()
    
    -- 1: Invocação-Ritual (Sem limitação de ativações/turnos)
    VampireHunter.AddSelfRitual(c,aux.Stringid(id,0))

    -- 2: Efeito 1 (Destruir Magia/Armadilha)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.descon1)
    e2:SetTarget(s.destg1)
    e2:SetOperation(s.desop1)
    c:RegisterEffect(e2)

    -- 3: Efeito 2 (Destruir Monstro)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,3))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetCountLimit(1,id+1) -- Hard Once Per Turn separado
    e3:SetCondition(s.descon2)
    e3:SetTarget(s.destg2)
    e3:SetOperation(s.desop2)
    c:RegisterEffect(e3)

    -- 4: Passar Efeito (Indestrutível em Batalha + Atacar Todos)
    VampireHunter.RegisterInheritedEffect(c, id, function(rc)
        local e1=Effect.CreateEffect(rc)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
        e1:SetDescription(aux.Stringid(id,1)) 
        e1:SetRange(LOCATION_MZONE)
        e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
        e1:SetValue(1)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        rc:RegisterEffect(e1,true)
        
        local e2=Effect.CreateEffect(rc)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_ATTACK_ALL)
        e2:SetValue(1)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        rc:RegisterEffect(e2,true)
    end)
end

-- === Filtros Comuns ===
function s.vhfilter(c)
    return c:IsFaceup() and (c:IsSetCard(0x108e) or c:IsCode(80485722))
end
function s.stfilter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.mfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end

-- === Funções do Efeito 1 (Destruir Magia/Armadilha) ===
function s.descon1(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.destg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and s.stfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.stfilter,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,s.stfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop1(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end

-- === Funções do Efeito 2 (Destruir Monstro) ===
function s.descon2(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL) 
        and Duel.IsExistingMatchingCard(s.vhfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
function s.destg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.mfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.mfilter,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,s.mfilter,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end