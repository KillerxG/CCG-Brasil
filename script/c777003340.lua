--Oceanic Storm Blood Path
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Apply up to 3 effects
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES+CATEGORY_DESTROY+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
--(1)Apply up to 3 effects

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=0
	if s.thtg(e,tp,eg,ep,ev,re,r,rp,0) then ct=ct+1 end
	if s.destg(e,tp,eg,ep,ev,re,r,rp,0) then ct=ct+1 end
	if s.atktg(e,tp,eg,ep,ev,re,r,rp,0) then ct=ct+1 end
	if chk==0 then return ct>0 and Duel.CheckLPCost(tp,800) end
	ct=math.min(ct,Duel.GetLP(tp)//800)
	local t={}
	for i=1,ct do
		t[i]=i*800
	end
	local cost=Duel.AnnounceNumber(tp,table.unpack(t))
	Duel.PayLPCost(tp,cost)
	e:SetLabel(cost/800)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,3,1-tp,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	local opt=0
	local optp=0
	local b1=s.thtg(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=s.destg(e,tp,eg,ep,ev,re,r,rp,0)
	local b3=s.atktg(e,tp,eg,ep,ev,re,r,rp,0)
	local t
	for i=1,ct do
		local idtable={}
		local desctable={}
		t=1
		if b1 and (opt&1)==0 then
			idtable[t]=1
			desctable[t]=aux.Stringid(id,0)
			t=t+1
		end
		if b2 and (opt&2)==0 then
			idtable[t]=2
			desctable[t]=aux.Stringid(id,1)
			t=t+1
		end
		if b3 and (opt&4)==0 then
			idtable[t]=4
			desctable[t]=aux.Stringid(id,2)
			t=t+1
		end
		if t==1 then return end
		local op=idtable[Duel.SelectOption(tp,table.unpack(desctable)) + 1]
		optp=opt+optp
		opt=opt+op
		if opt==1 or (optp==2 and opt==3) or (optp==4 and opt==5) or ((optp==8 or optp==10) and opt==7) then
			s.thop(e,tp,eg,ep,ev,re,r,rp)
		elseif opt==2 or (optp==1 and opt==3) or (optp==4 and opt==6) or ((optp==6 or optp==9) and opt==7) then
			s.desop(e,tp,eg,ep,ev,re,r,rp)
		elseif opt==4 or (optp==1 and opt==5) or (optp==2 and opt==6) or ((optp==4 or optp==5) and opt==7) then
			s.atkop(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end
function s.thfilter(c)
	return c:IsSetCard(0x312) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>=2 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,2,1-tp,LOCATION_ONFIELD)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,2,2,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(tp,2,REASON_EFFECT)==2 then
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT|REASON_DISCARD)
	end
end