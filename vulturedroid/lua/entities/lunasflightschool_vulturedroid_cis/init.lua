--DO NOT EDIT OR REUPLOAD THIS FILE

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:SpawnFunction( ply, tr, ClassName )

	if not tr.Hit then return end

	local ent = ents.Create( ClassName )
	ent.dOwnerEntLFS = ply
	ent:SetPos( tr.HitPos + tr.HitNormal * 70 )
	ent:Spawn()
	ent:Activate()

	return ent

end

function ENT:RunOnSpawn()
	if not self:GetEngineActive() then
		self:PlayAnimation( "landing" )
	end
end

function ENT:PrimaryAttack()
	if not self:CanPrimaryAttack() or not self:GetEngineActive() then return end

	self:EmitSound( "VULTURE_FIRE" )
	
	self:SetNextPrimary( 0.08 )
	
	local fP = { Vector(27.95,108.99,115.03), Vector(29.15,-110.55,103.67), Vector(29.15,110.55,103.67),Vector(27.95,-108.99,115.03) }

	self.NumPrim = self.NumPrim and self.NumPrim + 1 or 1
	if self.NumPrim > 4 then self.NumPrim = 1 end
	
	local startpos =  self:GetRotorPos()
	local TracePlane = util.TraceHull( {
		start = startpos,
		endpos = (startpos + self:GetForward() * 50000),
		mins = Vector( -10, -10, -10 ),
		maxs = Vector( 10, 10, 10 ),
		filter = self
	} )
	
	local bullet = {}
	bullet.Num 	= 1
	bullet.Src 	= self:LocalToWorld( fP[self.NumPrim] )
	bullet.Dir 	= (TracePlane.HitPos - bullet.Src):GetNormalized()
	bullet.Spread 	= Vector( 0.02,  0.02, 0 )
	bullet.Tracer	= 1
	bullet.TracerName	= "lfs_laser_red"
	bullet.Force	= 100
	bullet.HullSize 	= 40
	bullet.Damage	= 25
	bullet.Attacker 	= self:GetDriver()
	bullet.AmmoType = "Pistol"
	bullet.Callback = function(att, tr, dmginfo)
		dmginfo:SetDamageType(DMG_AIRBOAT)
	end
	self:FireBullets( bullet )
	
	self:TakePrimaryAmmo()
end

function ENT:SecondaryAttack()
	if not self:CanPrimaryAttack() or not self:GetEngineActive() then return end
	
	self:SetNextPrimary( 0.16 )

	self:EmitSound( "VULTURE_ALTFIRE" )
	
	local startpos =  self:GetRotorPos()
	local TracePlane = util.TraceHull( {
		start = startpos,
		endpos = (startpos + self:GetForward() * 50000),
		mins = Vector( -10, -10, -10 ),
		maxs = Vector( 10, 10, 10 ),
		filter = function( e )
			local collide = e ~= self
			return collide
		end
	} )

	for i = 1, 2 do
		self.MirrorSec = not self.MirrorSec
		local Mirror = false
		for i = 0,1 do
			local M = Mirror and 1 or -1
			local Pos = Vector(29.15,110.55 * M,104 + (self.MirrorSec and 12 or 0))
			
			local bullet = {}
			bullet.Num 	= 1
			bullet.Src 	= self:LocalToWorld( Pos )
			bullet.Dir 	= (TracePlane.HitPos - bullet.Src):GetNormalized()
			bullet.Spread 	= Vector( 0.01,  0.01, 0 )
			bullet.Tracer	= 1
			bullet.TracerName	= "lfs_laser_red"
			bullet.Force	= 100
			bullet.HullSize 	= 40
			bullet.Damage	= 12.5
			bullet.Attacker 	= self:GetDriver()
			bullet.AmmoType = "Pistol"
			bullet.Callback = function(att, tr, dmginfo)
				dmginfo:SetDamageType(DMG_AIRBOAT)
			end
			self:FireBullets( bullet )
			self:TakePrimaryAmmo()
			Mirror = true
		end
	end
end

function ENT:OnKeyThrottle( bPressed )
	if bPressed then
		if self:CanSound() then
			self:EmitSound( "VULTURE_BOOST" )
			self:DelayNextSound( 1 )
		end
	else
		if (self:GetRPM() + 1) > self:GetMaxRPM() then
			if self:CanSound() then
				self:EmitSound( "VULTURE_BRAKE" )
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
			Fire2 = Driver:KeyDown( IN_ATTACK2 )
		end
	end
	
	if Fire1 then
		self:PrimaryAttack()
	end
	
	if Fire2 then
		self:SecondaryAttack()
	end
end

function ENT:StartEngine()
	if self:GetEngineActive() or self:IsDestroyed() or not self:IsEngineStartAllowed() then return end
	self:PlayAnimation( "takeoff" )
	
	self:SetEngineActive( true )
end

function ENT:StopEngine()
	if not self:GetEngineActive() then return end
	
	if not self:IsDestroyed() then
		self:PlayAnimation( "landing" )
	end
	
	self:SetEngineActive( false )
end
