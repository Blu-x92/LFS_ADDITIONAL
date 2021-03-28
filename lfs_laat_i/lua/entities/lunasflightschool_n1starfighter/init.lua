--DO NOT EDIT OR REUPLOAD THIS FILE

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")


function ENT:RunOnSpawn()
	if FrameTime() > 0.067 then
		self.ElevatorPos = Vector(-200,0,54.62)
		self.RudderPos = Vector(-200,0,54.62)
	end
end

function ENT:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	self:EmitSound( "N1_FIRE" )
	
	self:SetNextPrimary( 0.15 )
	
	for i = 0,1 do
		self.MirrorPrimary = not self.MirrorPrimary
		
		local Mirror = self.MirrorPrimary and -1 or 1
		
		local bullet = {}
		bullet.Num 	= 1
		bullet.Src 	= self:LocalToWorld( Vector(118.24,18.04 * Mirror,49.96) )
		bullet.Dir 	= self:LocalToWorldAngles( Angle(0,0,0) ):Forward()
		bullet.Spread 	= Vector( 0.01,  0.01, 0 )
		bullet.Tracer	= 1
		bullet.TracerName	= "lfs_laser_green"
		bullet.Force	= 100
		bullet.HullSize 	= 25
		bullet.Damage	= 40
		bullet.Attacker 	= self:GetDriver()
		bullet.AmmoType = "Pistol"
		bullet.Callback = function(att, tr, dmginfo)
			dmginfo:SetDamageType(DMG_AIRBOAT)
		end
		self:FireBullets( bullet )
		
		self:TakePrimaryAmmo()
	end
	
end

function ENT:SecondaryAttack()
	if self:GetAI() then return end
	if not self:CanSecondaryAttack() then return end
	
	self:SetNextSecondary( 1 )

	self:TakeSecondaryAmmo()

	self:EmitSound( "N1_FIRE2" )
	
	local startpos =  self:GetRotorPos()
	local tr = util.TraceHull( {
		start = startpos,
		endpos = (startpos + self:GetForward() * 50000),
		mins = Vector( -40, -40, -40 ),
		maxs = Vector( 40, 40, 40 ),
		filter = self
	} )
	
	local ent = ents.Create( "lunasflightschool_missile" )
	ent:SetPos( self:LocalToWorld( Vector(147.82,0,39.52) ) )
	ent:SetAngles( self:GetAngles() )
	ent:Spawn()
	ent:Activate()
	ent:SetAttacker( self:GetDriver() )
	ent:SetInflictor( self )
	ent:SetStartVelocity( self:GetVelocity():Length() )
	ent:SetCleanMissile( true )

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
end

function ENT:OnKeyThrottle( bPressed )
	if bPressed then
		if self:CanSound() then
			self:EmitSound( "N1_BOOST" )
			self:DelayNextSound( 1 )
		end
	else
		if (self:GetRPM() + 1) > self:GetMaxRPM() then
			if self:CanSound() then
				self:EmitSound( "N1_BRAKE" )
				self:DelayNextSound( 0.5 )
			end
		end
	end
end

function ENT:CreateAI()
end

function ENT:RemoveAI()
end

function ENT:ToggleLandingGear()
end

function ENT:RaiseLandingGear()
end

function ENT:HandleWeapons(Fire1, Fire2)
	local Driver = self:GetDriver()
	
	if IsValid( Driver ) then
		if self:GetAmmoPrimary() > 0 then
			Fire1 = Driver:KeyDown( IN_ATTACK )
		end
		
		if self:GetAmmoSecondary() > 0 then
			Fire2 = Driver:KeyDown( IN_ATTACK2 )
		end
	end
	
	if Fire1 then
		self:PrimaryAttack()
	end
	
	if self.OldFire2 ~= Fire2 then
		if Fire2 then
			self:SecondaryAttack()
		end
		self.OldFire2 = Fire2
	end
end

function ENT:OnEngineStarted()
	self:EmitSound( "lfs/naboo_n1_starfighter/start.wav" )
end

function ENT:OnEngineStopped()
	self:EmitSound( "lfs/naboo_n1_starfighter/stop.wav" )
end
