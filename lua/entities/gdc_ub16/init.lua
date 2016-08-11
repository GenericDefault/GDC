
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

--include('entities/base_wire_entity/init.lua'); 
include('shared.lua')

function ENT:Initialize()   

	self.ammos = 16
	self.clipsize = 16
	self.armed = false
	self.loading = false
	self.reloadtime = 0
	self.infire = false
	self.infire2 = false
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
 
	self.Inputs = Wire_CreateInputs( self.Entity, { "Fire Frag", "Fire HEAT"} )
	self.Outputs = Wire_CreateOutputs( self.Entity, { "Can Fire", "Shots", "Heat"})
end   

function ENT:SpawnFunction( ply, tr)
	
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 60
	
	
	local ent = ents.Create( "gdc_ub16" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	
	
	return ent

end

function ENT:firefrag()

		local ent = ents.Create( "gdca_57mms5frag" )
		ent:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 300 + self.Velo)
		ent:SetAngles( self.Entity:GetAngles() )
		ent:Spawn()
		ent:Activate()
		self.heat = self.heat+30

		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 30)
		effectdata:SetNormal(self:GetUp())
		effectdata:SetScale(0.8)
		effectdata:SetRadius(1)
		effectdata:SetMagnitude(self.Velo:Length())
		effectdata:SetAngles(self.Velo:Angle())
		util.Effect( "gdca_rocketlaunch", effectdata )
		self.Entity:EmitSound( "RocketPod.Emit" )
		self.ammos = self.ammos-1
	

end

function ENT:fireheat()

		local ent = ents.Create( "gdca_57mms5heat" )
		ent:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 300 + self.Velo)
		ent:SetAngles( self.Entity:GetAngles() )
		ent:Spawn()
		ent:Activate()
		self.heat = self.heat+30	
	
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 30)
		effectdata:SetNormal(self:GetUp())
		effectdata:SetScale(0.8)
		effectdata:SetRadius(1)
		effectdata:SetMagnitude(self.Velo:Length())
		effectdata:SetAngles(self.Velo:Angle())
		util.Effect( "gdca_rocketlaunch", effectdata )
		self.Entity:EmitSound( "RocketPod.Emit" )
		self.ammos = self.ammos-1
	

end

function ENT:Think()
	self.Velo = (self.Entity:GetPos()-self.Pos2)/9
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
			self.reloadtime = CurTime()+3		// Overheat for 2 seconds
			end

	if (self.reloadtime < CurTime()) then
	Wire_TriggerOutput(self.Entity, "Can Fire", 1)
	else
	Wire_TriggerOutput(self.Entity, "Can Fire", 0)
	end
	
	if self.inFire then
	if (self.reloadtime < CurTime()) then
	self:firefrag()	
	end
	end
	
	if self.inFire2 and !self.inFire then
	if (self.reloadtime < CurTime()) then
	self:fireheat()	
	end
	end

	self.Entity:NextThink( CurTime() + 0.12)
	return true
end

function ENT:TriggerInput(k, v)
if(k=="Fire Frag") then
		if((v or 0) >= 1) then
			self.inFire = true
		else
			self.inFire = false
		end
	end
	
	if(k=="Fire HEAT") then
		if((v or 0) >= 1) then
			self.inFire2 = true
		else
			self.inFire2 = false
		end
	end
	
end
 
 
