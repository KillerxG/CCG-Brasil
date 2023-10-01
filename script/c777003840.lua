--Weast Royal Dragon Summon
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Fusion Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.fustg)
	e1:SetOperation(s.fusop)
	c:RegisterEffect(e1)
	--(2)Synchro Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetTarget(s.syntg)
	e2:SetOperation(s.synop)
	c:RegisterEffect(e2)
	--(3)Xyz Summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetTarget(s.xyztg)
	e3:SetOperation(s.xyzop)
	c:RegisterEffect(e3)
	--(4)Link Summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,4))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_ACTIVATE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.linktg)
	e4:SetOperation(s.linkop)
	c:RegisterEffect(e4)
	--(5)Grant effect to "Weast Royal Dragon - Irya"
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,6))
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(s.seq2tg)
	e5:SetOperation(s.seq2op)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e6:SetRange(LOCATION_GRAVE)
	e6:SetTargetRange(LOCATION_MZONE,0)
	e6:SetTarget(s.eftg)
	e6:SetLabelObject(e5)
	c:RegisterEffect(e6)
end
s.listed_names={777003740}
--(1)Fusion Summon
function s.filter2(c,e,tp,m,f)
	return c:IsType(TYPE_FUSION) and (c:IsSetCard(0x288) or c:IsSetCard(0x287) or c:IsSetCard(0x286)) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,tp)
end
function s.fcheck(tp,sg,fc,mg)
	if sg:IsExists(Card.IsHasEffect,1,nil,id) then
		return sg:IsExists(s.filterchk,1,nil) end
	return true
end
function s.filterchk(c)
	return c:IsCode(777003710) and not c:IsHasEffect(id)
end
function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local mg1=Duel.GetFusionMaterial(tp)
		local e1,e2
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
			mg1:AddCard(c)
			e1=Effect.CreateEffect(c)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(511002961)
			e1:SetReset(RESET_CHAIN)
			c:RegisterEffect(e1)
			e2=Effect.CreateEffect(c)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(id)
			e2:SetReset(RESET_CHAIN)
			c:RegisterEffect(e2)
			Fusion.CheckAdditional=s.fcheck
		end
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil)
		Fusion.CheckAdditional=nil
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf)
			end
		end
		if e1 then e1:Reset() e2:Reset() end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.fusop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg1=Duel.GetFusionMaterial(tp):Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
	local exmat=false
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(511002961)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(id)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		mg1:AddCard(c)
		exmat=true
	end
	if exmat then Fusion.CheckAdditional=s.fcheck end
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil)
	Fusion.CheckAdditional=nil
	local mg2=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf)
	end
	if #sg1>0 or (sg2~=nil and #sg2>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			if exmat then Fusion.CheckAdditional=s.fcheck end
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,tp)
			Fusion.CheckAdditional=nil
			tc:SetMaterial(mat1)
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,tp)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
--(2)Synchro
function s.synfilter(c,e,tp,rel)
	if not c:IsType(TYPE_SYNCHRO) then return false end
	if not (c:IsSetCard(0x288) or c:IsSetCard(0x287) or c:IsSetCard(0x286))then
		return c:IsSynchroSummonable(nil)
	else
		local mg=Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_MZONE+LOCATION_HAND,0,nil,c)
		if c:IsSynchroSummonable(nil,mg) then return true end
		local mc=e:GetHandler()
		if not (e:IsHasType(EFFECT_TYPE_ACTIVATE) and (not rel or mc:IsRelateToEffect(e))) then return false end
		local e1=Effect.CreateEffect(mc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_MONSTER+TYPE_TUNER)
		e1:SetReset(RESET_CHAIN)
		mc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SYNCHRO_LEVEL)
		e2:SetValue(1)
		mc:RegisterEffect(e2)
		mg:AddCard(mc)
		local res=mg:IsExists(s.ddfilter,1,nil,c,mg,mc)
		e1:Reset()
		e2:Reset()
		return res
	end
end
function s.ddfilter(c,sc,mg,mc)
	return c:IsCode(777003710) and sc:IsSynchroSummonable(Group.FromCards(c,mc),mg)
end
function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.synop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.synfilter,tp,LOCATION_EXTRA,0,nil,e,tp,true)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		if not (tc:IsSetCard(0x288) or tc:IsSetCard(0x287) or tc:IsSetCard(0x286)) then
			Duel.SynchroSummon(tp,tc,nil)
		else
			local mg=Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_MZONE+LOCATION_HAND,0,nil,tc)
			local c=e:GetHandler()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EFFECT_ADD_TYPE)
			e1:SetValue(TYPE_MONSTER+TYPE_TUNER)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_SYNCHRO_LEVEL)
			e2:SetValue(2)
			c:RegisterEffect(e2)
			if e:IsHasType(EFFECT_TYPE_ACTIVATE) and c:IsRelateToEffect(e) and (not tc:IsSynchroSummonable(nil,mg) or mg:IsExists(s.ddfilter,1,nil,tc,mg+c,c) and Duel.SelectYesNo(tp,aux.Stringid(id,3))) then
				c:CancelToGrave()
				mg:AddCard(c)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
				local smat=mg:FilterSelect(tp,s.ddfilter,1,1,nil,tc,mg,c)
				Duel.SynchroSummon(tp,tc,smat+c,mg)
			else
				Duel.SynchroSummon(tp,tc,nil,mg)
			end
		end
	end
