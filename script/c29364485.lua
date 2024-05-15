--Necromorph Planet Aegis VII
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x1ff)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--add Necro counters each standby phase
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetTarget(s.addtg)
	e2:SetOperation(s.addop)
	c:RegisterEffect(e2)
  --Atk
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
  e3:SetTarget(s.tg)
	e3:SetValue(-300)
	c:RegisterEffect(e3)
	--Def
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
  --Negate an opponent's targeting effect
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(2,id)
  e5:SetCost(s.cost)
	e5:SetCondition(s.discon)
	e5:SetTarget(s.distg)
	e5:SetOperation(s.disop)
	c:RegisterEffect(e5)
  --Prevent destruction by effects
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e6:SetRange(LOCATION_FZONE)
	e6:SetCondition(s.ptcon)
	e6:SetValue(1)
	c:RegisterEffect(e6)
end
s.counter_place_list={0x1ff}
s.listed_names={id,178267253}
--specify to add Necro counters
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
  local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,0x1ff),tp,LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,#g,0,0x1ff)
end
--add the 'label' amount of Necro counters to this card
function s.addop(e,tp,eg,ep,ev,re,r,rp)
  local c = e:GetHandler()
	if c:IsRelateToEffect(e) then
    local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,0x1ff),tp,LOCATION_MZONE,0,nil)
		c:AddCounter(0x1ff,#g)
	end
end
--ATK/DEF mod
--Pick targets to reduce stats
function s.tg(e,c)
	return not c:IsRace(RACE_ZOMBIE)
end
--Negate targetted effects
function s.tfilter(c,tp)
	return c:IsOnField() and c:IsControler(tp)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1ff,2,REASON_COST) end
	Duel.RemoveCounter(tp,1,0,0x1ff,2,REASON_COST)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if not (rp==1-tp and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsExists(s.tfilter,1,nil,tp) and Duel.IsChainDisablable(ev)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsDestructable() and rc:IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
--Prevent destruction condition
function s.filter(c)
	return c:IsFaceup() and c:IsCode(178267253)
end
function s.ptcon(e)
	return Duel.IsExistingMatchingCard(s.filter,e:GetHandlerPlayer(),LOCATION_SZONE,0,1,nil)
end