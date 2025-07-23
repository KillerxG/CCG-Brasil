--Noctavius Skytwins
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()

    -- Fusion procedure: 1 WB + 1 Zumbi com condições específicas
    Fusion.AddProcMix(c,true,true,s.mat1,s.mat2)

    -- Contact Fusion: destruir os materiais do campo/mão
    Fusion.AddContactProc(c,s.contactfilter,s.contactop,s.splimit,nil,nil,nil,false)
	-- Ignition Effect: Target Zombie in GY, destroy Winged Beast, summon that Zombie
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.nzcon)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop1)
    c:RegisterEffect(e1)
	--Zombie
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EFFECT_ADD_RACE)
	e2:SetValue(RACE_ZOMBIE)
	c:RegisterEffect(e2)
	--Zombification
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(function(e) return e:GetHandler():IsSummonLocation(LOCATION_GRAVE) end)
	e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return not e:GetHandler():IsRace(RACE_ZOMBIE) end end)
	e3:SetOperation(s.tnop)
	c:RegisterEffect(e3)
end

-- Mat1: Winged Beast Level/Rank ≤6
function s.mat1(c,fc,sumtype,tp)
    return c:IsRace(RACE_WINGEDBEAST) and (c:GetLevel()<=6 or c:GetRank()<=6)
end

-- Mat2: Zombie Level/Rank ≥6
function s.mat2(c,fc,sumtype,tp)
    return c:IsRace(RACE_ZOMBIE) and (c:GetLevel()>=6 or c:GetRank()>=6)
end

-- Somente da mão ou campo
function s.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end

-- Contact Fusion: seleciona materiais da mão/campo
function s.contactfilter(tp)
    return Duel.GetMatchingGroup(s.contactmatfilter,tp,LOCATION_MZONE,0,nil)
end

-- Apenas monstros que podem ser destruídos como custo
function s.contactmatfilter(c)
    return c:IsMonster() and c:IsDestructable()
end

-- Executa o Contact Fusion: destrói os materiais
function s.contactop(g)
    Duel.Destroy(g,REASON_COST+REASON_MATERIAL)
end
-- Ignition effect
function s.nzcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsSummonLocation(LOCATION_GRAVE)
end
function s.GetCombinedValue(c)
    if c:IsLevelAbove(1) then return c:GetLevel()
    elseif c:IsRankAbove(1) then return c:GetRank()
    elseif c:IsType(TYPE_LINK) then return c:GetLink()
    else return 0 end
end
function s.zombietg(c,e,tp)
    return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end

function s.wbdestroyfilter2(c,value)
    return c:IsRace(RACE_WINGEDBEAST)
        and c:IsDestructable()
        and s.GetCombinedValue(c) > 0
        and s.GetCombinedValue(c) <= value
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.zombietg,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local tg=Duel.SelectTarget(tp,s.zombietg,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,1,0,0)
end

function s.spop1(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    local value = s.GetCombinedValue(tc)

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,s.wbdestroyfilter2,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK,0,1,1,nil,value)
    if #g==0 then return end

    if Duel.Destroy(g,REASON_EFFECT)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,true,false) then
        -- Escolher o campo (próprio ou oponente)
        local p=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,2)) -- "Your field" / "Opponent's field"
        if p==1 then
            Duel.SpecialSummon(tc,0,1-tp,1-tp,false,false,POS_FACEUP)
        else
            Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
        end
    end
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
		end
		    -- Optional Ignition effect gained after being summoned from GY
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(id,1))
		e3:SetCategory(CATEGORY_TODECK+CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
		e3:SetCode(EVENT_CHAINING)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCountLimit(1,id+1)
		e3:SetCondition(s.trigcon)
		e3:SetTarget(s.choicetg)
		e3:SetOperation(s.choiceop)
		c:RegisterEffect(e3)
end
-- Material Restriction (only Noctavius)
function s.matlimit(e,c)
    return not c:IsSetCard(0x758) -- Substitua 0x1A0 pelo set real de Noctavius
end

-- Efeito se foi invocado do GY
function s.gycon(e)
    return e:GetHandler():GetSummonLocation()==LOCATION_GRAVE
end
-- Efeito pós-GY: escolha entre banir 1 card virado p/ baixo ou invocar Zumbi
function s.trigcon(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    return rc and rc:IsSetCard(0x758) and rc~=e:GetHandler()-- substitua se seu Noctavius tiver outro SetCode
end
function s.choicetg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_EXTRA,0,1,nil,POS_FACEDOWN)
            or Duel.IsExistingMatchingCard(s.zombietg,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end
end
function s.choiceop(e,tp,eg,ep,ev,re,r,rp)
    local b1=Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_EXTRA,0,1,nil,POS_FACEDOWN)
    local b2=Duel.IsExistingMatchingCard(s.zombietg,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    if not b1 and not b2 then return end
    local opt=0
    if b1 and b2 then
        opt=Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5))
    elseif b1 then
        opt=0
    else
        opt=1
    end

    Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    if opt==0 then
        local g=Duel.GetFieldGroup(tp,LOCATION_EXTRA,0)
        if #g==0 then return end
        local rg=g:RandomSelect(tp,1)
        Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)
    else
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.zombietg,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
        if #g>0 then
            Duel.SpecialSummon(g,0,1-tp,1-tp,false,false,POS_FACEUP)
        end
    end
end
