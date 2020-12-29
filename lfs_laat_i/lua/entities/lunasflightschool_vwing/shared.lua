--DO NOT EDIT OR REUPLOAD THIS FILE

ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript" )

ENT.PrintName = "V-Wing"
ENT.Author = "Luna"
ENT.Information = "Starfighter of the Galactic Republic"
ENT.Category = "[LFS] - Star Wars Pack"

ENT.Spawnable		= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/blu/vwing.mdl"

ENT.AITEAM = 2

ENT.Mass = 2000
ENT.Inertia = Vector(150000,150000,150000)
ENT.Drag = -1

ENT.HideDriver = true
ENT.SeatPos = Vector(-28,0,50)
ENT.SeatAng = Angle(0,-90,0)

ENT.IdleRPM = 1
ENT.MaxRPM = 2800
ENT.LimitRPM = 3000

ENT.RotorPos = Vector(100,0.05,60)
ENT.WingPos = Vector(0,0,80)
ENT.ElevatorPos = Vector(-300,0,60)
ENT.RudderPos = Vector(-300,0,60)

ENT.MaxVelocity = 2150

ENT.MaxThrust = 20000

ENT.MaxTurnPitch = 700
ENT.MaxTurnYaw = 700
ENT.MaxTurnRoll = 400

ENT.MaxPerfVelocity = 1500

ENT.MaxHealth = 300
ENT.MaxShield = 100

ENT.Stability = 0.7

ENT.VerticalTakeoff = true
ENT.VtolAllowInputBelowThrottle = 10
ENT.MaxThrustVtol = 10000

ENT.MaxPrimaryAmmo = 3000
ENT.MaxSecondaryAmmo = -1

sound.Add( {
	name = "VWING_FIRE1",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 125,
	pitch = {95, 105},
	sound = "lfs/vwing/fire.mp3"
} )

sound.Add( {
	name = "VWING_FIRE2",
	channel = CHAN_ITEM,
	volume = 1.0,
	level = 125,
	pitch = {95, 105},
	sound = "lfs/vwing/fire.mp3"
} )

sound.Add( {
	name = "VWING_ENGINE",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 100,
	sound = "lfs/vwing/loop.wav"
} )

sound.Add( {
	name = "VWING_FOILS",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "lfs/vwing/sfoils.wav"
} )
