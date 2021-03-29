-- DO NOT EDIT OR REUPLOAD THIS FILE
-- DO NOT EDIT OR REUPLOAD THIS FILE
-- DO NOT EDIT OR REUPLOAD THIS FILE
-- DO NOT EDIT OR REUPLOAD THIS FILE
-- DO NOT EDIT OR REUPLOAD THIS FILE
-- DO NOT EDIT OR REUPLOAD THIS FILE
-- DO NOT EDIT OR REUPLOAD THIS FILE
-- DO NOT EDIT OR REUPLOAD THIS FILE
-- DO NOT EDIT OR REUPLOAD THIS FILE
-- DO NOT EDIT OR REUPLOAD THIS FILE
-- DO NOT EDIT OR REUPLOAD THIS FILE
-- DO NOT EDIT OR REUPLOAD THIS FILE
-- DO NOT EDIT OR REUPLOAD THIS FILE
-- DO NOT EDIT OR REUPLOAD THIS FILE

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:SpawnFunction( ply, tr, ClassName )
	if not tr.Hit then return end

	local ent = ents.Create( ClassName )
	ent.dOwnerEntLFS = ply
	ent:SetPos( tr.HitPos + tr.HitNormal * 350 )
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:OnReloadWeapon()
	self:SetAmmoTertiary( self.MaxTertiaryAmmo )

	self:EmitSound("lfs/weapons_reload.wav")
end

function ENT:OnUnloadWeapon()
	self:SetAmmoTertiary( 0 )

	self:EmitSound("weapons/357/357_reload4.wav")
end

function ENT:SetNextAltPrimary( delay )
	self.NextAltPrimary = CurTime() + delay
end

function ENT:CanAltPrimaryAttack()
	self.NextAltPrimary = self.NextAltPrimary or 0
	return self.NextAltPrimary < CurTime()
end

function ENT:TakeTertiaryAmmo()
	self:SetAmmoTertiary( math.max(self:GetAmmoTertiary() - 1,0) )
end
	
function ENT:AltPrimaryAttack( Driver, Pod, Dir )
	if not self:CanAltPrimaryAttack() then return end
	
	if not IsValid( Pod ) then return end
	if not IsValid( Driver ) then return end
	
	local ID = self:LookupAttachment( "muzzle" )
	local Attachment = self:GetAttachment( ID )
	
	if not Attachment then return end

	self:SetNextAltPrimary( 0.04 )
	
	local TargetDir = Attachment.Ang:Forward()
	
	-- ignore attachment angles and make aiming 100% accurate to player view direction
	local Forward = self:LocalToWorldAngles( Angle(20,0,0) ):Forward()
	local AimDirToForwardDir = math.deg( math.acos( math.Clamp( Forward:Dot( Dir ) ,-1,1) ) )
	if AimDirToForwardDir < 120 then
		TargetDir = Dir
	end
	
	local bullet = {}
	bullet.Num 	= 1
	bullet.Src 	= Attachment.Pos
	bullet.Dir 	= TargetDir
	bullet.Spread 	= Vector( 0.01,  0.01, 0 )
	bullet.Tracer	= 2
	bullet.TracerName	= "lfs_tracer_red"
	bullet.Force	= 30
	bullet.HullSize 	= 22
	bullet.Damage	= 18
	bullet.Attacker 	= Driver
	bullet.AmmoType = "Pistol"
	bullet.Callback = function(att, tr, dmginfo)
		dmginfo:SetDamageType(DMG_AIRBOAT)
	end
	self:FireBullets( bullet )
	
	self:TakeTertiaryAmmo()
end

