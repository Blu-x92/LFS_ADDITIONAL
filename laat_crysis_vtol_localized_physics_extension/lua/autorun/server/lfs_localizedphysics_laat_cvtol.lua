LFS_LOCALPHYSICS_CLASSES = {
	["lfs_crysis_vtol"] = true,
	["lunasflightschool_laatigunship"] = true,
}

local CheckVehicle = {
}

hook.Add( "PlayerLeaveVehicle", "!!!_zz_laati_vtol_stuff", function( ply, veh )
	if ply.lfsEnterVehicleTime then
		if ply.lfsEnterVehicleTime > CurTime() then
			timer.Simple(FrameTime(), function()
				if not IsValid( veh ) or not IsValid( ply ) then return end
				ply:EnterVehicle( veh )
			end)
		end
	end
end)

hook.Add( "OnEntityCreated", "!!!_zz_laati_vtol_stuff", function( ent )
	if not IsValid( ent ) then return end

	local CLASS = ent:GetClass()

	if LFS_LOCALPHYSICS_CLASSES[ CLASS ] then

		if not GravHull then 
			print("[LFS] localphysics extension requires gravity hull designator to work")
			print("[LFS] Get (Official) Gravity Hull Designator - Localized Physics Addon:")
			print("[LFS] https://steamcommunity.com/sharedfiles/filedetails/?id=531849338")
			
			return
		end

		timer.Simple(FrameTime() * 2, 
			function()
				if not IsValid( ent ) then return end

				GravHull.RegisterHull(ent,0,100)
				GravHull.UpdateHull(ent,1, ent:GetUp())

				ent.Use = function(ent, ply )
					if not IsValid( ply ) then return end
					ply.lfsEnterVehicleTime = CurTime() + 0.1

					if ent:GetlfsLockedStatus() or (simfphys.LFS.TeamPassenger:GetBool() and ((ent:GetAITEAM() ~= ply:lfsGetAITeam()) and ply:lfsGetAITeam() ~= 0 and ent:GetAITEAM() ~= 0)) then 

						ent:EmitSound( "doors/default_locked.wav" )

						return
					end

					ent:SetPassenger( ply )
				end
				
				if CLASS:lower() == "lunasflightschool_laatigunship" then
					for _, Pod in pairs( ent:GetPassengerSeats() ) do
						if IsValid( Pod ) and Pod:GetNWInt( "pPodIndex", 0 ) > 4 then
							Pod:Remove()
						end
					end

					ent.CreateDoor = function( ent )
						if not IsValid( ent.LeftDoorPhys ) then
							local door = ents.Create( "prop_physics" )
							door:SetModel( "models/hunter/plates/plate3x3.mdl" )
							door:SetPos( ent:LocalToWorld( Vector(-40,70,90) ) )
							door:SetAngles( ent:LocalToWorldAngles( Angle(0,-5,115) ) )
							door:Spawn()
							door:Activate()
							door:SetNoDraw( true ) 
							ent:DeleteOnRemove( door )
							local weld = constraint.Weld( door, ent, 0, 0, 0, true, false )
							
							ent.LeftDoorPhys = door
							ent:dOwner( door )
						end
						
						if not IsValid( ent.RightDoorPhys ) then
							local door = ents.Create( "prop_physics" )
							door:SetModel( "models/hunter/plates/plate3x3.mdl" )
							door:SetPos( ent:LocalToWorld( Vector(-40,-70,90) ) )
							door:SetAngles( ent:LocalToWorldAngles( Angle(0,5,65) ) )
							door:Spawn()
							door:Activate()
							door:SetNoDraw( true ) 
							ent:DeleteOnRemove( door )
							local weld = constraint.Weld( door, ent, 0, 0, 0, true, false )
							
							ent.RightDoorPhys = door
							ent:dOwner( door )
						end
						
						GravHull.RegisterHull(ent,0,100)
						GravHull.UpdateHull(ent,1, ent:GetUp())
					end

					ent.CreateRearDoor = function( ent )
						if IsValid( ent.RearDoorPhys ) then return end
						
						local door = ents.Create( "prop_physics" )
						door:SetModel( "models/hunter/plates/plate2x4.mdl" )
						door:SetPos( ent:LocalToWorld( Vector(-270,0,55) ) )
						door:SetAngles( ent:LocalToWorldAngles( Angle(0,90,25) ) )
						door:Spawn()
						door:Activate()
						door:SetNoDraw( true ) 
						ent:DeleteOnRemove( door )
						local weld = constraint.Weld( door, ent, 0, 0, 0, true, false )

						ent.RearDoorPhys = door
						ent:dOwner( door )
						
						GravHull.RegisterHull(ent,0,100)
						GravHull.UpdateHull(ent,1, ent:GetUp())
					end

					table.insert(CheckVehicle, ent)
				end

				if CLASS:lower() == "lfs_crysis_vtol" then
					ent.CreateRearDoor = function( ent )
						if IsValid( ent.RearDoorPhys ) then return end
						
						local door = ents.Create( "prop_physics" )
						door:SetModel( "models/hunter/plates/plate2x2.mdl" )
						door:SetPos( ent:LocalToWorld( Vector(-210,0,-10) ) )
						door:SetAngles( ent:LocalToWorldAngles( Angle(70,0,0) ) )
						door:Spawn()
						door:Activate()
						door:SetNoDraw( true ) 
						ent:DeleteOnRemove( door )
						local weld = constraint.Weld( door, ent, 0, 0, 0, true, false )

						ent.RearDoorPhys = door
						ent:dOwner( door )
						
						GravHull.RegisterHull(ent,0,100)
						GravHull.UpdateHull(ent,1, ent:GetUp())
					end

					table.insert(CheckVehicle, ent)
				end
			end
		)
	end
end )

hook.Add( "Think", "!!!zzzlfs_laati_cvtol_physdoors", function()
	for k, v in pairs( CheckVehicle ) do
		if IsValid( v ) then
			local CLASS = v:GetClass():lower()
			
			if CLASS:lower() == "lfs_crysis_vtol" then
				local RearDoor = v:GetForceOpenDoor()
				if IsValid( v.RearDoorPhys ) then
					if RearDoor then
						v.RearDoorPhys:Remove()
					end
				else
					if not RearDoor and not IsValid( v.RearDoorPhys ) then
						if v.CreateRearDoor then
							v:CreateRearDoor()
						end
					end
				end
			end
			
			if CLASS:lower() == "lunasflightschool_laatigunship" then
				local RearDoor = v:GetRearHatch()
				if IsValid( v.RearDoorPhys ) then
					if RearDoor then
						v.RearDoorPhys:Remove()
					end
				else
					if not RearDoor and not IsValid( v.RearDoorPhys ) then
						if v.CreateRearDoor then
							v:CreateRearDoor()
						end
					end
				end
				
				if v:GetBodygroup( 2 ) == 0 then
					local Door = v:GetDoorMode() ~= 0
					
					if IsValid( v.LeftDoorPhys ) then
						if Door then
							v.LeftDoorPhys:Remove()

							if IsValid( v.RightDoorPhys ) then
								v.RightDoorPhys:Remove()
							end
						end
					else
						if not Door and (not IsValid( v.RightDoorPhys ) or not  IsValid( v.LeftDoorPhys )) then
							if v.CreateDoor then
								v:CreateDoor()
							end
						end
					end
				else
					if IsValid( v.LeftDoorPhys ) then
						v.LeftDoorPhys:Remove()
					end

					if IsValid( v.RightDoorPhys ) then
						v.RightDoorPhys:Remove()
					end
				end
			end
		else
			CheckVehicle[k] = nil
		end
	end
end )