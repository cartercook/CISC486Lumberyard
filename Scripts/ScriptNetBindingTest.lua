scriptnetbindingtest =
{
    Properties =
    {
        m_triggerArea =
        {
            entity="",
            description="Area used to trigger logging."
        },
        
        m_health = 
        { 
            default=100, 
            netSynched = 
            {
            }
        },
        
        m_variant = 
        { 
            default="", 
            netSynched = 
            {
                ForceIndex=3
            }
        },

        OuterGroup =
        {
            m_value1 =
            {
                default=100,
                netSynched = { }
            },
            
            m_nonNetworkedValue =
            {
                default="I'm a default value!"
            },

            SubGroup =
            {
                m_value2 =
                {
                    default=50,
                    netSynched = { }
                }
            }
        }
    },
    
    NetRPCs =
    {
        TestRPCNoParam = {},
        TestRPCParam = {}
    }
}

function scriptnetbindingtest:OnActivate()    
    self.tickBusHandler = TickBusHandler(self,0);
    
    self.m_typeToggle = math.random(2);
    self.m_rpcToggle = math.random(2);
    self.m_paramToggle = math.random(2);
    self.m_allowClientRPCToggle = math.random(2);
    self.m_counter = math.random();
    
    self.m_logEnabled = false;
    if (self.Properties.m_triggerArea.id ~= 0) then        
        self.triggerAreaBusHandler = TriggerAreaNotificationBusHandler(self,self.Properties.m_triggerArea);
	else
		self.m_logEnabled = true;
    end
end

function scriptnetbindingtest:OnDeactivate()
    if (self.tickBusHandler ~= nil) then
        self.tickBusHandler:Disconnect();
        self.tickBusHandler = nil;
    end
    
    if (self.triggerAreaBusHandler ~= nil) then
        self.triggerAreaBusHandler:Disconnect();
        self.triggerAreaBusHandler = nil;
    end
end

function scriptnetbindingtest:OnReplicaActivate(isMaster)    
end

function scriptnetbindingtest:OnTick(deltaTime,timePoint)    
    self.m_counter = self.m_counter + deltaTime;
       
    if (self.m_counter >= 1.0) then
        self.m_counter = 0;
        if (self.IsMaster()) then           
            if (self.m_toggle == 1) then
                if (self.m_paramToggle == 1) then
                    self.Properties.m_variant = "Test String";
                else
                    self.Properties.m_variant = 10;
                end
                
                if (self.Properties.m_variant ~= nil) then            
                    self:TryLogValue("Variant: " .. self.Properties.m_variant);
                end
                
                if (self.m_rpcToggle == 1) then
                    if (self.m_paramToggle == 1) then
                        self.NetRPCs.TestRPCParam(deltaTime);
                    else
                        self.NetRPCs.TestRPCParam("StringParam - " .. deltaTime);
                    end
                    
                    self.m_paramToggle = math.random(2);
                else
                    self.NetRPCs.TestRPCNoParam();
                end
                
                self.m_rpcToggle = math.random(2);
            else            
                local tempHealth = self.Properties.m_health;
                if (tempHealth ~= nil) then
                    self.Properties.m_health = tempHealth - 1;
                    self:TryLogValue("Health: " .. self.Properties.m_health);
                end

                self.Properties.OuterGroup.m_value1 = self.Properties.OuterGroup.m_value1 - 1;
                self:TryLogValue("SubGroup-Value1: " .. self.Properties.OuterGroup.m_value1);
                
                self.Properties.OuterGroup.m_nonNetworkedValue = "I'm an updated value!";
                self:TryLogValue("SubGroup-NonNetworkedValue: " .. self.Properties.OuterGroup.m_nonNetworkedValue);

                self.Properties.OuterGroup.SubGroup.m_value2 = self.Properties.OuterGroup.SubGroup.m_value2 - 1;
                self:TryLogValue("SubGroup-Value2: " .. self.Properties.OuterGroup.SubGroup.m_value2);                
            end
            
            self.m_toggle = math.random(2);
        else
            if (self.m_rpcToggle == 1) then                
                if (self.m_paramToggle == 1) then                    
                    self:TryLogValue("Call To Master - TestRPCParam(" .. deltaTime .. ")");
                    self.NetRPCs.TestRPCParam(deltaTime);
                else                    
                    self:TryLogValue("Call To Master - TestRPCParam(StringParam - " .. deltaTime .. ")");
                    self.NetRPCs.TestRPCParam("StringParam - " .. deltaTime);
                end
                
                self.m_paramToggle = math.random(2);
            else
                self:TryLogValue("Call To Master - TestRPCNoParam");
                self.NetRPCs.TestRPCNoParam();
            end
            
            self.m_rpcToggle = math.random(2);            
            
            self:TryLogValue("SubGroup-NonNetworkedValue: " .. self.Properties.OuterGroup.m_nonNetworkedValue);
        end
    end
end

function scriptnetbindingtest:OnTriggerAreaEntered(triggeringEntityId)
    self.m_logEnabled = true;    
end

function scriptnetbindingtest:OnTriggerAreaExited(triggeringEntityId)
    self.m_logEnabled = false;    
end

function scriptnetbindingtest:TryLogValue(value)    
    if (self.m_logEnabled) then
        Debug.Log(value);
    end
end

-- These are various callback functions specified by the network table or RPCs

function scriptnetbindingtest.Properties.m_health.netSynched:OnNewValue()
    self:TryLogValue("Net - HealthChanged: " .. self.Properties.m_health);
end

function scriptnetbindingtest.Properties.m_variant.netSynched:OnNewValue()
    self:TryLogValue("Net - VariantChanged: " .. self.Properties.m_variant);
end

function scriptnetbindingtest.Properties.OuterGroup.m_value1.netSynched:OnNewValue()
    self:TryLogValue("Net - Value1Changed: " .. self.Properties.OuterGroup.m_value1);
end

function scriptnetbindingtest.Properties.OuterGroup.SubGroup.m_value2.netSynched:OnNewValue()
    self:TryLogValue("Net - Value2Chagned: " .. self.Properties.OuterGroup.SubGroup.m_value2);
end

function scriptnetbindingtest.NetRPCs.TestRPCNoParam:OnMaster()
    self.m_allowClientRPCToggle = math.random(2);
    self:TryLogValue("Master RPC - No Param");
    self:TryLogValue("Client Allowed: " .. tostring(self.m_allowClientRPCToggle));
    
    return self.m_allowClientRPCToggle == 1;
end

function scriptnetbindingtest.NetRPCs.TestRPCNoParam:OnProxy()
    self:TryLogValue("Proxy RPC - No Param");
end

function scriptnetbindingtest.NetRPCs.TestRPCParam:OnMaster(param1)	
    self.m_allowClientRPCToggle = math.random(2);
    
    self:TryLogValue("Master RPC - Param");
    self:TryLogValue("Param1 - " .. tostring(param1));
    self:TryLogValue("Client Allowed: " .. tostring(self.m_allowClientRPCToggle));
    
    return self.m_allowClientRPCToggle == 1;
end

function scriptnetbindingtest.NetRPCs.TestRPCParam:OnProxy(param1)
    self:TryLogValue("Proxy RPC - Param");
    self:TryLogValue("Param1 - " .. tostring(param1));    
end