function ENT:OnTick()
	self:SetIsGroundTouching( not self.LandingGearUp and self:HitGround() )
	
	local GroundTouching = self:GetIsGroundTouching()
	
	if self.oldGroundTouching ~= GroundTouching then
		self.oldGroundTouching = GroundTouching
		
		self:OnGroundTouched( GroundTouching )
	end
	
	local Driver = self:GetDriver()
	if not IsValid( Driver ) then return end
	
	local Space = Driver:KeyDown( IN_JUMP )
	
	if self.oldKeySpace ~= Space then
		self.oldKeySpace = Space
		if Space then
			if self:GetForceOpenDoor() then
				self:OnDoorOpen()
			else
				self:OnDoorClose()
			end
			
			self:SetForceOpenDoor( not self:GetForceOpenDoor() )
		end
	end
end

function ENT:OnDoorOpen()
	self:EmitSound( "lfs/crysis_vtol/door_open.wav" )
end

function ENT:OnDoorClose()
	self:EmitSound( "lfs/crysis_vtol/door_close.wav" )
end

function ENT:OnGroundTouched( On )
	if On then
		if not self:GetForceOpenDoor() then
			self:SetForceOpenDoor( true )
			self:OnDoorOpen()
		end
	else
		if self:GetForceOpenDoor() then
			self:SetForceOpenDoor( false )
			self:OnDoorClose()
		end
	end
end

function ENT:RunOnSpawn()
	self:GetDriverSeat().ExitPos = Vector(-12.9,0,-45)
	
	local GunnerSeat = self:AddPassengerSeat( Vector(233.6,0,-42.42), Angle(0,-90,0) )
	GunnerSeat.ExitPos = Vector(-12.9,0,-45)
	
	self:SetGunnerSeat( GunnerSeat )
	
	self:AddPassengerSeat( Vector(-154.8,-44.5,-40), Angle(0,0,0) ).ExitPos = Vector(-167.38,-16.49,-45)
	self:AddPassengerSeat( Vector(-106.3,-44.5,-40), Angle(0,0,0) ).ExitPos = Vector(-121.21,-19.29,-45)
	self:AddPassengerSeat( Vector(-53.2,-44.5,-40), Angle(0,0,0) ).ExitPos = Vector(-69.64,-18.28,-45)
	
	self:AddPassengerSeat( Vector(-154.8,44.5,-40), Angle(0,180,0) ).ExitPos = Vector(-146.99,13.78,-45)
	self:AddPassengerSeat( Vector(-106.3,44.5,-40), Angle(0,180,0) ).ExitPos = Vector(-95.05,18.11,-45)
	self:AddPassengerSeat( Vector(-53.2,44.5,-40), Angle(0,180,0) ).ExitPos = Vector(-41.3,18.94,-45)
end

function ENT:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	self:SetNextPrimary( 0.1 )
	
	local Driver = self:GetDriver()
	
	local bullet = {}
	bullet.Num 	= 1
	bullet.Src 	= self:LocalToWorld( Vector(106,-53.95,36) )
	bullet.Dir 	= self:LocalToWorldAngles( Angle(0,1,0) ):Forward()
	bullet.Spread 	= Vector( 0.015,  0.015, 0 )
	bullet.Tracer	= 1
	bullet.TracerName	= "lfs_tracer_white"
	bullet.Force	= 10
	bullet.HullSize 	= 30
	bullet.Damage	= 40
	bullet.Attacker 	= Driver
	bullet.AmmoType = "Pistol"
	
	self:FireBullets( bullet )
	
	self:TakePrimaryAmmo()
end


