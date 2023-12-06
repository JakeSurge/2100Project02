--Enable extensions to add specific index type
CREATE EXTENSION pg_trgm;
CREATE EXTENSION btree_gin;

--Create indexes to increase read speed
CREATE INDEX item_id ON public.items using GIN (item_id)
CREATE INDEX item_name ON public.items USING GIN (item_name);
CREATE INDEX attack ON public.items (attack_damage) INCLUDE(attack_speed);

--Views for easily accessible defaults views of information from the database
--Main Items Table View
CREATE MATERIALIZED VIEW public.default AS
	SELECT items.*, survival_obtainable.survival_obtainable FROM items, survival_obtainable
		WHERE items.item_id = survival_obtainable.item_id
		ORDER BY items.item_id ASC;
--Breaking Speeds View
CREATE MATERIALIZED VIEW public.breaking_speeds_view AS
	SELECT items.item_id, items.item_name, breaking_types.breaking_type_name, breaking_speeds.breaking_speed FROM items, breaking_types, breaking_speeds
		WHERE items.item_id = breaking_speeds.item_id
		AND breaking_types.breaking_type_id = breaking_speeds.breaking_type_id
		ORDER BY items.item_id ASC;
--Food Effects View
CREATE MATERIALIZED VIEW public.food_effects_view AS
	SELECT items.item_id, items.item_name, effects.effect_name, food_effects.effect_degree, food_effects.time, food_effects.chance FROM items, effects, food_effects
		WHERE items.item_id = food_effects.item_id
		AND effects.effect_id = food_effects.effect_id
		ORDER BY items.item_id ASC;
--Smelting Obtainable View
CREATE MATERIALIZED VIEW public.smelting_obtainable_view AS
	SELECT items.item_id, items.item_name, smelting_methods.smelting_method_name FROM items, smelting_methods, smelting_obtainable
		WHERE items.item_id = smelting_obtainable.item_id
		AND smelting_methods.smelting_method_id = smelting_obtainable.smelting_method_id
		ORDER BY items.item_id ASC;
--Smeltable Items View
CREATE MATERIALIZED VIEW public.smeltable_items_view AS
	SELECT items.item_id, items.item_name, smeltable_items.smelting_xp, smelting_methods.smelting_method_name FROM items, smelting_methods, smeltable_items
		WHERE items.item_id = smeltable_items.item_id
		AND smelting_methods.smelting_method_id = smeltable_items.smelting_method_id
		ORDER BY items.item_id ASC;
--Fuel Duration View
CREATE MATERIALIZED VIEW public.fuel_duration_view AS
	Select items.item_id, items.item_name, fuel_duration.fuel_duration FROM items, fuel_duration
		WHERE items.item_id = fuel_duration.item_id
		ORDER BY items.item_id ASC;
--Food Items View
CREATE MATERIALIZED VIEW public.food_items_view AS
	Select items.item_id, items.item_name, food_items.hunger, food_items.saturation FROM items, food_items
		WHERE items.item_id = food_items.item_id
		ORDER BY items.item_id ASC;
--Cooldown View
CREATE MATERIALIZED VIEW public.cooldown_view AS
	Select items.item_id, items.item_name, cooldown.cooldown FROM items, cooldown
		WHERE items.item_id = cooldown.item_id
		ORDER BY items.item_id ASC;