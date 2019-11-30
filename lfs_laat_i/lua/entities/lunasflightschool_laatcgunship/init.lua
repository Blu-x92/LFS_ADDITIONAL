--DO NOT EDIT OR REUPLOAD THIS FILE

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:SpawnFunction( ply, tr, ClassName )
	if not tr.Hit then return end

	local ent = ents.Create( ClassName )
	ent.dOwnerEntLFS = ply
	ent:SetPos( tr.HitPos + tr.HitNormal * 50 )
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:RunOnSpawn()
	self:GetDriverSeat().ExitPos = Vector(75,0,36)
	
	local GunnerSeat = self:AddPassengerSeat( Vector(115,0,140), Angle(0,-90,0) )
	GunnerSeat.ExitPos = Vector(75,0,36)
	
	self:SetGunnerSeat( GunnerSeat )
end

function ENT:PrimaryAttack()
	if not self:CanPrimaryAttack() or not self:GetEngineActive() then return end

	local ID_L = self:LookupAttachment( "muzzle_frontgun_left" )
	local ID_R = self:LookupAttachment( "muzzle_frontgun_right" )
	local MuzzleL = self:GetAttachment( ID_L )
	local MuzzleR= self:GetAttachment( ID_R )
	
	if not MuzzleL or not MuzzleR then return end
	
	self:SetNextPrimary( 0.25 )
	
	self.MirrorPrimary = not self.MirrorPrimary
	
	if not isnumber( self.frontgunYaw ) then return end

	if self.frontgunYaw > 5 and self.MirrorPrimary then return end
	if self.frontgunYaw < -5 and not self.MirrorPrimary then return end
	
	self:EmitSound( "LAATi_FIRE" )

	local Pos = self.MirrorPrimary and MuzzleL.Pos or MuzzleR.Pos
	local Dir =  (self.MirrorPrimary and MuzzleL.Ang or MuzzleR.Ang):Up()
	
	local bullet = {}
	bullet.Num 	= 1
	bullet.Src 	= Pos
	bullet.Dir 	= Dir
	bullet.Spread 	= Vector( 0.01,  0.01, 0 )
	bullet.Tracer	= 1
	bullet.TracerName	= "lfs_laser_green"
	bullet.Force	= 100
	bullet.HullSize 	= 20
	bullet.Damage	= 125
	bullet.Attacker 	= self:GetDriver()
	bullet.AmmoType = "Pistol"
	bullet.Callback = function(att, tr, dmginfo)
		dmginfo:SetDamageType(DMG_AIRBOAT)
	end
	self:FireBullets( bullet )
	
	self:TakePrimaryAmmo()
end

function ENT:SecondaryAttack()
end

function ENT:SetNextAltPrimary( delay )
	self.NextAltPrimary = CurTime() + delay
end

function ENT:CanAltPrimaryAttack()
	self.NextAltPrimary = self.NextAltPrimary or 0
	return self.NextAltPrimary < CurTime()
end

function ENT:FireRearGun( TargetPos )
	if not self:CanAltPrimaryAttack() then return end
	
	if not isvector( TargetPos ) then return end
	
	local ID = self:LookupAttachment( "muzzle_reargun" )
	local Muzzle = self:GetAttachment( ID )
	
	if not Muzzle then return end
	
	self:EmitSound( "LAATi_FIRE" )
	
	self:SetNextAltPrimary( 0.3 )
	
	local bullet = {}
	bullet.Num 	= 1
	bullet.Src 	= Muzzle.Pos
	bullet.Dir 	= (TargetPos - Muzzle.Pos):GetNormalized()
	bullet.Spread 	= Vector( 0.02,  0.02, 0 )
	bullet.Tracer	= 1
	bullet.TracerName	= "lfs_laser_green"
	bullet.Force	= 100
	bullet.HullSize 	= 20
	bullet.Damage	= 125
	bullet.Attacker 	= self:GetGunner()
	bullet.AmmoType = "Pistol"
	bullet.Callback = function(att, tr, dmginfo)
		dmginfo:SetDamageType(DMG_AIRBOAT)
	end
	self:FireBullets( bullet )
end