function ENT:SecondaryAttack()
	if self:GetAI() then return end
	
	if not self:CanSecondaryAttack() then return end
	
	self:SetNextSecondary( 1.5 )

	self:TakeSecondaryAmmo()

	self:EmitSound( "CRYSIS_VTOL_MISSILE_FIRE" )
	
	local startpos =  self:GetRotorPos()
	local tr = util.TraceHull( {
		start = startpos,
		endpos = (startpos + self:GetForward() * 50000),
		mins = Vector( -40, -40, -40 ),
		maxs = Vector( 40, 40, 40 ),
		filter = self
	} )

	local ent = ents.Create( "lunasflightschool_missile" )
	local Pos = self:LocalToWorld( Vector(106,53.95,36) )
	ent:SetPos( Pos )
	ent:SetAngles( (tr.HitPos - Pos):Angle() )
	ent:Spawn()
	ent:Activate()
	ent:SetAttacker( self:GetDriver() )
	ent:SetInflictor( self )
	ent:SetStartVelocity( self:GetVelocity():Length() )
	ent:SetDirtyMissile( true )
	
	if tr.Hit then
		local Target = tr.Entity
		if IsValid( Target ) then
			if Target:GetClass():lower() ~= "lunasflightschool_missile" then
				ent:SetLockOn( Target )
				ent:SetStartVelocity( 0 )
			end
		end
	end
	
	constraint.NoCollide( ent, self, 0, 0 ) 
	
	if istable( self.LandingGearPlates ) then
		for _, v in pairs( self.LandingGearPlates ) do
			if IsValid( v ) then
				constraint.NoCollide( ent, v, 0, 0 ) 
			end
		end
	end
end

function ENT:CreateAI()
end

function ENT:RemoveAI()
end

function ENT:OnEngineStarted()
	self:EmitSound( "lfs/crysis_vtol/engine_start.wav" )
	
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
	self:EmitSound( "lfs/crysis_vtol/engine_stop.wav" )
	
	if IsValid( self.RotorWashEnt ) then
		self.RotorWashEnt:Remove()
	end
end

function ENT:OnVtolMode( On )
	if On then
		self:EmitSound( "lfs/crysis_vtol/vtol_off.wav" )
		self:DeployLandingGear()
		self.MaxTurnRoll = 450
	else
		self:EmitSound( "lfs/crysis_vtol/vtol_on.wav" )
		self:RaiseLandingGear()
		self.MaxTurnRoll = 300
	end
end

function ENT:InitWheels()
	local GearPlates = {
		Vector(-22.5,201.77,-127),
		Vector(-22.5,-201.77,-127),
		Vector(205,0,-142),
		Vector(-260,0,-110),
	}
	
	self.LandingGearPlates = {}

	for _, v in pairs( GearPlates ) do
		local Plate = ents.Create( "prop_physics" )
		if IsValid( Plate ) then
			Plate:SetPos( self:LocalToWorld( v ) )
			Plate:SetAngles( self:LocalToWorldAngles( Angle(5,0,0) ) )
			
			Plate:SetModel( "models/hunter/plates/plate1x1.mdl" )
			Plate:Spawn()
			Plate:Activate()
			
			Plate:SetNoDraw( true )
			Plate:DrawShadow( false )
			Plate.DoNotDuplicate = true
			
			local pObj = Plate:GetPhysicsObject()
			if not IsValid( pObj ) then
				self:Remove()
				print("LFS: Failed to initialize landing gear phys model. Plane terminated.")
				return
			end
		
			pObj:EnableMotion(false)
			pObj:SetMass( 500 )
			
			table.insert( self.LandingGearPlates, Plate )
			self:DeleteOnRemove( Plate )
			self:dOwner( Plate )
			
			constraint.Weld( self, Plate, 0, 0, 0,false, true ) 
			constraint.NoCollide( Plate, self, 0, 0 ) 
			
			pObj:EnableMotion( true )
			pObj:EnableDrag( false ) 
			
			Plate:SetPos( self:GetPos() )
			
		else
			self:Remove()
		
			print("LFS: Failed to initialize landing gear. Plane terminated.")
		end
	end

	timer.Simple( 0.5, function()
		if not IsValid( self ) then return end
		
		local PObj = self:GetPhysicsObject()
		if IsValid( PObj ) then 
			PObj:EnableMotion( true )
		end
		
		self:PhysWake() 
	end)
end