end
--(3)Xyz Summon
function s.xzfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,true,true)
		and (c:IsLocation(LOCATION_GRAVE) and c:IsCanBeEffectTarget(e))
end
function s.xyzfilter(c,sg,e,tp)
	local ct=#sg
	local mc=e:GetHandler()
	local e1=nil
	if sg:IsExists(Card.IsCode,1,nil,777003710) then
		e1=Effect.CreateEffect(mc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetCode(511002116)
		e1:SetReset(RESET_CHAIN)
		mc:RegisterEffect(e1,true)
	end
	local res=c:IsXyzSummonable(nil,sg,ct,ct) and Duel.GetLocationCountFromEx(tp,tp,sg,c)>0 and (c:IsSetCard(0x288) or c:IsSetCard(0x287) or c:IsSetCard(0x286))
	if e1 then e1:Reset() sg:RemoveCard(mc) end
	return res
end
function s.rescon(mft,exft,ft)
	return function(sg,e,tp,mg)
				local exct=sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
				local mct=sg:FilterCount(aux.NOT(Card.IsLocation),nil,LOCATION_EXTRA)
				return exft>=exct and mft>=mct and ft>=#sg
					and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,sg,sg,e,tp)
			end
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local mg=Duel.GetMatchingGroup(s.xzfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	local ftex=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ftt=Duel.GetUsableMZoneCount(tp)
	ftex=math.min(ftex,aux.CheckSummonGate(tp) or ftex)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ftt=math.min(ftt,1) ftex=math.min(ftex,1) ft=math.min(ft,1) end
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2) and ftt>0 and (ft>0 or ftex>0)
		and aux.SelectUnselectGroup(mg,e,tp,nil,ftt,s.rescon(ft,ftex,ftt),0) end
	local sg=aux.SelectUnselectGroup(mg,e,tp,nil,ftt,s.rescon(ft,ftex,ftt),1,tp,HINTMSG_SPSUMMON,s.rescon(ft,ftex,ftt))
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,#sg+1,tp,LOCATION_EXTRA)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and #g>1 then return end
	local ftex=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)
	local ftt=Duel.GetUsableMZoneCount(tp)
	ftex=math.min(ftex,aux.CheckSummonGate(tp) or ftex)
	if ftt<#g or g:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)>ftex then
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local sg=aux.SelectUnselectGroup(g,e,tp,nil,ftt,s.rescon(ft,ftex,ftt),1,tp,HINTMSG_SPSUMMON,s.rescon(ft,ftex,ftt))
		if #sg<=0 then return false end
		g=sg
	end
	if Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)>0 then
		for tc in aux.Next(g) do
			if tc:IsLocation(LOCATION_MZONE) then
				s.disop(tc,e:GetHandler())
			end
		end
	else
		return
	end
	Duel.AdjustInstantly(c)
	local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,g,g,e,tp)
	if #xyzg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		local e1
		if g:IsExists(Card.IsCode,1,nil,777003710) then
			e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(511002116)
			c:RegisterEffect(e1,true)
		end
		Duel.XyzSummon(tp,xyz,nil,g)
		if e1 then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_SPSUMMON_COST)
			e2:SetOperation(function()
				e1:Reset()
			end)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			xyz:RegisterEffect(e2,true)
		end
	end
end
function s.disop(tc,c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	tc:RegisterEffect(e2)
end
--(4)Link Summon
function s.lkfilter2(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
function s.rmfilter(c)
	return c:IsMonster() and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true,false)
end
function s.spfilter(c,e,tp,ct,g)
	return (c:IsSetCard(0x288) or c:IsSetCard(0x287) or c:IsSetCard(0x286) or c:IsSetCard(0x284)) and c:IsType(TYPE_LINK) and c:IsLink(ct)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		and Duel.GetLocationCountFromEx(tp,tp,g,c)>0
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	local nums={}
	for i=1,#g do
		if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,i,g) then
			table.insert(nums,i)
		end
	end
	if chk==0 then return #nums>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	local ct=Duel.AnnounceNumber(tp,table.unpack(nums))
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rg=g:Select(tp,ct,ct,nil)
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	e:SetLabel(ct)
	e:SetLabelObject(rg)
	rg:KeepAlive()
end
function s.linktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end 
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.linkop(e,tp,eg,ep,ev,re,r,rp)
	--special Summon
	local c=e:GetHandler()
	local ct=e:GetLabel()
	local rg=e:GetLabelObject()
	if not ct then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,ct)
	if #g>0 then
		Duel.SpecialSummon(g,SUMMON_TYPE_LINK,tp,tp,false,false,POS_FACEUP) 
	end
		if c:IsRelateToEffect(e) and rg and rg:IsExists(Card.IsCode,1,nil,777003710) and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local ag=Duel.SelectMatchingCard(tp,s.lkfilter2,tp,LOCATION_REMOVED,0,1,2,nil)
		Duel.SendtoGrave(ag,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,ag)
		rg:DeleteGroup()
		end
end
--(5)Grant effect to "Weast Royal Dragon - Irya"
function s.eftg(e,c)
	return c:IsType(TYPE_EFFECT) and c:IsCode(777003710)
end
function s.seq2tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil)
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.seq2op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsControler(tp) or tc:IsImmuneToEffect(e) or Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	Duel.MoveSequence(tc,math.log(Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,0)>>16,2))
end
