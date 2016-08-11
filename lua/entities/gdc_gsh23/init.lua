AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--include('entities/base_wire_entity/init.lua'); 
include('shared.lua')

// READ ME!

// So you found this entity and you're wondering why its not on the list.
// It's because it's an exploit and I don't want it to be minged. It isn't even the best weapon but it's easy to abuse so 
// DONT TELL ANYBODY HOW TO USE IT. Otherwise I will change/remove it so it's not usable by you, and you'll be sorry.

function ENT:Initialize()   

	local CheckHo = ents.FindByClass( "gdc_gsh23" )		
	for _,t in pairs(CheckHo) do
	if t.Entity:IsValid() and (t.Entity!=self.Entity) and (t.Entity:GetClass()=="gdc_gsh23") then
	if t:GetPos():Distance(self:GetPos())<1000 then
	self.Entity:Remove() 		print("Removed Extra GSH-23")	
	end
	end
	end

	self.armed = false
	self.loading = false
	self.reloadtime = 0
	self.inFireAPT = false
	self.inFireHEFIT = false
	self.heat = 0
	self.Velo = Vector(0,0,0)
	self.Pos2 = self.Entity:GetPos()
	self.Entity:SetModel( "models/props_c17/signpole001.mdl" ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox     
	util.PrecacheSound("GSh23.Single")
	self.Entity:DrawShadow( false )
          
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
	phys:Wake() 
	end 
 
	self.Inputs = Wire_CreateInputs( self.Entity, { "Fire AP-T", "Fire HEFI-T"} )
	self.Outputs = Wire_CreateOutputs( self.Entity, { "Can Fire", "Heat"})
end   

function ENT:SpawnFunction( ply, tr)
	
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 60
	
	local ent = ents.Create( "gdc_gau19" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent
end

function ENT:fireapt()

		local ent = ents.Create( "gdca_23x115_apt" )
		ent:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 250)
		ent:SetAngles( self.Entity:GetAngles() )
		ent:Spawn()
		ent:Activate()
		self.heat = self.heat+6
		
		
		local phys = self.Entity:GetPhysicsObject()  	
		if (phys:IsValid()) then  		
		phys:ApplyForceCenter( self.Entity:GetUp() * -23000 ) 
		end 
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 110)
		effectdata:SetNormal(self:GetUp())
		effectdata:SetScale(0.6)
		effectdata:SetRadius(2)
		effectdata:SetMagnitude(self.Velo:Length())
		effectdata:SetAngles(self.Velo:Angle())
		util.Effect( "gdca_highrpmmuzzle", effectdata )
		util.ScreenShake(self.Entity:GetPos(), 2, 5, 0.1, 400 )
		self.Entity:EmitSound( "GSh23.Emit" )
	

end

function ENT:firehefit()
	local ent = ents.Create( "gdca_23x115_hefit" )
		ent:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 250)
		ent:SetAngles( self.Entity:GetAngles() )
		ent:Spawn()
		ent:Activate()
		self.heat = self.heat+6
		
		local phys = self.Entity:GetPhysicsObject()  	
		if (phys:IsValid()) then  		
		phys:ApplyForceCenter( self.Entity:GetUp() * -23000 ) 
		end 
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 110)
		effectdata:SetNormal(self:GetUp())
		effectdata:SetScale(0.6)
		effectdata:SetRadius(2)
		effectdata:SetMagnitude(self.Velo:Length())
		effectdata:SetAngles(self.Velo:Angle())
		util.Effect( "gdca_highrpmmuzzle", effectdata )
		util.ScreenShake(self.Entity:GetPos(), 2, 5, 0.1, 400 )
		self.Entity:EmitSound( "GSh23.Emit" )
	
end

function ENT:Think()
	self.Velo = (self.Entity:GetPos()-self.Pos2)*33.4
	self.Pos2 = self.Entity:GetPos()

			if self.heat>0 then
			Wire_TriggerOutput(self.Entity, "Heat", self.heat)
			self.heat = self.heat-2
			end

			if self.heat>100 then
			self.reloadtime = CurTime()+4		// Overheat for 4 seconds
			end

	if (self.reloadtime < CurTime()) then
	Wire_TriggerOutput(self.Entity, "Can Fire", 1)
	else
	Wire_TriggerOutput(self.Entity, "Can Fire", 0)
	end
	
	if self.inFireAPT then
	if (self.reloadtime < CurTime()) then
	self:fireapt()	
	end
	end
	
	if self.inFireHEFIT and !self.inFireAPT then
	if (self.reloadtime < CurTime()) then
	self:firehefit()	
	end
	end

	self.Entity:NextThink( CurTime() + .03)
	return true

end

function ENT:TriggerInput(k, v)

	if(k=="Fire AP-T") then
		if((v or 0) == 1) then		// See a pattern with the non-menu'd weapons? 529
		self.inFireAPT = true
		else
		self.inFireAPT = false
		end
		end
	
	if(k=="Fire HEFI-T") then
		if((v or 0) == 1) then
		self.inFireHEFIT = true
		else
		self.inFireHEFIT = false
		end
		end
	
end
 
 
