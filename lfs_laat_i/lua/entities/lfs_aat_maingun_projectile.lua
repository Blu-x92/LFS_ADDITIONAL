--DO NOT EDIT OR REUPLOAD THIS FILE

AddCSLuaFile()

ENT.Type            = "anim"

function ENT:SetupDataTables()
	self:NetworkVar( "Entity",0, "Attacker" )
	self:NetworkVar( "Entity",1, "Inflictor" )
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
			pObj:SetVelocityInstantaneous( self:GetForward() * 4000 )
		end

		local Vel = self:GetVelocity()

		local trace = util.TraceHull( {
			start = self:GetPos(),
			endpos = self:GetPos() + Vel:GetNormalized() * (Vel:Length() * FrameTime() + 25),
			mins = Vector(-5,-5,-5),
			maxs = Vector(5,5,5),
			filter = {self,self:GetInflictor()}
		} )

		if trace.Hit then
			self:SetPos( trace.HitPos )
			self:ProjDetonate()
			self:LFSDamage( trace.Entity )
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
			dmginfo:SetDamage( 250 )
			dmginfo:SetAttacker( IsValid( self:GetAttacker() ) and self:GetAttacker() or self )
			dmginfo:SetDamageType( DMG_DIRECT )
			dmginfo:SetInflictor( self ) 
			dmginfo:SetDamagePosition( Pos ) 
		HitEnt:TakeDamageInfo( dmginfo )

		sound.Play( "Missile.ShotDown", Pos, 140)
	end

	function ENT:Initialize()	
		self:SetModel( "models/weapons/w_missile_launch.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetRenderMode( RENDERMODE_TRANSALPHA )
		self:PhysWake()
		self:SetCollisionGroup( COLLISION_GROUP_WORLD )

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
		util.BlastDamage( IsValid( Inflictor ) and Inflictor or Entity(0), IsValid( Attacker ) and Attacker or Entity(0), self:GetPos(),100,400)

		local effectdata = EffectData()
			effectdata:SetOrigin( self:GetPos() )
		util.Effect( "lfs_aat_laser_explosion", effectdata )

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

	function ENT:PhysicsCollide( data )
		self.Explode = true
	end

	function ENT:OnTakeDamage( dmginfo )	
	end
else
	function ENT:Initialize()	
	end

	local mat = Material( "sprites/light_glow02_add" )
	local mat_laser = Material( "effects/spark" )

	function ENT:Draw()
		local pos = self:GetPos()
		local dir = self:GetForward()
		local length = 100

		render.SetMaterial( mat_laser )
		render.DrawBeam( pos + dir * length, pos, 40, 1, 0, Color(255,0,0,255) )
		render.DrawBeam( pos + dir * length, pos, 15, 1, 0, Color(255,255,255,255) )

		render.SetMaterial( mat )
		render.DrawSprite( pos + dir * length * 0.3, 100, 100, Color( 255, 0, 0, 255 ) )
		render.DrawSprite( pos + dir * length * 0.45, 100, 100, Color( 255, 0, 0, 255 ) )
		render.DrawSprite( pos + dir * length * 0.6, 100, 100, Color( 255, 0, 0, 255 ) )
		render.DrawSprite( pos + dir * length * 0.75, 100, 100, Color( 255, 0, 0, 255 ) )
		render.DrawSprite( pos + dir * length * 0.9, 100, 100, Color( 255, 0, 0, 255 ) )
	end

	function ENT:Think()
	end

	function ENT:OnRemove()
	end
end