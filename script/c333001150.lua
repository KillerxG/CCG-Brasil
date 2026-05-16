--Noctavius Skyplume
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_WINGEDBEAST),2,2)
    -- E1: If Link Summoned, destroy a monster this card points to, then Special Summon 1 Zombie from GY to a zone it points to
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
    e1:SetCondition(s.lkcon)
    e1:SetTarget(s.lktg)
    e1:SetOperation(s.lkop)
    c:RegisterEffect(e1)
	--Zombie
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EFFECT_ADD_RACE)
	e2:SetValue(RACE_ZOMBIE)
	c:RegisterEffect(e2)
	-- Trigger: When a Zombie monster your opponent controls is sent from their field to your hand or Extra Deck
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_HAND)
	e3:SetCountLimit(1,id+1)
    e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_TO_DECK)
	c:RegisterEffect(e4)
	--Zombification
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCondition(function(e) return e:GetHandler():IsSummonLocation(LOCATION_GRAVE) end)
	e5:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return not e:GetHandler():IsRace(RACE_ZOMBIE) end end)
	e5:SetOperation(s.tnop)
	c:RegisterEffect(e5)
end
-- Verifica se foi Invocado por Link Summon
function s.lkcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and not e:GetHandler():IsSummonLocation(LOCATION_GRAVE)
end
function s.desfilter(c,e,tp,g,nc)	
	return c:IsMonster() and g:IsContains(c)
end
function s.spfilter(c,e,tp,p,zones)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,p,zones)
end
function s.lktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zones_tp=aux.GetMMZonesPointedTo(tp)
	local zones_opp=aux.GetMMZonesPointedTo(1-tp)
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp,e:GetHandler():GetLinkedGroup(),false)
		and (Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,tp,zones_tp)
		or Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,1-tp,zones_opp)) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.lkop(e,tp,eg,ep,ev,re,r,rp)
	local zones={}
	zones[tp]=aux.GetMMZonesPointedTo(tp)
	zones[1-tp]=aux.GetMMZonesPointedTo(1-tp)
	local g=e:GetHandler():GetLinkedGroup()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local tg=g:Select(tp,1,1,nil)
	if #tg>0 then
		Duel.HintSelection(tg)
		if Duel.Destroy(tg,REASON_EFFECT)>0 then
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=(Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp,tp,zones[tp])+Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp,1-tp,zones[1-tp])):Select(tp,1,1,nil):GetFirst()
	if tc then
		local p
		if s.spfilter(tc,e,tp,tp,zones[tp]) and s.spfilter(tc,e,tp,1-tp,zones[1-tp]) then
			p=Duel.SelectYesNo(tp,aux.Stringid(id,1)) and 1-tp or tp
		elseif s.spfilter(tc,e,tp,tp,zones[tp]) then
			p=tp
		else
			p=1-tp
		end
		Duel.SpecialSummon(tc,0,tp,p,false,false,POS_FACEUP,zones[p])
	end
end
end
end
--e3
-- Filtro: verifica se a carta foi um monstro Zumbi do oponente que estava no campo
function s.cfilter(c,e,tp)
    return c:IsPreviousLocation(LOCATION_MZONE)
        and c:GetPreviousControler()~=tp
        and c:IsPreviousRaceOnField(RACE_ZOMBIE)
        and (c:IsLocation(LOCATION_HAND))
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end

-- Condição: verifica se ao menos 1 carta no grupo preenche o filtro
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,e,tp) and not e:GetHandler():IsSummonLocation(LOCATION_GRAVE)
end

-- Alvo: define as cartas válidas para Special Summon
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=eg:Filter(s.cfilter,nil,e,tp)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and g:FilterCount(Card.IsCanBeSpecialSummoned,nil,e,0,tp,false,false)>0
    end
    Duel.SetTargetCard(g)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
end

-- Operação: faz a Invocação-Especial dos monstros válidos
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local g=eg:Filter(s.cfilter,nil,e,tp):Filter(Card.IsRelateToEffect,nil,e)
    for tc in g:Iter() do
        Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
    end
    Duel.SpecialSummonComplete()
end
--zombiefication
function s.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
	--Treated as a Zombie
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(RACE_ZOMBIE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1)
	--Cannot be used as material for a Fusion/Synchro/Xyz/Link Summon, unless it is for a "Gold Pride" monster
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,2))
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetCode(EFFECT_CANNOT_BE_MATERIAL)
		e2:SetValue(s.matlimit)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e2)
		    -- Efeito: Quando o oponente adiciona um card à mão, Deck ou Extra Deck
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,4))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_TO_HAND)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+3)
    e3:SetCondition(s.sphcon)
    e3:SetTarget(s.sphtg)
    e3:SetOperation(s.sphop)
    c:RegisterEffect(e3)
	end
end
function s.matlimit(e,c,sumtype,tp)
	if not c then return false end
	local summon_types={SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK}
	for _,val in pairs(summon_types) do
		if val==sumtype then return not c:IsSetCard(0x758) end
	end
	return false
end
--efeito
--filter
function s.sphfilter(c,tp)
    return c:IsControler(tp) and not c:IsReason(REASON_DRAW)
end
-- Condição: Um card foi adicionado à mão, Deck ou Extra Deck do oponente
function s.sphcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.sphfilter,1,nil,1-tp)
end
-- Verifica se há alvos válidos para os dois lados
function s.zombiefilter(c,e,tp)
    return c:IsRace(RACE_ZOMBIE) and c:IsLevelAbove(6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.wbfilter(c,e,tp)
    return c:IsRace(RACE_WINGEDBEAST) and c:IsLevelBelow(6) and c:IsCanBeSpecialSummoned(e,0,1-tp,false,false,POS_FACEUP)
end
function s.sphtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToExtra() end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end
-- Operação: Retorna este card ao Extra Deck, invoca zumbi, depois invoca besta alada
function s.sphop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
	local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.zombiefilter),tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp)
    -- Retorna este card ao Extra Deck
    if Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)==0 then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
    -- Invocar do GY do oponente (Zumbi Nv6)
    local g1=Duel.SelectMatchingCard(tp,s.zombiefilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
    if #g1>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
        Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
		local g2=Duel.SelectMatchingCard(1-tp,s.wbfilter,1-tp,LOCATION_DECK,0,1,1,nil,e,tp)
    if #g2>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 then
        Duel.SpecialSummon(g2,0,1-tp,1-tp,false,false,POS_FACEUP)
    end
    end

    -- Invocar do Deck do oponente (Besta Alada Nv6)
    end
end