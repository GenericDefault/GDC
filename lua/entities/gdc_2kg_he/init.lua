
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

--include('entities/base_wire_entity/init.lua');
include('shared.lua')

function ENT:SpawnFunction( ply, tr)
	
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 60
	
	local ent = ents.Create( "gdc_2hg_he" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()

	return ent

end

function ENT:Initialize()
	self.Entity:SetModel( "models/props_junk/popcan01a.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox   
	self.Entity:DrawShadow( false )

	self.infire = false
	self.Entity:SetOwner(self.owner)
	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then 
	phys:Wake()
	end
   	self.Inputs = Wire_CreateInputs ( self.Entity, { "Detonate" } )

end


function ENT:Think()

        if self.infire then			
					local effectdata = EffectData()
					effectdata:SetOrigin(self.Entity:GetPos())	// Position of Impact
					effectdata:SetNormal(Vector(0,0,1))		// Direction of Impact
					effectdata:SetStart(Vector(0,0,1))		// Direction of Round
					effectdata:SetScale(2.0)			// Size of explosion
					effectdata:SetRadius(1)				// Texture of Impact
					effectdata:SetMagnitude(25)			// Length of explosion trails
					util.Effect( "gdcw_nadeairburst", effectdata )
			sound.Play( "Explosion.Boom", self.Entity:GetPos())
		util.ScreenShake(self.Entity:GetPos(), 20, 5, 1, 3000 )
			if GDCENGINE then	
			local attack = gdc.gdcsplode( self.Entity:GetPos(), 600, 500, self.Entity)	// Position, Radius, Damage, Self		
			end	
		util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 1100, 200)
		self.Entity:Remove()
	end
end
		

function ENT:TriggerInput(iname, value)

	if (iname == "Detonate") then
		if (value == 1 && self.infire == false) then self.infire = true end
		if (value == 0 && self.infire == true) then self.infire = false end
	end

end






