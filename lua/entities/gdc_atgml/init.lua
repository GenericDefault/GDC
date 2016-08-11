
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

--include('entities/base_wire_entity/init.lua'); 
include('shared.lua')

function ENT:Initialize()   

	self.ammos = 1
	self.clipsize = 1
	self.armed = false
	self.loading = false
	self.reloadtime = 0
	self.InFire = false
	self.InFire2 = false
	self.Wobbliness 	= 0.5
	self.Zmod 		= 0.0
	self.DistanceCutoff 	= 5000

	self.TVEnt 		= self.Entity
	self.TVActive 		= 0
	self.TVDirection 	= self.Entity:GetForward()
	self.TVPosition 	= self.Entity:GetPos()
	self.TVRotate 		= Angle(0,0,0)
	self.Velo 		= Vector(0,0,0)
	self.Pos2 		= self.Entity:GetPos()

	self.Entity:SetModel( "models/props_pipes/pipecluster08d_extender64.mdl" ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox     
	self.Entity:SetColor(130,170,100,255)
	self.Entity:DrawShadow( false )

          
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:Wake() 
	end 
 
	self.Inputs = WireLib.CreateSpecialInputs(self, { "Fire ATGM", "Position", "Wobbliness", "Distance Cutoff", "Z Modulation", "Fire TVGM", "TV Rotate"}, { "NORMAL", "VECTOR", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "ANGLE" } )
	self.Outputs = WireLib.CreateSpecialOutputs( self, { "Can Fire", "TV Active", "TV Missile", "TV Position", "TV Direction"}, { "NORMAL", "NORMAL", "ENTITY", "VECTOR", "VECTOR" })
end   

function ENT:SpawnFunction( ply, tr)
	
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 10
	local ent = ents.Create( "gdc_atgml" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:fireatgm()

		local GPSMISSILE = ents.Create( "gdca_atgm" )
		GPSMISSILE:SetPos( self.Entity:GetPos() + (self.Entity:GetUp()*300) + self.Velo)
		GPSMISSILE:SetAngles( self.Entity:GetAngles() )
		GPSMISSILE.Guider = self.Entity
		GPSMISSILE:Spawn()
		GPSMISSILE:Initialize()
		GPSMISSILE:Activate()
		GPSMISSILE.Target = self.Target or Vector(0,0,0)
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 30)
		effectdata:SetNormal(self:GetUp())
		effectdata:SetScale(1.5)
		effectdata:SetRadius(2)
		effectdata:SetMagnitude(self.Velo:Length())
		effectdata:SetAngles(self.Velo:Angle())
		util.Effect( "gdca_rocketlaunch", effectdata )
		self.Entity:EmitSound( "GML.Emit" )
		self.ammos = self.ammos-1
end

function ENT:firetvgm()

		local TVMISSILE = ents.Create( "gdca_tvgm" )
		TVMISSILE:SetPos( self.Entity:GetPos() + (self.Entity:GetUp()*300))
		TVMISSILE:SetAngles( self.Entity:GetAngles() )
		TVMISSILE.Guider = self.Entity
		TVMISSILE:Spawn()
		TVMISSILE:Initialize()
		TVMISSILE:Activate()
		self.TVEnt 		= TVMISSILE
		self.TVActive 		= 1
		self.TVDirection	= TVMISSILE:GetUp()
		self.TVPosition 	= TVMISSILE:GetPos() + TVMISSILE:GetUp()*400	

		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 30)
		effectdata:SetNormal(self:GetUp())
		effectdata:SetScale(1.5)
		effectdata:SetRadius(2)
		effectdata:SetMagnitude(self.Velo:Length())
		effectdata:SetAngles(self.Velo:Angle())
		util.Effect( "gdca_rocketlaunch", effectdata )
		self.Entity:EmitSound( "GML.Emit" )
		self.ammos = self.ammos-1
end

function ENT:Think()
	self.Velo = (self.Entity:GetPos()-self.Pos2)
	self.Pos2 = self.Entity:GetPos()

	if !self.TVEnt:IsValid() || self.TVEnt==self.Entity 	then	
	self.TVEnt = self.Entity
	self.TVActive = 0
	self.TVDirection = self.Entity:GetForward()
	self.TVPosition = self.Entity:LocalToWorld(self.Entity:OBBCenter())
	else			
	self.TVDirection = self.TVEnt:GetUp()
	self.TVPosition = self.TVEnt:LocalToWorld(self.TVEnt:OBBCenter()) + self.TVEnt:GetUp()*400
	end

	Wire_TriggerOutput(self.Entity, "TV Bomb", 	self.TVEnt)
	Wire_TriggerOutput(self.Entity, "TV Active", 	self.TVActive)
	Wire_TriggerOutput(self.Entity, "TV Direction", self.TVDirection)
	Wire_TriggerOutput(self.Entity, "TV Position",  self.TVPosition)


	if self.ammos <= 0 then
	self.reloadtime = CurTime()+10
	self.ammos = self.clipsize
	end
	
	if (self.reloadtime < CurTime()) then
	Wire_TriggerOutput(self.Entity, "Can Fire", 1)
	else
	Wire_TriggerOutput(self.Entity, "Can Fire", 0)
	end
	
	if self.InFire then
	if (self.reloadtime < CurTime()) then
	self:fireatgm()	
	end
	end

	if self.InFire2 then
	if (self.reloadtime < CurTime()) then
	self:firetvgm()	
	end
	end

	self.Entity:NextThink( CurTime() + .01)
	return true
end

function ENT:TriggerInput(k, v)
	self.Velo = (self.Entity:GetPos()-self.Pos2)
	self.Pos2 = self.Entity:GetPos()

	if (k == "Position") then
	self.Target = v or Vector(0,0,0)
	end

	if (k == "Wobbliness") then
	self.Wobbliness = math.Clamp(v,0,5) or 1
	end

	if (k == "Distance Cutoff") then
	self.DistanceCutoff = v or 5000
	end

	if (k == "Z Modulation") then
	self.Zmod = v else self.Zmod = 0.0
	end


		if(k=="Fire ATGM") then
		if((v or 0) >= 1) then
		self.InFire = true
		else
		self.InFire = false
		end
		end

		if(k=="Fire TVGM") then
		if((v or 0) >= 1) then
		self.InFire2 = true
		else
		self.InFire2 = false
		end
		end

		if (k == "TV Rotate") then
		if(v) then
		self.TVRotate = v or Angle(0,0,0)
		end	end
end
 