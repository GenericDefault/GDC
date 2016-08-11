
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

--include('entities/base_wire_entity/init.lua'); 
include('shared.lua')



function ENT:Initialize()   

	local CheckHo = ents.FindByClass( "gdc_m230" )		
	for _,t in pairs(CheckHo) do
	if t.Entity:IsValid() and (t.Entity!=self.Entity) and (t.Entity:GetClass()=="gdc_m230") then
	if t:GetPos():Distance(self:GetPos())<1000 then
	self.Entity:Remove() 		print("Removed Extra M230")	
	end
	end
	end

	self.armed = false
	self.loading = false
	self.reloadtime = 0
	self.infire = false
	self.heat = 0
	self.Velo = Vector(0,0,0)
	self.Pos2 = self.Entity:GetPos()
	self.Entity:SetModel( "models/props_lab/pipesystem01a.mdl" ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox     
	self.Entity:SetColor(100,100,100,255)
	self.Entity:DrawShadow( false )
	
          
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:Wake() 
	end 
 
	self.Inputs = Wire_CreateInputs( self.Entity, { "Fire"} )
	self.Outputs = Wire_CreateOutputs( self.Entity, { "Can Fire", "Heat"})
end   

function ENT:SpawnFunction( ply, tr)
	
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 60
	
	
	local ent = ents.Create( "gdc_m230" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	
	
	return ent

end

function ENT:firerac5()

		local ent = ents.Create( "gdca_30x113hei" )
		ent:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 150)
		ent:SetAngles( self.Entity:GetAngles() )
		ent:Spawn()
		ent:Activate()
		self.heat = self.heat+8
		
		local phys = self.Entity:GetPhysicsObject()  	
		if (phys:IsValid()) then  		
		phys:ApplyForceCenter( self.Entity:GetUp() * -30000 ) 
		end 
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 30)
		effectdata:SetNormal(self:GetUp())
		effectdata:SetScale(0.7)
		effectdata:SetRadius(4)
		effectdata:SetMagnitude(self.Velo:Length())
		effectdata:SetAngles(self.Velo:Angle())
		util.Effect( "gdca_autocannonmuzzle", effectdata )
		self.Entity:EmitSound( "M230.Emit" )
		util.ScreenShake(self.Entity:GetPos(), 25, 5, 0.2, 350 )
	

end

function ENT:Think()
	self.Velo = (self.Entity:GetPos()-self.Pos2)*10
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
	
	if self.inFire then
	if (self.reloadtime < CurTime()) then
	self:firerac5()	
	end
	end

	self.Entity:NextThink( CurTime() + .1)
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

	
end
 
 
