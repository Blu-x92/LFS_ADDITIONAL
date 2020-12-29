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

ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript_gunship" )

ENT.PrintName = "AAT"
ENT.Author = "Luna"
ENT.Information = "Trade Federation Hover Tank. Later used in the Droid army of the Separatists"
ENT.Category = "[LFS] - Star Wars Pack"

ENT.Spawnable		= true
ENT.AdminSpawnable	= false

ENT.MDL = "models/blu/aat.mdl"

ENT.MaxPrimaryAmmo = 450
ENT.MaxSecondaryAmmo = 42

ENT.AITEAM = 1

ENT.Mass = 2500

ENT.HideDriver = true
ENT.SeatPos = Vector(20,0,80)
ENT.SeatAng = Angle(0,-90,0)

ENT.MaxHealth = 2700

ENT.MaxTurnPitch = 1000
ENT.MaxTurnYaw = 80
ENT.MaxTurnRoll = 1000

ENT.PitchDamping = 1
ENT.YawDamping = 1.5
ENT.RollDamping = 1

ENT.TurnForcePitch = 25
ENT.TurnForceYaw = 800
ENT.TurnForceRoll = 25

ENT.RotorPos = Vector(70,0,43)

ENT.IdleRPM = 0
ENT.MaxRPM = 100
ENT.LimitRPM = 100
ENT.RPMThrottleIncrement = 250

ENT.MaxVelocity = 400
ENT.BoostVelAdd = 100
ENT.ThrustMul = 5
ENT.DampingMul = 1

ENT.DontPushMePlease = true

ENT.LAATC_PICKUPABLE = true
ENT.LAATC_PICKUP_POS = Vector(-260,0,0)
ENT.LAATC_PICKUP_Angle = Angle(0,0,0)

ENT.MaintenanceTime = 20
ENT.MaintenanceRepairAmount = 750

function ENT:AddDataTables()
	self:NetworkVar( "Bool",20, "IsCarried" )
	self:NetworkVar( "Bool",21, "WeaponOutOfRange" )
	self:NetworkVar( "Float",21, "TurretHeat" )

	if SERVER then
		self:NetworkVarNotify( "IsCarried", self.OnIsCarried )
	end
end


sound.Add( {
	name = "lfsAAT_FIRE",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 125,
	pitch = {103, 105},
	sound = "lfs/aat/fire.mp3"
} )

sound.Add( {
	name = "lfsAAT_FIREMISSILE",
	channel = CHAN_VOICE,
	volume = 1.0,
	level = 125,
	pitch = {95, 105},
	sound = "lfs/aat/fire_missile.mp3"
} )


sound.Add( {
	name = "lfsAAT_FIRECANNON",
	channel = CHAN_ITEM,
	volume = 1.0,
	level = 125,
	pitch = {95, 105},
	sound = "lfs/aat/fire_turret.mp3"
} )

sound.Add( {
	name = "lfsAAT_ENGINE",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 90,
	sound = "lfs/aat/loop.wav"
} )

sound.Add( {
	name = "lfsAAT_ENGINE_HI",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 90,
	sound = "lfs/aat/loop_HI.wav"
} )


sound.Add( {
	name = "lfsAAT_DIST",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 110,
	sound = "^lfs/aat/dist.wav"
} )

sound.Add( {
	name = "lfsAAT_EXPLOSION",
	channel = CHAN_STATIC,
	volume = 0.5,
	level = 100,
	pitch = 125,
	sound = {"lfs/plane_preexp1.ogg","lfs/plane_preexp2.ogg","lfs/plane_preexp3.ogg"}
} )
