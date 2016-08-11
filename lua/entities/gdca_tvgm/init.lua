AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()   

self.flightvector = self.Entity:GetUp()*10
self.Rotate = Angle(0,0,0)
self.Rotate = self.Guider.TVRotate
self.Timeleft = CurTime() + 10
self.ArmedTime = CurTime() + 1
self.Armed = false
self.Accelerator 	= 20
self.AccelRate		= 1
self.AccelMax		= 200
self.Entity:SetModel( "models/props_c17/canister01a.mdl" ) 
self.Entity:PhysicsInit( SOLID_VPHYSICS )
self.Entity:SetMoveType( MOVETYPE_NONE )
self.Entity:SetSolid( SOLID_VPHYSICS )
self.Entity:SetCollisionGroup(COLLISION_GROUP_WORLD)
self.Sound = CreateSound( self.Entity, Sound( "Phx.Turbine" ) ) 
self.Sound:Play()

Glow = ents.Create("env_sprite")
Glow:SetKeyValue("model","orangecore2.vmt")
Glow:SetKeyValue("rendercolor","255 150 100")
Glow:SetKeyValue("scale","0.25")
Glow:SetPos(self.Entity:GetPos()-(self.Entity:GetUp()*30))
Glow:SetParent(self.Entity)
Glow:Spawn()
Glow:Activate()

Shine = ents.Create("env_sprite")
Shine:SetPos(self.Entity:GetPos()-(self.Entity:GetUp()*30))
Shine:SetKeyValue("renderfx", "0")
Shine:SetKeyValue("rendermode", "5")
Shine:SetKeyValue("renderamt", "255")
Shine:SetKeyValue("rendercolor", "255 150 100")
Shine:SetKeyValue("framerate12", "20")
Shine:SetKeyValue("model", "light_glow03.spr")
Shine:SetKeyValue("scale", "0.3")
Shine:SetKeyValue("GlowProxySize", "50")
Shine:SetParent(self.Entity)
Shine:Spawn()
Shine:Activate()


self:Think()
end   
function ENT:OnRemove()
	self.Sound:Stop()
end

 function ENT:Think()

if (self.Accelerator<self.AccelMax) then self.Accelerator = self.Accelerator+self.AccelRate	end	// Speed it up!

if !self.Guider:IsValid() then self.Guider = self.Entity end
	
		if (self.Timeleft < CurTime()) || (!self.Entity:IsInWorld()) then
		self.Entity:Remove()				
		end

		if !self.Armed then
		if self.ArmedTime < CurTime() and self.flightvector:Length()>20 then
		self.Armed = true				
		end	end

	local trace = {}
		trace.start 	= self.Entity:GetPos()
		trace.endpos 	= self.Entity:GetPos() + self.flightvector
		trace.filter 	= self.Entity 
		trace.mask 	= MASK_SHOT + MASK_WATER			// Trace for stuff that bullets would normally hit
	local tr = util.TraceLine( trace )


				if self.Armed and tr.Hit then
					if tr.HitSky then
					self.Entity:Remove()
					return true
					end
					if tr.MatType==83 then				//83 is wata
					local effectdata = EffectData()
					effectdata:SetOrigin( tr.HitPos )
					effectdata:SetNormal( tr.HitNormal )		// In case you hit sideways water?
					effectdata:SetScale( 70 )			// Big splash for big bullets
					util.Effect( "watersplash", effectdata )
					self.Entity:Remove()
					return true
					end

					util.BlastDamage(self.Entity, self.Entity, tr.HitPos, 1500, 200)
					local effectdata = EffectData()
					effectdata:SetOrigin(tr.HitPos)				// Position of Impact
					effectdata:SetNormal(tr.HitNormal)			// Direction of Impact
					effectdata:SetStart(self.flightvector:GetNormalized())	// Direction of Round
					effectdata:SetEntity(self.Entity)			// Who done it?
					effectdata:SetScale(3.7)				// Size of explosion
					effectdata:SetRadius(tr.MatType)			// Texture of Impact
					effectdata:SetMagnitude(20)				// Length of explosion trails	
				util.Effect( "gdca_cinematicboom", effectdata )
				util.ScreenShake(tr.HitPos, 20, 5, 1, 4500 )
				util.Decal("Scorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
			if GDCENGINE then
			gdc.gdcheat( tr.HitPos+(tr.HitNormal*5), self.Entity:GetUp(), 500, 600, 100, 3000, self.Entity)	
			//position, direction, sphereradius, spheredamage, coneradius, conedamage, shell)	
			end	
				self.Entity:Remove()
				end

		self.Rotate 	= Angle(math.Clamp(-self.Guider.TVRotate.p*(math.Clamp(self.Accelerator,0,100)/2000),-2,2),math.Clamp(-self.Guider.TVRotate.y*(math.Clamp(self.Accelerator,0,100)/2000),-2,2),0)

	self.Entity:SetAngles(self.flightvector:Angle()+Angle(90,0,0)+self.Rotate)
	self.Entity:SetPos(self.Entity:GetPos() + self.flightvector)
	self.flightvector = self.Entity:GetUp()*self.Accelerator
	self.Entity:NextThink( CurTime() )
	return true
end
 
 
