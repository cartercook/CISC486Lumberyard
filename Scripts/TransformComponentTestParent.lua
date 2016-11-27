
transformcomponenttestparent =
{
    Properties =
    {
        TraversalSpeed = 5.0,
        TraversalHeight = 10.0,
    },
}

function transformcomponenttestparent:OnActivate()    
    -- Tick notifications
    self.tickBusHandler = TickBusHandler(self, 0)

    -- Transform Notifications
    self.transformBusSender = TransformBusSender(self.entityId);    
    
    self.m_isAtTop = false;
    self.m_movementCounter = math.random()
    self.m_movementOffset = 0;
end

function transformcomponenttestparent:OnDeactivate()
    if (self.tickBusHandler ~= nil) then
        self.tickBusHandler:Disconnect()
    end
end

function transformcomponenttestparent:OnTick(deltaTime, timePoint)    
    if (self.m_movementOffset == 0) then        
        self.m_movementCounter = self.m_movementCounter - deltaTime;    
        
        if (self.m_movementCounter <= 0) then
            self.m_movementCounter = 0;
            self.m_movementOffset = self.Properties.TraversalHeight;
        end    
    else        
        local transform = self.transformBusSender:GetWorldTM();        
        local translation = transform:GetTranslation();
        
        local displacement = self.Properties.TraversalSpeed * deltaTime;        
        
        if (displacement >= self.m_movementOffset) then        
            displacement = self.m_movementOffset;
        end
        
        self.m_movementOffset = self.m_movementOffset - displacement;
        
        if (self.m_isAtTop == true) then
            translation.z = translation.z - displacement;
        else
            translation.z = translation.z + displacement;
        end
        
        transform:SetTranslation(translation);
        
        self.transformBusSender:SetWorldTM(transform);
        
        if (self.m_movementOffset <= 0) then
            self.m_isAtTop = not self.m_isAtTop;
            self.m_movementCounter = math.random() + math.random(0,2)
        end
    end
end