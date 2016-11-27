transformcomponenttestchild =
{
    Properties =
    {
        ParentEntity1 = { entity="", description="Random Parent 1"},
        ParentEntity2 = { entity="", description="Random Parent 2"},
        ParentEntity3 = { entity="", description="Random Parent 3"},
    },
}

function transformcomponenttestchild:OnActivate()    
    Debug.Assert(self.Properties.ParentEntity1.id ~= 0,"Missing Parent 1");    
    Debug.Assert(self.Properties.ParentEntity2.id ~= 0,"Missing Parent 2");    
    Debug.Assert(self.Properties.ParentEntity3.id ~= 0,"Missing Parent 3");    

    self.transformBusSender = TransformBusSender(self.entityId);
    
    self.parentEntity1 = self.Properties.ParentEntity1;
    self.parentEntity2 = self.Properties.ParentEntity2;
    self.parentEntity3 = self.Properties.ParentEntity3;
    
    self.tickBusHandler = TickBusHandler(self,0);
    
    local transform = self.transformBusSender:GetWorldTM();    
    self.m_initialPosition = transform:GetTranslation();
    
    self.m_parentCounter = math.random();
end

function transformcomponenttestchild:OnDeactivate()
    if (self.tickBusHandler ~= nil) then    
        self.tickBusHandler:Disconnect();
    end
end

function transformcomponenttestchild:OnTick(deltaTime,timePoint)
    self.m_parentCounter = self.m_parentCounter - deltaTime;
    
    if (self.m_parentCounter <= 0) then
        self.m_parentCounter = math.random() + math.random(0,1);
        local randomValue = math.random(0,4);
        
        if (randomValue == 0) then
            local transform = self.transformBusSender:GetLocalTM();
            transform:SetTranslation(Vector3(0,0,0));
            self.transformBusSender:SetLocalTM(transform);
            
            self.transformBusSender:SetParentRelative(self.parentEntity1);
        elseif (randomValue == 1) then
            local transform = self.transformBusSender:GetLocalTM();
            transform:SetTranslation(Vector3(0,0,0));
            self.transformBusSender:SetLocalTM(transform);
            
            self.transformBusSender:SetParentRelative(self.parentEntity2);
        elseif (randomValue == 2) then
            local transform = self.transformBusSender:GetLocalTM();
            transform:SetTranslation(Vector3(0,0,0));
            self.transformBusSender:SetLocalTM(transform);
            
            self.transformBusSender:SetParentRelative(self.parentEntity3);
        else
            self.transformBusSender:SetParent(EntityId(0));
            
            local transform = self.transformBusSender:GetWorldTM();
            transform:SetTranslation(self.m_initialPosition);
            self.transformBusSender:SetWorldTM(transform);
        end
    end
end