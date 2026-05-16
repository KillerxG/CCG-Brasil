--Hate Hat Pact Mind
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
    --(1)Ritual Summon
    local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_EQUALORHIGHER,filter=s.ritfilter,extrafil=s.extrafil,extraop=s.extraop,matfilter=s.matfilter,location=LOCATION_HAND})
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    c:RegisterEffect(e1)	
	--(2)Add back to hand
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND)
	e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+1)
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end
--(1)Ritual Summon
function s.ritfilter(c)
    return c:IsSetCard(0x275) and c:IsRitualMonster()
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
    return Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
end
function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
    local hate_hat_ritual_materials = mat:Filter(function(c) return c:IsSetCard(0x275) and c:IsRitualMonster() end,nil)
    if hate_hat_ritual_materials:GetCount() == mat:GetCount() then
        --If all monsters tributed are "Hate Hat"
        Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=hate_hat_ritual_materials:Select(tp,1,1,nil)
        local tc=g:GetFirst()
        if tc then
			Duel.ReleaseRitualMaterial(mat)
            Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,true,POS_FACEUP)
        end
		tc:CompleteProcedure()
    else
        --If at least one of them is not "Hate Hat"
		Duel.ReleaseRitualMaterial(mat)
        Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
    end
end
function s.matfilter(c,rc)
    return c:IsAbleToGrave() and c:IsType(TYPE_MONSTER)
end
--(2)Add back to hand
function s.cfilter(c,tp)
	return c:IsType(TYPE_TOKEN) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
