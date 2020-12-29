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
	self:GetDriverSeat():SetCameraDistance( 1 )
	
	local GunnerSeat = self:AddPassengerSeat( Vector(111.87,0,156), Angle(0,-90,0) )
	GunnerSeat.ExitPos = Vector(75,0,36)
	
	self:SetGunnerSeat( GunnerSeat )
	
	do
		local BallTurretPod = self:AddPassengerSeat( Vector(0,0,100), Angle(0,-90,0) )
		
		local ID = self:LookupAttachment( "muzzle_ballturret_left" )
		local Muzzle = self:GetAttachment( ID )
		
		if Muzzle then
			local Pos,Ang = LocalToWorld( Vector(0,-20,-55), Angle(180,0,-90), Muzzle.Pos, Muzzle.Ang )
			
			BallTurretPod:SetParent( NULL )
			BallTurretPod:SetPos( Pos )
			BallTurretPod:SetAngles( Ang )
			BallTurretPod:SetParent( self, ID )
			self:SetBTPodL( BallTurretPod )
		end
	end
	
	do
		local BallTurretPod = self:AddPassengerSeat( Vector(0,0,100), Angle(0,-90,0) )
		
		local ID = self:LookupAttachment( "muzzle_ballturret_right" )
		local Muzzle = self:GetAttachment( ID )
		
		if Muzzle then
			local Pos,Ang = LocalToWorld( Vector(0,-20,-55), Angle(180,0,-90), Muzzle.Pos, Muzzle.Ang )
			
			BallTurretPod:SetParent( NULL )
			BallTurretPod:SetPos( Pos )
			BallTurretPod:SetAngles( Ang )
			BallTurretPod:SetParent( self, ID )
			self:SetBTPodR( BallTurretPod )
		end
	end
	
	self:AddPassengerSeat( Vector(95,0,15), Angle(0,90,0) ).ExitPos = Vector(75,0,36)
	
	for i = 0, 5 do
		local X = i * 35
		local Y = 30 - i * 3
		
		self:AddPassengerSeat( Vector(10 - X,Y,10), Angle(0,0,0) ).ExitPos = Vector(10 - X,25,33)
		self:AddPassengerSeat( Vector(10 - X,-Y,10), Angle(0,180,0) ).ExitPos = Vector(10 - X,-25,33)
	end

	self:SetPoseParameter("ballturret_left_pitch", 0 )
	self:SetPoseParameter("ballturret_left_yaw", -70 )
	self:SetPoseParameter("ballturret_right_pitch", 0 )
	self:SetPoseParameter("ballturret_right_yaw", -70 )

	self:OnBallturretMounted( self:GetBodygroup(4) == 0, nil )

	if FrameTime() > 0.067 then
		self.MaxTurnPitch = 70
		self.MaxTurnYaw = 70
		self.MaxTurnRoll = 70

		self.PitchDamping = 1
		self.YawDamping = 1
		self.RollDamping = 1

		self.TurnForcePitch = 3000
		self.TurnForceYaw = 3000
		self.TurnForceRoll = 400
	end
end

function ENT:PrimaryAttack()
	if not self:CanPrimaryAttack() or not self:GetEngineActive() then return end

	local ID_L = self:LookupAttachment( "muzzle_frontgun_left" )
	local ID_R = self:LookupAttachment( "muzzle_frontgun_right" )
	local MuzzleL = self:GetAttachment( ID_L )
	local MuzzleR= self:GetAttachment( ID_R )
	
	if not MuzzleL or not MuzzleR then return end

	self:SetNextPrimary( 0.25 )
	self:EmitSound( "LAATi_FIRE" )

	for i = 1, 2 do
		self.MirrorPrimary = not self.MirrorPrimary
		
		if not isnumber( self.frontgunYaw ) then return end

		if (self.frontgunYaw < 5 and self.MirrorPrimary) or (self.frontgunYaw > -5 and not self.MirrorPrimary) then
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
			bullet.Damage	= 63
			bullet.Attacker 	= self:GetDriver()
			bullet.AmmoType = "Pistol"
			bullet.Callback = function(att, tr, dmginfo)
				dmginfo:SetDamageType(DMG_AIRBOAT)
			end
			self:FireBullets( bullet )
			
			self:TakePrimaryAmmo()
		end
	end
