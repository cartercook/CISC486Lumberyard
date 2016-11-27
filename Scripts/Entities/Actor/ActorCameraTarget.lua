----------------------------------------------------------------------------------------------------
--
-- All or portions of this file Copyright (c) Amazon.com, Inc. or its affiliates or
-- its licensors.
--
-- For complete copyright and license terms please see the LICENSE at the root of this
-- distribution (the "License"). All use of this software is governed by the License,
-- or, if provided, by the license below or the license accompanying this file. Do not
-- remove or modify any license notices. This file is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--
--
----------------------------------------------------------------------------------------------------
ActorCameraTarget = {
	Client = {},
	Server = {},
	Properties = {
		IsAuthority = false, -- this gets set by code FlowNode_SetOwner
		Ack = 0,
	},
}

Net.Expose {
	Class = ActorCameraTarget,

	ClientMethods = {
		ClUpdateAngles = { RELIABLE_UNORDERED, NO_ATTACH, VEC3, INT8 },
	},
	ServerProperties = {
	},
}

------------------------------------------------------------------------------------------------------
function ActorCameraTarget:OnSpawn()
	CryAction.CreateGameObjectForEntity(self.id);
	CryAction.BindGameObjectToNetwork(self.id);
	CryAction.ForceGameObjectUpdate(self.id, true);
	self:Activate(1);
end

------------------------------------------------------------------------------------------------------
--- Client Functions
function ActorCameraTarget.Client:OnInit()
	self.Properties.IsAuthority = false;
end

function ActorCameraTarget.Client:OnUpdate(frameTime)
	if (self.Properties.IsAuthority) then
		-- Log("ActorCameraTarget.Client:OnUpdate send clients orientation " .. self.Properties.Ack);
		self.Properties.Ack = self.Properties.Ack + 1;
		self.otherClients:ClUpdateAngles(g_localChannelId, self:GetWorldAngles(), self.Properties.Ack);
	end
end

function ActorCameraTarget.Client:ClUpdateAngles(angles, ack)
	if (self.Properties.IsAuthority) then
		-- could verify the ack
	else
		--Log("ActorCameraTarget.Client:ClUpdateAngles updating orientation  " .. ack);
		self:SetWorldAngles(angles);
	end
end

------------------------------------------------------------------------------------------------------
--- Server Functions
function ActorCameraTarget.Server:OnInit()
	self.Properties.IsAuthority = true;
end
