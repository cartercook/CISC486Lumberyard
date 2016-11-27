spawnercomponenttest =
{
	Properties =
	{		
	}
}

function spawnercomponenttest:OnActivate()
	self.tickBusHandler = TickBusHandler(self,0);
	self.spawnerNotificationHandler = SpawnerComponentNotificationBusHandler(self,self.entityId);
	self.spawnerRequestSender = SpawnerComponentRequestBusSender(self.entityId);

	self.m_counter = 0;
	self.spawnTicket = nil;
end

function spawnercomponenttest:OnDeactivate()
	if (self.tickBusHandler ~= nil) then
		self.tickBusHandler:Disconnect();
	end

	self.tickBusHandler = nil;

	if (self.spawnerNotificationHandler ~= nil) then
		self.spawnerNotificationHandler:Disconnect();
	end

	self.spawnerNotificationHandler = nil;

	self.spawnerRequestSender = nil;
end

function spawnercomponenttest:OnTick(deltaTime,timePoint)
	self.m_counter = self.m_counter + deltaTime;

	if (self.m_counter >= 1.0) then
		self.m_counter = 0;

		if (self.spawnTicket == nil) then
			self.spawnTicket = self.spawnerRequestSender:Spawn();
		else
			self.spawnerRequestSender:Spawn()
		end

		if (self.spawnTicket:IsValid()) then
			Debug.Log("Spawning!");
		else
			Debug.Log("Failure!");
		end
	end
end

function spawnercomponenttest:OnSpawned(sliceTicket,entityList)
	if (self.spawnTicket ~= nil) then
		if (self.spawnTicket == sliceTicket) then
			Debug.Log("Match!");
		else
			self.spawnTicket = nil;
			Debug.Log("MisMatch!");
		end
	end
end