end

function ENT:SecondaryAttack()
	if self:GetAI() then return end
	
	if not self:CanSecondaryAttack() then return end
	
	self:EmitSound( "LAATi_FIREMISSILE" )
	
	self:SetNextSecondary( 0.6 )
	
	self:TakeSecondaryAmmo()
	
	local startpos = self:GetRotorPos()
	local tr = util.TraceHull( {
		start = startpos,
		endpos = (startpos + self:GetForward() * 50000),
		mins = Vector( -40, -40, -40 ),
		maxs = Vector( 40, 40, 40 ),
		filter = function( e )
			local collide = e ~= self
			return collide
		end
	} )
	local AltLauncherType = self:GetBodygroup( 3 ) == 0

	self.MirrorSec = not self.MirrorSec

	local i = self.MirrorSec and -1 or 1

	local ent = ents.Create( "lunasflightschool_missile" )
	local Pos = self:LocalToWorld( Vector((AltLauncherType and -20 or 206.07) ,59 * i,286.88) )
	ent:SetPos( Pos )
	ent:SetAngles( (tr.HitPos - Pos):Angle() )
	ent:Spawn()
	ent:Activate()
	ent:SetAttacker( self:GetDriver() )
	ent:SetInflictor( self )
	ent:SetStartVelocity( self:GetVelocity():Length() )

	if tr.Hit then
		local Target = tr.Entity
		if IsValid( Target ) then
			if Target:GetClass():lower() ~= "lunasflightschool_missile" then
				ent:SetLockOn( Target )
				ent:SetStartVelocity( 0 )
			end
		end
	end
	
	if AltLauncherType then
		ent:SetCleanMissile( true )
	else
		ent:SetDirtyMissile( true )
	end
	
	constraint.NoCollide( ent, self, 0, 0 ) 
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
	if self:GetAI() then return end
	
	local Driver = self:GetDriver()
	
	if not IsValid( Driver ) then return end
	
	if Driver:KeyDown( IN_ZOOM ) then
		local ToggleHatch = not self:GetRearHatch()
		self:SetRearHatch( ToggleHatch )
		
		if ToggleHatch then
			self:EmitSound( "lfs/laat/door_open.wav" )
		else
			self:EmitSound( "lfs/laat/door_close.wav" )
		end
	else
		if self:GetBodygroup( 2 ) == 0 then
			local DoorMode = self:GetDoorMode() + 1

			self:SetDoorMode( DoorMode )
			
			if DoorMode == 1 then
				self:EmitSound( "lfs/laat/door_open.wav" )
			end
			
			if DoorMode == 2 then
				self:PlayAnimation( "doors_open" )
				self:EmitSound( "lfs/laat/door_large_open.wav" )
			end
			
			if DoorMode == 3 then
				self:PlayAnimation( "doors_close" )
				self:EmitSound( "lfs/laat/door_large_close.wav" )
			end
			
			if DoorMode >= 4 then
				self:SetDoorMode( 0 )
				self:EmitSound( "lfs/laat/door_close.wav" )
			end
		else
			local DoorMode = self:GetDoorMode() + 1

			self:SetDoorMode( DoorMode )

			if DoorMode == 1 then
				self:PlayAnimation( "doors_open" )
				self:EmitSound( "lfs/laat/door_large_open.wav" )
			end
			
			if DoorMode >= 2 then
				self:PlayAnimation( "doors_close" )
				self:EmitSound( "lfs/laat/door_large_close.wav" )
				self:SetDoorMode( 0 )
			end
		end
	end

	if self:GetDoorMode() == 0 and not self:GetRearHatch() then
		if not self:GetlfsLockedStatus() then
			self:SetlfsLockedStatus( true )
		end
	else
		if self:GetlfsLockedStatus() then
			self:SetlfsLockedStatus( false )
		end
	end
end