function ENT:MainGunPoser( EyeAngles )
	local startpos =  self:GetRotorPos()
	local TracePlane = util.TraceHull( {
		start = startpos,
		endpos = (startpos + EyeAngles:Forward() * 50000),
		mins = Vector( -10, -10, -10 ),
		maxs = Vector( 10, 10, 10 ),
		filter = self
	} )
	
	local AimAngles = self:WorldToLocalAngles( (TracePlane.HitPos - self:LocalToWorld(  Vector(256,0,36) ) ):GetNormalized():Angle() )
	
	self.frontgunYaw = -AimAngles.y
	
	self:SetPoseParameter("frontgun_pitch", -AimAngles.p )
	self:SetPoseParameter("frontgun_yaw", -AimAngles.y )
end

function ENT:OnGravityModeChanged( b )
end

function ENT:CreateAI()
end

function ENT:RemoveAI()
end

function ENT:OnKeyThrottle( bPressed )
end

function ENT:OnEngineStarted()
	local RotorWash = ents.Create( "env_rotorwash_emitter" )
	
	if IsValid( RotorWash ) then
		RotorWash:SetPos( self:LocalToWorld( Vector(50,0,0) ) )
		RotorWash:SetAngles( Angle(0,0,0) )
		RotorWash:Spawn()
		RotorWash:Activate()
		RotorWash:SetParent( self )
		
		RotorWash.DoNotDuplicate = true
		self:DeleteOnRemove( RotorWash )
		self:dOwner( RotorWash )
		
		self.RotorWashEnt = RotorWash
	end
end

function ENT:OnEngineStopped()
	--self:EmitSound( "lfs/crysis_vtol/engine_stop.wav" )
	
	if IsValid( self.RotorWashEnt ) then
		self.RotorWashEnt:Remove()
	end
	
	self:SetGravityMode( true )
end

function ENT:OnVtolMode( IsOn )
end

function ENT:OnLandingGearToggled( bOn )
end

function ENT:OnTick()
	self:GunnerWeapons( self:GetGunner(), self:GetGunnerSeat() )
end

function ENT:GunnerWeapons( Driver, Pod )
	if not IsValid( Pod ) or not IsValid( Driver ) then return end

	Driver:CrosshairDisable()

	local EyeAngles = Pod:WorldToLocalAngles( Driver:EyeAngles() )
	
	local Forward = self:GetForward()
	local Back = -Forward

	local KeyAttack = Driver:KeyDown( IN_ATTACK )

	local startpos = self:GetRotorPos() + EyeAngles:Up() * 250
	local TracePlane = util.TraceLine( {
		start = startpos,
		endpos = (startpos + EyeAngles:Forward() * 50000),
		filter = self
	} )
	
	local AimAngYaw = math.abs( self:WorldToLocalAngles( EyeAngles ).y )
	
	local WingTurretActive = AimAngYaw < 55
	local RearGunActive = math.deg( math.acos( math.Clamp( Back:Dot( EyeAngles:Forward() ) ,-1,1) ) ) < 35
	
	local FireRearGun = KeyAttack and RearGunActive
	
	self:SetGXHairRG( RearGunActive )
	
	if AimAngYaw > 120 then
		local Pos,Ang = WorldToLocal( Vector(0,0,0), (TracePlane.HitPos - self:LocalToWorld( Vector(-400,0,158.5)) ):GetNormalized():Angle(), Vector(0,0,0), self:LocalToWorldAngles( Angle(0,180,0) ) )
		
		self:SetPoseParameter("reargun_pitch", -Ang.p )
		self:SetPoseParameter("reargun_yaw", -Ang.y )
	else
		self:SetPoseParameter("reargun_pitch", -30 )
		self:SetPoseParameter("reargun_yaw", 0 )
	end
	
	if FireRearGun then
		self:FireRearGun( TracePlane.HitPos )
	end
end

function ENT:HitGround()
	local tr = util.TraceLine( {
		start = self:LocalToWorld( Vector(0,0,100) ),
		endpos = self:LocalToWorld( Vector(0,0,-20) ),
		filter = function( ent ) 
			if ( ent == self ) then 
				return false
			end
		end
	} )
	
	return tr.Hit 
end