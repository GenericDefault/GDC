
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

--include('entities/base_wire_entity/init.lua'); 
include('shared.lua')


function ENT:Initialize()   

	self.ammos = 7
	self.clipsize = 7
	self.armed = false
	self.loading = false
	self.reloadtime = 0
	self.infire = false
	self.Airburst 	= 0
	self.Velo = Vector(0,0,0)
	self.Pos2 = self.Entity:GetPos()
	self.Entity:SetModel( "models/props_pipes/pipecluster08d_extender64.mdl" ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox     
	self.Entity:SetColor(100,100,100,255)
	self.Entity:DrawShadow( false )
	
          
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:Wake() 
	end 
 
	self.Inputs = Wire_CreateInputs( self.Entity, { "Fire", "Airburst Time", "Reload"} )
	self.Outputs = Wire_CreateOutputs( self.Entity, { "Can Fire", "Shots"})
end   

function ENT:SpawnFunction( ply, tr)
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 60
	local ent = ents.Create( "gdc_l60" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:firebofors()

		local ent = ents.Create( "gdca_40x311he" )
		ent:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 200)
		ent:SetAngles( self.Entity:GetAngles() )
		ent.Gun = self.Entity
		ent:Spawn()
		ent:Activate()
		self.ammos = self.ammos-1

		local phys = self.Entity:GetPhysicsObject()  	
		if (phys:IsValid()) then  		
		phys:ApplyForceCenter( self.Entity:GetUp() * -40000 ) 
		end 
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 40)
		effectdata:SetNormal(self:GetUp())
		effectdata:SetScale(1.2)
		effectdata:SetRadius(6)
		effectdata:SetMagnitude(self.Velo:Length())
		effectdata:SetAngles(self.Velo:Angle())
		util.Effect( "gdca_autocannonmuzzle", effectdata )
		self.Entity:EmitSound( "L60.Emit" )
		util.ScreenShake(self.Entity:GetPos(), 40, 5, 0.2, 400 )
	

end

function ENT:Think()
	self.Velo = (self.Entity:GetPos()-self.Pos2)*2
	self.Pos2 = self.Entity:GetPos()

Wire_TriggerOutput(self.Entity, "Shots", self.ammos)
	if self.ammos <= 0 then
	self.reloadtime = CurTime()+5
	self.ammos = self.clipsize
	end
	
	if (self.reloadtime < CurTime()) then
	Wire_TriggerOutput(self.Entity, "Can Fire", 1)
	else
	Wire_TriggerOutput(self.Entity, "Can Fire", 0)
	end
	
	if (self.inFire == true) then
	if (self.reloadtime < CurTime()) then
	self:firebofors()	
	end
	end

	self.Entity:NextThink( CurTime() + .5)
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
	
	if(k=="Reload") then
	if((v or 0) >= 1) then
	self.ammos = 0
	end
	end
	
		if(k=="Airburst Time") then
		if((v or 0) >= 0) then
		self.Airburst = v
		else	self.Airburst = 0	end	end
end
 
 