function ENT:OnBallturretMounted( ismounted, oldvar )
	if ismounted == oldvar then return end

	if ismounted then
		if IsValid( self.BTPodR_ent_orig ) then 
			self:SetBTPodR( self.BTPodR_ent_orig )
			self.BTPodR_ent_orig:SetNWInt( "pPodIndex", self.BTPodR_index_orig )
		end

		if IsValid( self.BTPodL_ent_orig ) then 
			self:SetBTPodL( self.BTPodL_ent_orig )
			self.BTPodL_ent_orig:SetNWInt( "pPodIndex", self.BTPodL_index_orig )
		end
	else
		local Pod_R = self:GetBTPodR()
		if IsValid( Pod_R ) then 
			self.BTPodR_ent_orig = Pod_R
			self.BTPodR_index_orig = Pod_R:GetNWInt( "pPodIndex" )
			Pod_R:SetNWInt( "pPodIndex", -1 )
		end

		local Pod_L = self:GetBTPodL()
		if IsValid( Pod_L ) then 
			self.BTPodL_ent_orig = Pod_L
			self.BTPodL_index_orig = Pod_L:GetNWInt( "pPodIndex" )
			Pod_L:SetNWInt( "pPodIndex", -1 )
		end

		local Gunner_R = self:GetBTGunnerR()
		if IsValid( Gunner_R ) then
			Gunner_R:ExitVehicle()
		end

		local Gunner_L = self:GetBTGunnerL()
		if IsValid( Gunner_L ) then
			Gunner_L:ExitVehicle()
		end

		self:SetBTPodR( NULL )
		self:SetBTRFire( false )
		self:SetBTGunnerR( NULL )
		
		self:SetBTPodL( NULL )
		self:SetBTLFire( false )
		self:SetBTGunnerL( NULL )
	end
end

function ENT:GetPassengerSeats()
	if not istable( self.pSeats ) then
		self.pSeats = {}
		
		local DriverSeat = self:GetDriverSeat()

		for _, v in pairs( self:GetChildren() ) do
			if v ~= DriverSeat and v:GetClass():lower() == "prop_vehicle_prisoner_pod" then
				table.insert( self.pSeats, v )
			end
		end
	end

	if self:GetBodygroup(4) == 1 then
		local pSeats = table.Copy( self.pSeats )

		for k, v in pairs( pSeats ) do
			if v == self.BTPodR_ent_orig or v == self.BTPodL_ent_orig then
				pSeats[k] = nil
			end
		end

		return pSeats
	else
		return self.pSeats
	end
end

function ENT:OnTick()
	do
		local DoorMode = self:GetDoorMode()
		local TargetValue = DoorMode >= 1 and 1 or 0
		self.SDsm = isnumber( self.SDsm ) and (self.SDsm + math.Clamp((TargetValue - self.SDsm) * 5,-1,2) * FrameTime() ) or 0
		self:SetPoseParameter("sidedoor_extentions", self.SDsm )
	end

	local BTbodygroup = self:GetBodygroup(4)

	if BTbodygroup ~= self.oldBTbodygroup then
		self:OnBallturretMounted( BTbodygroup == 0, self.oldBTbodygroup == 0 )

		self.oldBTbodygroup = BTbodygroup
	end

	do
		local Pod = self:GetBTPodL()
		
		if IsValid( Pod ) then
			local ply = Pod:GetDriver()
			
			if ply ~= self:GetBTGunnerL() then
				self:SetBTGunnerL( ply )
			end
			
			if IsValid( ply ) then
				self:BallTurretL( ply, Pod )
				self:SetBTLFire( ply:KeyDown( IN_ATTACK ) )
			else
				self:SetBTLFire( false )
			end
		end
	end
	
	do
		local Pod = self:GetBTPodR()
		
		if IsValid( Pod ) then
			local ply = Pod:GetDriver()
			
			if ply ~= self:GetBTGunnerR() then
				self:SetBTGunnerR( ply )
			end
			
			if IsValid( ply ) then
				self:BallTurretR( ply, Pod )
				self:SetBTRFire( ply:KeyDown( IN_ATTACK ) )
			else
				self:SetBTRFire( false )
			end
		end
	end
	
	self:GunnerWeapons( self:GetGunner(), self:GetGunnerSeat() )
