--East Wings Blader, Cecilia
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	--(1)Place 1 monster from the GY in the Spell/Trap Zone as a Continuous Spell
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.gypltg)
	e1:SetOperation(s.gyplop)
	c:RegisterEffect(e1)
	--(2)Effect Gain: Direct Attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(function(e) return e:GetHandler():IsContinuousSpell() end)
	e3:SetTarget(s.eftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	--(3)Effect Gain: Indes by battle
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(1)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetCondition(function(e) return e:GetHandler():IsContinuousSpell() end)
	e5:SetTarget(s.eftg)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
	--(4)Switch Locations
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,id+1)
	e6:SetTarget(s.chtg)
	e6:SetOperation(s.chop)
	c:RegisterEffect(e6)
end
--(1)Place 1 monster from the GY in the Spell/Trap Zone as a Continuous Spell
function s.gyplfilter(c)
	return c:IsSetCard(0x314) and c:IsMonster() and not c:IsForbidden()
end
function s.gypltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.gyplfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.gyplfilter,tp,LOCATION_GRAVE,0,1,nil)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.gyplfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.gyplop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e)
		and s.stplace(tc,tp,c) and c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.stplace(c,tp,rc)
	if not Duel.MoveToField(c,tp,c:GetOwner(),LOCATION_SZONE,POS_FACEUP,c:IsMonsterCard()) then return end
	--Treated as a Continuous Spell
	local e1=Effect.CreateEffect(rc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
	e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
	c:RegisterEffect(e1)
	return true
end
--(2)Effect Gain: Direct Attack
function s.eftg(e,c)
	local g=e:GetHandler():GetColumnGroup(0,0)
	return c:IsType(TYPE_EFFECT) and c:IsSetCard(0x314) and c:GetSequence()<5 and g:IsContains(c)
end
--(4)Switch Locations
function s.rescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetControler)==1
end
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,LOCATION_MMZONE,0)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_MMZONE,0)
	if #g==0 then return end
	local swap_g=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,aux.Stringid(id,1))
	if #swap_g~=2 then return end
	Duel.HintSelection(swap_g,true)
	Duel.SwapSequence(swap_g:GetFirst(),swap_g:GetNext())
end