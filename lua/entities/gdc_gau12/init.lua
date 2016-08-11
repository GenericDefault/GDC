
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

--include('entities/base_wire_entity/init.lua'); 
include('shared.lua')

function ENT:Initialize()   


	local CheckHo = ents.FindByClass( "gdc_gau12" )		
	for _,t in pairs(CheckHo) do
	if t.Entity:IsValid() and (t.Entity!=self.Entity) and (t.Entity:GetClass()=="gdc_flamethrower") then
	if t:GetPos():Distance(self:GetPos())<1000 then
	self.Entity:Remove() 		print("Removed Extra GAU-12")	
	end
	end
	end

	self.loading = false
	self.reloadtime = 0
	self.FireAPI 	= false
	self.FireAPIT 	= false
	self.FireHEI 	= false
	self.FireHEIT 	= false
	self.Airburst 	= 0
	self.heat = 0
	self.Velo = Vector(0,0,0)
	self.Pos2 = self.Entity:GetPos()
	self.Entity:SetModel( "models/props_lab/pipesystem01b.mdl" ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox     
	self.Entity:SetColor(180,180,180,255)
	self.Entity:DrawShadow( false )
	
          
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:Wake() 
	end 
 
	self.Inputs = Wire_CreateInputs( self.Entity, { "Fire API", "Fire APIT", "Fire HEI", "Fire HEIT", "Airburst Time"} )
	self.Outputs = Wire_CreateOutputs( self.Entity, { "Can Fire", "Heat"})
end   

function ENT:SpawnFunction( ply, tr)
	
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 60
	local ent = ents.Create( "gdc_gau12" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:fireapi()
		local ent = ents.Create( "gdca_25x137_api" )
		ent:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 300)
		ent:SetAngles( self.Entity:GetAngles() )
		ent:Spawn()
		ent:Activate()
		self.heat = self.heat+5

		local phys = self.Entity:GetPhysicsObject()  	
		if (phys:IsValid()) then  		
		phys:ApplyForceCenter( self.Entity:GetUp() * -25000 ) 
		end 
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 40)
		effectdata:SetNormal(self:GetUp())
		effectdata:SetScale(0.6)
		effectdata:SetRadius(1)
		effectdata:SetMagnitude(self.Velo:Length())
		effectdata:SetAngles(self.Velo:Angle())
		util.Effect( "gdca_highrpmmuzzle", effectdata )
		util.ScreenShake(self.Entity:GetPos(), 2, 5, 0.1, 400 )
		self.Entity:EmitSound( "GAU12.Emit" )
end

function ENT:fireapit()
		local ent = ents.Create( "gdca_25x137_apit" )
		ent:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 300)
		ent:SetAngles( self.Entity:GetAngles() )
		ent:Spawn()
		ent:Activate()
		self.heat = self.heat+5

		local phys = self.Entity:GetPhysicsObject()  	
		if (phys:IsValid()) then  		
		phys:ApplyForceCenter( self.Entity:GetUp() * -25000 ) 
		end 
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 40)
		effectdata:SetNormal(self:GetUp())
		effectdata:SetScale(0.6)
		effectdata:SetRadius(1)
		effectdata:SetMagnitude(self.Velo:Length())
		effectdata:SetAngles(self.Velo:Angle())
		util.Effect( "gdca_highrpmmuzzle", effectdata )
		util.ScreenShake(self.Entity:GetPos(), 2, 5, 0.1, 400 )
		self.Entity:EmitSound( "GAU12.Emit" )
end

function ENT:firehei()
		local ent = ents.Create( "gdca_25x137_hei" )
		ent:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 300)
		ent:SetAngles( self.Entity:GetAngles() )
		ent.Gun = self.Entity
		ent:Spawn()
		ent:Activate()
		self.heat = self.heat+5

		local phys = self.Entity:GetPhysicsObject()  	
		if (phys:IsValid()) then  		
		phys:ApplyForceCenter( self.Entity:GetUp() * -25000 ) 
		end 
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 40)
		effectdata:SetNormal(self:GetUp())
		effectdata:SetScale(0.6)
		effectdata:SetRadius(1)
		effectdata:SetMagnitude(self.Velo:Length())
		effectdata:SetAngles(self.Velo:Angle())
		util.Effect( "gdca_highrpmmuzzle", effectdata )
		util.ScreenShake(self.Entity:GetPos(), 20, 5, 0.1, 400 )
		self.Entity:EmitSound( "GAU12.Emit" )
end

function ENT:fireheit()

		local ent = ents.Create( "gdca_25x137_heit" )
		ent:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 300)
		ent:SetAngles( self.Entity:GetAngles() )
		ent.Gun = self.Entity
		ent:Spawn()
		ent:Activate()
		self.heat = self.heat+5

		local phys = self.Entity:GetPhysicsObject()  	
		if (phys:IsValid()) then  		
		phys:ApplyForceCenter( self.Entity:GetUp() * -25000 ) 
		end 
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 40)
		effectdata:SetNormal(self:GetUp())
		effectdata:SetScale(0.6)
		effectdata:SetRadius(1)
		effectdata:SetMagnitude(self.Velo:Length())
		effectdata:SetAngles(self.Velo:Angle())
		util.Effect( "gdca_highrpmmuzzle", effectdata )
		util.ScreenShake(self.Entity:GetPos(), 20, 5, 0.1, 400 )
		self.Entity:EmitSound( "GAU12.Emit" )

end

function ENT:Think()
	self.Velo = (self.Entity:GetPos()-self.Pos2)*25
	self.Pos2 = self.Entity:GetPos()

			if self.heat>0 then
			Wire_TriggerOutput(self.Entity, "Heat", self.heat)
			self.heat = self.heat-1
			end

			if self.heat>100 then
			self.reloadtime = CurTime()+4		// Overheat for 4 seconds
			end
	
		if (self.reloadtime < CurTime()) then
		Wire_TriggerOutput(self.Entity, "Can Fire", 1)
		else
		Wire_TriggerOutput(self.Entity, "Can Fire", 0)
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

	self.Entity:NextThink( CurTime() + .04)
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
 
 
