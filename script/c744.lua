--Main Character
local s,id=GetID()
function s.initial_effect(c)
--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
		--set
	local e1=Effect.CreateEffect(c)	
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_HAND+LOCATION_DECK)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
		--ceate monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	-- create spell/trap
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetOperation(s.op2)
	c:RegisterEffect(e3)
	-- create Ritual
	local e4=e2:Clone()
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetOperation(s.op3)
	c:RegisterEffect(e4)
		-- create Fusion
	local e5=e2:Clone()
	e5:SetDescription(aux.Stringid(id,5))
	e5:SetOperation(s.op4)
	c:RegisterEffect(e5)
		-- create Synchro
	local e6=e2:Clone()
	e6:SetDescription(aux.Stringid(id,7))
	e6:SetOperation(s.op5)
	c:RegisterEffect(e6)
			-- create Xyz
	local e7=e2:Clone()
	e7:SetDescription(aux.Stringid(id,9))
	e7:SetOperation(s.op6)
	c:RegisterEffect(e7)
				-- create Link
	local e8=e2:Clone()
	e8:SetDescription(aux.Stringid(id,11))
	e8:SetOperation(s.op7)
	c:RegisterEffect(e8)
end
function s.op(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
	--local tc2=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)	

--move to field
	if tc==nil then
		Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		
	end
end
--card summon
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac=Duel.AnnounceCard(tp,TYPE_MONSTER)
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_MONSTER_FILTER)
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
local token=Duel.CreateToken(tp,ac)
if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.SpecialSummon(token,0,tp,tp,true,true,POS_FACEUP)
else
		Duel.SendtoHand(token,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,token)
end
end
--spell/trap
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac=Duel.AnnounceCard(tp,TYPE_SPELL+TYPE_TRAP)
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_MONSTER_FILTER)
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
local token=Duel.CreateToken(tp,ac)
		Duel.SendtoHand(token,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,token)
end
--ritual summon
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac=Duel.AnnounceCard(tp,TYPE_RITUAL)
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_MONSTER_FILTER)
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
local token=Duel.CreateToken(tp,ac)
if  token:IsType(TYPE_MONSTER) then
--Duel.SelectYesNo(tp,aux.Stringid(id,12)) then
		Duel.SpecialSummon(token,SUMMON_TYPE_RITUAL,tp,tp,true,true,POS_FACEUP)
else
		Duel.SendtoHand(token,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,token)
end
end
--fusion summon
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac=Duel.AnnounceCard(tp,TYPE_FUSION)
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_MONSTER_FILTER)
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
local token=Duel.CreateToken(tp,ac)
if Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		Duel.SpecialSummon(token,SUMMON_TYPE_FUSION,tp,tp,true,true,POS_FACEUP)
else
		Duel.SendtoHand(token,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,token)
end
end
--synchro summon
function s.op5(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac=Duel.AnnounceCard(tp,TYPE_SYNCHRO)
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_MONSTER_FILTER)
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
local token=Duel.CreateToken(tp,ac)
if Duel.SelectYesNo(tp,aux.Stringid(id,6)) then
		Duel.SpecialSummon(token,SUMMON_TYPE_SYNCHRO,tp,tp,true,true,POS_FACEUP)
else
		Duel.SendtoHand(token,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,token)
end
end
--xyz summon
function s.filter2(c)
    return c:IsAbleToGrave()
end
function s.op6(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac=Duel.AnnounceCard(tp,TYPE_XYZ)
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_MONSTER_FILTER)
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
local token=Duel.CreateToken(tp,ac)
if Duel.SelectYesNo(tp,aux.Stringid(id,8)) then
		Duel.SpecialSummon(token,SUMMON_TYPE_XYZ,tp,tp,true,true,POS_FACEUP) 
			if Duel.SelectYesNo(tp,aux.Stringid(id,13)) then 
local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE+LOCATION_HAND+LOCATION_REMOVED,0,1,5,nil)
	if #g>0 then
            Duel.Overlay(token,g)
        end
    end
else
		Duel.SendtoHand(token,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,token)
end
end
--link summon
function s.op7(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac=Duel.AnnounceCard(tp,TYPE_LINK)
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_MONSTER_FILTER)
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
local token=Duel.CreateToken(tp,ac)
if Duel.SelectYesNo(tp,aux.Stringid(id,10)) then
		Duel.SpecialSummon(token,SUMMON_TYPE_LINK,tp,tp,true,true,POS_FACEUP)
else
		Duel.SendtoHand(token,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,token)
end
end