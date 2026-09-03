-- Last Hope
local s,id=GetID()

function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
	--Remember if either player Special Summoned an "Idrakian" monster this Duel
	if not s.tracker_registered then
		s.tracker_registered=true
		local ge=Effect.GlobalEffect()
		ge:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge:SetOperation(s.trackop)
		Duel.RegisterEffect(ge,0)
	end
end

function s.idrakianfilter(c,p)
	return c:IsSetCard(0x313) and c:IsSummonPlayer(p)
end

function s.trackop(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		if Duel.GetFlagEffect(p,id+1)==0 and eg:IsExists(s.idrakianfilter,1,nil,p) then
			Duel.RegisterFlagEffect(p,id+1,0,0,1)
		end
	end
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.GetLP(tp)<=4000
		and Duel.GetFlagEffect(tp,id)==0 and Duel.GetFlagEffect(tp,id+1)>0
		and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(tp,id,0,0,1)

	local hand=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	local hand_count=#hand
	if hand_count==0 or Duel.SendtoGrave(hand,REASON_EFFECT)~=hand_count then return end

	local tc=Duel.CreateToken(tp,777000000)
	if not tc or Duel.SendtoHand(tc,nil,REASON_EFFECT)==0 then return end
	Duel.ConfirmCards(1-tp,tc)

	local draw_count=5-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	if Duel.GetLP(tp)<=2000 and draw_count>0 and Duel.IsPlayerCanDraw(tp,draw_count)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.BreakEffect()
		Duel.Draw(tp,draw_count,REASON_EFFECT)
	end
end
