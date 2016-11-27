
triggerareatestscript =
{
    Properties =
    {
        LightEntity = { entity="", description="Light entity to manipulate."},
    },
}

function triggerareatestscript:OnActivate()        
    -- For Handling TriggerAreaBus
    self.triggerAreaBusHandler = TriggerAreaNotificationBusHandler(self,self.entityId);    
    self.m_triggeringCounter = 0;
    
    Debug.Assert(self.Properties.LightEntity.id ~= 0, "No light is attached!");    
    
    if (self.Properties.LightEntity.id ~= 0) then        
        self.lightBusSender = LightComponentRequestBusSender(self.Properties.LightEntity);
        self.lightBusSender:TurnOffLight();
    end
end

function triggerareatestscript:OnTriggerAreaEntered(triggeringEntityId)    
    self.m_triggeringCounter = self.m_triggeringCounter + 1;
    
    self.lightBusSender:TurnOnLight();    
end

function triggerareatestscript:OnTriggerAreaExited(triggeringEntityId)    
    self.m_triggeringCounter = self.m_triggeringCounter - 1;
    
    if (self.m_triggeringCounter == 0) then
        self.lightBusSender:TurnOffLight();
    end
end

function triggerareatestscript:OnDeactivate()
    if (self.triggerAreaBusHandler ~= nil) then
        self.triggerAreaBusHandler:Disconnect();
    end
end