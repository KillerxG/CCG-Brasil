Duel.LoadScript("VampireHunter.lua")
local s,id=GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()
    
    -- 1: Invocação-Ritual (Sem limitação de ativações/turnos)
    VampireHunter.AddSelfRitual(c,aux.Stringid(id,0))

    -- 2: Efeito Contínuo (Armades na Battle Phase - Sub-boss)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EFFECT_CANNOT_ACTIVATE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0,1)
    e2:SetCondition(s.bpcon)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- 3: Efeito 1 (Banir Monstro)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_REMOVE)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.rmcon1)
    e3:SetTarget(s.rmtg1)
    e3:SetOperation(s.rmop1)
    c:RegisterEffect(e3)

    -- 4: Efeito 2 (Banir Magia/Armadilha)
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,3))
    e4:SetCategory(CATEGORY_REMOVE)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetCountLimit(1,id+1) -- Hard Once Per Turn separado
    e4:SetCondition(s.rmcon2)
    e4:SetTarget(s.rmtg2)
    e4:SetOperation(s.rmop2)
    c:RegisterEffect(e4)

    -- 5: Passar Efeito (Armades na Battle Phase para a Torre)
    VampireHunter.RegisterInheritedEffect(c, id, function(rc)
        local e1=Effect.CreateEffect(rc)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
        e1:SetDescription(aux.Stringid(id,1)) 
        e1:SetCode(EFFECT_CANNOT_ACTIVATE)
        e1:SetRange(LOCATION_MZONE)
        e1:SetTargetRange(0,1)
        e1:SetCondition(s.bpcon)
        e1:SetValue(1)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        rc:RegisterEffect(e1,true)
    end)
end

-- === Filtros e Condições Comuns ===
function s.bpcon(e)
    return Duel.IsBattlePhase()
end
function s.vhfilter(c)
    return c:IsFaceup() and (c:IsSetCard(0x108e) or c:IsCode(80485722))
end
function s.mfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
function s.stfilter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end

-- === Funções do Efeito 1 (Banir Monstro) ===
function s.rmcon1(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.rmtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.mfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.mfilter,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,s.mfilter,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmop1(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
    end
end

-- === Funções do Efeito 2 (Banir Magia/Armadilha) ===
function s.rmcon2(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL) 
        and Duel.IsExistingMatchingCard(s.vhfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
function s.rmtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and s.stfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.stfilter,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,s.stfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmop2(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
    end
end