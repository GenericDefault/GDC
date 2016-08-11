AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

--include('entities/base_wire_entity/init.lua'); 
include('shared.lua')


function ENT:Initialize()   

	self.ammos 		= 1
	self.clipsize 		= 1
	self.armed 		= false
	self.loading 		= false
	self.reloadtime 	= 0
	self.Dropping1 		= false
	self.Dropping2 		= false
	self.Dropping3 		= false
	self.Dropping4 		= false
	self.TVEnt 		= self.Entity
	self.TVActive 		= 0
	self.TVDirection 	= self.Entity:GetForward()
	self.TVPosition 	= self.Entity:GetPos()
	self.TVRotate 		= Angle(0,0,0)
	self.Velo 		= Vector(0,0,0)
	self.Pos2 		= self.Entity:GetPos()

	self.Entity:SetModel( "models/props_phx/ww2bomb.mdl" ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox     
	//self.Entity:SetColor(200,200,200)
	self.Entity:SetMaterial("models/props_lab/door_klab01")
	self.Entity:DrawShadow( false )

          
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
	phys:Wake() 
	end 
 
	self.Inputs = WireLib.CreateSpecialInputs(self, { "Unguided","GPS GBU","TV GBU", "Target Position", "TV Rotate", "Unguided TPA" }, { "NORMAL", "NORMAL", "NORMAL", "VECTOR", "ANGLE", "NORMAL" } )
	self.Outputs = WireLib.CreateSpecialOutputs(self, { "Ready","TV Active", "TV Bomb","TV Position", "TV Direction", }, { "NORMAL", "NORMAL", "ENTITY", "VECTOR", "VECTOR" } )
end   

function ENT:SpawnFunction( ply, tr)
	
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 10
	local ent = ents.Create( "gdc_50kgbomber" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent

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
	self.TVDirection = self.TVEnt:GetForward()
	self.TVPosition = self.TVEnt:LocalToWorld(self.TVEnt:OBBCenter())
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
	Wire_TriggerOutput(self.Entity, "Ready", 1)
	else
	Wire_TriggerOutput(self.Entity, "Ready", 0)
	end
	
	if self.Dropping1 then
	if (self.reloadtime < CurTime()) then
	self:dropdumb()	
	end
	end

	if self.Dropping2 and !self.Dropping1 then
	if (self.reloadtime < CurTime()) then
	self:dropgps()	
	end
	end

	if self.Dropping3 and !self.Dropping2 and !self.Dropping1 then
	if (self.reloadtime < CurTime()) then
	self:droptv()	
	end
	end

	if self.Dropping4 and !self.Dropping3 and !self.Dropping2 and !self.Dropping1 then
	if (self.reloadtime < CurTime()) then
	self:droptpa()	
	end
	end

	self.Entity:NextThink( CurTime() + .01)
	return true
end

function ENT:TriggerInput(k, v)

		if (k == "Target Position") then
		if(v) then
		self.Target = v or Vector(0,0,0)
		end	end

		if (k == "TV Rotate") then
		if(v) then
		self.TVRotate = v or Angle(0,0,0)
		end	end

		if(k=="Unguided") then
		if((v or 0) >= 1) then
		self.Dropping1 = true
		else
		self.Dropping1 = false
		end
		end

		if(k=="GPS GBU") then
		if((v or 0) >= 1) then
		self.Dropping2 = true
		else
		self.Dropping2 = false
		end
		end

		if(k=="TV GBU") then
		if((v or 0) >= 1) then
		self.Dropping3 = true
		else
		self.Dropping3 = false
		end
		end

		if(k=="Unguided TPA") then
		if((v or 0) >= 1) then
		self.Dropping4 = true
		else
		self.Dropping4 = false
		end
		end
end
 

function ENT:dropdumb()

		local Bomb = ents.Create( "gdca_50kg_unguided" )
		Bomb:SetPos( self.Entity:GetPos())
		Bomb:SetAngles( self.Entity:GetAngles() )
		Bomb.Dropper = self.Entity
		Bomb:Spawn()
		Bomb:Initialize()
		Bomb:Activate()
		self.ammos = self.ammos-1	

end

function ENT:droptpa()

		local Bomb = ents.Create( "gdca_50kg_unguided_tpa" )
		Bomb:SetPos( self.Entity:GetPos())
		Bomb:SetAngles( self.Entity:GetAngles() )
		Bomb.Dropper = self.Entity
		Bomb:Spawn()
		Bomb:Initialize()
		Bomb:Activate()
		self.ammos = self.ammos-1	

end

function ENT:droptv()

		local TVBomb = ents.Create( "gdca_50kg_tvguided" )
		TVBomb:SetPos( self.Entity:GetPos())
		TVBomb:SetAngles( self.Entity:GetAngles() )
		TVBomb.Dropper = self.Entity
		TVBomb:Spawn()
		TVBomb:Initialize()
		TVBomb:Activate()
		self.TVEnt 		= TVBomb
		self.TVActive 		= 1
		self.TVDirection	= TVBomb:GetForward()
		self.TVPosition 	= TVBomb:GetPos()

		self.ammos = self.ammos-1	

end

function ENT:dropgps()

		local GPSBomb = ents.Create( "gdca_50kg_gpsguided" )
		GPSBomb:SetPos( self.Entity:GetPos())
		GPSBomb:SetAngles( self.Entity:GetAngles() )
		GPSBomb.Dropper = self.Entity
		GPSBomb:Spawn()
		GPSBomb:Initialize()
		GPSBomb:Activate()

		self.ammos = self.ammos-1	

end