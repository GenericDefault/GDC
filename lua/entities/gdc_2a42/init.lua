
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

--include('entities/base_wire_entity/init.lua'); 
include('shared.lua')

util.PrecacheSound("arty/cannon.wav")

function ENT:Initialize()   

	self.ammos 	= 1
	self.clipsize 	= 1
	self.armed 	= false
	self.loading 	= false
	self.reloadtime = 0
	self.infire 	= false
	self.infire2 	= false
	self.inFireAP 	= false
	self.inFireAPT 	= false
	self.Airburst 	= 0
	self.Velo = Vector(0,0,0)
	self.Pos2 = self.Entity:GetPos()
	self.Entity:SetModel( "models/props_lab/pipesystem01a.mdl" ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox     
	self.Entity:DrawShadow( false )

	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
	phys:Wake() 
	end 
 
	self.Inputs = Wire_CreateInputs( self.Entity, { "Fire", "Fire Tracer", "Fire AP", "Fire APT", "Airburst Time"} )

end   

function ENT:SpawnFunction( ply, tr)
	
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 60
	
	
	local ent = ents.Create( "gdc_2a42" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	
	
	return ent

end

function ENT:fire()

		local ent = ents.Create( "gdca_30x165_he" )
		ent:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 100)
		ent:SetAngles( self.Entity:GetAngles() )
		ent.Gun = self.Entity
		ent:Spawn()
		ent:Activate()
		
		local phys = self.Entity:GetPhysicsObject()  	
		if (phys:IsValid()) then  		
		phys:ApplyForceCenter( self.Entity:GetUp() * -30000 ) 
		end 
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 30)
		effectdata:SetNormal(self:GetUp())
		effectdata:SetScale(0.8)
		effectdata:SetRadius(5)
		effectdata:SetMagnitude(self.Velo:Length())
		effectdata:SetAngles(self.Velo:Angle())
		util.Effect( "gdca_autocannonmuzzle", effectdata )
		util.ScreenShake(self.Entity:GetPos(), 30, 5, 0.2, 400 )
		self.Entity:EmitSound( "2A42.Emit" )
		self.ammos = self.ammos-1
end

function ENT:firetracer()

	local ent = ents.Create( "gdca_30x165_het" )
		ent:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 100)
		ent:SetAngles( self.Entity:GetAngles() )
		ent.Gun = self.Entity
		ent:Spawn()
		ent:Activate()

		local phys = self.Entity:GetPhysicsObject()  	
		if (phys:IsValid()) then  		
		phys:ApplyForceCenter( self.Entity:GetUp() * -30000 ) 
		end 
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 30)
		effectdata:SetNormal(self:GetUp())
		effectdata:SetScale(0.8)
		effectdata:SetRadius(5)
		effectdata:SetMagnitude(self.Velo:Length())
		effectdata:SetAngles(self.Velo:Angle())
		util.Effect( "gdca_autocannonmuzzle", effectdata )
		util.ScreenShake(self.Entity:GetPos(), 30, 5, 0.2, 400 )
		self.Entity:EmitSound( "2A42.Emit" )
		self.ammos = self.ammos-1
end

function ENT:fireap()

	local ent = ents.Create( "gdca_30x165_ap" )
		ent:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 100)
		ent:SetAngles( self.Entity:GetAngles() )
		ent:Spawn()
		ent:Activate()

		local phys = self.Entity:GetPhysicsObject()  	
		if (phys:IsValid()) then  		
		phys:ApplyForceCenter( self.Entity:GetUp() * -10000 ) 
		end 
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 30)
		effectdata:SetNormal(self:GetUp())
		effectdata:SetScale(0.8)
		effectdata:SetRadius(5)
		effectdata:SetMagnitude(self.Velo:Length())
		effectdata:SetAngles(self.Velo:Angle())
		util.Effect( "gdca_autocannonmuzzle", effectdata )
		util.ScreenShake(self.Entity:GetPos(), 30, 5, 0.2, 400 )
		self.Entity:EmitSound( "2A42.Emit" )
		self.ammos = self.ammos-1
end

function ENT:fireapt()

	local ent = ents.Create( "gdca_30x165_apt" )
		ent:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 100)
		ent:SetAngles( self.Entity:GetAngles() )
		ent:Spawn()
		ent:Activate()

		local phys = self.Entity:GetPhysicsObject()  	
		if (phys:IsValid()) then  		
		phys:ApplyForceCenter( self.Entity:GetUp() * -10000 ) 
		end 
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 30)
		effectdata:SetNormal(self:GetUp())
		effectdata:SetScale(0.8)
		effectdata:SetRadius(5)
		effectdata:SetMagnitude(self.Velo:Length())
		effectdata:SetAngles(self.Velo:Angle())
		util.Effect( "gdca_autocannonmuzzle", effectdata )
		util.ScreenShake(self.Entity:GetPos(), 30, 5, 0.2, 400 )
		self.Entity:EmitSound( "2A42.Emit" )
		self.ammos = self.ammos-1
end

function ENT:Think()
	self.Velo = (self.Entity:GetPos()-self.Pos2)*66
	self.Pos2 = self.Entity:GetPos()

	if self.ammos <= 0 then
	self.reloadtime = CurTime()+0.3
	self.ammos = self.clipsize
	end
	
	
	if self.inFire then
	if (self.reloadtime < CurTime()) then
	self:fire()	
	end
	end
	
	if self.inFire2 and !self.inFire then
	if (self.reloadtime < CurTime()) then
	self:firetracer()			
	end
	end

	if self.inFireAP and !self.inFire and !self.inFire2 then
	if (self.reloadtime < CurTime()) then
	self:fireap()			
	end
	end

	if self.inFireAPT and !self.inFire and !self.inFire2 and !self.inFireAP then
	if (self.reloadtime < CurTime()) then
	self:fireapt()			
	end
	end

	self.Entity:NextThink( CurTime() + .01)
	return true
end

function ENT:TriggerInput(k, v)

		if(k=="Fire") then
		if((v or 0) >= 1) then
		self.inFire = true
		else
		self.inFire = false
		end
		end
	
		if(k=="Fire Tracer") then
		if((v or 0) >= 1) then
		self.inFire2 = true
		else
		self.inFire2 = false
		end
		end

		if(k=="Fire AP") then
		if((v or 0) >= 1) then
		self.inFireAP = true
		else
		self.inFireAP = false
		end
		end

		if(k=="Fire APT") then
		if((v or 0) >= 1) then
		self.inFireAPT = true
		else
		self.inFireAPT = false
		end
		end

		if(k=="Airburst Time") then
		if((v or 0) >= 0) then
		self.Airburst = v
		else	self.Airburst = 0	end	end
	
end
 
 
