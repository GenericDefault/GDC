AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

util.PrecacheSound( "weapons/rpg/rocket1.wav" )

function ENT:Initialize()   

	local CheckHo = ents.FindByClass( "gdca_gmissile" )		
	for _,t in pairs(CheckHo) do
	if t.Entity:IsValid() and (t.Entity!=self.Entity) and (t.Entity:GetClass()=="gdca_gmissile") then
	if t:GetPos():Distance(self:GetPos())<200 then
	self.Entity:Remove()
	end
	end
	end

self.Accelerator 	= 50
self.AccelRate		= 1
self.AccelMax		= 170
self.flightvector = self.Entity:GetUp() * self.Accelerator
self.timeleft = CurTime() + 10
self.nexttarGet = CurTime()
self.Entity:SetModel( "models/props_c17/canister01a.mdl" ) 	
self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
self.Entity:SetMoveType( MOVETYPE_NONE )   --after all, gmod is a physics  	
self.Entity:SetSolid( SOLID_NONE )        -- CHEESECAKE!    >:3 
self.Sound = CreateSound( self.Entity, Sound( "Phx.HoverHeavy" ) ) //Phx.Turbine weapons/rpg/rocket1.wav
self.Sound:Play()
self.Target = self.Entity    
self.Flared = false
self.TPos = self.Target:GetPos()

SmokeTrail = ents.Create("env_spritetrail")
SmokeTrail:SetKeyValue("lifetime","1")
SmokeTrail:SetKeyValue("startwidth","40")
SmokeTrail:SetKeyValue("endwidth","200")
SmokeTrail:SetKeyValue("spritename","trails/smoke.vmt")
SmokeTrail:SetKeyValue("rendermode","5")
SmokeTrail:SetKeyValue("rendercolor","200 200 200")
SmokeTrail:SetPos(self.Entity:GetPos())
SmokeTrail:SetParent(self.Entity)
SmokeTrail:Spawn()
SmokeTrail:Activate()

Glow = ents.Create("env_sprite")
Glow:SetPos(self.Entity:GetPos())
Glow:SetKeyValue("renderfx", "0")
Glow:SetKeyValue("rendermode", "5")
Glow:SetKeyValue("renderamt", "255")
Glow:SetKeyValue("rendercolor", "250 200 150")
Glow:SetKeyValue("framerate12", "20")
Glow:SetKeyValue("model", "light_glow03.spr")
Glow:SetKeyValue("scale", "2.5")
Glow:SetKeyValue("GlowProxySize", "50")
Glow:SetParent(self.Entity)
Glow:Spawn()
Glow:Activate()

self:Think()
end   

function ENT:OnRemove()
	self.Sound:Stop()
end

 function ENT:Think()
	
local MissilePosition 	= self.Entity:GetPos()
local MissileUp 	= self.Entity:GetUp()

if (self.Accelerator<self.AccelMax) then self.Accelerator = self.Accelerator+self.AccelRate	end	// Speed it up!

	if self.timeleft < CurTime() then
	self.Entity:Remove()				
	end

	local trace = {}
		trace.start 	= MissilePosition
		trace.endpos 	= MissilePosition + self.flightvector*1.1
		trace.filter 	= self.Entity 
		trace.mask 	= MASK_SHOT + MASK_WATER			// Trace for stuff that bullets would normally hit
	local tr = util.TraceLine( trace )


				if tr.Hit then
					if tr.HitSky || tr.StartSolid then
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

					util.BlastDamage(self.Entity, self.Entity, tr.HitPos, 600, 150)
					local effectdata = EffectData()
					effectdata:SetOrigin(tr.HitPos)				// Position of Impact
					effectdata:SetNormal(tr.HitNormal)			// Direction of Impact
					effectdata:SetStart(self.flightvector:GetNormalized())	// Direction of Round
					effectdata:SetEntity(self.Entity)			// Who done it?
					effectdata:SetScale(2.5)					// Size of explosion
					effectdata:SetRadius(tr.MatType)			// Texture of Impact
					effectdata:SetMagnitude(16)				// Length of explosion trails	
					util.Effect( "gdca_cinematicboom", effectdata )
					util.ScreenShake(tr.HitPos, 10, 5, 1, 2000 )
					util.Decal("Scorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)


			if GDCENGINE then	
			local attack = gdc.gdcsplode( tr.HitPos, 300, 500, self.Entity)	// Position, Radius, Damage, Self		
			end	
			self.Entity:Remove() 
			end
			
	if self.nexttarGet < CurTime() then 

if !self.Flared then
	local EIS = ents.FindInSphere(self:GetPos(), 40000)
	local distance = 40000
	//if self.nexttarGet < CurTime() then 
		for _,t in pairs(EIS) do
			if !(t:GetClass() == "gdca_flare") and !self.Flared then
			if (t:IsValid() and (t:GetClass() == "prop_physics" || t:GetClass() == "prop_vehicle_prisoner_pod" || t:GetClass() == "prop_vehicle_jeep" || t:GetClass() == "prop_vehicle_airboat" || t:GetClass() == "gdca_flare" || t:IsNPC()) and (t:GetVelocity():Length() > 300)) then
				if ( (t:GetPos():Distance(MissilePosition)<distance) and (MissileUp:DotProduct((t:GetPos() - MissilePosition):GetNormalized())>0.99) ) then
						self.Target = t
				end
				end
						elseif (t:GetClass() == "gdca_flare") then
						if (MissileUp:DotProduct((t:GetPos() - MissilePosition):GetNormalized())>0.99)  then
						self.Target = t 
						self.Flared = true
						end
						end
			end
			self.nexttarGet = CurTime() + 0.3
		end
end	

	if self.Target:IsValid() and self.Target!=self.Entity and self.Target:GetPos():Distance(MissilePosition)<40000 and MissileUp:DotProduct((self.Target:GetPos() - MissilePosition):GetNormalized())>0.50 then
	ForwardAngle = MissileUp:Angle()
			
	IDist 		= (self.Target:GetPos() - MissilePosition):Length()	// In Units
	ITime 		= IDist/self.Accelerator				// In server ticks, 1/66 second
	TVel 		= (self.Target:GetPos()-self.TPos)			// Net Velocity (Delta Distance)	
	IPos 		= self.Target:GetPos()+(TVel*ITime)			// Fly to intercept
	self.TPos 	= self.Target:GetPos()					// Refresh the target position

	TangY = (IPos - MissilePosition):GetNormalized():Angle().y
	AddY = math.Clamp(math.AngleDifference(TangY, MissileUp:Angle().y)*15,-self.Accelerator/150,self.Accelerator/150)
	TangP = (IPos - MissilePosition):GetNormalized():Angle().p
	AddP = math.Clamp(math.AngleDifference(TangP, MissileUp:Angle().p)*15,-self.Accelerator/150,self.Accelerator/150)
	self.Entity:SetAngles((Angle(AddP,AddY,0) + ForwardAngle) + Angle(90,0,0) + Angle(math.Rand(-0.8,0.8),math.Rand(-0.8,0.8),math.Rand(-0.8,0.8)))
	else
	self.Entity:SetAngles(self.flightvector:Angle() + Angle(90,0,0))
	end

	self.flightvector = MissileUp*self.Accelerator
	self.Entity:SetPos(MissilePosition + self.flightvector)
	self.Entity:NextThink( CurTime() )
	return true
end
 
 