function ENT:HandleLandingGear()
	local TVal = self.LandingGearUp and 0 or 1
	
	local Speed = FrameTime() * 0.5
	
	self:SetLGear( self:GetLGear() + math.Clamp(TVal - self:GetLGear(),-Speed,Speed) )
	
	if istable( self.LandingGearPlates ) then
		for _, v in pairs( self.LandingGearPlates ) do
			if IsValid( v ) then
				local pObj = v:GetPhysicsObject()
				if IsValid( pObj ) then
					pObj:SetMass( 1 + 2000 * self:GetLGear() ^ 10 )
				end
			end
		end
	end
end

function ENT:HandleWeapons(Fire1, Fire2, Fire3)
	local Driver = self:GetDriver()
	
	local Gunner = self:GetGunner()
	local GunnerSeat = self:GetGunnerSeat()
	local GunnerDir = self:GetForward()
	
	self.barrelSpinAdd = self.barrelSpinAdd and (self.barrelSpinAdd - self.barrelSpinAdd * FrameTime() * 5) or 0
	self.barrelSpin = self.barrelSpin and (self.barrelSpin + self.barrelSpinAdd) or 0

	if IsValid( Driver ) then
		if self:GetAmmoPrimary() > 0 then
			Fire1 = Driver:KeyDown( IN_ATTACK )
		end
		
		if self:GetAmmoSecondary() > 0 then
			Fire2 = Driver:KeyDown( IN_ATTACK2 )
		end
	end
	
	if IsValid( Gunner ) and IsValid( GunnerSeat ) then
		local EyeAng = Gunner:EyeAngles()
		local GunnerAng = GunnerSeat:WorldToLocalAngles( EyeAng )
		
		GunnerDir = GunnerAng:Forward()
		
		Gunner:CrosshairDisable()
		
		if self:GetAmmoTertiary() > 0 then
			Fire3 = Gunner:KeyDown( IN_ATTACK )
		end
		
		local TurretAng = self:WorldToLocalAngles( GunnerAng )
		
		self:SetPoseParameter("turret_yaw", -TurretAng.y )
		self:SetPoseParameter("turret_pitch", TurretAng.p )
	end
	
	self:SetPoseParameter("zbarrel_spin", self.barrelSpin )
	
	if Fire1 then
		self:PrimaryAttack()
	end

	if self.OldFire2 ~= Fire2 then
		if Fire2 then
			self:SecondaryAttack()
		end
		self.OldFire2 = Fire2
	end
	
	if Fire3 then
		self:AltPrimaryAttack( Gunner, GunnerSeat, GunnerDir )
		self.barrelSpinAdd = 30
	end
	
	if self.OldFire ~= Fire1 then
		if Fire1 then
			self.wpn1 = CreateSound( self, "CRYSIS_VTOL_AC_FIRE" )
			self.wpn1:Play()
			self:CallOnRemove( "stopmesounds1", function( ent )
				if ent.wpn1 then
					ent.wpn1:Stop()
				end
			end)
		else
			if self.OldFire == true then
				if self.wpn1 then
					self.wpn1:Stop()
				end
				self.wpn1 = nil
				
				self:EmitSound( "CRYSIS_VTOL_AC_LASTSHOT" )
			end
		end
		
		self.OldFire = Fire1
	end
	
	if self.OldFire3 ~= Fire3 then
		if Fire3 then
			self.wpn2 = CreateSound( self, "CRYSIS_VTOL_MINIGUN_FIRE" )
			self.wpn2:Play()
			self:CallOnRemove( "stopmesounds2", function( ent )
				if ent.wpn2 then
					ent.wpn2:Stop()
				end
			end)
		else
			if self.OldFire3 == true then
				if self.wpn2 then
					self.wpn2:Stop()
				end
				self.wpn2 = nil
				
				self:EmitSound( "CRYSIS_VTOL_MINIGUN_LASTSHOT" )
			end
		end
		
		self.OldFire3 = Fire3
	end
end
