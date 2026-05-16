--Noctavius Skyrend
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_WINGEDBEAST),6,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)
	c:EnableReviveLimit()
		--spsummon
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	e0:SetCountLimit(1,id)
	e0:SetTarget(s.selfsptg)
	e0:SetOperation(s.selfspop)
	c:RegisterEffect(e0)
			--Zombie
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EFFECT_ADD_RACE)
	e2:SetValue(RACE_ZOMBIE)
	c:RegisterEffect(e2)
    -- Efeito: Desanexar 1 matéria + Tributar 1 monstro (de qualquer lado) => Invocar 1 Zumbi do cemitério no campo do controlador do monstro tributado
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+1)
	e3:SetCondition(s.nzcon)
    e3:SetCost(s.spcost)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
	--Zombification
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(function(e) return e:GetHandler():IsSummonLocation(LOCATION_GRAVE) end)
	e4:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return not e:GetHandler():IsRace(RACE_ZOMBIE) end end)
	e4:SetOperation(s.tnop)
	c:RegisterEffect(e4)
end
--xyz
function s.desfilter(c,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsLevel(6) and Duel.GetMZoneCount(tp,c)>0
end
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_GRAVE,0,2,c,tp)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local exc=c:IsRelateToEffect(e) and c or nil
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_GRAVE,0,2,2,exc,tp)
			if c and Duel.SpecialSummon(c,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)~=0 then
		Duel.Overlay(c,g)
					c:CompleteProcedure()
	end
end
-- Filtro: Monstros que podem ser tributados
function s.costfilter(c)
    return c:IsReleasable()
end

-- Custo: Desanexar 1 matéria + Tributar 1 monstro de qualquer lado
function s.nzcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsSummonLocation(LOCATION_GRAVE)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    -- Verifica se há 1 matéria e 1 monstro tributável
    if chk==0 then
        return c:IsType(TYPE_XYZ) and c:CheckRemoveOverlayCard(tp,1,REASON_COST)
            and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
    end
    -- Desanexar 1 matéria
    c:RemoveOverlayCard(tp,1,1,REASON_COST)
    -- Selecionar e tributar 1 monstro do campo
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
    e:SetLabel(g:GetFirst():GetControler()) -- Armazena o dono do monstro tributado
    Duel.Release(g,REASON_COST)
end

-- Alvo: 1 monstro Zumbi do seu cemitério
function s.spfilter(c,e,tp)
    return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

-- Operação: Invocar o monstro Zumbi no campo do jogador que controlava o monstro tributado
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local p=e:GetLabel() -- Controlador do monstro tributado
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if tc then
        Duel.SpecialSummon(tc,0,tp,p,false,false,POS_FACEUP)
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
		e2:SetDescription(aux.Stringid(id,3))
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetCode(EFFECT_CANNOT_BE_MATERIAL)
		e2:SetValue(s.matlimit)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- E3: Todos os monstros que você controla que não sejam "Noctavius" têm o ATK reduzido pela metade
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_UPDATE_ATTACK)
		e3:SetRange(LOCATION_MZONE)
		e3:SetTargetRange(LOCATION_MZONE,0)
		e3:SetReset(RESET_EVENT|RESETS_STANDARD)
		e3:SetTarget(s.atktg)
		e3:SetValue(s.atkval)
		c:RegisterEffect(e3)	
		-- E4: Você não pode Invocar Especial monstros com ATK menor que este card, exceto se vierem do cemitério
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e4:SetRange(LOCATION_MZONE)
		e4:SetTargetRange(1,0) -- afeta apenas o controlador
		e4:SetTarget(s.splimit)
		e4:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e4)	
		-- E5: Retorna ao Extra Deck, ambos os jogadores escolhem buscar Winged Beast do Deck ou Zumbi do GY
		local e5=Effect.CreateEffect(c)
		e5:SetDescription(aux.Stringid(id,4))
		e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e5:SetType(EFFECT_TYPE_IGNITION)
		e5:SetRange(LOCATION_MZONE)
		e5:SetCountLimit(1,id+2) -- 1 vez por turno
		e5:SetReset(RESET_EVENT|RESETS_STANDARD)
		e5:SetCost(s.cost)
		e5:SetOperation(s.operation)
		c:RegisterEffect(e5)		
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
-- E3: Aplica -50% de ATK a todos os seus monstros que não forem do arquétipo "Noctavius" (0x758)
function s.atktg(e,c)
    return not c:IsSetCard(0x758)
end
function s.atkval(e,c)
    return math.floor(-c:GetAttack()/2)
end
-- E4: Impede SpSummon de monstros com ATK menor que este card, exceto se vierem do Cemitério
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    if not c:IsLocation(LOCATION_GRAVE) and c:GetAttack()<e:GetHandler():GetAttack() then
        return true
    end
    return false
end
--e5
-- Custo: Retornar este card para o Extra Deck
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToExtraAsCost() end
    Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_COST)
end

-- Filtros para as opções
function s.wingfilter(c)
    return c:IsRace(RACE_WINGEDBEAST) and c:IsAbleToHand()
end
function s.zombiefilter(c)
    return c:IsRace(RACE_ZOMBIE) and c:IsAbleToHand()
end
-- Operação: ambos os jogadores escolhem uma das opções válidas, se possível
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    for p=0,1 do
        local canWing=Duel.IsExistingMatchingCard(s.wingfilter,p,LOCATION_DECK,0,1,nil)
        local canZombie=Duel.IsExistingMatchingCard(s.zombiefilter,p,LOCATION_GRAVE,0,1,nil)

        if canWing or canZombie then
            local options = {}
            local ops = {}
            if canWing then
                table.insert(options, aux.Stringid(id,5)) -- Texto: "Add 1 Winged Beast from Deck"
                table.insert(ops, 0)
            end
            if canZombie then
                table.insert(options, aux.Stringid(id,6)) -- Texto: "Add 1 Zombie from GY"
                table.insert(ops, 1)
            end

            Duel.Hint(HINT_SELECTMSG,p,aux.Stringid(id,7)) -- Texto: "Choose an effect"
            local choice = Duel.SelectOption(p, table.unpack(options))
            local opt = ops[choice+1] -- +1 porque Lua começa em 1, SelectOption retorna 0-based

            -- Aplicar efeito baseado na escolha
            if opt==0 then
                Duel.Hint(HINT_SELECTMSG,p,HINTMSG_ATOHAND)
                local g=Duel.SelectMatchingCard(p,s.wingfilter,p,LOCATION_DECK,0,1,1,nil)
                if #g>0 then
                    Duel.SendtoHand(g,nil,REASON_EFFECT)
                    Duel.ConfirmCards(1-p,g)
                end
            elseif opt==1 then
                Duel.Hint(HINT_SELECTMSG,p,HINTMSG_ATOHAND)
                local g=Duel.SelectMatchingCard(p,s.zombiefilter,p,LOCATION_GRAVE,0,1,1,nil)
                if #g>0 then
                    Duel.SendtoHand(g,nil,REASON_EFFECT)
                    Duel.ConfirmCards(1-p,g)
                end
            end
        end
    end
end
