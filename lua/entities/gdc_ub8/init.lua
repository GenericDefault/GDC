
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

--include('entities/base_wire_entity/init.lua'); 
include('shared.lua')

function ENT:Initialize()   

	self.ammos = 8
	self.clipsize = 8
	self.armed = false
	self.loading = false
	self.reloadtime = 0
	self.infireheat = false
	self.infirefae = false
	self.infirepenetrator = false
	self.heat = 0
	self.Velo = Vector(0,0,0)
	self.Pos2 = self.Entity:GetPos()
	self.Entity:SetModel( "models/props_pipes/pipecluster08d_extender64.mdl" ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox     
	//self.Entity:SetColor(70,70,70,255)
	self.Entity:DrawShadow( false )
	
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
	phys:Wake() 
	end 
 
	self.Inputs = Wire_CreateInputs( self.Entity, { "Fire HEAT", "Fire FAE", "Fire Penetrator"} )
	self.Outputs = Wire_CreateOutputs( self.Entity, { "Can Fire", "Shots", "Heat"})
end   

function ENT:SpawnFunction( ply, tr)
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 60
	local ent = ents.Create( "gdc_ub8" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end

	function ENT:fireheat()
		local ent = ents.Create( "gdca_80mms8heat" )
		ent:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 300 + self.Velo)
		ent:SetAngles( self.Entity:GetAngles() )
		ent:Spawn()
		ent:Activate()
		self.heat = self.heat+40	
	
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 30)
		effectdata:SetNormal(self:GetUp())
		effectdata:SetScale(1.2)
		effectdata:SetRadius(1)
		effectdata:SetMagnitude(self.Velo:Length())
		effectdata:SetAngles(self.Velo:Angle())
		util.Effect( "gdca_rocketlaunch", effectdata )
		self.Entity:EmitSound( "RocketPod.Emit" )
		self.ammos = self.ammos-1
	end

	function ENT:firefae()
		local ent = ents.Create( "gdca_80mms8fae" )
		ent:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 300 + self.Velo)
		ent:SetAngles( self.Entity:GetAngles() )
		ent:Spawn()
		ent:Activate()
		self.heat = self.heat+40	
	
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 30)
		effectdata:SetNormal(self:GetUp())
		effectdata:SetScale(1.2)
		effectdata:SetRadius(1)
		effectdata:SetMagnitude(self.Velo:Length())
		effectdata:SetAngles(self.Velo:Angle())
		util.Effect( "gdca_rocketlaunch", effectdata )
		self.Entity:EmitSound( "RocketPod.Emit" )
		self.ammos = self.ammos-1
	end

	function ENT:firepenetrator()

		local ent = ents.Create( "gdca_80mms8penetrator" )
		ent:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 300 + self.Velo)
		ent:SetAngles( self.Entity:GetAngles() )
		ent:Spawn()
		ent:Activate()
		self.heat = self.heat+40

		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 30)
		effectdata:SetNormal(self:GetUp())
		effectdata:SetScale(1.2)
		effectdata:SetRadius(1)
		effectdata:SetMagnitude(self.Velo:Length())
		effectdata:SetAngles(self.Velo:Angle())
		util.Effect( "gdca_rocketlaunch", effectdata )
		self.Entity:EmitSound( "RocketPod.Emit" )
		self.ammos = self.ammos-1
	end

function ENT:Think()
	self.Velo = (self.Entity:GetPos()-self.Pos2)/19
	self.Pos2 = self.Entity:GetPos()

Wire_TriggerOutput(self.Entity, "Shots", self.ammos)

	if self.ammos <= 0 then
	self.reloadtime = CurTime()+16
	self.ammos = self.clipsize
	end

			if self.heat>0 then
			Wire_TriggerOutput(self.Entity, "Heat", self.heat)
			self.heat = self.heat-10
			end

			if self.heat>100 then
			self.reloadtime = CurTime()+3		// Overheat for 3 seconds
			end

	if (self.reloadtime < CurTime()) then
	Wire_TriggerOutput(self.Entity, "Can Fire", 1)
	else
	Wire_TriggerOutput(self.Entity, "Can Fire", 0)
	end
	
	if self.inFireHEAT then
	if (self.reloadtime < CurTime()) then
	self:fireheat()
	end
	end
	
	if self.inFireFAE and !self.inFireHEAT then
	if (self.reloadtime < CurTime()) then
	self:firefae()	
	end
	end

	if self.inFirePenetrator and !self.inFireHEAT and !self.inFireFAE then
	if (self.reloadtime < CurTime()) then
	self:firepenetrator()
	end
	end

	self.Entity:NextThink( CurTime() + 0.25)
	return true
end

function ENT:TriggerInput(k, v)
	if(k=="Fire HEAT") then
		if((v or 0) >= 1) then
		self.inFireHEAT = true
		else
		self.inFireHEAT = false
		end
	end
	
	if(k=="Fire FAE") then
		if((v or 0) >= 1) then
		self.inFireFAE = true
		else
		self.inFireFAE = false
		end
	end

	if(k=="Fire Penetrator") then
		if((v or 0) >= 1) then
		self.inFirePenetrator = true
		else
		self.inFirePenetrator = false
		end
	end
end