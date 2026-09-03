-- Nordic Ascension
local s,id=GetID()

s.exchange_map={
	[67098114]=776000280,
	[30604579]=776000270,
	[93483212]=776000260
}
s.banish_locations=LOCATION_HAND|LOCATION_DECK|LOCATION_EXTRA|LOCATION_GRAVE

function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end

function s.banishfilter(c,code)
	return c:IsCode(code) and c:IsAbleToRemove()
end

function s.hasthree(tp,code)
	return Duel.GetMatchingGroupCount(s.banishfilter,tp,s.banish_locations,0,nil,code)>=3
end

function s.choicefilter(c,tp)
	return s.exchange_map[c:GetCode()] and s.hasthree(tp,c:GetCode())
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	if not aux.CanActivateSkill(tp) or Duel.GetLP(tp)>3500
		or Duel.GetFlagEffect(tp,id)>0 then return false end
	for code in pairs(s.exchange_map) do
		if s.hasthree(tp,code) then return true end
	end
	return false
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(tp,id,0,0,1)

	--Choose which Divine Beast will be used, among the available options
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local cg=Duel.SelectMatchingCard(tp,s.choicefilter,tp,s.banish_locations,0,1,1,nil,tp)
	local selected=cg:GetFirst()
	if not selected then return end
	local code=selected:GetCode()

	--Banish exactly 3 copies of the chosen monster
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rg=Duel.SelectMatchingCard(tp,s.banishfilter,tp,s.banish_locations,0,3,3,nil,code)
	if #rg~=3 or Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)~=3 then return end

	--Add its corresponding form from outside of the Duel
	local new_code=s.exchange_map[code]
	local tc=Duel.CreateToken(tp,new_code)
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,tc)
	end
end
