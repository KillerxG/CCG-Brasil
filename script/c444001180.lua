Duel.LoadScript("VampireHunter.lua")
local s,id=GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()
    
    -- 1: Invocação-Ritual (Sem limitação de ativações/turnos)
    VampireHunter.AddSelfRitual(c,aux.Stringid(id,0))

    -- 2: Efeito Contínuo (Oponente não ativa efeitos no GY)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EFFECT_CANNOT_ACTIVATE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0,1)
    e2:SetValue(s.aclimit)
    c:RegisterEffect(e2)

    -- 3: Efeito 1 (Negar carta com a face para cima no campo)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_DISABLE)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.effcon1)
    e3:SetTarget(s.efftg1)
    e3:SetOperation(s.effop1)
    c:RegisterEffect(e3)
    
    -- 4: Efeito 2 (Called by the Grave)
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,3))
    e4:SetCategory(CATEGORY_REMOVE+CATEGORY_DISABLE)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY) -- Não dá alvo no script antigo e no PSCT atualizado
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetCountLimit(1,id+1) -- Hard Once Per Turn separado
    e4:SetCondition(s.effcon2)
    e4:SetTarget(s.efftg2)
    e4:SetOperation(s.effop2)
    c:RegisterEffect(e4)

    -- 5: Passar Efeito (Inafetado por não-alvo)
    VampireHunter.RegisterInheritedEffect(c, id, function(rc)
        local e1=Effect.CreateEffect(rc)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
        e1:SetDescription(aux.Stringid(id,1)) 
        e1:SetRange(LOCATION_MZONE)
        e1:SetCode(EFFECT_IMMUNE_EFFECT)
        e1:SetValue(s.efilter)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        rc:RegisterEffect(e1,true)
    end)
end

-- === Filtros Comuns e Efeitos Passivos ===
function s.aclimit(e,re,tp)
    return re:GetActivateLocation()==LOCATION_GRAVE
end
function s.efilter(e,te)
    if te:GetOwnerPlayer()==e:GetHandlerPlayer() then return false end
    if not te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    return not g or not g:IsContains(e:GetHandler())
end
function s.vhfilter(c)
    return c:IsFaceup() and (c:IsSetCard(0x108e) or c:IsCode(80485722))
end
function s.negfilter(c)
    return c:IsFaceup() and not c:IsDisabled()
end

-- === Funções do Efeito 1 (Negar no Campo) ===
function s.effcon1(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.efftg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and s.negfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.negfilter,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
    local g=Duel.SelectTarget(tp,s.negfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.effop1(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsDisabled() then
        Duel.NegateRelatedChain(tc,RESET_TURN_SET)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetValue(RESET_TURN_SET)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e2)
    end
end

-- === Funções do Efeito 2 (Called by the Grave) ===
function s.effcon2(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL) 
        and Duel.IsExistingMatchingCard(s.vhfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
function s.efftg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_GRAVE)
end
function s.effop2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
    local tc=g:GetFirst()
    if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_REMOVED) then
        local code=tc:GetOriginalCodeRule()
        
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_ACTIVATE)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(0,1)
        e1:SetValue(s.calledlimit)
        e1:SetLabel(code)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
        
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetCode(EFFECT_DISABLE)
        e2:SetTargetRange(0,LOCATION_ONFIELD)
        e2:SetTarget(s.calleddis)
        e2:SetLabel(code)
        e2:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e2,tp)
        
        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
        e3:SetTargetRange(0,LOCATION_MZONE)
        e3:SetTarget(s.calleddis)
        e3:SetLabel(code)
        e3:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e3,tp)
        
        local e4=Effect.CreateEffect(c)
        e4:SetType(EFFECT_TYPE_FIELD)
        e4:SetCode(EFFECT_DISABLE_EFFECT)
        e4:SetTargetRange(0,LOCATION_ONFIELD)
        e4:SetTarget(s.calleddis)
        e4:SetLabel(code)
        e4:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e4,tp)
    end
end
function s.calledlimit(e,re,tp)
    local ccode1,ccode2=re:GetHandler():GetOriginalCodeRule()
    return ccode1==e:GetLabel() or ccode2==e:GetLabel()
end
function s.calleddis(e,c)
    local ccode1,ccode2=c:GetOriginalCodeRule()
    return ccode1==e:GetLabel() or ccode2==e:GetLabel()
end