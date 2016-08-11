
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

--include('entities/base_wire_entity/init.lua'); 
include('shared.lua')

util.PrecacheSound("arty/artyfire.wav")

function ENT:Initialize()   

	local CheckHo = ents.FindByClass( "gdc_mk19" )		
	for _,t in pairs(CheckHo) do
	if t.Entity:IsValid() and (t.Entity!=self.Entity) and (t.Entity:GetClass()=="gdc_mk19") then
	if t:GetPos():Distance(self:GetPos())<100 then
	self.Entity:Remove() 		print("Removed Extra MK-19")	
	end
	end
	end

	self.ammos = 32
	self.clipsize = 32
	self.loading = false
	self.reloadtime = 0
	self.infire = false
	self.infire2 = false
	self.Velo = Vector(0,0,0)
	self.Pos2 = self.Entity:GetPos()
	self.Entity:SetModel( "models/props_lab/pipesystem01b.mdl" ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox     
	self.Entity:DrawShadow( false )
	
          
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:Wake() 
	end 
 
	self.Inputs = Wire_CreateInputs( self.Entity, { "Fire HE", "Fire HEDP", "Fire Marker" } )
	self.Outputs = Wire_CreateOutputs( self.Entity, { "Can Fire"})
end   

function ENT:SpawnFunction( ply, tr)
	
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 10
	
	
	local ent = ents.Create( "gdc_mk19" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	
	
	return ent

end

function ENT:firehedp()

		local ent = ents.Create( "gdca_40x53_hedp" )
		ent:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 100)
		ent:SetAngles( self.Entity:GetAngles() )
		ent:Spawn()
		ent:Activate()
		self.armed = false
		
		local phys = self.Entity:GetPhysicsObject()  	
		if (phys:IsValid()) then  		
		phys:ApplyForceCenter( self.Entity:GetUp() * -10000 ) 
		end 
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 30)
		effectdata:SetNormal(self:GetUp())
		effectdata:SetScale(0.5)
		effectdata:SetRadius(1)
		effectdata:SetMagnitude(self.Velo:Length())
		effectdata:SetAngles(self.Velo:Angle())
		util.Effect( "gdca_cannonmuzzle", effectdata )
		util.ScreenShake(self.Entity:GetPos(), 20, 5, 0.2, 200 )
		self.Entity:EmitSound( "MK19.Emit" )
		self.ammos = self.ammos-1
	

end

function ENT:firehe()

	local ent = ents.Create( "gdca_40x53_he" )
		ent:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 150)
		ent:SetAngles( self.Entity:GetAngles() )
		ent:Spawn()
		ent:Activate()
		self.armed = false
		
		local phys = self.Entity:GetPhysicsObject()  	
		if (phys:IsValid()) then  		
		phys:ApplyForceCenter( self.Entity:GetUp() * -10000 ) 
		end 
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 30)
		effectdata:SetNormal(self:GetUp())
		effectdata:SetScale(0.5)
		effectdata:SetRadius(1)
		effectdata:SetMagnitude(self.Velo:Length())
		effectdata:SetAngles(self.Velo:Angle())
		util.Effect( "gdca_cannonmuzzle", effectdata )
		util.ScreenShake(self.Entity:GetPos(), 20, 5, 0.2, 200 )
		self.Entity:EmitSound( "MK19.Emit" )
		self.ammos = self.ammos-1

end

function ENT:firemarker()

	local ent = ents.Create( "gdca_40x53_marker" )
		ent:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 150)
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
		effectdata:SetScale(0.5)
		effectdata:SetRadius(1)
		effectdata:SetMagnitude(self.Velo:Length())
		effectdata:SetAngles(self.Velo:Angle())
		util.Effect( "gdca_cannonmuzzle", effectdata )
		util.ScreenShake(self.Entity:GetPos(), 20, 5, 0.2, 200 )
		self.Entity:EmitSound( "MK19.Emit" )
		self.ammos = self.ammos-1

end

function ENT:Think()
	self.Velo = (self.Entity:GetPos()-self.Pos2)*4.54
	self.Pos2 = self.Entity:GetPos()

	if self.ammos <= 0 then
	self.reloadtime = CurTime()+8
	self.ammos = self.clipsize
	end
	
	if (self.reloadtime < CurTime()) then
		Wire_TriggerOutput(self.Entity, "Can Fire", 1)
	else
		Wire_TriggerOutput(self.Entity, "Can Fire", 0)
	end
	
	if self.inFire then
	if (self.reloadtime < CurTime()) then
	self:firehedp()		
	end
	end
	
	if self.inFire2 and !self.inFire then
	if (self.reloadtime < CurTime()) then
	self:firehe()	
	end
	end

	if self.inFire3 and !self.inFire then
	if (self.reloadtime < CurTime()) then
	self:firemarker()	
	end
	end

	self.Entity:NextThink( CurTime() + .22)
	return true
end

function ENT:TriggerInput(k, v)

		if(k=="Fire HEDP") then
		if((v or 0) >= 1) then
		self.inFire = true
		else
		self.inFire = false
		end
		end
	
		if(k=="Fire HE") then
		if((v or 0) >= 1) then
		self.inFire2 = true
		else
		self.inFire2 = false
		end
		end

		if(k=="Fire Marker") then
		if((v or 0) >= 1) then
		self.inFire3 = true
		else
		self.inFire3 = false
		end
		end
	
end
 
 