end

function ENT:BallTurretL( Driver, Pod )
	local EyeAngles = Pod:WorldToLocalAngles( Driver:EyeAngles() )
	
	local _,LocalAng = WorldToLocal( Vector(0,0,0), EyeAngles, Vector(0,0,0), self:LocalToWorldAngles( Angle(0,90,0)  ) )

	self:SetPoseParameter("ballturret_left_pitch", LocalAng.p )
	self:SetPoseParameter("ballturret_left_yaw", LocalAng.y )
	
	if self:GetBTLFire() then
		local ID = self:LookupAttachment( "muzzle_ballturret_left" )
		local Muzzle = self:GetAttachment( ID )
		
		if Muzzle then
			local Dir = Muzzle.Ang:Up()
			local startpos = Muzzle.Pos
			
			local Trace = util.TraceLine( {
				start = startpos,
				endpos = (startpos + Dir * 50000),
			} )
			
			self:BallturretDamage( Trace.Entity, Driver, Trace.HitPos, Dir )
		end
	end
end

function ENT:BallTurretR( Driver, Pod )
	local EyeAngles = Pod:WorldToLocalAngles( Driver:EyeAngles() )
	
	local _,LocalAng = WorldToLocal( Vector(0,0,0), EyeAngles, Vector(0,0,0), self:LocalToWorldAngles( Angle(0,-90,0)  ) )

	self:SetPoseParameter("ballturret_right_pitch", LocalAng.p )
	self:SetPoseParameter("ballturret_right_yaw", -LocalAng.y )
	
	if self:GetBTRFire() then
		local ID = self:LookupAttachment( "muzzle_ballturret_right" )
		local Muzzle = self:GetAttachment( ID )
		
		if Muzzle then
			local Dir = Muzzle.Ang:Up()
			local startpos = Muzzle.Pos
			
			local Trace = util.TraceLine( {
				start = startpos,
				endpos = (startpos + Dir * 50000),
			} )
			
			self:BallturretDamage( Trace.Entity, Driver, Trace.HitPos, Dir )
		end
	end
end

function ENT:GunnerWeapons( Driver, Pod )
	if not IsValid( Pod ) or not IsValid( Driver ) then 
		self:SetWingTurretFire( false ) 
		
		return
	else
		Driver:CrosshairDisable()
	end

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
	
	local FireWingTurret = KeyAttack and WingTurretActive
	local FireRearGun = KeyAttack and RearGunActive
	
	self:SetGXHairRG( RearGunActive )
	self:SetGXHairWT( WingTurretActive )
	
	if FireWingTurret then
		self:SetWingTurretTarget( TracePlane.HitPos )
		
		local DesEndPos = TracePlane.HitPos
		local DesStartPos = Vector(-172.97,334.04,93.25)
		for i = -1,1,2 do
			local StartPos = self:LocalToWorld( DesStartPos * Vector(1,i,1) )
			
			local Trace = util.TraceLine( { start = StartPos, endpos = DesEndPos} )
			local EndPos = Trace.HitPos
			
			if self.Entity:WorldToLocal( EndPos ).z < 0 then
				DesStartPos = Vector(-172.97,334.04,93.25)
			else
				DesStartPos = Vector(-174.79,350.05,125.98)
			end
			
			self:BallturretDamage( Trace.Entity, Driver, EndPos, (EndPos - StartPos):GetNormalized() )
		end
	end
	self:SetWingTurretFire( FireWingTurret )

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

function ENT:BallturretDamage( target, attacker, HitPos, HitDir )
	if not IsValid( target ) or not IsValid( attacker ) then return end

	if target ~= self then
		local dmginfo = DamageInfo()
		dmginfo:SetDamage( 1000 * FrameTime() )
		dmginfo:SetAttacker( attacker )
		dmginfo:SetDamageType( bit.bor( DMG_SHOCK, DMG_ENERGYBEAM ) )
		dmginfo:SetInflictor( self ) 
		dmginfo:SetDamagePosition( HitPos ) 
		dmginfo:SetDamageForce( HitDir * 10000 ) 
		target:TakeDamageInfo( dmginfo )
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