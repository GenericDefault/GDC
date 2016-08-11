
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

--include('entities/base_wire_entity/init.lua'); 
include('shared.lua')

function ENT:Initialize()   

	local CheckHo = ents.FindByClass( "gdc_m101" )		
	for _,t in pairs(CheckHo) do
	if t.Entity:IsValid() and (t.Entity!=self.Entity) and (t.Entity:GetClass()=="gdc_m101") then
	if t:GetPos():Distance(self:GetPos())<500 then
	self.Entity:Remove() 		print("Removed Extra M101")	
	end
	end
	end

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
 
	self.Inputs = Wire_CreateInputs( self.Entity, { "Fire HE", "Fire WP" } )
	self.Outputs = Wire_CreateOutputs( self.Entity, { "Can Fire"})
end   

function ENT:SpawnFunction( ply, tr)
	
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 10
	
	
	local ent = ents.Create( "gdc_m101" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	
	
	return ent

end

function ENT:firewp()

		local ent = ents.Create( "gdca_105x372wp" )
		ent:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 100)
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
		effectdata:SetScale(1.6)
		effectdata:SetRadius(3)
		effectdata:SetMagnitude(self.Velo:Length())
		effectdata:SetAngles(self.Velo:Angle())
		util.Effect( "gdca_cannonmuzzle", effectdata )
		util.ScreenShake(self.Entity:GetPos(), 90, 5, 0.3, 1050 )
		self.Entity:EmitSound( "M101.Emit" )
		self.ammos = self.ammos-1
	

end

function ENT:firehe()

	local ent = ents.Create( "gdca_105x372he" )
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
		effectdata:SetScale(1.6)
		effectdata:SetRadius(3)
		effectdata:SetMagnitude(self.Velo:Length())
		effectdata:SetAngles(self.Velo:Angle())
		util.Effect( "gdca_cannonmuzzle", effectdata )
		util.ScreenShake(self.Entity:GetPos(), 90, 5, 0.3, 1050 )
		self.Entity:EmitSound( "M101.Emit" )
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
	self:firewp()	
	end
	end
	
	if self.inFire2 and !self.inFire then
	if (self.reloadtime < CurTime()) then
	self:firehe()	
	end
	end

	self.Entity:NextThink( CurTime() + .01)
	return true
end

function ENT:TriggerInput(k, v)
if(k=="Fire WP") then
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
	
end
 
 
