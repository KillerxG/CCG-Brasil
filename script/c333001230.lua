--Freealow Plumarshall
local s,id=GetID()
function s.initial_effect(c)
    -- E1: Quando é Invocado - destrói monstro com valor ≤ nível, e o dono compra 1
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
		    -- E2: Revive with level/rank/link of the monster that destroyed it
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_BATTLE_DESTROYED)
    e3:SetCountLimit(1,id+1)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.bspop)
    c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(s.spcon)
    e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- E1
function s.val(c)
    if c:IsType(TYPE_LINK) then return c:GetLink()
    elseif c:IsType(TYPE_XYZ) then return c:GetRank()
    else return c:GetLevel() end
end

function s.targetfilter(c,lv)
    return c:IsFaceup() and s.val(c)>0 and s.val(c)<=lv and c:IsDestructable()
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    if chkc then return chkc:IsOnField() and s.targetfilter(chkc,c:GetLevel()) end
    if chk==0 then return Duel.IsExistingTarget(s.targetfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c:GetLevel()) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,s.targetfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,c:GetLevel())
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,g:GetFirst():GetOwner(),1)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
        Duel.Draw(tc:GetOwner(),1,REASON_EFFECT)
    end
end
-- E2: condição – destruído por batalha ou por efeito de monstro
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsReason(REASON_DESTROY) then return false end
    if c:IsReason(REASON_EFFECT) and re and re:GetHandler():IsMonster() then
        -- armazena o destruidor no efeito usando uma flag
        e:SetLabelObject(re:GetHandler())
        return true
    end
    return false
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end

    local rc=e:GetLabelObject()
    if not rc or not rc:IsType(TYPE_MONSTER) then return end

    local newlv=0
    if rc:IsType(TYPE_LINK) then
        newlv=rc:GetLink()
    elseif rc:IsType(TYPE_XYZ) then
        newlv=rc:GetRank()
    else
        newlv=rc:GetLevel()
    end

    if newlv>0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_LEVEL)
        e1:SetValue(newlv)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e1)
    end
end

function s.bspop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local tc=Duel.GetAttacker()
	if c==tc then tc=Duel.GetAttackTarget() end
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end

    local rc=tc
    if not rc or not rc:IsType(TYPE_MONSTER) then return end

    local newlv=0
    if rc:IsType(TYPE_LINK) then
        newlv=rc:GetLink()
    elseif rc:IsType(TYPE_XYZ) then
        newlv=rc:GetRank()
    else
        newlv=rc:GetLevel()
    end

    if newlv>0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_LEVEL)
        e1:SetValue(newlv)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e1)
    end
end