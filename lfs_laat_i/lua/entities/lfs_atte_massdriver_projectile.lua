--DO NOT EDIT OR REUPLOAD THIS FILE

AddCSLuaFile()

ENT.Type            = "anim"

function ENT:SetupDataTables()
	self:NetworkVar( "Entity",0, "Attacker" )
	self:NetworkVar( "Entity",1, "Inflictor" )
	self:NetworkVar( "Entity",2, "RearEnt" )
end

if SERVER then
	function ENT:SpawnFunction( ply, tr, ClassName )

		if not tr.Hit then return end

		local ent = ents.Create( ClassName )
		ent:SetPos( tr.HitPos + tr.HitNormal * 20 )
		ent:Spawn()
		ent:Activate()

		return ent

	end

	function ENT:BlindFire()
		local pObj = self:GetPhysicsObject()
		
		if IsValid( pObj ) then
			pObj:SetVelocityInstantaneous( self:GetForward() * 6000 )
		end

		local Vel = self:GetVelocity()

		local trace = util.TraceHull( {
			start = self:GetPos(),
			endpos = self:GetPos() + Vel:GetNormalized() * (Vel:Length() * FrameTime() + 25),
			mins = Vector(-5,-5,-5),
			maxs = Vector(5,5,5),
			filter = {self,self:GetInflictor(), self:GetRearEnt()}
		} )

		if trace.Hit then
			self:SetPos( trace.HitPos )
			self:ProjDetonate()
			self:simfphysDamage( trace.Entity )
			self:LFSDamage( trace.Entity )
		end
	end

	function ENT:Initialize()	
		self:SetModel( "models/weapons/w_missile_launch.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetRenderMode( RENDERMODE_TRANSALPHA )
		self:PhysWake()
		
		local pObj = self:GetPhysicsObject()
		
		if IsValid( pObj ) then
			pObj:EnableGravity( false ) 
			pObj:SetMass( 1 ) 
		end
		
		self.SpawnTime = CurTime()
	end

	function ENT:ProjDetonate()
		local Inflictor = self:GetInflictor()
		local Attacker = self:GetAttacker()
		util.BlastDamage( IsValid( Inflictor ) and Inflictor or Entity(0), IsValid( Attacker ) and Attacker or Entity(0), self:GetPos(),200,600)

		local effectdata = EffectData()
			effectdata:SetOrigin( self:GetPos() )
		util.Effect( "laatc_atte_massdriver_explosion", effectdata )

		self:Remove()
	end

	function ENT:Think()	
		local curtime = CurTime()
		self:NextThink( curtime )

		self:BlindFire()

		if self.Explode then
			self:ProjDetonate()
		end
		
		if (self.SpawnTime + 12) < curtime then
			self:Remove()
		end
		
		return true
	end

	local IsThisSimfphys = {
		["gmod_sent_vehicle_fphysics_base"] = true,
		["gmod_sent_vehicle_fphysics_wheel"] = true,
	}

	function ENT:simfphysDamage( HitEnt )
		if not IsValid( HitEnt ) then return end

		local Class = HitEnt:GetClass():lower()

		if IsThisSimfphys[ Class ] then
			local Pos = self:GetPos()
			
			if Class == "gmod_sent_vehicle_fphysics_wheel" then
				HitEnt = HitEnt:GetBaseEnt()
			end

			local effectdata = EffectData()
				effectdata:SetOrigin( Pos )
				effectdata:SetNormal( -self:GetForward() )
			util.Effect( "manhacksparks", effectdata, true, true )

			local dmginfo = DamageInfo()
				dmginfo:SetDamage( 1000 )
				dmginfo:SetAttacker( IsValid( self:GetAttacker() ) and self:GetAttacker() or self )
				dmginfo:SetDamageType( DMG_DIRECT )
				dmginfo:SetInflictor( self ) 
				dmginfo:SetDamagePosition( Pos ) 
			HitEnt:TakeDamageInfo( dmginfo )
			
			sound.Play( "Missile.ShotDown", Pos, 140)
		end
	end

	function ENT:LFSDamage( HitEnt )
		if not IsValid( HitEnt ) then return end

		if not HitEnt.LFS and not HitEnt.IdentifiesAsLFS then return end

		local Pos = self:GetPos()

		local effectdata = EffectData()
			effectdata:SetOrigin( Pos )
			effectdata:SetNormal( -self:GetForward() )
		util.Effect( "manhacksparks", effectdata, true, true )

		local dmginfo = DamageInfo()
			dmginfo:SetDamage( 500 )
			dmginfo:SetAttacker( IsValid( self:GetAttacker() ) and self:GetAttacker() or self )
			dmginfo:SetDamageType( DMG_DIRECT )
			dmginfo:SetInflictor( self ) 
			dmginfo:SetDamagePosition( Pos ) 
		HitEnt:TakeDamageInfo( dmginfo )

		sound.Play( "Missile.ShotDown", Pos, 140)
	end

	function ENT:PhysicsCollide( data )
		self.Explode = true
	end

	function ENT:OnTakeDamage( dmginfo )	
	end
else
	function ENT:Initialize()	
	end

	local mat = Material( "sprites/light_glow02_add" )
	function ENT:Draw()
		self:DrawModel()

		local pos = self:GetPos()


		local r = 0
		local g = 127
		local b = 255
		
		render.SetMaterial( mat )

		for i =0,10 do
			local Size = (16 - i) * 16 + math.random(-5,5)
			render.DrawSprite( pos - self:GetForward() * i * 10 + VectorRand(), Size, Size, Color( r, g, b, 255 ) )
		end

		render.DrawSprite( pos, 128, 128, Color( r, g, b, 255 ) )
	end

	function ENT:Think()
	end

	function ENT:OnRemove()
	end
end