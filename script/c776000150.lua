--Naikardian - Astrea
--Scripted by KillerxG
local s,id=GetID()
Duel.LoadScript("proc_divine_hierarchy_mod.lua")
function s.initial_effect(c)		
	--Divine Hierarchy Rank 3
	DivineHierarchyMod.Register(c,3)
	--(1)Summon with 3 tribute
	local e1=aux.AddNormalSummonProcedure(c,true,false,3,3)
	local e2=aux.AddNormalSetProcedure(c)
	--(2)Cannot disable Summon
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e3)
	--(3)Summon Success cannot Chain
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetOperation(s.sumsuc)
	c:RegisterEffect(e4)
	-- e5: Não pode declarar ataques em monstros
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
    e5:SetValue(1)
    c:RegisterEffect(e5)

    -- e6: Declarar o nome de 1 Magia/Armadilha e adicionar de fora do Duelo
    local e6 = Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id, 0))
    e6:SetCategory(CATEGORY_TOHAND)
    e6:SetType(EFFECT_TYPE_IGNITION)
    e6:SetRange(LOCATION_MZONE)
    e6:SetCountLimit(1)
    e6:SetTarget(s.thtg)
    e6:SetOperation(s.thop)
    c:RegisterEffect(e6)

    -- e7: Tributar 1 OUTRO monstro -> Special Summon (Ignorando condições)
    local e7 = Effect.CreateEffect(c)
    e7:SetDescription(aux.Stringid(id, 1))
    e7:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e7:SetType(EFFECT_TYPE_IGNITION)
    e7:SetRange(LOCATION_MZONE)
    e7:SetCountLimit(1)
    e7:SetCost(s.spcost)
    e7:SetTarget(s.sptg)
    e7:SetOperation(s.spop)
    c:RegisterEffect(e7)
	
	-- e8: Permitir ativação de Armadilhas no turno em que foram Baixadas
    local e8 = Effect.CreateEffect(c)
    e8:SetType(EFFECT_TYPE_FIELD)
    e8:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
    e8:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e8:SetRange(LOCATION_MZONE)
    e8:SetTargetRange(LOCATION_SZONE, 0) -- Afeta as suas Magias/Armadilhas
    c:RegisterEffect(e8)

    -- e9: A primeira vez que uma Armadilha seria destruída por efeito, ela não é
    local e9 = Effect.CreateEffect(c)
    e9:SetType(EFFECT_TYPE_FIELD)
    e9:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
    e9:SetRange(LOCATION_MZONE)
    e9:SetTargetRange(LOCATION_SZONE, 0)
    e9:SetTarget(s.indtg)
    e9:SetValue(s.indct)
    c:RegisterEffect(e9)
end
--(3)Summon Success cannot Chain
function s.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetChainLimitTillChainEnd(aux.FALSE)
end

-- ====================================================================
-- Efeito 6: Declarar e Adicionar M/T de Fora do Duelo
-- ====================================================================
function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CODE)
    
    -- Filtro de barra de pesquisa restrito para a interface: 
    -- "É Magia" OU "É Armadilha"
    local ac = Duel.AnnounceCard(tp, TYPE_SPELL, OPCODE_ISTYPE, TYPE_TRAP, OPCODE_ISTYPE, OPCODE_OR)
    Duel.SetTargetParam(ac)
    Duel.SetOperationInfo(0, CATEGORY_ANNOUNCE, nil, 0, tp, 0)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    local ac = Duel.GetChainInfo(0, CHAININFO_TARGET_PARAM)
    local token = Duel.CreateToken(tp, ac)
    
    if token and token:IsAbleToHand() then
        Duel.SendtoHand(token, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, token)
    end
end

-- ====================================================================
-- Efeito 7: Tributar outro monstro para Invocar (Ignorando Condições)
-- ====================================================================
function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    -- Garante que apenas MONSTROS possam ser escolhidos para o tributo
    if chk == 0 then return Duel.CheckReleaseGroupCost(tp, Card.IsType, 1, false, nil, c, TYPE_MONSTER) end
    local g = Duel.SelectReleaseGroupCost(tp, Card.IsType, 1, 1, false, nil, c, TYPE_MONSTER)
    Duel.Release(g, REASON_COST)
end

function s.spfilter(c, e, tp)
    -- Trava a busca estritamente para cartas do tipo Monstro
    return c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e, 0, tp, true, false)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    -- Usa GetMZoneCount para prever a vaga criada após o tributo
    if chk == 0 then return Duel.GetMZoneCount(tp) > -1 
        and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    
    local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.spfilter), tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
    local tc = g:GetFirst()
    
    -- Invocação limpa, ignorando condições (true)
    if tc then 
        Duel.SpecialSummon(tc, 0, tp, tp, true, false, POS_FACEUP) 
    end
end
-- ====================================================================
-- e9: A primeira vez que uma Armadilha seria destruída por efeito, ela não é
-- ====================================================================
function s.indtg(e, c)
    -- Garante que o escudo se aplique apenas às suas cartas de Armadilha
    return c:IsType(TYPE_TRAP)
end

function s.indct(e, re, r, rp)
    -- Retorna 1 carga de proteção se a destruição for causada por efeito de carta
    if (r & REASON_EFFECT) ~= 0 then
        return 1
    else
        return 0
    end
end