--DO NOT EDIT OR REUPLOAD THIS FILE
--DO NOT EDIT OR REUPLOAD THIS FILE
--DO NOT EDIT OR REUPLOAD THIS FILE
--DO NOT EDIT OR REUPLOAD THIS FILE
--DO NOT EDIT OR REUPLOAD THIS FILE
--DO NOT EDIT OR REUPLOAD THIS FILE
--DO NOT EDIT OR REUPLOAD THIS FILE
--DO NOT EDIT OR REUPLOAD THIS FILE
--DO NOT EDIT OR REUPLOAD THIS FILE
--DO NOT EDIT OR REUPLOAD THIS FILE

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")
include("sv_generic_hovering.lua")

ENT.RunSpeed = 400
ENT.WalkSpeed = 100

ENT.HoverDist = 95
ENT.TraceLengthAdd = 50
ENT.TraceHullRadius = 10

ENT.TurnRate = 1
ENT.AngularForceMul = 50
ENT.AngularVelDamping = 2

ENT.NormalAlignLever = 1000
ENT.NormalAlignMul = 2

ENT.AlignToGround = false

ENT.StrafeAngle = 30

ENT.ForceMul1 = 5
ENT.ForceMul2 = 0.5

function ENT:SpawnFunction( ply, tr, ClassName )
	if not tr.Hit then return end

	local ent = ents.Create( ClassName )
	ent.dOwnerEntLFS = ply
	ent:SetPos( tr.HitPos + tr.HitNormal )
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:RunOnSpawn()
end

function ENT:OnTick()
	local FT = FrameTime()

	local Driver = self:GetDriver()

	local IsSprinting = self:GetIsSprinting()

	local Vel = self:GetVelocity()

	if self.bOnGround then
		self:SetMove( self:GetMove() + self:WorldToLocal( self:GetPos() + Vel ).x * FT * (IsSprinting and 1.5 or 3) )
	end

	local Move = self:GetMove()
	
	if Move > 360 then self:SetMove( Move - 360 ) end
	if Move < -360 then self:SetMove( Move + 360 ) end

	self:SetIsMoving(math.abs(self.smSpeed or 0) > 1 and self.bOnGround)
	self:SetIsSprinting( math.abs(self.smSpeed or 0) >= 300 )

	local Move = self:GetMove()
	self.mP = math.cos( math.rad(Move * 2) ) * 10
	self.mR = math.cos( math.rad(Move) ) * 5
end

function ENT:MainGunPoser( EyeAngles )
	self.MainGunDir = EyeAngles:Forward()
	
	local startpos = self:GetRotorPos()
	local TracePlane = util.TraceHull( {
		start = startpos,
		endpos = (startpos + self.MainGunDir * 50000),
		mins = Vector( -10, -10, -10 ),
		maxs = Vector( 10, 10, 10 ),
		filter = self
	} )
	
	local AimAngles = self:WorldToLocalAngles( (TracePlane.HitPos - self:LocalToWorld( Vector(265,0,100)) ):GetNormalized():Angle() )
	
	self:SetPoseParameter("gun_pitch", AimAngles.p )
	self:SetPoseParameter("gun_yaw", AimAngles.y )

	local ID = self:LookupAttachment( "muzzle" )
	local Muzzle = self:GetAttachment( ID )
	
	self.TrEndPos = TracePlane.HitPos
	
	if Muzzle then
		local ADir = (self.TrEndPos - Muzzle.Pos):GetNormalized()
		local tAng = self:WorldToLocalAngles( (self.TrEndPos - startpos):Angle() )

		self.CanTarget = tAng.p < 30 and tAng.p > -15 and math.abs(tAng.y) < 30

		self:SetFrontInRange( self.CanTarget )
	end
end


function ENT:PrimaryAttack()
	if not self:CanPrimaryAttack() or not self.TrEndPos then return end

	local ID = self:LookupAttachment( "muzzle" )

	local Muzzle = self:GetAttachment( ID )
	
	if not Muzzle then return end

	self.charge = self.charge - 1

	self:SetNextPrimary( 0.25 )

	self:EmitSound( "LAATi_ATRT_FIRE_POP" )
	self:EmitSound( "LAATi_ATRT_FIRE" )

	local Pos = Muzzle.Pos
	local Dir = Muzzle.Ang:Up()

	if self.CanTarget then
		Dir = (self.TrEndPos -  Muzzle.Pos):GetNormalized()
	end

	local bullet = {}
	bullet.Num 	= 1
	bullet.Src 	= Pos
	bullet.Dir 	= Dir
	bullet.Spread 	= Vector( 0.015,  0.015, 0 )
	bullet.Tracer	= 1
	bullet.TracerName	= "lfs_laser_green"
	bullet.Force	= 100
	bullet.HullSize 	= 22
	bullet.Damage	= 100
	bullet.Attacker 	= self:GetDriver()
	bullet.AmmoType = "Pistol"
	bullet.Callback = function(att, tr, dmginfo)
		dmginfo:SetDamageType(DMG_AIRBOAT)
	end
	self:FireBullets( bullet )
	
	self:TakePrimaryAmmo()
end


function ENT:HandleWeapons(Fire1, Fire2)
	local Driver = self:GetDriver()
	
	local Fire1 = false
	
	if IsValid( Driver ) then
		Fire1 = Driver:KeyDown( IN_ATTACK )
	end

	self.charge = self.charge or 0
	if self.charging then
		self.charge = math.min(self.charge + FrameTime() * 15,self:GetMaxAmmoPrimary())
		self:SetAmmoPrimary( math.max( self.charge, 0 ) )
		
		if self.charge >= self:GetMaxAmmoPrimary() or not Fire1 then
			self.charging = false
			
			if self.snd_chrg then
				self.snd_chrg:Stop()
				self.snd_chrg = nil
			end
		end
	end
	
	if Fire1 ~= self.OldKeyAttack then
		self.OldKeyAttack = Fire1
		if Fire1 then
			if not self.charging then
				self:EmitSound("LAATi_ATRT_CHARGE")
				self.charging = true
			end
		end
	end
	
	local fire = Fire1 and self.charge > 0 and not self.charging
	
	if fire then
		self:PrimaryAttack()
	else
		if not self.charging then
			self.charge = math.max(self.charge - FrameTime() * 120,0)
			self:SetAmmoPrimary( math.max( self.charge, 0 ) )
		end
	end
	
	self.OldFire = self.OldFire or false
	if self.OldFire ~= fire then
		self.OldFire = fire
		if not fire then
			self:EmitSound("LAATi_ATRT_STOPCHARGE")
		end
	end
end
