AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--include('entities/base_wire_entity/init.lua'); 
include('shared.lua')

function ENT:Initialize()  

	local CheckHo = ents.FindByClass( "gdc_m197" )		
	for _,t in pairs(CheckHo) do
	if t.Entity:IsValid() and (t.Entity!=self.Entity) and (t.Entity:GetClass()=="gdc_m197") then
	if t:GetPos():Distance(self:GetPos())<1000 then
	self.Entity:Remove() 		print("Removed Extra M197")	
	end
	end
	end
 
	self.reloadtime = 0
	self.InFireHEI = false
	self.InFireHEIT = false
	self.InFireAPI = false
	self.heat = 0
	self.Velo = Vector(0,0,0)
	self.Pos2 = self.Entity:GetPos()
	self.Entity:SetModel( "models/props_lab/pipesystem01b.mdl" ) 
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox     
	self.Entity:SetColor(100,100,100,255)
	self.Entity:DrawShadow( false )
	
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
	phys:Wake() 
	end 
 
	self.Inputs = Wire_CreateInputs( self.Entity, { "Fire", "Fire Tracer", "Fire API" } )
	self.Outputs = Wire_CreateOutputs( self.Entity, { "Can Fire", "Heat"})
end   


function ENT:FireHEI()
		local ent = ents.Create( "gdca_20x102_hei" )
		ent:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 200)
		ent:SetAngles( self.Entity:GetAngles() )
		ent:Spawn()
		ent:Activate()
		self.heat = self.heat+4
		
		local phys = self.Entity:GetPhysicsObject()  	
		if (phys:IsValid()) then  		
		phys:ApplyForceCenter( self.Entity:GetUp() * -20000 ) 
		end 
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 30)
		effectdata:SetNormal(self:GetUp())
		effectdata:SetScale(0.65)
		effectdata:SetRadius(2)
		effectdata:SetMagnitude(self.Velo:Length())
		effectdata:SetAngles(self.Velo:Angle())
		util.Effect( "gdca_autocannonmuzzle", effectdata )
		self.Entity:EmitSound( "M197.Emit" )
		util.ScreenShake(self.Entity:GetPos(), 20, 5, 0.1, 500 )
end

function ENT:FireHEIT()
		local ent = ents.Create( "gdca_20x102_heit" )
		ent:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 200)
		ent:SetAngles( self.Entity:GetAngles() )
		ent:Spawn()
		ent:Activate()
		self.heat = self.heat+4
		
		local phys = self.Entity:GetPhysicsObject()  	
		if (phys:IsValid()) then  		
		phys:ApplyForceCenter( self.Entity:GetUp() * -20000 ) 
		end 
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 30)
		effectdata:SetNormal(self:GetUp())
		effectdata:SetScale(0.65)
		effectdata:SetRadius(2)
		effectdata:SetMagnitude(self.Velo:Length())
		effectdata:SetAngles(self.Velo:Angle())
		util.Effect( "gdca_autocannonmuzzle", effectdata )
		self.Entity:EmitSound( "M197.Emit" )
		util.ScreenShake(self.Entity:GetPos(), 20, 5, 0.1, 500 )
end

function ENT:FireAPI()
		local ent = ents.Create( "gdca_20x102_api" )
		ent:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 200)
		ent:SetAngles( self.Entity:GetAngles() )
		ent:Spawn()
		ent:Activate()
		self.heat = self.heat+4
		
		local phys = self.Entity:GetPhysicsObject()  	
		if (phys:IsValid()) then  		
		phys:ApplyForceCenter( self.Entity:GetUp() * -10000 ) 
		end 
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 30)
		effectdata:SetNormal(self:GetUp())
		effectdata:SetScale(0.65)
		effectdata:SetRadius(2)
		effectdata:SetMagnitude(self.Velo:Length())
		effectdata:SetAngles(self.Velo:Angle())
		util.Effect( "gdca_autocannonmuzzle", effectdata )
		self.Entity:EmitSound( "M197.Emit" )
		util.ScreenShake(self.Entity:GetPos(), 20, 5, 0.1, 500 )
end

function ENT:Think()
	self.Velo = (self.Entity:GetPos()-self.Pos2)*11.8
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
	
		if self.InFireHEI then
		if (self.reloadtime < CurTime()) then
		self:FireHEI()
		end
		end

		if self.InFireHEIT and !self.InFireHEI then
		if (self.reloadtime < CurTime()) then
		self:FireHEIT()
		end
		end

		if self.InFireAPI and !self.InFireHEIT and !self.InFireHEI then
		if (self.reloadtime < CurTime()) then
		self:FireAPI()
		end
		end

	self.Entity:NextThink( CurTime() + .085)
	return true
end

function ENT:TriggerInput(k, v)

		if(k=="Fire") then
		if((v or 0) >= 1) then
		self.InFireHEI = true
		else
		self.InFireHEI = false
		end
		end
	
		if(k=="Fire Tracer") then
		if((v or 0) >= 1) then
		self.InFireHEIT = true
		else
		self.InFireHEIT = false
		end
		end

		if(k=="Fire API") then
		if((v or 0) >= 1) then
		self.InFireAPI = true
		else
		self.InFireAPI = false
		end
		end
	
end
 
 
