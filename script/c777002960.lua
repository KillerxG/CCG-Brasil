--Promised Land, Blessed Amethyst
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Recycle or SS
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--(2)Special Summon Procedure
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
--(1)Recycle or SS
function s.filter(c,e,tp,lc)
	return c:IsSetCard(0x278) and c:IsMonster()
		and (c:IsAbleToHand() or (lc>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local lc=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp,lc) end
	if chk==0 then return true end
	if Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,lc) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,lc)
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,tp,0)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_GRAVE)
		Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_GRAVE)
	else
		e:SetCategory(0)
		e:SetProperty(0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc and tc:IsRelateToEffect(e)) then return end
	aux.ToHandOrElse(tc,tp,
		function()
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		end,
		function() Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end,
		aux.Stringid(id,1)
	)
end
--(2)Special Summon
function s.spcfilter(c)
	return c:IsSpellTrap() and c:IsSetCard(0x278)
		and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true,true)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local rg=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_GRAVE,0,e:GetHandler())
	return #rg>0 and aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local rg=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_GRAVE,0,c)
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_REMOVE,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	g:DeleteGroup()
end
function s.destg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local at=Duel.GetAttacker()
	if chk==0 then return at:IsRelateToBattle() end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,at,1,tp,0)
	if at:GetBaseAttack()>0 then
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,1,1-tp,at:GetBaseAttack())
	end
end