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

function ENT:Explode()
	if self.ExplodedAlready then return end
	
	self.ExplodedAlready = true
	
	self:DropHeldEntity()
	
	local Driver = self:GetDriver()
	local Gunner = self:GetGunner()
	
	if IsValid( Driver ) then
		Driver:TakeDamage( Driver:Health(), self.FinalAttacker or Entity(0), self.FinalInflictor or Entity(0) )
	end
	
	if IsValid( Gunner ) then
		Gunner:TakeDamage( Gunner:Health(), self.FinalAttacker or Entity(0), self.FinalInflictor or Entity(0) )
	end
	
	if istable( self.pSeats ) then
		for _, pSeat in pairs( self.pSeats ) do
			if IsValid( pSeat ) then
				local psgr = pSeat:GetDriver()
				if IsValid( psgr ) then
					psgr:TakeDamage( psgr:Health(), self.FinalAttacker or Entity(0), self.FinalInflictor or Entity(0) )
				end
			end
		end
	end
	
	local ent = ents.Create( "lunasflightschool_destruction" )
	if IsValid( ent ) then
		ent:SetPos( self:LocalToWorld( self:OBBCenter() ) )
		ent.GibModels = self.GibModels
		
		ent:Spawn()
		ent:Activate()
	end
	
	self:Remove()
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

function ENT:OnRemove()
	self:DropHeldEntity()
end

function ENT:DropHeldEntity()
	if IsValid( self.PosEnt ) then
		self.PosEnt:Remove()
	end

	self.wheel_L = NULL
	self.wheel_R = NULL

	local FrontEnt = self:GetHeldEntity()
	
	if IsValid( FrontEnt ) then
		if FrontEnt.SetIsCarried then
			FrontEnt:SetIsCarried( false )
		end
		
		if FrontEnt.GetRearEnt then
			local RearEnt = self:GetHeldEntity():GetRearEnt()
			
			RearEnt:SetCollisionGroup( self.OldCollisionGroup2 or COLLISION_GROUP_NONE  )
		end

		FrontEnt:SetCollisionGroup( self.OldCollisionGroup or COLLISION_GROUP_NONE )
		FrontEnt.smSpeed = 200
	end
	
	self:SetHeldEntity( NULL )
end

function ENT:HandleLandingGear()
	local Driver = self:GetDriver()
	
	if IsValid( Driver ) then
		local KeyJump = Driver:lfsGetInput( "VSPEC" )
		
		if self.OldKeyJump ~= KeyJump then
			self.OldKeyJump = KeyJump
			if KeyJump then
				self:ToggleLandingGear()
				self:PhysWake()
			end
		end
	end
end

function ENT:OnLandingGearToggled( bOn )
	self.GrabberEnabled = not self.GrabberEnabled
	
	if self.GrabberEnabled then
		self:EmitSound( "LAATc_GRABBER" )
		
		if IsValid( self.PICKUP_ENT ) then
			self.PosEnt = ents.Create( "prop_physics" )
			
			if IsValid( self.PosEnt ) then
				self.PosEnt:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
				self.PosEnt:SetPos( self.PICKUP_ENT:GetPos() )
				self.PosEnt:SetAngles( self.PICKUP_ENT:GetAngles() )
				self.PosEnt:SetCollisionGroup( COLLISION_GROUP_WORLD )
				self.PosEnt:Spawn()
				self.PosEnt:Activate()
				self.PosEnt:SetNoDraw( true ) 
				self:DeleteOnRemove( self.PosEnt )
			
				constraint.Weld( self.PosEnt, self.PICKUP_ENT, 0, 0, 0, false, false )
				
				if self.PICKUP_ENT.GetRearEnt then
					local RearEnt = self.PICKUP_ENT:GetRearEnt()
					RearEnt:SetAngles( self.PICKUP_ENT:GetAngles() )
					RearEnt:SetPos( self.PICKUP_ENT:GetPos() )
					constraint.Weld( self.PosEnt, RearEnt, 0, 0, 0, false, false )
					
					self.OldCollisionGroup2 = RearEnt:GetCollisionGroup()
					
					RearEnt:SetCollisionGroup( COLLISION_GROUP_WORLD )
					
					self.wheel_L = RearEnt -- !!HACK!! for AI traces
				end
				
				self.wheel_R = self.PICKUPENT -- !!HACK!! for AI traces
				
				self:SetHeldEntity( self.PICKUP_ENT )
				
				self.OldCollisionGroup = self:GetHeldEntity():GetCollisionGroup()
				self:GetHeldEntity():SetCollisionGroup( COLLISION_GROUP_WORLD )
				
				if self:GetHeldEntity().SetIsCarried then
					self:GetHeldEntity():SetIsCarried( true )
				end
			else
				self.GrabberEnabled = false
				print("[LFS] LAATc: ERROR COULDN'T CREATE PICKUP_ENT")
			end
		end
	else
		if IsValid( self:GetHeldEntity() ) then
			if self:CanDrop() then
				self:DropHeldEntity()
			else
				self:EmitSound( "LAATc_GRABBER_CANTDROP" )
				self.GrabberEnabled = true
			end
		else
			self:EmitSound( "LAATc_GRABBER" )
		end
	end
end

function ENT:OnTick()
	self:Grabber()
	self:GunnerWeapons( self:GetGunner(), self:GetGunnerSeat() )
end

function ENT:Grabber()
	local Rate = FrameTime()
	local Active = self.GrabberEnabled
	
	self.smGrabber = self.smGrabber and self.smGrabber + math.Clamp( (Active and 0 or 1) - self.smGrabber,-Rate,Rate) or 0
	self:SetPoseParameter("grabber", self.smGrabber )
	
	if Active then
		if IsValid( self.PosEnt ) then
			local PObj = self.PosEnt:GetPhysicsObject()
			
			if PObj:IsMotionEnabled() then
				PObj:EnableMotion( false )
			end
			
			local HeldEntity = self:GetHeldEntity()
			if IsValid( HeldEntity ) then
				self.PosEnt:SetPos( self:LocalToWorld( HeldEntity.LAATC_PICKUP_POS or Vector(0,0,0) ) + self:GetVelocity() * FrameTime() )
				self.PosEnt:SetAngles( self:LocalToWorldAngles( HeldEntity.LAATC_PICKUP_Angle or Angle(0,0,0) ) )
			end
			
			if self:GetAI() then self:SetAI( false ) end
		end
	else
		if (self.NextFind or 0) < CurTime() then
			self.NextFind = CurTime() + 1
			
			local StartPos = self:LocalToWorld( Vector(-120,0,100) )
			
			self.PICKUP_ENT = NULL
			local Dist = 1000
			
			for k, v in pairs( ents.FindInSphere( StartPos, 150 ) ) do
				if v.LAATC_PICKUPABLE then

					local Len = (StartPos - v:GetPos()):Length()

					if Len < Dist then
						self.PICKUP_ENT = v
						Dist = Len
					end
				end
			end
		end
	end
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

function ENT:CanDrop()
	local tr = util.TraceLine( {
		start = self:LocalToWorld( Vector(0,0,100) ),
		endpos = self:LocalToWorld( Vector(0,0,-150) ),
		filter = function( ent ) 
			if ent == self or ent == self:GetHeldEntity() then 
				return false
			end
		end
	} )
	
	return tr.Hit 
end