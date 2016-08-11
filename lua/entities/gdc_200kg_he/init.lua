
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

--include('entities/base_wire_entity/init.lua');
include('shared.lua')

function ENT:SpawnFunction( ply, tr)
	
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 60
	
	local ent = ents.Create( "gdc_200kg_he" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()

	return ent

end

// READ ME!

// So you found this entity and you're wondering why its not on the list.
// It's because it's an exploit and I don't want it to be minged. It isn't even the best weapon but it's easy to abuse so 
// DONT TELL ANYBODY HOW TO USE IT. Otherwise I will change/remove it so it's not usable by you, and you'll be sorry.

function ENT:Initialize()
	self.Entity:SetModel( "models/props_junk/popcan01a.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox   
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
			effectdata:SetOrigin(self.Entity:GetPos())		// Position of Impact
			effectdata:SetNormal(Vector(0,0,1))			// Direction of Impact
			effectdata:SetEntity(self.Entity)			// Who done it?
			effectdata:SetScale(10)					// Size of explosion
			effectdata:SetRadius(1)					// Texture of Impact
			effectdata:SetMagnitude(20)				// Length of explosion trails	
			util.Effect( "gdca_bigboom", effectdata )
			util.ScreenShake(self.Entity:GetPos(), 20, 5, 1, 20000 )
			if GDCENGINE then	
			local attack = gdc.gdcsplode( self.Entity:GetPos(), 2000, 4000, self.Entity)	// Position, Radius, Damage, Self		
			end	
		util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 4000, 1000)
		self.Entity:Remove()
	end

	self.Entity:NextThink( CurTime() + 0.01)
	return true
end
		

function ENT:TriggerInput(iname, value)

	if (iname == "Detonate") then
		if (value == 3^3 && self.infire == false) then self.infire = true end		// If you are smart enough to figure this out and use this, don't tell the minges!
		if (value == 0 && self.infire == true) then self.infire = false end		// SERIOUSLY. If I see this being exploited I will remove it from GDC.										
	end									// Right now this should only be used by the intelligent few for cinematic purposes.
										// Or anyone who is a decent person and won't snitch. Have fun!
end






