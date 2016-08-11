
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

--include('entities/base_wire_entity/init.lua'); 
include('shared.lua')


function ENT:Initialize()   


	self.ammos =1
	self.clipsize = 1
	self.armed = false
	self.loading = false
	self.reloadtime = 0
	self.infire = false
	self.infire2 = false
	self.Velo = Vector(0,0,0)
	self.Pos2 = self.Entity:GetPos()
	self.Entity:SetModel( "models/props_pipes/pipecluster08d_extender128.mdl" ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox     
	self.Entity:DrawShadow( false )
	
          
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:Wake() 
	end 
 
	self.Inputs = Wire_CreateInputs( self.Entity, { "Fire HEAT", "Fire SABOT" } )
	self.Outputs = Wire_CreateOutputs( self.Entity, { "Can Fire"})
end   

function ENT:SpawnFunction( ply, tr)
	
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 10
	
	
	local ent = ents.Create( "gdc_m256" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	
	
	return ent

end

function ENT:firesabot()

		local ent = ents.Create( "gdca_120mm_sabot" )
		ent:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 150)
		ent:SetAngles( self.Entity:GetAngles() )
		ent:Spawn()
		ent:Activate()
		self.armed = false
		
		
		local phys = self.Entity:GetPhysicsObject()  	
		if (phys:IsValid()) then  		
		phys:ApplyForceCenter( self.Entity:GetUp() * -120000 ) 
		end 
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 80)
		effectdata:SetNormal(self:GetUp())
		effectdata:SetScale(2)
		effectdata:SetRadius(4)
		effectdata:SetMagnitude(self.Velo:Length())
		effectdata:SetAngles(self.Velo:Angle())
		util.Effect( "gdca_cannonmuzzle", effectdata )
		util.ScreenShake(self.Entity:GetPos(), 95, 5, 0.4, 1200 )
		self.Entity:EmitSound( "M256.Emit" )
		self.ammos = self.ammos-1
	

end

function ENT:fireheat()

	local ent = ents.Create( "gdca_120mm_heat" )
		ent:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 150)
		ent:SetAngles( self.Entity:GetAngles() )
		ent:Spawn()
		ent:Activate()
		self.armed = false
		
		
		local phys = self.Entity:GetPhysicsObject()  	
		if (phys:IsValid()) then  		
			phys:ApplyForceCenter( self.Entity:GetUp() * -120000 ) 
		end 
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 80)
		effectdata:SetNormal(self:GetUp())
		effectdata:SetScale(2)
		effectdata:SetRadius(4)
		effectdata:SetMagnitude(self.Velo:Length())
		effectdata:SetAngles(self.Velo:Angle())
		util.Effect( "gdca_cannonmuzzle", effectdata )
		util.ScreenShake(self.Entity:GetPos(), 95, 5, 0.4, 1200 )
		self.Entity:EmitSound( "M256.Emit" )
		self.ammos = self.ammos-1
	

end

function ENT:Think()
	self.Velo = (self.Entity:GetPos()-self.Pos2)*66
	self.Pos2 = self.Entity:GetPos()

	if self.ammos <= 0 then
	self.reloadtime = CurTime()+7
	self.ammos = self.clipsize
	end
	
	if (self.reloadtime < CurTime()) then
	Wire_TriggerOutput(self.Entity, "Can Fire", 1)
	else
	Wire_TriggerOutput(self.Entity, "Can Fire", 0)
	end
	
	if self.inFire then
	if (self.reloadtime < CurTime()) then
	self:firesabot()	
	end
	end
	
	if self.inFire2 and !self.inFire then
	if (self.reloadtime < CurTime()) then
	self:fireheat()	
	end
	end

	self.Entity:NextThink( CurTime() + .01)
	return true
end

function ENT:TriggerInput(k, v)
if(k=="Fire SABOT") then
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
 
 
