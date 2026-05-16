--Freealow Plumarshall
local s,id=GetID()
function s.initial_effect(c)
    -- E1: Boost ATK de WIND quando Invocado
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
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
-- e1: atk gain
function s.desfilter(c,e,tp)
    return c:IsAttribute(ATTRIBUTE_WIND)
        and (c:IsControler(tp) or c:IsLocation(LOCATION_HAND))
        and c:IsDestructable()
        and c~=e:GetHandler() -- garante que não seja este card
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x759),tp,LOCATION_MZONE,0,1,nil) and
	Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_DECK,0,1,e:GetHandler(),e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_DECK,0,1,1,e:GetHandler(),e,tp)
    Duel.SetTargetCard(g)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
 local tz=Duel.GetFirstTarget()
local c=e:GetHandler()
local lv=c:GetLevel()
local atk=lv*200
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_WIND),tp,LOCATION_MZONE,0,nil)
	if tz and Duel.Destroy(tz,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) and c:IsFaceup() then
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_BATTLE)
		tc:RegisterEffect(e1)
	end
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