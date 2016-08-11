
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

--include('entities/base_wire_entity/init.lua'); 
include('shared.lua')

util.PrecacheSound("Bushmaster.Single")

function ENT:Initialize()   

	self.ammos 	= 1
	self.clipsize 	= 1
	self.reloadtime = 0
	self.FireAPI 	= false
	self.FireAPIT 	= false
	self.FireHEI 	= false
	self.FireHEIT 	= false
	self.Airburst 	= 0
	self.Velo = Vector(0,0,0)
	self.Pos2 = self.Entity:GetPos()
	self.Entity:SetModel( "models/props_lab/pipesystem01a.mdl" ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:DrawShadow( false )
          
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
	phys:Wake() 
	end 
 
	self.Inputs = Wire_CreateInputs( self.Entity, { "Fire API", "Fire APIT", "Fire HEI", "Fire HEIT", "Airburst Time"} )
end   

function ENT:SpawnFunction( ply, tr)
	
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 60
	local ent = ents.Create( "gdc_m242" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:fireapi()
		local Round = ents.Create( "gdca_25x137_api" )
		Round:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 100)
		Round:SetAngles( self.Entity:GetAngles() )
		Round:Spawn()
		Round:Activate()
		
		local phys = self.Entity:GetPhysicsObject()  	
		if (phys:IsValid()) then  		
		phys:ApplyForceCenter( self.Entity:GetUp() * -25000 ) 
		end 
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 30)
		effectdata:SetNormal(self:GetUp())
		effectdata:SetScale(0.7)
		effectdata:SetRadius(3)
		effectdata:SetMagnitude(self.Velo:Length())
		effectdata:SetAngles(self.Velo:Angle())
		util.Effect( "gdca_autocannonmuzzle", effectdata )
		util.ScreenShake(self.Entity:GetPos(), 25, 5, 0.2, 350 )
		self.Entity:EmitSound( "M242.Emit" )
		self.ammos = self.ammos-1
end

function ENT:fireapit()
		local Round = ents.Create( "gdca_25x137_apit" )
		Round:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 100)
		Round:SetAngles( self.Entity:GetAngles() )
		Round:Spawn()
		Round:Activate()
		
		local phys = self.Entity:GetPhysicsObject()  	
		if (phys:IsValid()) then  		
		phys:ApplyForceCenter( self.Entity:GetUp() * -25000 ) 
		end 
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 30)
		effectdata:SetNormal(self:GetUp())
		effectdata:SetScale(0.7)
		effectdata:SetRadius(3)
		effectdata:SetMagnitude(self.Velo:Length())
		effectdata:SetAngles(self.Velo:Angle())
		util.Effect( "gdca_autocannonmuzzle", effectdata )
		util.ScreenShake(self.Entity:GetPos(), 25, 5, 0.2, 350 )
		self.Entity:EmitSound( "M242.Emit" )
		self.ammos = self.ammos-1
end

function ENT:firehei()
		local Round = ents.Create( "gdca_25x137_hei" )
		Round:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 100)
		Round:SetAngles( self.Entity:GetAngles())
		Round.Gun = self.Entity
		Round:Spawn()
		Round:Activate()
		
		local phys = self.Entity:GetPhysicsObject()  	
		if (phys:IsValid()) then  		
		phys:ApplyForceCenter( self.Entity:GetUp() * -25000 ) 
		end 
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 30)
		effectdata:SetNormal(self:GetUp())
		effectdata:SetScale(0.7)
		effectdata:SetRadius(3)
		effectdata:SetMagnitude(self.Velo:Length())
		effectdata:SetAngles(self.Velo:Angle())
		util.Effect( "gdca_autocannonmuzzle", effectdata )
		util.ScreenShake(self.Entity:GetPos(), 25, 5, 0.2, 350 )
		self.Entity:EmitSound( "M242.Emit" )
		self.ammos = self.ammos-1
end

function ENT:fireheit()
		local Round = ents.Create( "gdca_25x137_heit" )
		Round:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 100)
		Round:SetAngles( self.Entity:GetAngles() )
		Round.Gun = self.Entity
		Round:Spawn()
		Round:Activate()

		local phys = self.Entity:GetPhysicsObject()  	
		if (phys:IsValid()) then  		
		phys:ApplyForceCenter( self.Entity:GetUp() * -25000 ) 
		end 
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 30)
		effectdata:SetNormal(self:GetUp())
		effectdata:SetScale(0.7)
		effectdata:SetRadius(3)
		effectdata:SetMagnitude(self.Velo:Length())
		effectdata:SetAngles(self.Velo:Angle())
		util.Effect( "gdca_autocannonmuzzle", effectdata )
		util.ScreenShake(self.Entity:GetPos(), 25, 5, 0.2, 350 )
		self.Entity:EmitSound( "M242.Emit" )
		self.ammos = self.ammos-1
end



function ENT:Think()
	self.Velo = (self.Entity:GetPos()-self.Pos2)*66
	self.Pos2 = self.Entity:GetPos()

	if self.ammos <= 0 then
	self.reloadtime = CurTime()+0.2
	self.ammos = self.clipsize
	end
	
	
	if self.FireAPI then
	if (self.reloadtime < CurTime()) then
	self:fireapi()	
	end
	end

	if self.FireAPIT and !self.FireAPI then
	if (self.reloadtime < CurTime()) then
	self:fireapit()	
	end
	end
	
	if self.FireHEI and !self.FireAPI and !self.FireAPIT then
	if (self.reloadtime < CurTime()) then
	self:firehei()	
	end
	end
	if self.FireHEIT and !self.FireAPI and !self.FireAPIT and !self.FireHEI then
	if (self.reloadtime < CurTime()) then
	self:fireheit()	
	end
	end

	self.Entity:NextThink( CurTime() + .01)
	return true
end

function ENT:TriggerInput(k, v)

		if(k=="Fire API") then
		if((v or 0) >= 1) then
		self.FireAPI = true
		else
		self.FireAPI = false
		end
		end
	
		if(k=="Fire HEI") then
		if((v or 0) >= 1) then
		self.FireHEI = true
		else
		self.FireHEI = false
		end
		end

		if(k=="Fire HEIT") then
		if((v or 0) >= 1) then
		self.FireHEIT = true
		else
		self.FireHEIT = false
		end
		end

		if(k=="Fire APIT") then
		if((v or 0) >= 1) then
		self.FireAPIT = true
		else
		self.FireAPIT = false
		end
		end

		if(k=="Airburst Time") then
		if((v or 0) >= 0) then
		self.Airburst = v
		else	self.Airburst = 0	end	end
		
end