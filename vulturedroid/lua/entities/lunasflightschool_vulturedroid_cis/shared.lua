--DO NOT EDIT OR REUPLOAD THIS FILE

ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript" )

ENT.PrintName = "Vulture Droid (CIS)"
ENT.Author = "Blu"
ENT.Information = ""
ENT.Category = "[LFS]"

ENT.Spawnable		= true
ENT.AdminSpawnable		= false

ENT.LFS = true

ENT.MDL = "models/blu/vulturedroid.mdl"

ENT.AITEAM = 1

ENT.Mass = 2000
ENT.Inertia = Vector(150000,150000,150000)
ENT.Drag = -1

ENT.HideDriver = true
ENT.SeatPos = Vector(-30,0,113)
ENT.SeatAng = Angle(0,-90,0)

ENT.IdleRPM = 1
ENT.MaxRPM = 2800
ENT.LimitRPM = 3000

ENT.RotorPos = Vector(40,0,115)
ENT.WingPos = Vector(100,0,115)
ENT.ElevatorPos = Vector(-300,0,135)
ENT.RudderPos = Vector(-300,0,135)

ENT.MaxVelocity = 2150

ENT.MaxThrust = 20000

ENT.MaxTurnPitch = 1200
ENT.MaxTurnYaw = 1500
ENT.MaxTurnRoll = 700

ENT.MaxPerfVelocity = 1500

ENT.MaxHealth = 450

ENT.Stability = 0.7

ENT.VerticalTakeoff = true
ENT.VtolAllowInputBelowThrottle = 10
ENT.MaxThrustVtol = 10000

ENT.MaxPrimaryAmmo = 1600
ENT.MaxSecondaryAmmo = -1

sound.Add( {
	name = "VULTURE_FIRE",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 125,
	pitch = {95, 105},
	sound = "lfs/vulturedroid/fire.wav"
} )

sound.Add( {
	name = "VULTURE_ALTFIRE",
	channel = CHAN_ITEM,
	volume = 1.0,
	level = 125,
	pitch = {95, 105},
	sound = "lfs/vulturedroid/fire.mp3"
} )

sound.Add( {
	name = "VULTURE_ENGINE",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^lfs/vulturedroid/loop.wav"
} )

sound.Add( {
	name = "VULTURE_DIST",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^lfs/vulturedroid/dist.wav"
} )

sound.Add( {
	name = "VULTURE_BOOST",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "lfs/vulturedroid/boost.wav"
} )

sound.Add( {
	name = "VULTURE_BRAKE",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "lfs/vulturedroid/brake.wav"
} )