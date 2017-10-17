mobs:register_mob("mob_mecha:mecha", {
	type = "monster",
	passive = false,
	reach = 1,
	damage = 2,
	attack_type = "shoot",
	hp_min = 72,
	hp_max = 102,
	armor = 100,
   shoot_interval = 1.5,
   arrow = "mob_mecha:glaser",
   shoot_offset = 0,
	collisionbox = {-0.6, 0, -0.6, 0.6, 3.5, 0.6},
   sounds = {
      shoot_attack = "Laser",
   },
	visual = "mesh",
	mesh = "assaultsuit.b3d",
	textures = {
		{"scifi_assaultsuit.png"},
	},
	visual_size = {x=1, y=1},
	makes_footstep_sound = true,
	walk_velocity = 2,
	run_velocity = 3,
	jump = true,
    
    runaway = true,
    fly = true,
    walk_chance = 0,

	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
	view_range = 14,
	animation = {
		speed_normal = 10,
		speed_run = 12,
		walk_start = 120,
		walk_end = 140,
		stand_start = 80,
		stand_end = 110,
		run_start = 120,
		run_end = 140,
		shoot_start = 40,
		shoot_end = 51,

	},


	do_custom = function(self, dtime)

		-- set needed values if not already present
		if not self.v2 then
			self.v2 = 0
			self.max_speed_forward = 6
			self.max_speed_reverse = 2
			self.accel = 6
			self.terrain_type = 3
			-- self.driver_attach_at = {x = 0, y = 20, z = -2}
            self.driver_attach_at = {x = 0, y = 40, z = 5}
			--self.driver_eye_offset = {x = 0, y = 3, z = 0}
            self.driver_eye_offset = {x = 0, y = 20, z = 7}
		end

		-- if driver present allow control of horse
		if self.driver then

			mobs.drive(self, "walk", "stand", false, dtime)

			return false -- skip rest of mob functions
		end

		return true
	end,

	on_die = function(self, pos)

		-- drop saddle when horse is killed while riding
		-- also detach from horse properly
		if self.driver then
			minetest.add_item(pos, "mobs:saddle")
			mobs.detach(self.driver, {x = 1, y = 0, z = 1})
		end

	end,

	on_rightclick = function(self, clicker)

        mobs:capture_mob(self, clicker, 0, 0, 0, true, nil)

		-- make sure player is clicking
		if not clicker or not clicker:is_player() then
			return
		end

		-- feed, tame or heal horse
		--if mobs:feed_tame(self, clicker, 10, true, true) then
		--	return
		--end

			local inv = clicker:get_inventory()

			-- detatch player already riding horse
			if self.driver and clicker == self.driver then

				mobs.detach(clicker, {x = 1, y = 0, z = 1})

				-- add saddle back to inventory
				if inv:room_for_item("main", "mobs:saddle") then
					inv:add_item("main", "mobs:saddle")
				else
					minetest.add_item(clicker.getpos(), "mobs:saddle")
				end

			-- attach player to horse
			elseif not self.driver
			and clicker:get_wielded_item():get_name() == "mobs:saddle" then

				self.object:set_properties({stepheight = 1.1})
				mobs.attach(self, clicker)

				-- take saddle from inventory
				inv:remove_item("main", "mobs:saddle")
			end

		-- used to capture horse with magic lasso
		mobs:capture_mob(self, clicker, 0, 0, 80, false, nil)
	end


})

mobs:register_spawn("mob_mecha:mecha", {"default:stone","default:dirt_with_grass"}, 20, 10, 15000, 2, 31000)

mobs:register_egg("mob_mecha:mecha", "Assault Suit", "scifi_assaultsuit_inv.png", 0)

mobs:register_arrow("mob_mecha:glaser", {
   visual = "sprite",
   visual_size = {x = 0.5, y = 0.5},
   textures = {"scifi_mobs_glaser.png"},
   velocity = 18,
   tail = 1, -- enable tail
   tail_texture = "scifi_mobs_glaser.png",

   hit_player = function(self, player)
      player:punch(self.object, 1.0, {
         full_punch_interval = 1.0,
         damage_groups = {fleshy = 8},
      }, nil)
   end,
   
   hit_mob = function(self, player)
      player:punch(self.object, 1.0, {
         full_punch_interval = 1.0,
         damage_groups = {fleshy = 8},
      }, nil)
   end,

   hit_node = function(self, pos, node)
      mobs:explosion(pos, 1, 1, 1)
   end,
})

