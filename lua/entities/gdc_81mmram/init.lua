
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

--include('entities/base_wire_entity/init.lua'); 
include('shared.lua')

function ENT:Initialize()   

	self.ammos = 1
	self.clipsize = 1
	self.loading = false
	self.reloadtime = 0
	self.FireHE = false
	self.FireWP = false
	self.Velo = Vector(0,0,0)
	self.Pos2 = self.Entity:GetPos()
	self.Entity:SetModel( "models/props_pipes/pipecluster08d_extender64.mdl" ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox     
	//self.Entity:SetColor(100,100,100,255)
	self.Entity:DrawShadow( false )

          
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:Wake() 
	end 
 
	self.Inputs = Wire_CreateInputs( self.Entity, { "Fire", "Fire WP"} )
	self.Outputs = Wire_CreateOutputs( self.Entity, { "Can Fire"})
end   

function ENT:SpawnFunction( ply, tr)
	
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 60
	
	
	local ent = ents.Create( "gdc_81mmram" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	
	
	return ent

end

function ENT:firehe()

		local ent = ents.Create( "gdca_ram_he" )
		ent:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 100)
		ent:SetAngles( self.Entity:GetAngles() )
		ent:Spawn()
		ent:Activate()

		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 30)
		effectdata:SetNormal(self:GetUp())
		effectdata:SetScale(1.3)
		effectdata:SetRadius(3)
		effectdata:SetMagnitude(self.Velo:Length())
		effectdata:SetAngles(self.Velo:Angle())
		util.Effect( "gdca_rocketlaunch", effectdata )
		self.Entity:EmitSound( "RAM.Emit" )
		self.ammos = self.ammos-1

end

function ENT:firewp()

		local ent = ents.Create( "gdca_ram_wp" )
		ent:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 100)
		ent:SetAngles( self.Entity:GetAngles() )
		ent:Spawn()
		ent:Activate()
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 30)
		effectdata:SetNormal(self:GetUp())
		effectdata:SetScale(1.3)
		effectdata:SetRadius(3)
		effectdata:SetMagnitude(self.Velo:Length())
		effectdata:SetAngles(self.Velo:Angle())
		util.Effect( "gdca_rocketlaunch", effectdata )
		self.Entity:EmitSound( "RAM.Emit" )
		self.ammos = self.ammos-1

end
function ENT:Think()
	self.Velo = (self.Entity:GetPos()-self.Pos2)*66
	self.Pos2 = self.Entity:GetPos()

Wire_TriggerOutput(self.Entity, "Shots", self.ammos)
	if self.ammos <= 0 then
	self.reloadtime = CurTime()+2
	self.ammos = self.clipsize
	end
	
	if (self.reloadtime < CurTime()) then
	Wire_TriggerOutput(self.Entity, "Can Fire", 1)
	else
	Wire_TriggerOutput(self.Entity, "Can Fire", 0)
	end
	
	if self.FireHE then
	if (self.reloadtime < CurTime()) then
	self:firehe()	
	end
	end

	if self.FireWP and !self.FireHE then
	if (self.reloadtime < CurTime()) then
	self:firewp()	
	end
	end

	self.Entity:NextThink( CurTime() + .01)
	return true
end

function ENT:TriggerInput(k, v)

		if(k=="Fire") then
		if((v or 0) >= 1) then
		self.FireHE = true
		else
		self.FireHE = false
		end
		end

		if(k=="Fire WP") then
		if((v or 0) >= 1) then
		self.FireWP = true
		else
		self.FireWP = false
		end
		end	
	
end
 
 
