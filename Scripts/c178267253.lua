--Necromorph Ship USG Ishimura
local s,id=GetID()
function s.initial_effect(c)
  c:EnableCounterPermit(0x1ff)
	c:SetUniqueOnField(1,0,id)
	--Activate Necromorph Planet Aegis VII
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	--e1:SetTarget(s.actg)
	e1:SetOperation(s.acop)
	c:RegisterEffect(e1)
  --add Necro counters each end phase
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetTarget(s.addtg)
	e2:SetOperation(s.addop)
	c:RegisterEffect(e2)
  --Destruction replacement
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTarget(s.desreptg)
	c:RegisterEffect(e3)
  --Add trap
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
  e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,{id,1})
  e4:SetCost(s.thcost)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
s.counter_place_list={0x1ff}
s.listed_names={id,29364485}
--Activate planet from deck or gy
function s.filter(c,tp)
	return c:IsCode(29364485) and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil,tp) end
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  if Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,tp):GetFirst()
    Duel.ActivateFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
	end
end
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
--Avoid destruction by removing 2 Necro counters
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
	return not c:IsReason(REASON_REPLACE)
		and c:IsCanRemoveCounter(tp,0x1ff,2,REASON_COST) end
	if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		c:RemoveCounter(tp,0x1ff,2,REASON_COST)
		return true
	else return false end
end
--Add trap
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1ff,2,REASON_COST) end
	Duel.RemoveCounter(tp,1,0,0x1ff,2,REASON_COST)
end
function s.thfilter(c)
	return c:IsSetCard(0x1ff) and c:IsTrap() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end