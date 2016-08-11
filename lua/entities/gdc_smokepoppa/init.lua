
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

--include('entities/base_wire_entity/init.lua'); 
include('shared.lua')

function ENT:Initialize()   

	local CheckHo = ents.FindByClass( "gdc_smokepoppa" )		
	for _,t in pairs(CheckHo) do
	if t.Entity:IsValid() and (t.Entity!=self.Entity) and (t.Entity:GetClass()=="gdc_smokepoppa") then
	if t:GetPos():Distance(self:GetPos())<1000 then
	self.Entity:Remove() 		print("Removed Extra Smoke Deployer")	
	end
	end
	end

	self.ammos = 1
	self.clipsize = 1
	self.armed = false
	self.loading = false
	self.reloadtime = 0
	self.infire = false
	self.Entity:SetModel( "models/props_junk/popcan01a.mdl" ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox     
	self.Entity:SetColor(180,180,180,255)
	self.Entity:DrawShadow( false )
	
          
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:Wake() 
	end 
 
	self.Inputs = Wire_CreateInputs( self.Entity, { "Pop Smoke" } )
	self.Outputs = Wire_CreateOutputs( self.Entity, { "Can Fire", "Shots"})
end   

function ENT:SpawnFunction( ply, tr)
	
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 60
	
	
	local ent = ents.Create( "gdc_smokepoppa" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	
	
	return ent

end

function ENT:popsmoke()
		
		self.Entity:EmitSound( "BaseSmokeEffect.Sound")
		self.ammos = self.ammos-1
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos())
		effectdata:SetNormal(self:GetUp())
		effectdata:SetScale(1)
		util.Effect( "gdca_popsmoke", effectdata )

	

end

function ENT:Think()

Wire_TriggerOutput(self.Entity, "Shots", self.ammos)
	if self.ammos <= 0 then
	self.reloadtime = CurTime()+15
	self.ammos = self.clipsize
	end
	
	if (self.reloadtime < CurTime()) then
		Wire_TriggerOutput(self.Entity, "Can Fire", 1)
	else
		Wire_TriggerOutput(self.Entity, "Can Fire", 0)
	end
	
	if (self.inFire == true) then
		if (self.reloadtime < CurTime()) then
		
			self:popsmoke()
			
		end
	end

	self.Entity:NextThink( CurTime() + 0.1)
	return true
end

function ENT:TriggerInput(k, v)
if(k=="Pop Smoke") then
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
	
end
 
 
