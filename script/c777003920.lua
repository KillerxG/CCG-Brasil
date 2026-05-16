--Ancient Scriptures
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Ritual Summon
	local e1=Ritual.AddProcGreater({handler=c,filter=aux.FilterBoolFunction(Card.IsType,TYPE_RITUAL),
		stage2=s.stage2,extratg=s.extratg})
end

--(1)Ritual Summon
function s.posfilter(c)
	return c:IsFaceup() and c:IsDestructable()
end
function s.stage2(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	if not tc:IsLevel(9) then return end
	local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_ONFIELD,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local sg=g:Select(tp,1,1,nil)
			Duel.HintSelection(sg)
			Duel.Destroy(sg,REASON_EFFECT)
	end
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end