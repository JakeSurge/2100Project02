--
-- PostgreSQL database dump
--

-- Dumped from database version 15.4
-- Dumped by pg_dump version 15.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: btree_gin; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gin WITH SCHEMA public;


--
-- Name: EXTENSION btree_gin; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION btree_gin IS 'support for indexing common datatypes in GIN';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: breaking_speeds; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.breaking_speeds (
    item_id character varying(100) NOT NULL,
    breaking_type_id integer NOT NULL,
    breaking_speed double precision NOT NULL
);


ALTER TABLE public.breaking_speeds OWNER TO postgres;

--
-- Name: breaking_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.breaking_types (
    breaking_type_id integer NOT NULL,
    breaking_type_name character varying(25) NOT NULL
);


ALTER TABLE public.breaking_types OWNER TO postgres;

--
-- Name: items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.items (
    item_id character varying(100) NOT NULL,
    item_name character varying(100) NOT NULL,
    stackability smallint NOT NULL,
    attack_speed double precision NOT NULL,
    attack_damage double precision NOT NULL,
    peaceful_obtainable boolean NOT NULL,
    renewable boolean NOT NULL
);


ALTER TABLE public.items OWNER TO postgres;

--
-- Name: breaking_speeds_view; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.breaking_speeds_view AS
 SELECT items.item_id,
    items.item_name,
    breaking_types.breaking_type_name,
    breaking_speeds.breaking_speed
   FROM public.items,
    public.breaking_types,
    public.breaking_speeds
  WHERE (((items.item_id)::text = (breaking_speeds.item_id)::text) AND (breaking_types.breaking_type_id = breaking_speeds.breaking_type_id))
  ORDER BY items.item_id
  WITH NO DATA;


ALTER TABLE public.breaking_speeds_view OWNER TO postgres;

--
-- Name: breaking_types_breakin_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.breaking_types_breakin_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.breaking_types_breakin_type_id_seq OWNER TO postgres;

--
-- Name: breaking_types_breakin_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.breaking_types_breakin_type_id_seq OWNED BY public.breaking_types.breaking_type_id;


--
-- Name: cooldown; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cooldown (
    item_id character varying(100) NOT NULL,
    cooldown double precision NOT NULL
);


ALTER TABLE public.cooldown OWNER TO postgres;

--
-- Name: cooldown_view; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.cooldown_view AS
 SELECT items.item_id,
    items.item_name,
    cooldown.cooldown
   FROM public.items,
    public.cooldown
  WHERE ((items.item_id)::text = (cooldown.item_id)::text)
  ORDER BY items.item_id
  WITH NO DATA;


ALTER TABLE public.cooldown_view OWNER TO postgres;

--
-- Name: damage_per_second; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.damage_per_second AS
 SELECT items.item_id,
    round(((items.attack_damage * items.attack_speed))::numeric, 2) AS damage_per_second
   FROM public.items
  WITH NO DATA;


ALTER TABLE public.damage_per_second OWNER TO postgres;

--
-- Name: survival_obtainable; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.survival_obtainable (
    item_id character varying(100) NOT NULL,
    survival_obtainable boolean NOT NULL
);


ALTER TABLE public.survival_obtainable OWNER TO postgres;

--
-- Name: default; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public."default" AS
 SELECT i.item_id,
    i.item_name,
    i.stackability,
    i.attack_speed,
    i.attack_damage,
    dps.damage_per_second,
    i.peaceful_obtainable,
    i.renewable,
    surv.survival_obtainable
   FROM public.items i,
    public.survival_obtainable surv,
    public.damage_per_second dps
  WHERE (((i.item_id)::text = (surv.item_id)::text) AND ((i.item_id)::text = (dps.item_id)::text))
  ORDER BY i.item_id
  WITH NO DATA;


ALTER TABLE public."default" OWNER TO postgres;

--
-- Name: effects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.effects (
    effect_id integer NOT NULL,
    effect_name character varying(50) NOT NULL
);


ALTER TABLE public.effects OWNER TO postgres;

--
-- Name: effects_effect_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.effects_effect_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.effects_effect_id_seq OWNER TO postgres;

--
-- Name: effects_effect_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.effects_effect_id_seq OWNED BY public.effects.effect_id;


--
-- Name: food_effects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.food_effects (
    item_id character varying(100) NOT NULL,
    effect_id smallint NOT NULL,
    effect_degree smallint NOT NULL,
    "time" smallint NOT NULL,
    chance double precision NOT NULL
);


ALTER TABLE public.food_effects OWNER TO postgres;

--
-- Name: food_effects_view; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.food_effects_view AS
 SELECT items.item_id,
    items.item_name,
    effects.effect_name,
    food_effects.effect_degree,
    food_effects."time",
    food_effects.chance
   FROM public.items,
    public.effects,
    public.food_effects
  WHERE (((items.item_id)::text = (food_effects.item_id)::text) AND (effects.effect_id = food_effects.effect_id))
  ORDER BY items.item_id
  WITH NO DATA;


ALTER TABLE public.food_effects_view OWNER TO postgres;

--
-- Name: food_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.food_items (
    item_id character varying(100) NOT NULL,
    hunger smallint NOT NULL,
    saturation double precision NOT NULL
);


ALTER TABLE public.food_items OWNER TO postgres;

--
-- Name: food_items_view; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.food_items_view AS
 SELECT items.item_id,
    items.item_name,
    food_items.hunger,
    food_items.saturation
   FROM public.items,
    public.food_items
  WHERE ((items.item_id)::text = (food_items.item_id)::text)
  ORDER BY items.item_id
  WITH NO DATA;


ALTER TABLE public.food_items_view OWNER TO postgres;

--
-- Name: fuel_duration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fuel_duration (
    item_id character varying(100) NOT NULL,
    fuel_duration smallint NOT NULL
);


ALTER TABLE public.fuel_duration OWNER TO postgres;

--
-- Name: fuel_duration_view; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.fuel_duration_view AS
 SELECT items.item_id,
    items.item_name,
    fuel_duration.fuel_duration
   FROM public.items,
    public.fuel_duration
  WHERE ((items.item_id)::text = (fuel_duration.item_id)::text)
  ORDER BY items.item_id
  WITH NO DATA;


ALTER TABLE public.fuel_duration_view OWNER TO postgres;

--
-- Name: smeltable_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.smeltable_items (
    item_id character varying(100) NOT NULL,
    smelting_xp double precision NOT NULL,
    smelting_method_id integer NOT NULL
);


ALTER TABLE public.smeltable_items OWNER TO postgres;

--
-- Name: smelting_methods; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.smelting_methods (
    smelting_method_id integer NOT NULL,
    smelting_method_name character varying(50) NOT NULL
);


ALTER TABLE public.smelting_methods OWNER TO postgres;

--
-- Name: smeltable_items_view; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.smeltable_items_view AS
 SELECT items.item_id,
    items.item_name,
    smeltable_items.smelting_xp,
    smelting_methods.smelting_method_name
   FROM public.items,
    public.smelting_methods,
    public.smeltable_items
  WHERE (((items.item_id)::text = (smeltable_items.item_id)::text) AND (smelting_methods.smelting_method_id = smeltable_items.smelting_method_id))
  ORDER BY items.item_id
  WITH NO DATA;


ALTER TABLE public.smeltable_items_view OWNER TO postgres;

--
-- Name: smelting_methods_smelting_method_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.smelting_methods_smelting_method_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.smelting_methods_smelting_method_id_seq OWNER TO postgres;

--
-- Name: smelting_methods_smelting_method_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.smelting_methods_smelting_method_id_seq OWNED BY public.smelting_methods.smelting_method_id;


--
-- Name: smelting_obtainable; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.smelting_obtainable (
    item_id character varying(100) NOT NULL,
    smelting_method_id smallint NOT NULL
);


ALTER TABLE public.smelting_obtainable OWNER TO postgres;

--
-- Name: smelting_obtainable_view; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.smelting_obtainable_view AS
 SELECT items.item_id,
    items.item_name,
    smelting_methods.smelting_method_name
   FROM public.items,
    public.smelting_methods,
    public.smelting_obtainable
  WHERE (((items.item_id)::text = (smelting_obtainable.item_id)::text) AND (smelting_methods.smelting_method_id = smelting_obtainable.smelting_method_id))
  ORDER BY items.item_id
  WITH NO DATA;


ALTER TABLE public.smelting_obtainable_view OWNER TO postgres;

--
-- Name: breaking_types breaking_type_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.breaking_types ALTER COLUMN breaking_type_id SET DEFAULT nextval('public.breaking_types_breakin_type_id_seq'::regclass);


--
-- Name: effects effect_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.effects ALTER COLUMN effect_id SET DEFAULT nextval('public.effects_effect_id_seq'::regclass);


--
-- Name: smelting_methods smelting_method_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.smelting_methods ALTER COLUMN smelting_method_id SET DEFAULT nextval('public.smelting_methods_smelting_method_id_seq'::regclass);


--
-- Data for Name: breaking_speeds; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.breaking_speeds (item_id, breaking_type_id, breaking_speed) FROM stdin;
stone	1	1
granite	1	1
polished_granite	1	1
diorite	1	1
polished_diorite	1	1
andesite	1	1
polished_andesite	1	1
deepslate	1	1
cobbled_deepslate	1	1
polished_deepslate	1	1
calcite	1	1
tuff	1	1
dripstone_block	1	1
grass_block	1	1
dirt	1	1
coarse_dirt	1	1
podzol	1	1
rooted_dirt	1	1
mud	1	1
crimson_nylium	1	1
warped_nylium	1	1
cobblestone	1	1
oak_planks	1	1
spruce_planks	1	1
birch_planks	1	1
jungle_planks	1	1
acacia_planks	1	1
dark_oak_planks	1	1
mangrove_planks	1	1
crimson_planks	1	1
warped_planks	1	1
oak_sapling	1	1
spruce_sapling	1	1
birch_sapling	1	1
jungle_sapling	1	1
acacia_sapling	1	1
dark_oak_sapling	1	1
mangrove_propagule	1	1
sand	1	1
red_sand	1	1
gravel	1	1
coal_ore	1	1
deepslate_coal_ore	1	1
iron_ore	1	1
deepslate_iron_ore	1	1
copper_ore	1	1
deepslate_copper_ore	1	1
gold_ore	1	1
deepslate_gold_ore	1	1
redstone_ore	1	1
deepslate_redstone_ore	1	1
emerald_ore	1	1
deepslate_emerald_ore	1	1
lapis_ore	1	1
deepslate_lapis_ore	1	1
diamond_ore	1	1
deepslate_diamond_ore	1	1
nether_gold_ore	1	1
nether_quartz_ore	1	1
ancient_debris	1	1
coal_block	1	1
raw_iron_block	1	1
raw_copper_block	1	1
raw_gold_block	1	1
amethyst_block	1	1
iron_block	1	1
copper_block	1	1
gold_block	1	1
diamond_block	1	1
netherite_block	1	1
exposed_copper	1	1
weathered_copper	1	1
oxidized_copper	1	1
cut_copper	1	1
exposed_cut_copper	1	1
weathered_cut_copper	1	1
oxidized_cut_copper	1	1
cut_copper_stairs	1	1
exposed_cut_copper_stairs	1	1
weathered_cut_copper_stairs	1	1
oxidized_cut_copper_stairs	1	1
cut_copper_slab	1	1
exposed_cut_copper_slab	1	1
weathered_cut_copper_slab	1	1
oxidized_cut_copper_slab	1	1
waxed_copper_block	1	1
waxed_exposed_copper	1	1
waxed_weathered_copper	1	1
waxed_oxidized_copper	1	1
waxed_cut_copper	1	1
waxed_exposed_cut_copper	1	1
waxed_weathered_cut_copper	1	1
waxed_oxidized_cut_copper	1	1
waxed_cut_copper_stairs	1	1
waxed_exposed_cut_copper_stairs	1	1
waxed_weathered_cut_copper_stairs	1	1
waxed_oxidized_cut_copper_stairs	1	1
waxed_cut_copper_slab	1	1
waxed_exposed_cut_copper_slab	1	1
waxed_weathered_cut_copper_slab	1	1
waxed_oxidized_cut_copper_slab	1	1
oak_log	1	1
spruce_log	1	1
birch_log	1	1
jungle_log	1	1
acacia_log	1	1
dark_oak_log	1	1
mangrove_log	1	1
mangrove_roots	1	1
muddy_mangrove_roots	1	1
crimson_stem	1	1
warped_stem	1	1
stripped_oak_log	1	1
stripped_spruce_log	1	1
stripped_birch_log	1	1
stripped_jungle_log	1	1
stripped_acacia_log	1	1
stripped_dark_oak_log	1	1
stripped_mangrove_log	1	1
stripped_crimson_stem	1	1
stripped_warped_stem	1	1
stripped_oak_wood	1	1
stripped_spruce_wood	1	1
stripped_birch_wood	1	1
stripped_jungle_wood	1	1
stripped_acacia_wood	1	1
stripped_dark_oak_wood	1	1
stripped_mangrove_wood	1	1
stripped_crimson_hyphae	1	1
stripped_warped_hyphae	1	1
oak_wood	1	1
spruce_wood	1	1
birch_wood	1	1
jungle_wood	1	1
acacia_wood	1	1
dark_oak_wood	1	1
mangrove_wood	1	1
crimson_hyphae	1	1
warped_hyphae	1	1
oak_leaves	1	1
spruce_leaves	1	1
birch_leaves	1	1
jungle_leaves	1	1
acacia_leaves	1	1
dark_oak_leaves	1	1
mangrove_leaves	1	1
azalea_leaves	1	1
flowering_azalea_leaves	1	1
sponge	1	1
wet_sponge	1	1
glass	1	1
tinted_glass	1	1
lapis_block	1	1
sandstone	1	1
chiseled_sandstone	1	1
cut_sandstone	1	1
cobweb	1	1
grass	1	1
fern	1	1
azalea	1	1
flowering_azalea	1	1
dead_bush	1	1
seagrass	1	1
sea_pickle	1	1
white_wool	1	1
orange_wool	1	1
magenta_wool	1	1
light_blue_wool	1	1
yellow_wool	1	1
lime_wool	1	1
pink_wool	1	1
gray_wool	1	1
light_gray_wool	1	1
cyan_wool	1	1
purple_wool	1	1
blue_wool	1	1
brown_wool	1	1
green_wool	1	1
red_wool	1	1
black_wool	1	1
dandelion	1	1
poppy	1	1
blue_orchid	1	1
allium	1	1
azure_bluet	1	1
red_tulip	1	1
orange_tulip	1	1
white_tulip	1	1
pink_tulip	1	1
oxeye_daisy	1	1
cornflower	1	1
lily_of_the_valley	1	1
wither_rose	1	1
spore_blossom	1	1
brown_mushroom	1	1
red_mushroom	1	1
crimson_fungus	1	1
warped_fungus	1	1
crimson_roots	1	1
warped_roots	1	1
nether_sprouts	1	1
weeping_vines	1	1
twisting_vines	1	1
sugar_cane	1	1
kelp	1	1
moss_carpet	1	1
moss_block	1	1
hanging_roots	1	1
big_dripleaf	1	1
small_dripleaf	1	1
bamboo	1	1
oak_slab	1	1
spruce_slab	1	1
birch_slab	1	1
jungle_slab	1	1
acacia_slab	1	1
dark_oak_slab	1	1
mangrove_slab	1	1
crimson_slab	1	1
warped_slab	1	1
stone_slab	1	1
smooth_stone_slab	1	1
sandstone_slab	1	1
cut_sandstone_slab	1	1
cobblestone_slab	1	1
brick_slab	1	1
stone_brick_slab	1	1
mud_brick_slab	1	1
nether_brick_slab	1	1
quartz_slab	1	1
red_sandstone_slab	1	1
cut_red_sandstone_slab	1	1
purpur_slab	1	1
prismarine_slab	1	1
prismarine_brick_slab	1	1
dark_prismarine_slab	1	1
smooth_quartz	1	1
smooth_red_sandstone	1	1
smooth_sandstone	1	1
smooth_stone	1	1
bricks	1	1
bookshelf	1	1
mossy_cobblestone	1	1
obsidian	1	1
torch	1	1
end_rod	1	1
chorus_flower	1	1
purpur_block	1	1
purpur_pillar	1	1
purpur_stairs	1	1
chest	1	1
crafting_table	1	1
furnace	1	1
ladder	1	1
cobblestone_stairs	1	1
snow	1	1
ice	1	1
snow_block	1	1
cactus	1	1
clay	1	1
jukebox	1	1
oak_fence	1	1
spruce_fence	1	1
birch_fence	1	1
jungle_fence	1	1
acacia_fence	1	1
dark_oak_fence	1	1
mangrove_fence	1	1
crimson_fence	1	1
warped_fence	1	1
pumpkin	1	1
carved_pumpkin	1	1
jack_o_lantern	1	1
netherrack	1	1
soul_sand	1	1
soul_soil	1	1
basalt	1	1
polished_basalt	1	1
smooth_basalt	1	1
soul_torch	1	1
glowstone	1	1
stone_bricks	1	1
mossy_stone_bricks	1	1
cracked_stone_bricks	1	1
chiseled_stone_bricks	1	1
packed_mud	1	1
mud_bricks	1	1
deepslate_bricks	1	1
cracked_deepslate_bricks	1	1
deepslate_tiles	1	1
cracked_deepslate_tiles	1	1
chiseled_deepslate	1	1
brown_mushroom_block	1	1
red_mushroom_block	1	1
mushroom_stem	1	1
iron_bars	1	1
chain	1	1
glass_pane	1	1
melon	1	1
vine	1	1
glow_lichen	1	1
brick_stairs	1	1
stone_brick_stairs	1	1
mud_brick_stairs	1	1
mycelium	1	1
lily_pad	1	1
nether_bricks	1	1
cracked_nether_bricks	1	1
chiseled_nether_bricks	1	1
nether_brick_fence	1	1
nether_brick_stairs	1	1
sculk	1	1
sculk_vein	1	1
sculk_catalyst	1	1
sculk_shrieker	1	1
enchanting_table	1	1
end_stone	1	1
end_stone_bricks	1	1
dragon_egg	1	1
sandstone_stairs	1	1
ender_chest	1	1
emerald_block	1	1
oak_stairs	1	1
spruce_stairs	1	1
birch_stairs	1	1
jungle_stairs	1	1
acacia_stairs	1	1
dark_oak_stairs	1	1
mangrove_stairs	1	1
crimson_stairs	1	1
warped_stairs	1	1
beacon	1	1
cobblestone_wall	1	1
mossy_cobblestone_wall	1	1
brick_wall	1	1
prismarine_wall	1	1
red_sandstone_wall	1	1
mossy_stone_brick_wall	1	1
granite_wall	1	1
stone_brick_wall	1	1
mud_brick_wall	1	1
nether_brick_wall	1	1
andesite_wall	1	1
red_nether_brick_wall	1	1
sandstone_wall	1	1
end_stone_brick_wall	1	1
diorite_wall	1	1
blackstone_wall	1	1
polished_blackstone_wall	1	1
polished_blackstone_brick_wall	1	1
cobbled_deepslate_wall	1	1
polished_deepslate_wall	1	1
deepslate_brick_wall	1	1
deepslate_tile_wall	1	1
anvil	1	1
chipped_anvil	1	1
damaged_anvil	1	1
chiseled_quartz_block	1	1
quartz_block	1	1
quartz_bricks	1	1
quartz_pillar	1	1
quartz_stairs	1	1
white_terracotta	1	1
orange_terracotta	1	1
magenta_terracotta	1	1
light_blue_terracotta	1	1
yellow_terracotta	1	1
lime_terracotta	1	1
pink_terracotta	1	1
gray_terracotta	1	1
light_gray_terracotta	1	1
cyan_terracotta	1	1
purple_terracotta	1	1
blue_terracotta	1	1
brown_terracotta	1	1
green_terracotta	1	1
red_terracotta	1	1
black_terracotta	1	1
hay_block	1	1
white_carpet	1	1
orange_carpet	1	1
magenta_carpet	1	1
light_blue_carpet	1	1
yellow_carpet	1	1
lime_carpet	1	1
pink_carpet	1	1
gray_carpet	1	1
light_gray_carpet	1	1
cyan_carpet	1	1
purple_carpet	1	1
blue_carpet	1	1
brown_carpet	1	1
green_carpet	1	1
red_carpet	1	1
black_carpet	1	1
terracotta	1	1
packed_ice	1	1
sunflower	1	1
lilac	1	1
rose_bush	1	1
peony	1	1
tall_grass	1	1
large_fern	1	1
white_stained_glass	1	1
orange_stained_glass	1	1
magenta_stained_glass	1	1
light_blue_stained_glass	1	1
yellow_stained_glass	1	1
lime_stained_glass	1	1
pink_stained_glass	1	1
gray_stained_glass	1	1
light_gray_stained_glass	1	1
cyan_stained_glass	1	1
purple_stained_glass	1	1
blue_stained_glass	1	1
brown_stained_glass	1	1
green_stained_glass	1	1
red_stained_glass	1	1
black_stained_glass	1	1
white_stained_glass_pane	1	1
orange_stained_glass_pane	1	1
magenta_stained_glass_pane	1	1
light_blue_stained_glass_pane	1	1
yellow_stained_glass_pane	1	1
lime_stained_glass_pane	1	1
pink_stained_glass_pane	1	1
gray_stained_glass_pane	1	1
light_gray_stained_glass_pane	1	1
cyan_stained_glass_pane	1	1
purple_stained_glass_pane	1	1
blue_stained_glass_pane	1	1
brown_stained_glass_pane	1	1
green_stained_glass_pane	1	1
red_stained_glass_pane	1	1
black_stained_glass_pane	1	1
prismarine	1	1
prismarine_bricks	1	1
dark_prismarine	1	1
prismarine_stairs	1	1
prismarine_brick_stairs	1	1
dark_prismarine_stairs	1	1
sea_lantern	1	1
red_sandstone	1	1
chiseled_red_sandstone	1	1
cut_red_sandstone	1	1
red_sandstone_stairs	1	1
magma_block	1	1
nether_wart_block	1	1
warped_wart_block	1	1
red_nether_bricks	1	1
bone_block	1	1
shulker_box	1	1
white_shulker_box	1	1
orange_shulker_box	1	1
magenta_shulker_box	1	1
light_blue_shulker_box	1	1
yellow_shulker_box	1	1
lime_shulker_box	1	1
pink_shulker_box	1	1
gray_shulker_box	1	1
light_gray_shulker_box	1	1
cyan_shulker_box	1	1
purple_shulker_box	1	1
blue_shulker_box	1	1
brown_shulker_box	1	1
green_shulker_box	1	1
red_shulker_box	1	1
black_shulker_box	1	1
white_glazed_terracotta	1	1
orange_glazed_terracotta	1	1
magenta_glazed_terracotta	1	1
light_blue_glazed_terracotta	1	1
yellow_glazed_terracotta	1	1
lime_glazed_terracotta	1	1
pink_glazed_terracotta	1	1
gray_glazed_terracotta	1	1
light_gray_glazed_terracotta	1	1
cyan_glazed_terracotta	1	1
purple_glazed_terracotta	1	1
blue_glazed_terracotta	1	1
brown_glazed_terracotta	1	1
green_glazed_terracotta	1	1
red_glazed_terracotta	1	1
black_glazed_terracotta	1	1
white_concrete	1	1
orange_concrete	1	1
magenta_concrete	1	1
light_blue_concrete	1	1
yellow_concrete	1	1
lime_concrete	1	1
pink_concrete	1	1
gray_concrete	1	1
light_gray_concrete	1	1
cyan_concrete	1	1
purple_concrete	1	1
blue_concrete	1	1
brown_concrete	1	1
green_concrete	1	1
red_concrete	1	1
black_concrete	1	1
white_concrete_powder	1	1
orange_concrete_powder	1	1
magenta_concrete_powder	1	1
light_blue_concrete_powder	1	1
yellow_concrete_powder	1	1
lime_concrete_powder	1	1
pink_concrete_powder	1	1
gray_concrete_powder	1	1
light_gray_concrete_powder	1	1
cyan_concrete_powder	1	1
purple_concrete_powder	1	1
blue_concrete_powder	1	1
brown_concrete_powder	1	1
green_concrete_powder	1	1
red_concrete_powder	1	1
black_concrete_powder	1	1
turtle_egg	1	1
dead_tube_coral_block	1	1
dead_brain_coral_block	1	1
dead_bubble_coral_block	1	1
dead_fire_coral_block	1	1
dead_horn_coral_block	1	1
tube_coral_block	1	1
brain_coral_block	1	1
bubble_coral_block	1	1
fire_coral_block	1	1
horn_coral_block	1	1
tube_coral	1	1
brain_coral	1	1
bubble_coral	1	1
fire_coral	1	1
horn_coral	1	1
dead_brain_coral	1	1
dead_bubble_coral	1	1
dead_fire_coral	1	1
dead_horn_coral	1	1
dead_tube_coral	1	1
tube_coral_fan	1	1
brain_coral_fan	1	1
bubble_coral_fan	1	1
fire_coral_fan	1	1
horn_coral_fan	1	1
dead_tube_coral_fan	1	1
dead_brain_coral_fan	1	1
dead_bubble_coral_fan	1	1
dead_fire_coral_fan	1	1
dead_horn_coral_fan	1	1
blue_ice	1	1
conduit	1	1
polished_granite_stairs	1	1
smooth_red_sandstone_stairs	1	1
mossy_stone_brick_stairs	1	1
polished_diorite_stairs	1	1
mossy_cobblestone_stairs	1	1
end_stone_brick_stairs	1	1
stone_stairs	1	1
smooth_sandstone_stairs	1	1
smooth_quartz_stairs	1	1
granite_stairs	1	1
andesite_stairs	1	1
red_nether_brick_stairs	1	1
polished_andesite_stairs	1	1
diorite_stairs	1	1
cobbled_deepslate_stairs	1	1
polished_deepslate_stairs	1	1
deepslate_brick_stairs	1	1
deepslate_tile_stairs	1	1
polished_granite_slab	1	1
smooth_red_sandstone_slab	1	1
mossy_stone_brick_slab	1	1
polished_diorite_slab	1	1
mossy_cobblestone_slab	1	1
end_stone_brick_slab	1	1
smooth_sandstone_slab	1	1
smooth_quartz_slab	1	1
granite_slab	1	1
andesite_slab	1	1
red_nether_brick_slab	1	1
polished_andesite_slab	1	1
diorite_slab	1	1
cobbled_deepslate_slab	1	1
polished_deepslate_slab	1	1
deepslate_brick_slab	1	1
deepslate_tile_slab	1	1
scaffolding	1	1
redstone	1	1
redstone_torch	1	1
redstone_block	1	1
repeater	1	1
comparator	1	1
piston	1	1
sticky_piston	1	1
slime_block	1	1
honey_block	1	1
observer	1	1
hopper	1	1
dispenser	1	1
dropper	1	1
lectern	1	1
target	1	1
lever	1	1
lightning_rod	1	1
daylight_detector	1	1
sculk_sensor	1	1
tripwire_hook	1	1
trapped_chest	1	1
tnt	1	1
redstone_lamp	1	1
note_block	1	1
stone_button	1	1
polished_blackstone_button	1	1
oak_button	1	1
spruce_button	1	1
birch_button	1	1
jungle_button	1	1
acacia_button	1	1
dark_oak_button	1	1
mangrove_button	1	1
crimson_button	1	1
warped_button	1	1
stone_pressure_plate	1	1
polished_blackstone_pressure_plate	1	1
light_weighted_pressure_plate	1	1
heavy_weighted_pressure_plate	1	1
oak_pressure_plate	1	1
spruce_pressure_plate	1	1
birch_pressure_plate	1	1
jungle_pressure_plate	1	1
acacia_pressure_plate	1	1
dark_oak_pressure_plate	1	1
mangrove_pressure_plate	1	1
crimson_pressure_plate	1	1
warped_pressure_plate	1	1
iron_door	1	1
oak_door	1	1
spruce_door	1	1
birch_door	1	1
jungle_door	1	1
acacia_door	1	1
dark_oak_door	1	1
mangrove_door	1	1
crimson_door	1	1
warped_door	1	1
iron_trapdoor	1	1
oak_trapdoor	1	1
spruce_trapdoor	1	1
birch_trapdoor	1	1
jungle_trapdoor	1	1
acacia_trapdoor	1	1
dark_oak_trapdoor	1	1
mangrove_trapdoor	1	1
crimson_trapdoor	1	1
warped_trapdoor	1	1
oak_fence_gate	1	1
spruce_fence_gate	1	1
birch_fence_gate	1	1
jungle_fence_gate	1	1
acacia_fence_gate	1	1
dark_oak_fence_gate	1	1
mangrove_fence_gate	1	1
crimson_fence_gate	1	1
warped_fence_gate	1	1
powered_rail	1	1
detector_rail	1	1
rail	1	1
activator_rail	1	1
saddle	1	1
minecart	1	1
chest_minecart	1	1
furnace_minecart	1	1
tnt_minecart	1	1
hopper_minecart	1	1
carrot_on_a_stick	1	1
warped_fungus_on_a_stick	1	1
elytra	1	1
oak_boat	1	1
oak_chest_boat	1	1
spruce_boat	1	1
spruce_chest_boat	1	1
birch_boat	1	1
birch_chest_boat	1	1
jungle_boat	1	1
jungle_chest_boat	1	1
acacia_boat	1	1
acacia_chest_boat	1	1
dark_oak_boat	1	1
dark_oak_chest_boat	1	1
mangrove_boat	1	1
mangrove_chest_boat	1	1
turtle_helmet	1	1
scute	1	1
flint_and_steel	1	1
apple	1	1
bow	1	1
arrow	1	1
coal	1	1
charcoal	1	1
diamond	1	1
emerald	1	1
lapis_lazuli	1	1
quartz	1	1
amethyst_shard	1	1
raw_iron	1	1
iron_ingot	1	1
raw_copper	1	1
copper_ingot	1	1
raw_gold	1	1
gold_ingot	1	1
netherite_ingot	1	1
netherite_scrap	1	1
wooden_sword	1	1.5
wooden_sword	2	15
wooden_shovel	1	2
wooden_pickaxe	1	2
wooden_axe	1	2
wooden_hoe	1	2
stone_sword	1	1.5
stone_sword	2	15
stone_shovel	1	4
stone_pickaxe	1	4
stone_axe	1	4
stone_hoe	1	4
golden_sword	1	1.5
golden_sword	2	15
golden_shovel	1	12
golden_pickaxe	1	12
golden_axe	1	12
golden_hoe	1	12
iron_sword	1	1.5
iron_sword	2	15
iron_shovel	1	6
iron_pickaxe	1	6
iron_axe	1	6
iron_hoe	1	6
diamond_sword	1	1.5
diamond_sword	2	15
diamond_shovel	1	8
diamond_pickaxe	1	8
diamond_axe	1	8
diamond_hoe	1	8
netherite_sword	1	1.5
netherite_sword	2	15
netherite_shovel	1	9
netherite_pickaxe	1	9
netherite_axe	1	9
netherite_hoe	1	9
stick	1	1
bowl	1	1
mushroom_stew	1	1
string	1	1
feather	1	1
gunpowder	1	1
wheat_seeds	1	1
wheat	1	1
bread	1	1
leather_helmet	1	1
leather_chestplate	1	1
leather_leggings	1	1
leather_boots	1	1
chainmail_helmet	1	1
chainmail_chestplate	1	1
chainmail_leggings	1	1
chainmail_boots	1	1
iron_helmet	1	1
iron_chestplate	1	1
iron_leggings	1	1
iron_boots	1	1
diamond_helmet	1	1
diamond_chestplate	1	1
diamond_leggings	1	1
diamond_boots	1	1
golden_helmet	1	1
golden_chestplate	1	1
golden_leggings	1	1
golden_boots	1	1
netherite_helmet	1	1
netherite_chestplate	1	1
netherite_leggings	1	1
netherite_boots	1	1
flint	1	1
porkchop	1	1
cooked_porkchop	1	1
painting	1	1
golden_apple	1	1
enchanted_golden_apple	1	1
oak_sign	1	1
spruce_sign	1	1
birch_sign	1	1
jungle_sign	1	1
acacia_sign	1	1
dark_oak_sign	1	1
mangrove_sign	1	1
crimson_sign	1	1
warped_sign	1	1
bucket	1	1
water_bucket	1	1
lava_bucket	1	1
powder_snow_bucket	1	1
snowball	1	1
leather	1	1
milk_bucket	1	1
pufferfish_bucket	1	1
salmon_bucket	1	1
cod_bucket	1	1
tropical_fish_bucket	1	1
axolotl_bucket	1	1
tadpole_bucket	1	1
brick	1	1
clay_ball	1	1
dried_kelp_block	1	1
paper	1	1
book	1	1
slime_ball	1	1
egg	1	1
compass	1	1
recovery_compass	1	1
fishing_rod	1	1
clock	1	1
spyglass	1	1
glowstone_dust	1	1
cod	1	1
salmon	1	1
tropical_fish	1	1
pufferfish	1	1
cooked_cod	1	1
cooked_salmon	1	1
ink_sac	1	1
glow_ink_sac	1	1
cocoa_beans	1	1
white_dye	1	1
orange_dye	1	1
magenta_dye	1	1
light_blue_dye	1	1
yellow_dye	1	1
lime_dye	1	1
pink_dye	1	1
gray_dye	1	1
light_gray_dye	1	1
cyan_dye	1	1
purple_dye	1	1
blue_dye	1	1
brown_dye	1	1
green_dye	1	1
red_dye	1	1
black_dye	1	1
bone_meal	1	1
bone	1	1
sugar	1	1
cake	1	1
white_bed	1	1
orange_bed	1	1
magenta_bed	1	1
light_blue_bed	1	1
yellow_bed	1	1
lime_bed	1	1
pink_bed	1	1
gray_bed	1	1
light_gray_bed	1	1
cyan_bed	1	1
purple_bed	1	1
blue_bed	1	1
brown_bed	1	1
green_bed	1	1
red_bed	1	1
black_bed	1	1
cookie	1	1
filled_map	1	1
shears	1	1.5
shears	3	5
shears	2	15
shears	4	15
melon_slice	1	1
dried_kelp	1	1
pumpkin_seeds	1	1
melon_seeds	1	1
beef	1	1
cooked_beef	1	1
chicken	1	1
cooked_chicken	1	1
rotten_flesh	1	1
ender_pearl	1	1
blaze_rod	1	1
ghast_tear	1	1
gold_nugget	1	1
nether_wart	1	1
potion	1	1
glass_bottle	1	1
spider_eye	1	1
fermented_spider_eye	1	1
blaze_powder	1	1
magma_cream	1	1
brewing_stand	1	1
cauldron	1	1
ender_eye	1	1
glistering_melon_slice	1	1
experience_bottle	1	1
fire_charge	1	1
writable_book	1	1
written_book	1	1
item_frame	1	1
glow_item_frame	1	1
flower_pot	1	1
carrot	1	1
potato	1	1
baked_potato	1	1
poisonous_potato	1	1
map	1	1
golden_carrot	1	1
skeleton_skull	1	1
wither_skeleton_skull	1	1
zombie_head	1	1
creeper_head	1	1
dragon_head	1	1
nether_star	1	1
pumpkin_pie	1	1
firework_rocket	1	1
firework_star	1	1
enchanted_book	1	1
nether_brick	1	1
prismarine_shard	1	1
prismarine_crystals	1	1
rabbit	1	1
cooked_rabbit	1	1
rabbit_stew	1	1
rabbit_foot	1	1
rabbit_hide	1	1
armor_stand	1	1
iron_horse_armor	1	1
golden_horse_armor	1	1
diamond_horse_armor	1	1
leather_horse_armor	1	1
lead	1	1
name_tag	1	1
mutton	1	1
cooked_mutton	1	1
white_banner	1	1
orange_banner	1	1
magenta_banner	1	1
light_blue_banner	1	1
yellow_banner	1	1
lime_banner	1	1
pink_banner	1	1
gray_banner	1	1
light_gray_banner	1	1
cyan_banner	1	1
purple_banner	1	1
blue_banner	1	1
brown_banner	1	1
green_banner	1	1
red_banner	1	1
black_banner	1	1
end_crystal	1	1
chorus_fruit	1	1
popped_chorus_fruit	1	1
beetroot	1	1
beetroot_seeds	1	1
beetroot_soup	1	1
dragon_breath	1	1
splash_potion	1	1
spectral_arrow	1	1
tipped_arrow	1	1
lingering_potion	1	1
shield	1	1
totem_of_undying	1	1
shulker_shell	1	1
iron_nugget	1	1
music_disc_13	1	1
music_disc_cat	1	1
music_disc_blocks	1	1
music_disc_chirp	1	1
music_disc_far	1	1
music_disc_mall	1	1
music_disc_mellohi	1	1
music_disc_stal	1	1
music_disc_strad	1	1
music_disc_ward	1	1
music_disc_11	1	1
music_disc_wait	1	1
music_disc_otherside	1	1
music_disc_pigstep	1	1
trident	1	1
phantom_membrane	1	1
nautilus_shell	1	1
heart_of_the_sea	1	1
crossbow	1	1
suspicious_stew	1	1
loom	1	1
flower_banner_pattern	1	1
creeper_banner_pattern	1	1
skull_banner_pattern	1	1
mojang_banner_pattern	1	1
globe_banner_pattern	1	1
piglin_banner_pattern	1	1
composter	1	1
barrel	1	1
smoker	1	1
blast_furnace	1	1
cartography_table	1	1
fletching_table	1	1
grindstone	1	1
smithing_table	1	1
stonecutter	1	1
bell	1	1
lantern	1	1
soul_lantern	1	1
sweet_berries	1	1
glow_berries	1	1
campfire	1	1
soul_campfire	1	1
shroomlight	1	1
honeycomb	1	1
bee_nest	1	1
beehive	1	1
honey_bottle	1	1
honeycomb_block	1	1
lodestone	1	1
crying_obsidian	1	1
blackstone	1	1
blackstone_slab	1	1
blackstone_stairs	1	1
gilded_blackstone	1	1
polished_blackstone	1	1
polished_blackstone_slab	1	1
polished_blackstone_stairs	1	1
chiseled_polished_blackstone	1	1
polished_blackstone_bricks	1	1
polished_blackstone_brick_slab	1	1
polished_blackstone_brick_stairs	1	1
cracked_polished_blackstone_bricks	1	1
respawn_anchor	1	1
candle	1	1
white_candle	1	1
orange_candle	1	1
magenta_candle	1	1
light_blue_candle	1	1
yellow_candle	1	1
lime_candle	1	1
pink_candle	1	1
gray_candle	1	1
light_gray_candle	1	1
cyan_candle	1	1
purple_candle	1	1
blue_candle	1	1
brown_candle	1	1
green_candle	1	1
red_candle	1	1
black_candle	1	1
small_amethyst_bud	1	1
medium_amethyst_bud	1	1
large_amethyst_bud	1	1
amethyst_cluster	1	1
pointed_dripstone	1	1
ochre_froglight	1	1
verdant_froglight	1	1
pearlescent_froglight	1	1
echo_shard	1	1
bedrock	1	1
budding_amethyst	1	1
petrified_oak_slab	1	1
chorus_plant	1	1
spawner	1	1
farmland	1	1
infested_stone	1	1
infested_cobblestone	1	1
infested_stone_bricks	1	1
infested_mossy_stone_bricks	1	1
infested_cracked_stone_bricks	1	1
infested_chiseled_stone_bricks	1	1
infested_deepslate	1	1
reinforced_deepslate	1	1
end_portal_frame	1	1
command_block	1	1
barrier	1	1
light	1	1
dirt_path	1	1
repeating_command_block	1	1
chain_command_block	1	1
structure_void	1	1
structure_block	1	1
jigsaw	1	1
bundle	1	1
allay_spawn_egg	1	1
axolotl_spawn_egg	1	1
bat_spawn_egg	1	1
bee_spawn_egg	1	1
blaze_spawn_egg	1	1
cat_spawn_egg	1	1
cave_spider_spawn_egg	1	1
chicken_spawn_egg	1	1
cod_spawn_egg	1	1
cow_spawn_egg	1	1
creeper_spawn_egg	1	1
dolphin_spawn_egg	1	1
donkey_spawn_egg	1	1
drowned_spawn_egg	1	1
elder_guardian_spawn_egg	1	1
enderman_spawn_egg	1	1
endermite_spawn_egg	1	1
evoker_spawn_egg	1	1
fox_spawn_egg	1	1
frog_spawn_egg	1	1
ghast_spawn_egg	1	1
glow_squid_spawn_egg	1	1
goat_spawn_egg	1	1
guardian_spawn_egg	1	1
hoglin_spawn_egg	1	1
horse_spawn_egg	1	1
husk_spawn_egg	1	1
llama_spawn_egg	1	1
magma_cube_spawn_egg	1	1
mooshroom_spawn_egg	1	1
mule_spawn_egg	1	1
ocelot_spawn_egg	1	1
panda_spawn_egg	1	1
parrot_spawn_egg	1	1
phantom_spawn_egg	1	1
pig_spawn_egg	1	1
piglin_spawn_egg	1	1
piglin_brute_spawn_egg	1	1
pillager_spawn_egg	1	1
polar_bear_spawn_egg	1	1
pufferfish_spawn_egg	1	1
rabbit_spawn_egg	1	1
ravager_spawn_egg	1	1
salmon_spawn_egg	1	1
sheep_spawn_egg	1	1
shulker_spawn_egg	1	1
silverfish_spawn_egg	1	1
skeleton_spawn_egg	1	1
skeleton_horse_spawn_egg	1	1
slime_spawn_egg	1	1
spider_spawn_egg	1	1
squid_spawn_egg	1	1
stray_spawn_egg	1	1
strider_spawn_egg	1	1
tadpole_spawn_egg	1	1
trader_llama_spawn_egg	1	1
tropical_fish_spawn_egg	1	1
turtle_spawn_egg	1	1
vex_spawn_egg	1	1
villager_spawn_egg	1	1
vindicator_spawn_egg	1	1
wandering_trader_spawn_egg	1	1
warden_spawn_egg	1	1
witch_spawn_egg	1	1
wither_skeleton_spawn_egg	1	1
wolf_spawn_egg	1	1
zoglin_spawn_egg	1	1
zombie_spawn_egg	1	1
zombie_horse_spawn_egg	1	1
zombie_villager_spawn_egg	1	1
zombified_piglin_spawn_egg	1	1
player_head	1	1
command_block_minecart	1	1
knowledge_book	1	1
debug_stick	1	1
frogspawn	1	1
potion{Potion:water}	1	1
potion{Potion:empty}	1	1
potion{Potion:awkward}	1	1
potion{Potion:thick}	1	1
potion{Potion:mundane}	1	1
potion{Potion:regeneration}	1	1
potion{Potion:swiftness}	1	1
potion{Potion:fire_resistance}	1	1
potion{Potion:poison}	1	1
potion{Potion:healing}	1	1
potion{Potion:night_vision}	1	1
potion{Potion:weakness}	1	1
potion{Potion:strength}	1	1
potion{Potion:slowness}	1	1
potion{Potion:harming}	1	1
potion{Potion:water_breathing}	1	1
potion{Potion:invisibility}	1	1
potion{Potion:strong_regeneration}	1	1
potion{Potion:strong_swiftness}	1	1
potion{Potion:strong_poison}	1	1
potion{Potion:strong_healing}	1	1
potion{Potion:strong_strength}	1	1
potion{Potion:strong_leaping}	1	1
potion{Potion:strong_harming}	1	1
potion{Potion:long_regeneration}	1	1
potion{Potion:long_swiftness}	1	1
potion{Potion:long_fire_resistance}	1	1
potion{Potion:long_poison}	1	1
potion{Potion:long_night_vision}	1	1
potion{Potion:long_weakness}	1	1
potion{Potion:long_strength}	1	1
potion{Potion:long_slowness}	1	1
potion{Potion:leaping}	1	1
potion{Potion:long_water_breathing}	1	1
potion{Potion:long_invisibility}	1	1
potion{Potion:turtle_master}	1	1
potion{Potion:long_turtle_master}	1	1
potion{Potion:strong_turtle_master}	1	1
potion{Potion:slow_falling}	1	1
potion{Potion:long_slow_falling}	1	1
potion{Potion:luck}	1	1
potion{Potion:long_leaping}	1	1
potion{Potion:strong_slowness}	1	1
splash_potion{Potion:water}	1	1
splash_potion{Potion:mundane}	1	1
splash_potion{Potion:thick}	1	1
splash_potion{Potion:awkward}	1	1
splash_potion{Potion:uncraftable}	1	1
splash_potion{Potion:night_vision}	1	1
splash_potion{Potion:long_night_vision}	1	1
splash_potion{Potion:invisibility}	1	1
splash_potion{Potion:long_invisibility}	1	1
splash_potion{Potion:leaping}	1	1
splash_potion{Potion:long_leaping}	1	1
splash_potion{Potion:strong_leaping}	1	1
splash_potion{Potion:fire_resistance}	1	1
splash_potion{Potion:long_fire_resistance}	1	1
splash_potion{Potion:swiftness}	1	1
splash_potion{Potion:long_swiftness}	1	1
splash_potion{Potion:strong_swiftness}	1	1
splash_potion{Potion:slowness}	1	1
splash_potion{Potion:long_slowness}	1	1
splash_potion{Potion:strong_slowness}	1	1
splash_potion{Potion:turtle_master}	1	1
splash_potion{Potion:long_turtle_master}	1	1
splash_potion{Potion:strong_turtle_master}	1	1
splash_potion{Potion:water_breathing}	1	1
splash_potion{Potion:long_water_breathing}	1	1
splash_potion{Potion:healing}	1	1
splash_potion{Potion:strong_healing}	1	1
splash_potion{Potion:harming}	1	1
splash_potion{Potion:strong_harming}	1	1
splash_potion{Potion:poison}	1	1
splash_potion{Potion:long_poison}	1	1
splash_potion{Potion:strong_poison}	1	1
splash_potion{Potion:regeneration}	1	1
splash_potion{Potion:long_regeneration}	1	1
splash_potion{Potion:strong_regeneration}	1	1
splash_potion{Potion:strength}	1	1
splash_potion{Potion:long_strength}	1	1
splash_potion{Potion:strong_strength}	1	1
splash_potion{Potion:weakness}	1	1
splash_potion{Potion:long_weakness}	1	1
splash_potion{Potion:luck}	1	1
splash_potion{Potion:slow_falling}	1	1
splash_potion{Potion:long_slow_falling}	1	1
lingering_potion{Potion:water}	1	1
lingering_potion{Potion:mundane}	1	1
lingering_potion{Potion:thick}	1	1
lingering_potion{Potion:awkward}	1	1
lingering_potion{Potion:uncraftable}	1	1
lingering_potion{Potion:night_vision}	1	1
lingering_potion{Potion:long_night_vision}	1	1
lingering_potion{Potion:invisibility}	1	1
lingering_potion{Potion:long_invisibility}	1	1
lingering_potion{Potion:leaping}	1	1
lingering_potion{Potion:long_leaping}	1	1
lingering_potion{Potion:strong_leaping}	1	1
lingering_potion{Potion:fire_resistance}	1	1
lingering_potion{Potion:long_fire_resistance}	1	1
lingering_potion{Potion:swiftness}	1	1
lingering_potion{Potion:long_swiftness}	1	1
lingering_potion{Potion:strong_swiftness}	1	1
lingering_potion{Potion:slowness}	1	1
lingering_potion{Potion:long_slowness}	1	1
lingering_potion{Potion:strong_slowness}	1	1
lingering_potion{Potion:turtle_master}	1	1
lingering_potion{Potion:long_turtle_master}	1	1
lingering_potion{Potion:strong_turtle_master}	1	1
lingering_potion{Potion:water_breathing}	1	1
lingering_potion{Potion:long_water_breathing}	1	1
lingering_potion{Potion:healing}	1	1
lingering_potion{Potion:strong_healing}	1	1
lingering_potion{Potion:harming}	1	1
lingering_potion{Potion:strong_harming}	1	1
lingering_potion{Potion:poison}	1	1
lingering_potion{Potion:long_poison}	1	1
lingering_potion{Potion:strong_poison}	1	1
lingering_potion{Potion:regeneration}	1	1
lingering_potion{Potion:long_regeneration}	1	1
lingering_potion{Potion:strong_regeneration}	1	1
lingering_potion{Potion:strength}	1	1
lingering_potion{Potion:long_strength}	1	1
lingering_potion{Potion:strong_strength}	1	1
lingering_potion{Potion:weakness}	1	1
lingering_potion{Potion:long_weakness}	1	1
lingering_potion{Potion:luck}	1	1
lingering_potion{Potion:slow_falling}	1	1
lingering_potion{Potion:long_slow_falling}	1	1
tipped_arrow{Potion:water}	1	1
tipped_arrow{Potion:mundane}	1	1
tipped_arrow{Potion:thick}	1	1
tipped_arrow{Potion:awkward}	1	1
tipped_arrow{Potion:uncraftable}	1	1
tipped_arrow{Potion:night_vision}	1	1
tipped_arrow{Potion:long_night_vision}	1	1
tipped_arrow{Potion:invisibility}	1	1
tipped_arrow{Potion:long_invisibility}	1	1
tipped_arrow{Potion:leaping}	1	1
tipped_arrow{Potion:long_leaping}	1	1
tipped_arrow{Potion:strong_leaping}	1	1
tipped_arrow{Potion:fire_resistance}	1	1
tipped_arrow{Potion:long_fire_resistance}	1	1
tipped_arrow{Potion:swiftness}	1	1
tipped_arrow{Potion:long_swiftness}	1	1
tipped_arrow{Potion:strong_swiftness}	1	1
tipped_arrow{Potion:slowness}	1	1
tipped_arrow{Potion:long_slowness}	1	1
tipped_arrow{Potion:strong_slowness}	1	1
tipped_arrow{Potion:turtle_master}	1	1
tipped_arrow{Potion:long_turtle_master}	1	1
tipped_arrow{Potion:strong_turtle_master}	1	1
tipped_arrow{Potion:water_breathing}	1	1
tipped_arrow{Potion:long_water_breathing}	1	1
tipped_arrow{Potion:healing}	1	1
tipped_arrow{Potion:strong_healing}	1	1
tipped_arrow{Potion:harming}	1	1
tipped_arrow{Potion:strong_harming}	1	1
tipped_arrow{Potion:poison}	1	1
tipped_arrow{Potion:long_poison}	1	1
tipped_arrow{Potion:strong_poison}	1	1
tipped_arrow{Potion:regeneration}	1	1
tipped_arrow{Potion:long_regeneration}	1	1
tipped_arrow{Potion:strong_regeneration}	1	1
tipped_arrow{Potion:strength}	1	1
tipped_arrow{Potion:long_strength}	1	1
tipped_arrow{Potion:strong_strength}	1	1
tipped_arrow{Potion:weakness}	1	1
tipped_arrow{Potion:long_weakness}	1	1
tipped_arrow{Potion:luck}	1	1
tipped_arrow{Potion:slow_falling}	1	1
tipped_arrow{Potion:long_slow_falling}	1	1
\.


--
-- Data for Name: breaking_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.breaking_types (breaking_type_id, breaking_type_name) FROM stdin;
1	Default
2	Cobwebs
3	Wool
4	Leaves
\.


--
-- Data for Name: cooldown; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cooldown (item_id, cooldown) FROM stdin;
wooden_sword	0.625
wooden_shovel	1
wooden_pickaxe	0.833
wooden_axe	1.25
wooden_hoe	1
stone_sword	0.625
stone_shovel	1
stone_pickaxe	0.833
stone_axe	1.25
stone_hoe	0.5
golden_sword	0.625
golden_shovel	1
golden_pickaxe	0.833
golden_axe	1
golden_hoe	1
iron_sword	0.625
iron_shovel	1
iron_pickaxe	0.833
iron_axe	1.111
iron_hoe	0.333
diamond_sword	0.625
diamond_shovel	1
diamond_pickaxe	0.833
diamond_axe	1
diamond_hoe	0.25
netherite_sword	0.625
netherite_shovel	1
netherite_pickaxe	0.833
netherite_axe	1
netherite_hoe	0.25
ender_pearl	1
chorus_fruit	1
shield	5
trident	0.9
\.


--
-- Data for Name: effects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.effects (effect_id, effect_name) FROM stdin;
1	Teleport Randomly
2	Regeneration
3	Absorption
4	Resistance
5	Fire Resistance
6	Clears Poison
7	Poison
8	Hunger
9	Nausea
10	Jump Boost
11	Wither
12	Weakness
13	Blindness
14	Saturation
15	Night Vision
\.


--
-- Data for Name: food_effects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.food_effects (item_id, effect_id, effect_degree, "time", chance) FROM stdin;
chorus_fruit	1	1	0	1
enchanted_golden_apple	2	2	20	1
enchanted_golden_apple	3	4	120	1
enchanted_golden_apple	4	1	300	1
enchanted_golden_apple	5	1	300	1
golden_apple	2	2	5	1
golden_apple	3	1	120	1
honey_bottle	6	1	0	1
poisonous_potato	7	1	5	0.6
pufferfish	8	3	15	1
pufferfish	9	1	15	1
pufferfish	7	2	60	1
chicken	8	1	30	0.3
rotten_flesh	8	1	30	0.8
spider_eye	7	1	5	1
suspicious_stew	2	1	11	0.111
suspicious_stew	10	1	11	0.111
suspicious_stew	7	1	11	0.111
suspicious_stew	11	1	11	0.111
suspicious_stew	12	1	11	0.111
suspicious_stew	13	1	11	0.111
suspicious_stew	5	1	11	0.111
suspicious_stew	14	1	11	0.111
suspicious_stew	15	1	11	0.111
\.


--
-- Data for Name: food_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.food_items (item_id, hunger, saturation) FROM stdin;
apple	4	2.4
mushroom_stew	6	7.2
bread	5	6
porkchop	3	1.8
cooked_porkchop	8	12.8
golden_apple	4	9.6
enchanted_golden_apple	4	9.6
cod	2	0.4
salmon	2	0.4
tropical_fish	1	0.2
pufferfish	1	0.2
cooked_cod	5	6
cooked_salmon	6	9.6
cake	14	2.8
cookie	2	0.4
melon_slice	2	1.2
dried_kelp	1	0.6
beef	3	1.8
cooked_beef	8	12.8
chicken	2	1.2
cooked_chicken	6	7.2
rotten_flesh	4	0.8
spider_eye	2	3.2
carrot	3	3.6
potato	1	0.6
baked_potato	5	6
poisonous_potato	2	1.2
golden_carrot	6	14.4
pumpkin_pie	8	4.8
rabbit	3	1.8
cooked_rabbit	5	6
rabbit_stew	10	12
mutton	2	1.2
cooked_mutton	6	9.6
chorus_fruit	4	2.4
beetroot	1	1.2
beetroot_soup	6	7.2
suspicious_stew	6	7.2
sweet_berries	2	0.4
glow_berries	2	0.4
honey_bottle	6	1.2
\.


--
-- Data for Name: fuel_duration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fuel_duration (item_id, fuel_duration) FROM stdin;
oak_planks	15
spruce_planks	15
birch_planks	15
jungle_planks	15
acacia_planks	15
dark_oak_planks	15
mangrove_planks	15
oak_sapling	5
spruce_sapling	5
birch_sapling	5
jungle_sapling	5
acacia_sapling	5
dark_oak_sapling	5
mangrove_propagule	5
coal_block	800
oak_log	15
spruce_log	15
birch_log	15
jungle_log	15
acacia_log	15
dark_oak_log	15
mangrove_log	15
mangrove_roots	15
stripped_oak_log	15
stripped_spruce_log	15
stripped_birch_log	15
stripped_jungle_log	15
stripped_acacia_log	15
stripped_dark_oak_log	15
stripped_mangrove_log	15
stripped_oak_wood	15
stripped_spruce_wood	15
stripped_birch_wood	15
stripped_jungle_wood	15
stripped_acacia_wood	15
stripped_dark_oak_wood	15
stripped_mangrove_wood	15
oak_wood	15
spruce_wood	15
birch_wood	15
jungle_wood	15
acacia_wood	15
dark_oak_wood	15
mangrove_wood	15
azalea	5
white_wool	15
orange_wool	15
magenta_wool	15
light_blue_wool	15
yellow_wool	15
lime_wool	15
pink_wool	15
gray_wool	15
light_gray_wool	15
cyan_wool	15
purple_wool	15
blue_wool	15
brown_wool	15
green_wool	15
red_wool	15
black_wool	15
bamboo	2
oak_slab	7
spruce_slab	7
birch_slab	7
jungle_slab	7
acacia_slab	7
dark_oak_slab	7
mangrove_slab	7
bookshelf	15
chest	15
crafting_table	15
ladder	15
jukebox	15
oak_fence	15
spruce_fence	15
birch_fence	15
jungle_fence	15
acacia_fence	15
dark_oak_fence	15
mangrove_fence	15
oak_stairs	15
spruce_stairs	15
birch_stairs	15
jungle_stairs	15
acacia_stairs	15
dark_oak_stairs	15
mangrove_stairs	15
white_carpet	15
orange_carpet	15
magenta_carpet	15
light_blue_carpet	15
yellow_carpet	15
lime_carpet	15
pink_carpet	15
gray_carpet	15
light_gray_carpet	15
cyan_carpet	15
purple_carpet	15
blue_carpet	15
brown_carpet	15
green_carpet	15
red_carpet	15
black_carpet	15
scaffolding	2
lectern	15
daylight_detector	15
trapped_chest	15
note_block	15
oak_button	5
spruce_button	5
birch_button	5
jungle_button	5
acacia_button	5
dark_oak_button	5
mangrove_button	5
oak_pressure_plate	15
spruce_pressure_plate	15
birch_pressure_plate	15
jungle_pressure_plate	15
acacia_pressure_plate	15
dark_oak_pressure_plate	15
mangrove_pressure_plate	15
oak_door	10
spruce_door	10
birch_door	10
jungle_door	10
acacia_door	10
dark_oak_door	10
mangrove_door	10
oak_trapdoor	15
spruce_trapdoor	15
birch_trapdoor	15
jungle_trapdoor	15
acacia_trapdoor	15
dark_oak_trapdoor	15
mangrove_trapdoor	15
oak_fence_gate	15
spruce_fence_gate	15
birch_fence_gate	15
jungle_fence_gate	15
acacia_fence_gate	15
dark_oak_fence_gate	15
mangrove_fence_gate	15
oak_boat	60
oak_chest_boat	60
spruce_boat	60
spruce_chest_boat	60
birch_boat	60
birch_chest_boat	60
jungle_boat	60
jungle_chest_boat	60
acacia_boat	60
acacia_chest_boat	60
dark_oak_boat	60
dark_oak_chest_boat	60
mangrove_boat	60
mangrove_chest_boat	60
bow	15
coal	80
charcoal	80
wooden_sword	10
wooden_shovel	10
wooden_pickaxe	10
wooden_axe	10
wooden_hoe	10
stick	5
bowl	5
oak_sign	10
spruce_sign	10
birch_sign	10
jungle_sign	10
acacia_sign	10
dark_oak_sign	10
mangrove_sign	10
lava_bucket	1000
dried_kelp_block	200
fishing_rod	15
blaze_rod	120
white_banner	15
orange_banner	15
magenta_banner	15
light_blue_banner	15
yellow_banner	15
lime_banner	15
pink_banner	15
gray_banner	15
light_gray_banner	15
cyan_banner	15
purple_banner	15
blue_banner	15
brown_banner	15
green_banner	15
red_banner	15
black_banner	15
crossbow	15
loom	15
composter	15
barrel	15
cartography_table	15
fletching_table	15
smithing_table	15
\.


--
-- Data for Name: items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.items (item_id, item_name, stackability, attack_speed, attack_damage, peaceful_obtainable, renewable) FROM stdin;
stone	Stone	64	4	1	t	t
granite	Granite	64	4	1	t	t
polished_granite	Polished Granite	64	4	1	t	t
diorite	Diorite	64	4	1	t	t
polished_diorite	Polished Diorite	64	4	1	t	t
andesite	Andesite	64	4	1	t	t
polished_andesite	Polished Andesite	64	4	1	t	t
deepslate	Deepslate	64	4	1	t	t
cobbled_deepslate	Cobbled Deepslate	64	4	1	t	t
polished_deepslate	Polished Deepslate	64	4	1	t	t
calcite	Calcite	64	4	1	t	t
tuff	Tuff	64	4	1	t	t
dripstone_block	Dripstone Block	64	4	1	t	t
grass_block	Grass Block	64	4	1	t	t
dirt	Dirt	64	4	1	t	t
coarse_dirt	Coarse Dirt	64	4	1	t	t
podzol	Podzol	64	4	1	t	t
rooted_dirt	Rooted Dirt	64	4	1	t	t
mud	Mud	64	4	1	t	t
crimson_nylium	Crimson Nylium	64	4	1	t	t
warped_nylium	Warped Nylium	64	4	1	t	t
cobblestone	Cobblestone	64	4	1	t	t
oak_planks	Oak Planks	64	4	1	t	t
spruce_planks	Spruce Planks	64	4	1	t	t
birch_planks	Birch Planks	64	4	1	t	t
jungle_planks	Jungle Planks	64	4	1	t	t
acacia_planks	Acacia Planks	64	4	1	t	t
dark_oak_planks	Dark Oak Planks	64	4	1	t	t
mangrove_planks	Mangrove Planks	64	4	1	t	t
crimson_planks	Crimson Planks	64	4	1	t	t
warped_planks	Warped Planks	64	4	1	t	t
oak_sapling	Oak Sapling	64	4	1	t	t
spruce_sapling	Spruce Sapling	64	4	1	t	t
birch_sapling	Birch Sapling	64	4	1	t	t
jungle_sapling	Jungle Sapling	64	4	1	t	t
acacia_sapling	Acacia Sapling	64	4	1	t	t
dark_oak_sapling	Dark Oak Sapling	64	4	1	t	t
mangrove_propagule	Mangrove Propagule	64	4	1	t	t
sand	Sand	64	4	1	t	t
red_sand	Red Sand	64	4	1	t	t
gravel	Gravel	64	4	1	t	t
coal_ore	Coal Ore	64	4	1	t	f
deepslate_coal_ore	Deepslate Coal Ore	64	4	1	t	f
iron_ore	Iron Ore	64	4	1	t	f
deepslate_iron_ore	Deepslate Iron Ore	64	4	1	t	f
copper_ore	Copper Ore	64	4	1	t	t
deepslate_copper_ore	Deepslate Copper Ore	64	4	1	t	t
gold_ore	Gold Ore	64	4	1	t	f
deepslate_gold_ore	Deepslate Gold Ore	64	4	1	t	f
redstone_ore	Redstone Ore	64	4	1	t	f
deepslate_redstone_ore	Deepslate Redstone Ore	64	4	1	t	f
emerald_ore	Emerald Ore	64	4	1	t	f
deepslate_emerald_ore	Deepslate Emerald Ore	64	4	1	t	f
lapis_ore	Lapis Lazuli Ore	64	4	1	t	f
deepslate_lapis_ore	Deepslate Lapis Lazuli Ore	64	4	1	t	f
diamond_ore	Diamond Ore	64	4	1	t	f
deepslate_diamond_ore	Deepslate Diamond Ore	64	4	1	t	f
nether_gold_ore	Nether Gold Ore	64	4	1	t	f
nether_quartz_ore	Nether Quartz Ore	64	4	1	t	f
ancient_debris	Ancient Debris	64	4	1	t	t
coal_block	Block of Coal	64	4	1	t	t
raw_iron_block	Block of Raw Iron	64	4	1	t	t
raw_copper_block	Block of Raw Copper	64	4	1	t	t
raw_gold_block	Block of Raw Gold	64	4	1	t	t
amethyst_block	Block of Amethyst	64	4	1	t	t
iron_block	Block of Iron	64	4	1	t	t
copper_block	Block of Copper	64	4	1	t	t
gold_block	Block of Gold	64	4	1	t	t
diamond_block	Block of Diamond	64	4	1	t	t
netherite_block	Block of Netherite	64	4	1	t	t
exposed_copper	Exposed Copper	64	4	1	t	t
weathered_copper	Weathered Copper	64	4	1	t	t
oxidized_copper	Oxidized Copper	64	4	1	t	t
cut_copper	Cut Copper	64	4	1	t	t
exposed_cut_copper	Exposed Cut Copper	64	4	1	t	t
weathered_cut_copper	Weathered Cut Copper	64	4	1	t	t
oxidized_cut_copper	Oxidized Cut Copper	64	4	1	t	t
cut_copper_stairs	Cut Copper Stairs	64	4	1	t	t
exposed_cut_copper_stairs	Exposed Cut Copper Stairs	64	4	1	t	t
weathered_cut_copper_stairs	Weathered Cut Copper Stairs	64	4	1	t	t
oxidized_cut_copper_stairs	Oxidized Cut Copper Stairs	64	4	1	t	t
cut_copper_slab	Cut Copper Slab	64	4	1	t	t
exposed_cut_copper_slab	Exposed Cut Copper Slab	64	4	1	t	t
weathered_cut_copper_slab	Weathered Cut Copper Slab	64	4	1	t	t
oxidized_cut_copper_slab	Oxidized Cut Copper Slab	64	4	1	t	t
waxed_copper_block	Waxed Block of Copper	64	4	1	t	t
waxed_exposed_copper	Waxed Exposed Copper	64	4	1	t	t
waxed_weathered_copper	Waxed Weathered Copper	64	4	1	t	t
waxed_oxidized_copper	Waxed Oxidized Copper	64	4	1	t	t
waxed_cut_copper	Waxed Cut Copper	64	4	1	t	t
waxed_exposed_cut_copper	Waxed Exposed Cut Copper	64	4	1	t	t
waxed_weathered_cut_copper	Waxed Weathered Cut Copper	64	4	1	t	t
waxed_oxidized_cut_copper	Waxed Oxidized Cut Copper	64	4	1	t	t
waxed_cut_copper_stairs	Waxed Cut Copper Stairs	64	4	1	t	t
waxed_exposed_cut_copper_stairs	Waxed Exposed Cut Copper Stairs	64	4	1	t	t
waxed_weathered_cut_copper_stairs	Waxed Weathered Cut Copper Stairs	64	4	1	t	t
waxed_oxidized_cut_copper_stairs	Waxed Oxidized Cut Copper Stairs	64	4	1	t	t
waxed_cut_copper_slab	Waxed Cut Copper Slab	64	4	1	t	t
waxed_exposed_cut_copper_slab	Waxed Exposed Cut Copper Slab	64	4	1	t	t
waxed_weathered_cut_copper_slab	Waxed Weathered Cut Copper Slab	64	4	1	t	t
waxed_oxidized_cut_copper_slab	Waxed Oxidized Cut Copper Slab	64	4	1	t	t
oak_log	Oak Log	64	4	1	t	t
spruce_log	Spruce Log	64	4	1	t	t
birch_log	Birch Log	64	4	1	t	t
jungle_log	Jungle Log	64	4	1	t	t
acacia_log	Acacia Log	64	4	1	t	t
dark_oak_log	Dark Oak Log	64	4	1	t	t
mangrove_log	Mangrove Log	64	4	1	t	t
mangrove_roots	Mangrove Roots	64	4	1	t	t
muddy_mangrove_roots	Muddy Mangrove Roots	64	4	1	t	t
crimson_stem	Crimson Stem	64	4	1	t	t
warped_stem	Warped Stem	64	4	1	t	t
stripped_oak_log	Stripped Oak Log	64	4	1	t	t
stripped_spruce_log	Stripped Spruce Log	64	4	1	t	t
stripped_birch_log	Stripped Birch Log	64	4	1	t	t
stripped_jungle_log	Stripped Jungle Log	64	4	1	t	t
stripped_acacia_log	Stripped Acacia Log	64	4	1	t	t
stripped_dark_oak_log	Stripped Dark Oak Log	64	4	1	t	t
stripped_mangrove_log	Stripped Mangrove Log	64	4	1	t	t
stripped_crimson_stem	Stripped Crimson Stem	64	4	1	t	t
stripped_warped_stem	Stripped Warped Stem	64	4	1	t	t
stripped_oak_wood	Stripped Oak Wood	64	4	1	t	t
stripped_spruce_wood	Stripped Spruce Wood	64	4	1	t	t
stripped_birch_wood	Stripped Birch Wood	64	4	1	t	t
stripped_jungle_wood	Stripped Jungle Wood	64	4	1	t	t
stripped_acacia_wood	Stripped Acacia Wood	64	4	1	t	t
stripped_dark_oak_wood	Stripped Dark Oak Wood	64	4	1	t	t
stripped_mangrove_wood	Stripped Mangrove Wood	64	4	1	t	t
stripped_crimson_hyphae	Stripped Crimson Hyphae	64	4	1	t	t
stripped_warped_hyphae	Stripped Warped Hyphae	64	4	1	t	t
oak_wood	Oak Wood	64	4	1	t	t
spruce_wood	Spruce Wood	64	4	1	t	t
birch_wood	Birch Wood	64	4	1	t	t
jungle_wood	Jungle Wood	64	4	1	t	t
acacia_wood	Acacia Wood	64	4	1	t	t
dark_oak_wood	Dark Oak Wood	64	4	1	t	t
mangrove_wood	Mangrove Wood	64	4	1	t	t
crimson_hyphae	Crimson Hyphae	64	4	1	t	t
warped_hyphae	Warped Hyphae	64	4	1	t	t
oak_leaves	Oak Leaves	64	4	1	t	t
spruce_leaves	Spruce Leaves	64	4	1	t	t
birch_leaves	Birch Leaves	64	4	1	t	t
jungle_leaves	Jungle Leaves	64	4	1	t	t
acacia_leaves	Acacia Leaves	64	4	1	t	t
dark_oak_leaves	Dark Oak Leaves	64	4	1	t	t
mangrove_leaves	Mangrove Leaves	64	4	1	t	t
azalea_leaves	Azalea Leaves	64	4	1	t	t
flowering_azalea_leaves	Flowering Azalea Leaves	64	4	1	t	t
sponge	Sponge	64	4	1	t	f
wet_sponge	Wet Sponge	64	4	1	t	f
glass	Glass	64	4	1	t	t
tinted_glass	Tinted Glass	64	4	1	t	t
lapis_block	Block of Lapis Lazuli	64	4	1	t	t
sandstone	Sandstone	64	4	1	t	t
chiseled_sandstone	Chiseled Sandstone	64	4	1	t	t
cut_sandstone	Cut Sandstone	64	4	1	t	t
cobweb	Cobweb	64	4	1	t	f
grass	Grass	64	4	1	t	t
fern	Fern	64	4	1	t	t
azalea	Azalea	64	4	1	t	t
flowering_azalea	Flowering Azalea	64	4	1	t	t
dead_bush	Dead Bush	64	4	1	t	f
seagrass	Seagrass	64	4	1	t	t
sea_pickle	Sea Pickle	64	4	1	t	t
white_wool	White Wool	64	4	1	t	t
orange_wool	Orange Wool	64	4	1	t	t
magenta_wool	Magenta Wool	64	4	1	t	t
light_blue_wool	Light Blue Wool	64	4	1	t	t
yellow_wool	Yellow Wool	64	4	1	t	t
lime_wool	Lime Wool	64	4	1	t	t
pink_wool	Pink Wool	64	4	1	t	t
gray_wool	Gray Wool	64	4	1	t	t
light_gray_wool	Light Gray Wool	64	4	1	t	t
cyan_wool	Cyan Wool	64	4	1	t	t
purple_wool	Purple Wool	64	4	1	t	t
blue_wool	Blue Wool	64	4	1	t	t
brown_wool	Brown Wool	64	4	1	t	t
green_wool	Green Wool	64	4	1	t	t
red_wool	Red Wool	64	4	1	t	t
black_wool	Black Wool	64	4	1	t	t
dandelion	Dandelion	64	4	1	t	t
poppy	Poppy	64	4	1	t	t
blue_orchid	Blue Orchid	64	4	1	t	t
allium	Allium	64	4	1	t	t
azure_bluet	Azure Bluet	64	4	1	t	t
red_tulip	Red Tulip	64	4	1	t	t
orange_tulip	Orange Tulip	64	4	1	t	t
white_tulip	White Tulip	64	4	1	t	t
pink_tulip	Pink Tulip	64	4	1	t	t
oxeye_daisy	Oxeye Daisy	64	4	1	t	t
cornflower	Cornflower	64	4	1	t	t
lily_of_the_valley	Lily of the Valley	64	4	1	t	t
wither_rose	Wither Rose	64	4	1	t	t
spore_blossom	Spore Blossom	64	4	1	t	f
brown_mushroom	Brown Mushroom	64	4	1	t	t
red_mushroom	Red Mushroom	64	4	1	t	t
crimson_fungus	Crimson Fungus	64	4	1	t	t
warped_fungus	Warped Fungus	64	4	1	t	t
crimson_roots	Crimson Roots	64	4	1	t	t
warped_roots	Warped Roots	64	4	1	t	t
nether_sprouts	Nether Sprouts	64	4	1	t	t
weeping_vines	Weeping Vines	64	4	1	t	t
twisting_vines	Twisting Vines	64	4	1	t	t
sugar_cane	Sugar Cane	64	4	1	t	t
kelp	Kelp	64	4	1	t	t
moss_carpet	Moss Carpet	64	4	1	t	t
moss_block	Moss Block	64	4	1	t	t
hanging_roots	Hanging Roots	64	4	1	t	t
big_dripleaf	Big Dripleaf	64	4	1	t	t
small_dripleaf	Small Dripleaf	64	4	1	t	t
bamboo	Bamboo	64	4	1	t	t
oak_slab	Oak Slab	64	4	1	t	t
spruce_slab	Spruce Slab	64	4	1	t	t
birch_slab	Birch Slab	64	4	1	t	t
jungle_slab	Jungle Slab	64	4	1	t	t
acacia_slab	Acacia Slab	64	4	1	t	t
dark_oak_slab	Dark Oak Slab	64	4	1	t	t
mangrove_slab	Mangrove Slab	64	4	1	t	t
crimson_slab	Crimson Slab	64	4	1	t	t
warped_slab	Warped Slab	64	4	1	t	t
stone_slab	Stone Slab	64	4	1	t	t
smooth_stone_slab	Smooth Stone Slab	64	4	1	t	t
sandstone_slab	Sandstone Slab	64	4	1	t	t
cut_sandstone_slab	Cut Sandstone Slab	64	4	1	t	t
cobblestone_slab	Cobblestone Slab	64	4	1	t	t
brick_slab	Brick Slab	64	4	1	t	t
stone_brick_slab	Stone Brick Slab	64	4	1	t	t
mud_brick_slab	Mud Brick Slab	64	4	1	t	t
nether_brick_slab	Nether Brick Slab	64	4	1	t	t
quartz_slab	Quartz Slab	64	4	1	t	t
red_sandstone_slab	Red Sandstone Slab	64	4	1	t	t
cut_red_sandstone_slab	Cut Red Sandstone Slab	64	4	1	t	t
purpur_slab	Purpur Slab	64	4	1	t	t
prismarine_slab	Prismarine Slab	64	4	1	t	t
prismarine_brick_slab	Prismarine Brick Slab	64	4	1	t	t
dark_prismarine_slab	Dark Prismarine Slab	64	4	1	t	t
smooth_quartz	Smooth Quartz Block	64	4	1	t	t
smooth_red_sandstone	Smooth Red Sandstone	64	4	1	t	t
smooth_sandstone	Smooth Sandstone	64	4	1	t	t
smooth_stone	Smooth Stone	64	4	1	t	t
bricks	Bricks	64	4	1	t	t
bookshelf	Bookshelf	64	4	1	t	t
mossy_cobblestone	Mossy Cobblestone	64	4	1	t	t
obsidian	Obsidian	64	4	1	t	t
torch	Torch	64	4	1	t	t
end_rod	End Rod	64	4	1	t	t
chorus_flower	Chorus Flower	64	4	1	t	t
purpur_block	Purpur Block	64	4	1	t	t
purpur_pillar	Purpur Pillar	64	4	1	t	t
purpur_stairs	Purpur Stairs	64	4	1	t	t
chest	Chest	64	4	1	t	t
crafting_table	Crafting Table	64	4	1	t	t
furnace	Furnace	64	4	1	t	t
ladder	Ladder	64	4	1	t	t
cobblestone_stairs	Cobblestone Stairs	64	4	1	t	t
snow	Snow	64	4	1	t	t
ice	Ice	64	4	1	t	t
snow_block	Snow Block	64	4	1	t	t
cactus	Cactus	64	4	1	t	t
clay	Clay	64	4	1	t	t
jukebox	Jukebox	64	4	1	t	t
oak_fence	Oak Fence	64	4	1	t	t
spruce_fence	Spruce Fence	64	4	1	t	t
birch_fence	Birch Fence	64	4	1	t	t
jungle_fence	Jungle Fence	64	4	1	t	t
acacia_fence	Acacia Fence	64	4	1	t	t
dark_oak_fence	Dark Oak Fence	64	4	1	t	t
mangrove_fence	Mangrove Fence	64	4	1	t	t
crimson_fence	Crimson Fence	64	4	1	t	t
warped_fence	Warped Fence	64	4	1	t	t
pumpkin	Pumpkin	64	4	1	t	t
carved_pumpkin	Carved Pumpkin	64	4	1	t	t
jack_o_lantern	Jack o'Lantern	64	4	1	t	t
netherrack	Netherrack	64	4	1	t	t
soul_sand	Soul Sand	64	4	1	t	t
soul_soil	Soul Soil	64	4	1	t	t
basalt	Basalt	64	4	1	t	t
polished_basalt	Polished Basalt	64	4	1	t	t
smooth_basalt	Smooth Basalt	64	4	1	t	t
soul_torch	Soul Torch	64	4	1	t	t
glowstone	Glowstone	64	4	1	t	t
stone_bricks	Stone Bricks	64	4	1	t	t
mossy_stone_bricks	Mossy Stone Bricks	64	4	1	t	t
cracked_stone_bricks	Cracked Stone Bricks	64	4	1	t	t
chiseled_stone_bricks	Chiseled Stone Bricks	64	4	1	t	t
packed_mud	Packed Mud	64	4	1	t	t
mud_bricks	Mud Bricks	64	4	1	t	t
deepslate_bricks	Deepslate Bricks	64	4	1	t	t
cracked_deepslate_bricks	Cracked Deepslate Bricks	64	4	1	t	t
deepslate_tiles	Deepslate Tiles	64	4	1	t	t
cracked_deepslate_tiles	Cracked Deepslate Tiles	64	4	1	t	t
chiseled_deepslate	Chiseled Deepslate	64	4	1	t	t
brown_mushroom_block	Brown Mushroom Block	64	4	1	t	t
red_mushroom_block	Red Mushroom Block	64	4	1	t	t
mushroom_stem	Mushroom Stem	64	4	1	t	t
iron_bars	Iron Bars	64	4	1	t	t
chain	Chain	64	4	1	t	t
glass_pane	Glass Pane	64	4	1	t	t
melon	Melon	64	4	1	t	t
vine	Vines	64	4	1	t	t
glow_lichen	Glow Lichen	64	4	1	t	t
brick_stairs	Brick Stairs	64	4	1	t	t
stone_brick_stairs	Stone Brick Stairs	64	4	1	t	t
mud_brick_stairs	Mud Brick Stairs	64	4	1	t	t
mycelium	Mycelium	64	4	1	t	t
lily_pad	Lily Pad	64	4	1	t	t
nether_bricks	Nether Bricks	64	4	1	t	t
cracked_nether_bricks	Cracked Nether Bricks	64	4	1	t	t
chiseled_nether_bricks	Chiseled Nether Bricks	64	4	1	t	t
nether_brick_fence	Nether Brick Fence	64	4	1	t	t
nether_brick_stairs	Nether Brick Stairs	64	4	1	t	t
sculk	Sculk	64	4	1	t	t
sculk_vein	Sculk Vein	64	4	1	t	t
sculk_catalyst	Sculk Catalyst	64	4	1	t	t
sculk_shrieker	Sculk Shrieker	64	4	1	t	t
enchanting_table	Enchanting Table	64	4	1	t	t
end_stone	End Stone	64	4	1	t	t
end_stone_bricks	End Stone Bricks	64	4	1	t	t
dragon_egg	Dragon Egg	64	4	1	t	t
sandstone_stairs	Sandstone Stairs	64	4	1	t	t
ender_chest	Ender Chest	64	4	1	t	t
emerald_block	Block of Emerald	64	4	1	t	t
oak_stairs	Oak Stairs	64	4	1	t	t
spruce_stairs	Spruce Stairs	64	4	1	t	t
birch_stairs	Birch Stairs	64	4	1	t	t
jungle_stairs	Jungle Stairs	64	4	1	t	t
acacia_stairs	Acacia Stairs	64	4	1	t	t
dark_oak_stairs	Dark Oak Stairs	64	4	1	t	t
mangrove_stairs	Mangrove Stairs	64	4	1	t	t
crimson_stairs	Crimson Stairs	64	4	1	t	t
warped_stairs	Warped Stairs	64	4	1	t	t
beacon	Beacon	64	4	1	t	t
cobblestone_wall	Cobblestone Wall	64	4	1	t	t
mossy_cobblestone_wall	Mossy Cobblestone Wall	64	4	1	t	t
brick_wall	Brick Wall	64	4	1	t	t
prismarine_wall	Prismarine Wall	64	4	1	t	t
red_sandstone_wall	Red Sandstone Wall	64	4	1	t	t
mossy_stone_brick_wall	Mossy Stone Brick Wall	64	4	1	t	t
granite_wall	Granite Wall	64	4	1	t	t
stone_brick_wall	Stone Brick Wall	64	4	1	t	t
mud_brick_wall	Mud Brick Wall	64	4	1	t	t
nether_brick_wall	Nether Brick Wall	64	4	1	t	t
andesite_wall	Andesite Wall	64	4	1	t	t
red_nether_brick_wall	Red Nether Brick Wall	64	4	1	t	t
sandstone_wall	Sandstone Wall	64	4	1	t	t
end_stone_brick_wall	End Stone Brick Wall	64	4	1	t	t
diorite_wall	Diorite Wall	64	4	1	t	t
blackstone_wall	Blackstone Wall	64	4	1	t	t
polished_blackstone_wall	Polished Blackstone Wall	64	4	1	t	t
polished_blackstone_brick_wall	Polished Blackstone Brick Wall	64	4	1	t	t
cobbled_deepslate_wall	Cobbled Deepslate Wall	64	4	1	t	t
polished_deepslate_wall	Polished Deepslate Wall	64	4	1	t	t
deepslate_brick_wall	Deepslate Brick Wall	64	4	1	t	t
deepslate_tile_wall	Deepslate Tile Wall	64	4	1	t	t
anvil	Anvil	64	4	1	t	t
chipped_anvil	Chipped Anvil	64	4	1	t	t
damaged_anvil	Damaged Anvil	64	4	1	t	t
chiseled_quartz_block	Chiseled Quartz Block	64	4	1	t	t
quartz_block	Block of Quartz	64	4	1	t	t
quartz_bricks	Quartz Bricks	64	4	1	t	t
quartz_pillar	Quartz Pillar	64	4	1	t	t
quartz_stairs	Quartz Stairs	64	4	1	t	t
white_terracotta	White Terracotta	64	4	1	t	t
orange_terracotta	Orange Terracotta	64	4	1	t	t
magenta_terracotta	Magenta Terracotta	64	4	1	t	t
light_blue_terracotta	Light Blue Terracotta	64	4	1	t	t
yellow_terracotta	Yellow Terracotta	64	4	1	t	t
lime_terracotta	Lime Terracotta	64	4	1	t	t
pink_terracotta	Pink Terracotta	64	4	1	t	t
gray_terracotta	Gray Terracotta	64	4	1	t	t
light_gray_terracotta	Light Gray Terracotta	64	4	1	t	t
cyan_terracotta	Cyan Terracotta	64	4	1	t	t
purple_terracotta	Purple Terracotta	64	4	1	t	t
blue_terracotta	Blue Terracotta	64	4	1	t	t
brown_terracotta	Brown Terracotta	64	4	1	t	t
green_terracotta	Green Terracotta	64	4	1	t	t
red_terracotta	Red Terracotta	64	4	1	t	t
black_terracotta	Black Terracotta	64	4	1	t	t
hay_block	Hay Bale	64	4	1	t	t
white_carpet	White Carpet	64	4	1	t	t
orange_carpet	Orange Carpet	64	4	1	t	t
magenta_carpet	Magenta Carpet	64	4	1	t	t
light_blue_carpet	Light Blue Carpet	64	4	1	t	t
yellow_carpet	Yellow Carpet	64	4	1	t	t
lime_carpet	Lime Carpet	64	4	1	t	t
pink_carpet	Pink Carpet	64	4	1	t	t
gray_carpet	Gray Carpet	64	4	1	t	t
light_gray_carpet	Light Gray Carpet	64	4	1	t	t
cyan_carpet	Cyan Carpet	64	4	1	t	t
purple_carpet	Purple Carpet	64	4	1	t	t
blue_carpet	Blue Carpet	64	4	1	t	t
brown_carpet	Brown Carpet	64	4	1	t	t
green_carpet	Green Carpet	64	4	1	t	t
red_carpet	Red Carpet	64	4	1	t	t
black_carpet	Black Carpet	64	4	1	t	t
terracotta	Terracotta	64	4	1	t	t
packed_ice	Packed Ice	64	4	1	t	t
sunflower	Sunflower	64	4	1	t	t
lilac	Lilac	64	4	1	t	t
rose_bush	Rose Bush	64	4	1	t	t
peony	Peony	64	4	1	t	t
tall_grass	Tall Grass	64	4	1	t	f
large_fern	Large Fern	64	4	1	t	f
white_stained_glass	White Stained Glass	64	4	1	t	t
orange_stained_glass	Orange Stained Glass	64	4	1	t	t
magenta_stained_glass	Magenta Stained Glass	64	4	1	t	t
light_blue_stained_glass	Light Blue Stained Glass	64	4	1	t	t
yellow_stained_glass	Yellow Stained Glass	64	4	1	t	t
lime_stained_glass	Lime Stained Glass	64	4	1	t	t
pink_stained_glass	Pink Stained Glass	64	4	1	t	t
gray_stained_glass	Gray Stained Glass	64	4	1	t	t
light_gray_stained_glass	Light Gray Stained Glass	64	4	1	t	t
cyan_stained_glass	Cyan Stained Glass	64	4	1	t	t
purple_stained_glass	Purple Stained Glass	64	4	1	t	t
blue_stained_glass	Blue Stained Glass	64	4	1	t	t
brown_stained_glass	Brown Stained Glass	64	4	1	t	t
green_stained_glass	Green Stained Glass	64	4	1	t	t
red_stained_glass	Red Stained Glass	64	4	1	t	t
black_stained_glass	Black Stained Glass	64	4	1	t	t
white_stained_glass_pane	White Stained Glass Pane	64	4	1	t	t
orange_stained_glass_pane	Orange Stained Glass Pane	64	4	1	t	t
magenta_stained_glass_pane	Magenta Stained Glass Pane	64	4	1	t	t
light_blue_stained_glass_pane	Light Blue Stained Glass Pane	64	4	1	t	t
yellow_stained_glass_pane	Yellow Stained Glass Pane	64	4	1	t	t
lime_stained_glass_pane	Lime Stained Glass Pane	64	4	1	t	t
pink_stained_glass_pane	Pink Stained Glass Pane	64	4	1	t	t
gray_stained_glass_pane	Gray Stained Glass Pane	64	4	1	t	t
light_gray_stained_glass_pane	Light Gray Stained Glass Pane	64	4	1	t	t
cyan_stained_glass_pane	Cyan Stained Glass Pane	64	4	1	t	t
purple_stained_glass_pane	Purple Stained Glass Pane	64	4	1	t	t
blue_stained_glass_pane	Blue Stained Glass Pane	64	4	1	t	t
brown_stained_glass_pane	Brown Stained Glass Pane	64	4	1	t	t
green_stained_glass_pane	Green Stained Glass Pane	64	4	1	t	t
red_stained_glass_pane	Red Stained Glass Pane	64	4	1	t	t
black_stained_glass_pane	Black Stained Glass Pane	64	4	1	t	t
prismarine	Prismarine	64	4	1	t	t
prismarine_bricks	Prismarine Bricks	64	4	1	t	t
dark_prismarine	Dark Prismarine	64	4	1	t	t
prismarine_stairs	Prismarine Stairs	64	4	1	t	t
prismarine_brick_stairs	Prismarine Brick Stairs	64	4	1	t	t
dark_prismarine_stairs	Dark Prismarine Stairs	64	4	1	t	t
sea_lantern	Sea Lantern	64	4	1	t	t
red_sandstone	Red Sandstone	64	4	1	t	t
chiseled_red_sandstone	Chiseled Red Sandstone	64	4	1	t	t
cut_red_sandstone	Cut Red Sandstone	64	4	1	t	t
red_sandstone_stairs	Red Sandstone Stairs	64	4	1	t	t
magma_block	Magma Block	64	4	1	t	t
nether_wart_block	Nether Wart Block	64	4	1	t	t
warped_wart_block	Warped Wart Block	64	4	1	t	t
red_nether_bricks	Red Nether Bricks	64	4	1	t	t
bone_block	Bone Block	64	4	1	t	t
shulker_box	Shulker Box	1	4	1	t	t
white_shulker_box	White Shulker Box	1	4	1	t	t
orange_shulker_box	Orange Shulker Box	1	4	1	t	t
magenta_shulker_box	Magenta Shulker Box	1	4	1	t	t
light_blue_shulker_box	Light Blue Shulker Box	1	4	1	t	t
yellow_shulker_box	Yellow Shulker Box	1	4	1	t	t
lime_shulker_box	Lime Shulker Box	1	4	1	t	t
pink_shulker_box	Pink Shulker Box	1	4	1	t	t
gray_shulker_box	Gray Shulker Box	1	4	1	t	t
light_gray_shulker_box	Light Gray Shulker Box	1	4	1	t	t
cyan_shulker_box	Cyan Shulker Box	1	4	1	t	t
purple_shulker_box	Purple Shulker Box	1	4	1	t	t
blue_shulker_box	Blue Shulker Box	1	4	1	t	t
brown_shulker_box	Brown Shulker Box	1	4	1	t	t
green_shulker_box	Green Shulker Box	1	4	1	t	t
red_shulker_box	Red Shulker Box	1	4	1	t	t
black_shulker_box	Black Shulker Box	1	4	1	t	t
white_glazed_terracotta	White Glazed Terracotta	64	4	1	t	t
orange_glazed_terracotta	Orange Glazed Terracotta	64	4	1	t	t
magenta_glazed_terracotta	Magenta Glazed Terracotta	64	4	1	t	t
light_blue_glazed_terracotta	Light Blue Glazed Terracotta	64	4	1	t	t
yellow_glazed_terracotta	Yellow Glazed Terracotta	64	4	1	t	t
lime_glazed_terracotta	Lime Glazed Terracotta	64	4	1	t	t
pink_glazed_terracotta	Pink Glazed Terracotta	64	4	1	t	t
gray_glazed_terracotta	Gray Glazed Terracotta	64	4	1	t	t
light_gray_glazed_terracotta	Light Gray Glazed Terracotta	64	4	1	t	t
cyan_glazed_terracotta	Cyan Glazed Terracotta	64	4	1	t	t
purple_glazed_terracotta	Purple Glazed Terracotta	64	4	1	t	t
blue_glazed_terracotta	Blue Glazed Terracotta	64	4	1	t	t
brown_glazed_terracotta	Brown Glazed Terracotta	64	4	1	t	t
green_glazed_terracotta	Green Glazed Terracotta	64	4	1	t	t
red_glazed_terracotta	Red Glazed Terracotta	64	4	1	t	t
black_glazed_terracotta	Black Glazed Terracotta	64	4	1	t	t
white_concrete	White Concrete	64	4	1	t	t
orange_concrete	Orange Concrete	64	4	1	t	t
magenta_concrete	Magenta Concrete	64	4	1	t	t
light_blue_concrete	Light Blue Concrete	64	4	1	t	t
yellow_concrete	Yellow Concrete	64	4	1	t	t
lime_concrete	Lime Concrete	64	4	1	t	t
pink_concrete	Pink Concrete	64	4	1	t	t
gray_concrete	Gray Concrete	64	4	1	t	t
light_gray_concrete	Light Gray Concrete	64	4	1	t	t
cyan_concrete	Cyan Concrete	64	4	1	t	t
purple_concrete	Purple Concrete	64	4	1	t	t
blue_concrete	Blue Concrete	64	4	1	t	t
brown_concrete	Brown Concrete	64	4	1	t	t
green_concrete	Green Concrete	64	4	1	t	t
red_concrete	Red Concrete	64	4	1	t	t
black_concrete	Black Concrete	64	4	1	t	t
white_concrete_powder	White Concrete Powder	64	4	1	t	t
orange_concrete_powder	Orange Concrete Powder	64	4	1	t	t
magenta_concrete_powder	Magenta Concrete Powder	64	4	1	t	t
light_blue_concrete_powder	Light Blue Concrete Powder	64	4	1	t	t
yellow_concrete_powder	Yellow Concrete Powder	64	4	1	t	t
lime_concrete_powder	Lime Concrete Powder	64	4	1	t	t
pink_concrete_powder	Pink Concrete Powder	64	4	1	t	t
gray_concrete_powder	Gray Concrete Powder	64	4	1	t	t
light_gray_concrete_powder	Light Gray Concrete Powder	64	4	1	t	t
cyan_concrete_powder	Cyan Concrete Powder	64	4	1	t	t
purple_concrete_powder	Purple Concrete Powder	64	4	1	t	t
blue_concrete_powder	Blue Concrete Powder	64	4	1	t	t
brown_concrete_powder	Brown Concrete Powder	64	4	1	t	t
green_concrete_powder	Green Concrete Powder	64	4	1	t	t
red_concrete_powder	Red Concrete Powder	64	4	1	t	t
black_concrete_powder	Black Concrete Powder	64	4	1	t	t
turtle_egg	Turtle Egg	64	4	1	t	t
dead_tube_coral_block	Dead Tube Coral Block	64	4	1	t	t
dead_brain_coral_block	Dead Brain Coral Block	64	4	1	t	t
dead_bubble_coral_block	Dead Bubble Coral Block	64	4	1	t	t
dead_fire_coral_block	Dead Fire Coral Block	64	4	1	t	t
dead_horn_coral_block	Dead Horn Coral Block	64	4	1	t	t
tube_coral_block	Tube Coral Block	64	4	1	t	t
brain_coral_block	Brain Coral Block	64	4	1	t	t
bubble_coral_block	Bubble Coral Block	64	4	1	t	t
fire_coral_block	Fire Coral Block	64	4	1	t	t
horn_coral_block	Horn Coral Block	64	4	1	t	t
tube_coral	Tube Coral	64	4	1	t	t
brain_coral	Brain Coral	64	4	1	t	t
bubble_coral	Bubble Coral	64	4	1	t	t
fire_coral	Fire Coral	64	4	1	t	t
horn_coral	Horn Coral	64	4	1	t	t
dead_brain_coral	Dead Brain Coral	64	4	1	t	t
dead_bubble_coral	Dead Bubble Coral	64	4	1	t	t
dead_fire_coral	Dead Fire Coral	64	4	1	t	t
dead_horn_coral	Dead Horn Coral	64	4	1	t	t
dead_tube_coral	Dead Tube Coral	64	4	1	t	t
tube_coral_fan	Tube Coral Fan	64	4	1	t	t
brain_coral_fan	Brain Coral Fan	64	4	1	t	t
bubble_coral_fan	Bubble Coral Fan	64	4	1	t	t
fire_coral_fan	Fire Coral Fan	64	4	1	t	t
horn_coral_fan	Horn Coral Fan	64	4	1	t	t
dead_tube_coral_fan	Dead Tube Coral Fan	64	4	1	t	t
dead_brain_coral_fan	Dead Brain Coral Fan	64	4	1	t	t
dead_bubble_coral_fan	Dead Bubble Coral Fan	64	4	1	t	t
dead_fire_coral_fan	Dead Fire Coral Fan	64	4	1	t	t
dead_horn_coral_fan	Dead Horn Coral Fan	64	4	1	t	t
blue_ice	Blue Ice	64	4	1	t	t
conduit	Conduit	64	4	1	t	t
polished_granite_stairs	Polished Granite Stairs	64	4	1	t	t
smooth_red_sandstone_stairs	Smooth Red Sandstone Stairs	64	4	1	t	t
mossy_stone_brick_stairs	Mossy Stone Brick Stairs	64	4	1	t	t
polished_diorite_stairs	Polished Diorite Stairs	64	4	1	t	t
mossy_cobblestone_stairs	Mossy Cobblestone Stairs	64	4	1	t	t
end_stone_brick_stairs	End Stone Brick Stairs	64	4	1	t	t
stone_stairs	Stone Stairs	64	4	1	t	t
smooth_sandstone_stairs	Smooth Sandstone Stairs	64	4	1	t	t
smooth_quartz_stairs	Smooth Quartz Stairs	64	4	1	t	t
granite_stairs	Granite Stairs	64	4	1	t	t
andesite_stairs	Andesite Stairs	64	4	1	t	t
red_nether_brick_stairs	Red Nether Brick Stairs	64	4	1	t	t
polished_andesite_stairs	Polished Andesite Stairs	64	4	1	t	t
diorite_stairs	Diorite Stairs	64	4	1	t	t
cobbled_deepslate_stairs	Cobbled Deepslate Stairs	64	4	1	t	t
polished_deepslate_stairs	Polished Deepslate Stairs	64	4	1	t	t
deepslate_brick_stairs	Deepslate Brick Stairs	64	4	1	t	t
deepslate_tile_stairs	Deepslate Tile Stairs	64	4	1	t	t
polished_granite_slab	Polished Granite Slab	64	4	1	t	t
smooth_red_sandstone_slab	Smooth Red Sandstone Slab	64	4	1	t	t
mossy_stone_brick_slab	Mossy Stone Brick Slab	64	4	1	t	t
polished_diorite_slab	Polished Diorite Slab	64	4	1	t	t
mossy_cobblestone_slab	Mossy Cobblestone Slab	64	4	1	t	t
end_stone_brick_slab	End Stone Brick Slab	64	4	1	t	t
smooth_sandstone_slab	Smooth Sandstone Slab	64	4	1	t	t
smooth_quartz_slab	Smooth Quartz Slab	64	4	1	t	t
granite_slab	Granite Slab	64	4	1	t	t
andesite_slab	Andesite Slab	64	4	1	t	t
red_nether_brick_slab	Red Nether Brick Slab	64	4	1	t	t
polished_andesite_slab	Polished Andesite Slab	64	4	1	t	t
diorite_slab	Diorite Slab	64	4	1	t	t
cobbled_deepslate_slab	Cobbled Deepslate Slab	64	4	1	t	t
polished_deepslate_slab	Polished Deepslate Slab	64	4	1	t	t
deepslate_brick_slab	Deepslate Brick Slab	64	4	1	t	t
deepslate_tile_slab	Deepslate Tile Slab	64	4	1	t	t
scaffolding	Scaffolding	64	4	1	t	t
redstone	Redstone Dust	64	4	1	t	t
redstone_torch	Redstone Torch	64	4	1	t	t
redstone_block	Block of Redstone	64	4	1	t	t
repeater	Redstone Repeater	64	4	1	t	t
comparator	Redstone Comparator	64	4	1	t	t
piston	Piston	64	4	1	t	t
sticky_piston	Sticky Piston	64	4	1	t	t
slime_block	Slime Block	64	4	1	t	t
honey_block	Honey Block	64	4	1	t	t
observer	Observer	64	4	1	t	t
hopper	Hopper	64	4	1	t	t
dispenser	Dispenser	64	4	1	t	t
dropper	Dropper	64	4	1	t	t
lectern	Lectern	64	4	1	t	t
target	Target	64	4	1	t	t
lever	Lever	64	4	1	t	t
lightning_rod	Lightning Rod	64	4	1	t	t
daylight_detector	Daylight Detector	64	4	1	t	t
sculk_sensor	Sculk Sensor	64	4	1	t	t
tripwire_hook	Tripwire Hook	64	4	1	t	t
trapped_chest	Trapped Chest	64	4	1	t	t
tnt	TNT	64	4	1	t	t
redstone_lamp	Redstone Lamp	64	4	1	t	t
note_block	Note Block	64	4	1	t	t
stone_button	Stone Button	64	4	1	t	t
polished_blackstone_button	Polished Blackstone Button	64	4	1	t	t
oak_button	Oak Button	64	4	1	t	t
spruce_button	Spruce Button	64	4	1	t	t
birch_button	Birch Button	64	4	1	t	t
jungle_button	Jungle Button	64	4	1	t	t
acacia_button	Acacia Button	64	4	1	t	t
dark_oak_button	Dark Oak Button	64	4	1	t	t
mangrove_button	Mangrove Button	64	4	1	t	t
crimson_button	Crimson Button	64	4	1	t	t
warped_button	Warped Button	64	4	1	t	t
stone_pressure_plate	Stone Pressure Plate	64	4	1	t	t
polished_blackstone_pressure_plate	Polished Blackstone Pressure Plate	64	4	1	t	t
light_weighted_pressure_plate	Light Weighted Pressure Plate	64	4	1	t	t
heavy_weighted_pressure_plate	Heavy Weighted Pressure Plate	64	4	1	t	t
oak_pressure_plate	Oak Pressure Plate	64	4	1	t	t
spruce_pressure_plate	Spruce Pressure Plate	64	4	1	t	t
birch_pressure_plate	Birch Pressure Plate	64	4	1	t	t
jungle_pressure_plate	Jungle Pressure Plate	64	4	1	t	t
acacia_pressure_plate	Acacia Pressure Plate	64	4	1	t	t
dark_oak_pressure_plate	Dark Oak Pressure Plate	64	4	1	t	t
mangrove_pressure_plate	Mangrove Pressure Plate	64	4	1	t	t
crimson_pressure_plate	Crimson Pressure Plate	64	4	1	t	t
warped_pressure_plate	Warped Pressure Plate	64	4	1	t	t
iron_door	Iron Door	64	4	1	t	t
oak_door	Oak Door	64	4	1	t	t
spruce_door	Spruce Door	64	4	1	t	t
birch_door	Birch Door	64	4	1	t	t
jungle_door	Jungle Door	64	4	1	t	t
acacia_door	Acacia Door	64	4	1	t	t
dark_oak_door	Dark Oak Door	64	4	1	t	t
mangrove_door	Mangrove Door	64	4	1	t	t
crimson_door	Crimson Door	64	4	1	t	t
warped_door	Warped Door	64	4	1	t	t
iron_trapdoor	Iron Trapdoor	64	4	1	t	t
oak_trapdoor	Oak Trapdoor	64	4	1	t	t
spruce_trapdoor	Spruce Trapdoor	64	4	1	t	t
birch_trapdoor	Birch Trapdoor	64	4	1	t	t
jungle_trapdoor	Jungle Trapdoor	64	4	1	t	t
acacia_trapdoor	Acacia Trapdoor	64	4	1	t	t
dark_oak_trapdoor	Dark Oak Trapdoor	64	4	1	t	t
mangrove_trapdoor	Mangrove Trapdoor	64	4	1	t	t
crimson_trapdoor	Crimson Trapdoor	64	4	1	t	t
warped_trapdoor	Warped Trapdoor	64	4	1	t	t
oak_fence_gate	Oak Fence Gate	64	4	1	t	t
spruce_fence_gate	Spruce Fence Gate	64	4	1	t	t
birch_fence_gate	Birch Fence Gate	64	4	1	t	t
jungle_fence_gate	Jungle Fence Gate	64	4	1	t	t
acacia_fence_gate	Acacia Fence Gate	64	4	1	t	t
dark_oak_fence_gate	Dark Oak Fence Gate	64	4	1	t	t
mangrove_fence_gate	Mangrove Fence Gate	64	4	1	t	t
crimson_fence_gate	Crimson Fence Gate	64	4	1	t	t
warped_fence_gate	Warped Fence Gate	64	4	1	t	t
powered_rail	Powered Rail	64	4	1	t	t
detector_rail	Detector Rail	64	4	1	t	t
rail	Rail	64	4	1	t	t
activator_rail	Activator Rail	64	4	1	t	t
saddle	Saddle	1	4	1	t	t
minecart	Minecart	1	4	1	t	t
chest_minecart	Minecart with Chest	1	4	1	t	t
furnace_minecart	Minecart with Furnace	1	4	1	t	t
tnt_minecart	Minecart with TNT	1	4	1	t	t
hopper_minecart	Minecart with Hopper	1	4	1	t	t
carrot_on_a_stick	Carrot on a Stick	1	4	1	t	t
warped_fungus_on_a_stick	Warped Fungus on a Stick	1	4	1	t	t
elytra	Elytra	1	4	1	t	f
oak_boat	Oak Boat	1	4	1	t	t
oak_chest_boat	Oak Boat with Chest	1	4	1	t	t
spruce_boat	Spruce Boat	1	4	1	t	t
spruce_chest_boat	Spruce Boat with Chest	1	4	1	t	t
birch_boat	Birch Boat	1	4	1	t	t
birch_chest_boat	Birch Boat with Chest	1	4	1	t	t
jungle_boat	Jungle Boat	1	4	1	t	t
jungle_chest_boat	Jungle Boat with Chest	1	4	1	t	t
acacia_boat	Acacia Boat	1	4	1	t	t
acacia_chest_boat	Acacia Boat with Chest	1	4	1	t	t
dark_oak_boat	Dark Oak Boat	1	4	1	t	t
dark_oak_chest_boat	Dark Oak Boat with Chest	1	4	1	t	t
mangrove_boat	Mangrove Boat	1	4	1	t	t
mangrove_chest_boat	Mangrove Boat with Chest	1	4	1	t	t
turtle_helmet	Turtle Shell	1	4	1	t	t
scute	Scute	64	4	1	t	t
flint_and_steel	Flint and Steel	1	4	1	t	t
apple	Apple	64	4	1	t	t
bow	Bow	1	4	1	t	t
arrow	Arrow	64	4	1	t	t
coal	Coal	64	4	1	t	t
charcoal	Charcoal	64	4	1	t	t
diamond	Diamond	64	4	1	t	t
emerald	Emerald	64	4	1	t	t
lapis_lazuli	Lapis Lazuli	64	4	1	t	t
quartz	Nether Quartz	64	4	1	t	t
amethyst_shard	Amethyst Shard	64	4	1	t	t
raw_iron	Raw Iron	64	4	1	t	t
iron_ingot	Iron Ingot	64	4	1	t	t
raw_copper	Raw Copper	64	4	1	t	t
copper_ingot	Copper Ingot	64	4	1	t	t
raw_gold	Raw Gold	64	4	1	t	t
gold_ingot	Gold Ingot	64	4	1	t	t
netherite_ingot	Netherite Ingot	64	4	1	t	t
netherite_scrap	Netherite Scrap	64	4	1	t	t
wooden_sword	Wooden Sword	1	1.6	4	t	t
wooden_shovel	Wooden Shovel	1	1	2.5	t	t
wooden_pickaxe	Wooden Pickaxe	1	1.2	2	t	t
wooden_axe	Wooden Axe	1	0.8	7	t	t
wooden_hoe	Wooden Hoe	1	1	1	t	t
stone_sword	Stone Sword	1	1.6	5	t	t
stone_shovel	Stone Shovel	1	1	3.5	t	t
stone_pickaxe	Stone Pickaxe	1	1.2	3	t	t
stone_axe	Stone Axe	1	0.8	9	t	t
stone_hoe	Stone Hoe	1	2	1	t	t
golden_sword	Golden Sword	1	1.6	4	t	t
golden_shovel	Golden Shovel	1	1	2.5	t	t
golden_pickaxe	Golden Pickaxe	1	1.2	2	t	t
golden_axe	Golden Axe	1	1	7	t	t
golden_hoe	Golden Hoe	1	1	1	t	t
iron_sword	Iron Sword	1	1.6	6	t	t
iron_shovel	Iron Shovel	1	1	4.5	t	t
iron_pickaxe	Iron Pickaxe	1	1.2	4	t	t
iron_axe	Iron Axe	1	0.9	9	t	t
iron_hoe	Iron Hoe	1	3	1	t	t
diamond_sword	Diamond Sword	1	1.6	7	t	t
diamond_shovel	Diamond Shovel	1	1	5.5	t	t
diamond_pickaxe	Diamond Pickaxe	1	1.2	5	t	t
diamond_axe	Diamond Axe	1	1	9	t	t
diamond_hoe	Diamond Hoe	1	4	1	t	t
netherite_sword	Netherite Sword	1	1.6	8	t	t
netherite_shovel	Netherite Shovel	1	1	6.5	t	t
netherite_pickaxe	Netherite Pickaxe	1	1.2	6	t	t
netherite_axe	Netherite Axe	1	1	10	t	t
netherite_hoe	Netherite Hoe	1	4	1	t	t
stick	Stick	64	4	1	t	t
bowl	Bowl	64	4	1	t	t
mushroom_stew	Mushroom Stew	1	4	1	t	t
string	String	64	4	1	t	t
feather	Feather	64	4	1	t	t
gunpowder	Gunpowder	64	4	1	t	t
wheat_seeds	Wheat Seeds	64	4	1	t	t
wheat	Wheat	64	4	1	t	t
bread	Bread	64	4	1	t	t
leather_helmet	Leather Cap	1	4	1	t	t
leather_chestplate	Leather Tunic	1	4	1	t	t
leather_leggings	Leather Pants	1	4	1	t	t
leather_boots	Leather Boots	1	4	1	t	t
chainmail_helmet	Chainmail Helmet	1	4	1	t	t
chainmail_chestplate	Chainmail Chestplate	1	4	1	t	t
chainmail_leggings	Chainmail Leggings	1	4	1	t	t
chainmail_boots	Chainmail Boots	1	4	1	t	t
iron_helmet	Iron Helmet	1	4	1	t	t
iron_chestplate	Iron Chestplate	1	4	1	t	t
iron_leggings	Iron Leggings	1	4	1	t	t
iron_boots	Iron Boots	1	4	1	t	t
diamond_helmet	Diamond Helmet	1	4	1	t	t
diamond_chestplate	Diamond Chestplate	1	4	1	t	t
diamond_leggings	Diamond Leggings	1	4	1	t	t
diamond_boots	Diamond Boots	1	4	1	t	t
golden_helmet	Golden Helmet	1	4	1	t	t
golden_chestplate	Golden Chestplate	1	4	1	t	t
golden_leggings	Golden Leggings	1	4	1	t	t
golden_boots	Golden Boots	1	4	1	t	t
netherite_helmet	Netherite Helmet	1	4	1	t	t
netherite_chestplate	Netherite Chestplate	1	4	1	t	t
netherite_leggings	Netherite Leggings	1	4	1	t	t
netherite_boots	Netherite Boots	1	4	1	t	t
flint	Flint	64	4	1	t	t
porkchop	Raw Porkchop	64	4	1	t	t
cooked_porkchop	Cooked Porkchop	64	4	1	t	t
painting	Painting	64	4	1	t	t
golden_apple	Golden Apple	64	4	1	t	t
enchanted_golden_apple	Enchanted Golden Apple	64	4	1	t	f
oak_sign	Oak Sign	16	4	1	t	t
spruce_sign	Spruce Sign	16	4	1	t	t
birch_sign	Birch Sign	16	4	1	t	t
jungle_sign	Jungle Sign	16	4	1	t	t
acacia_sign	Acacia Sign	16	4	1	t	t
dark_oak_sign	Dark Oak Sign	16	4	1	t	t
mangrove_sign	Mangrove Sign	16	4	1	t	t
crimson_sign	Crimson Sign	16	4	1	t	t
warped_sign	Warped Sign	16	4	1	t	t
bucket	Bucket	16	4	1	t	t
water_bucket	Water Bucket	1	4	1	t	t
lava_bucket	Lava Bucket	1	4	1	t	t
powder_snow_bucket	Powder Snow Bucket	1	4	1	t	t
snowball	Snowball	16	4	1	t	t
leather	Leather	64	4	1	t	t
milk_bucket	Milk Bucket	1	4	1	t	t
pufferfish_bucket	Bucket of Pufferfish	1	4	1	t	t
salmon_bucket	Bucket of Salmon	1	4	1	t	t
cod_bucket	Bucket of Cod	1	4	1	t	t
tropical_fish_bucket	Bucket of Tropical Fish	1	4	1	t	t
axolotl_bucket	Bucket of Axolotl	1	4	1	t	t
tadpole_bucket	Bucket of Tadpole	1	4	1	t	t
brick	Brick	64	4	1	t	t
clay_ball	Clay Ball	64	4	1	t	t
dried_kelp_block	Dried Kelp Block	64	4	1	t	t
paper	Paper	64	4	1	t	t
book	Book	64	4	1	t	t
slime_ball	Slimeball	64	4	1	t	t
egg	Egg	16	4	1	t	t
compass	Compass	64	4	1	t	t
recovery_compass	Recovery Compass	64	4	1	t	t
fishing_rod	Fishing Rod	1	4	1	t	t
clock	Clock	64	4	1	t	t
spyglass	Spyglass	1	4	1	t	t
glowstone_dust	Glowstone Dust	64	4	1	t	t
cod	Raw Cod	64	4	1	t	t
salmon	Raw Salmon	64	4	1	t	t
tropical_fish	Tropical Fish	64	4	1	t	t
pufferfish	Pufferfish	64	4	1	t	t
cooked_cod	Cooked Cod	64	4	1	t	t
cooked_salmon	Cooked Salmon	64	4	1	t	t
ink_sac	Ink Sac	64	4	1	t	t
glow_ink_sac	Glow Ink Sac	64	4	1	t	t
cocoa_beans	Cocoa Beans	64	4	1	t	t
white_dye	White Dye	64	4	1	t	t
orange_dye	Orange Dye	64	4	1	t	t
magenta_dye	Magenta Dye	64	4	1	t	t
light_blue_dye	Light Blue Dye	64	4	1	t	t
yellow_dye	Yellow Dye	64	4	1	t	t
lime_dye	Lime Dye	64	4	1	t	t
pink_dye	Pink Dye	64	4	1	t	t
gray_dye	Gray Dye	64	4	1	t	t
light_gray_dye	Light Gray Dye	64	4	1	t	t
cyan_dye	Cyan Dye	64	4	1	t	t
purple_dye	Purple Dye	64	4	1	t	t
blue_dye	Blue Dye	64	4	1	t	t
brown_dye	Brown Dye	64	4	1	t	t
green_dye	Green Dye	64	4	1	t	t
red_dye	Red Dye	64	4	1	t	t
black_dye	Black Dye	64	4	1	t	t
bone_meal	Bone Meal	64	4	1	t	t
bone	Bone	64	4	1	t	t
sugar	Sugar	64	4	1	t	t
cake	Cake	1	4	1	t	t
white_bed	White Bed	1	4	1	t	t
orange_bed	Orange Bed	1	4	1	t	t
magenta_bed	Magenta Bed	1	4	1	t	t
light_blue_bed	Light Blue Bed	1	4	1	t	t
yellow_bed	Yellow Bed	1	4	1	t	t
lime_bed	Lime Bed	1	4	1	t	t
pink_bed	Pink Bed	1	4	1	t	t
gray_bed	Gray Bed	1	4	1	t	t
light_gray_bed	Light Gray Bed	1	4	1	t	t
cyan_bed	Cyan Bed	1	4	1	t	t
purple_bed	Purple Bed	1	4	1	t	t
blue_bed	Blue Bed	1	4	1	t	t
brown_bed	Brown Bed	1	4	1	t	t
green_bed	Green Bed	1	4	1	t	t
red_bed	Red Bed	1	4	1	t	t
black_bed	Black Bed	1	4	1	t	t
cookie	Cookie	64	4	1	t	t
filled_map	Map	64	4	1	t	t
shears	Shears	1	4	1	t	t
melon_slice	Melon Slice	64	4	1	t	t
dried_kelp	Dried Kelp	64	4	1	t	t
pumpkin_seeds	Pumpkin Seeds	64	4	1	t	t
melon_seeds	Melon Seeds	64	4	1	t	t
beef	Raw Beef	64	4	1	t	t
cooked_beef	Steak	64	4	1	t	t
chicken	Raw Chicken	64	4	1	t	t
cooked_chicken	Cooked Chicken	64	4	1	t	t
rotten_flesh	Rotten Flesh	64	4	1	t	t
ender_pearl	Ender Pearl	16	4	1	t	t
blaze_rod	Blaze Rod	64	4	1	t	t
ghast_tear	Ghast Tear	64	4	1	t	t
gold_nugget	Gold Nugget	64	4	1	t	t
nether_wart	Nether Wart	64	4	1	t	t
glass_bottle	Glass Bottle	64	4	1	t	t
spider_eye	Spider Eye	64	4	1	t	t
fermented_spider_eye	Fermented Spider Eye	64	4	1	t	t
blaze_powder	Blaze Powder	64	4	1	t	t
magma_cream	Magma Cream	64	4	1	t	t
brewing_stand	Brewing Stand	64	4	1	t	t
cauldron	Cauldron	64	4	1	t	t
ender_eye	Eye of Ender	64	4	1	t	t
glistering_melon_slice	Glistering Melon Slice	64	4	1	t	t
experience_bottle	Bottle o' Enchanting	64	4	1	t	t
fire_charge	Fire Charge	64	4	1	t	t
writable_book	Book and Quill	1	4	1	t	t
written_book	Written Book	16	4	1	t	t
item_frame	Item Frame	64	4	1	t	t
glow_item_frame	Glow Item Frame	64	4	1	t	t
flower_pot	Flower Pot	64	4	1	t	t
carrot	Carrot	64	4	1	t	t
potato	Potato	64	4	1	t	t
baked_potato	Baked Potato	64	4	1	t	t
poisonous_potato	Poisonous Potato	64	4	1	t	t
map	Empty Map	64	4	1	t	t
golden_carrot	Golden Carrot	64	4	1	t	t
skeleton_skull	Skeleton Skull	64	4	1	t	t
wither_skeleton_skull	Wither Skeleton Skull	64	4	1	t	t
zombie_head	Zombie Head	64	4	1	t	t
creeper_head	Creeper Head	64	4	1	t	t
dragon_head	Dragon Head	64	4	1	t	f
nether_star	Nether Star	64	4	1	t	t
pumpkin_pie	Pumpkin Pie	64	4	1	t	t
firework_rocket	Firework Rocket	64	4	1	t	t
firework_star	Firework Star	64	4	1	t	t
enchanted_book	Enchanted Book	1	4	1	t	t
nether_brick	Nether Brick	64	4	1	t	t
prismarine_shard	Prismarine Shard	64	4	1	t	t
prismarine_crystals	Prismarine Crystals	64	4	1	t	t
rabbit	Raw Rabbit	64	4	1	t	t
cooked_rabbit	Cooked Rabbit	64	4	1	t	t
rabbit_stew	Rabbit Stew	1	4	1	t	t
rabbit_foot	Rabbit's Foot	64	4	1	t	t
rabbit_hide	Rabbit Hide	64	4	1	t	t
armor_stand	Armor Stand	16	4	1	t	t
iron_horse_armor	Iron Horse Armor	1	4	1	t	f
golden_horse_armor	Golden Horse Armor	1	4	1	t	f
diamond_horse_armor	Diamond Horse Armor	1	4	1	t	f
leather_horse_armor	Leather Horse Armor	1	4	1	t	t
lead	Lead	64	4	1	t	t
name_tag	Name Tag	64	4	1	t	t
mutton	Raw Mutton	64	4	1	t	t
cooked_mutton	Cooked Mutton	64	4	1	t	t
white_banner	White Banner	16	4	1	t	t
orange_banner	Orange Banner	16	4	1	t	t
magenta_banner	Magenta Banner	16	4	1	t	t
light_blue_banner	Light Blue Banner	16	4	1	t	t
yellow_banner	Yellow Banner	16	4	1	t	t
lime_banner	Lime Banner	16	4	1	t	t
pink_banner	Pink Banner	16	4	1	t	t
gray_banner	Gray Banner	16	4	1	t	t
light_gray_banner	Light Gray Banner	16	4	1	t	t
cyan_banner	Cyan Banner	16	4	1	t	t
purple_banner	Purple Banner	16	4	1	t	t
blue_banner	Blue Banner	16	4	1	t	t
brown_banner	Brown Banner	16	4	1	t	t
green_banner	Green Banner	16	4	1	t	t
red_banner	Red Banner	16	4	1	t	t
black_banner	Black Banner	16	4	1	t	t
end_crystal	End Crystal	64	4	1	t	t
chorus_fruit	Chorus Fruit	64	4	1	t	t
popped_chorus_fruit	Popped Chorus Fruit	64	4	1	t	t
beetroot	Beetroot	64	4	1	t	t
beetroot_seeds	Beetroot Seeds	64	4	1	t	t
beetroot_soup	Beetroot Soup	1	4	1	t	t
dragon_breath	Dragon's Breath	64	4	1	t	t
spectral_arrow	Spectral Arrow	64	4	1	t	t
shield	Shield	1	4	1	t	t
totem_of_undying	Totem of Undying	1	4	1	t	t
shulker_shell	Shulker Shell	64	4	1	t	t
iron_nugget	Iron Nugget	64	4	1	t	t
music_disc_13	13 Disc	1	4	1	t	t
music_disc_cat	Cat Disc	1	4	1	t	t
music_disc_blocks	Blocks Disc	1	4	1	t	t
music_disc_chirp	Chirp Disc	1	4	1	t	t
music_disc_far	Far Disc	1	4	1	t	t
music_disc_mall	Mall Disc	1	4	1	t	t
music_disc_mellohi	Mellohi Disc	1	4	1	t	t
music_disc_stal	Stal Disc	1	4	1	t	t
music_disc_strad	Strad Disc	1	4	1	t	t
music_disc_ward	Ward Disc	1	4	1	t	t
music_disc_11	11 Disc	1	4	1	t	t
music_disc_wait	Wait Disc	1	4	1	t	t
music_disc_otherside	Otherside Disc	1	4	1	t	f
music_disc_pigstep	Pigstep Disc	1	4	1	t	f
trident	Trident	1	1.1	9	t	t
phantom_membrane	Phantom Membrane	64	4	1	t	t
nautilus_shell	Nautilus Shell	64	4	1	t	t
heart_of_the_sea	Heart of the Sea	64	4	1	t	f
crossbow	Crossbow	1	4	1	t	t
suspicious_stew	Suspicious Stew	1	4	1	t	t
loom	Loom	64	4	1	t	t
flower_banner_pattern	Flower Charge Banner Pattern	1	4	1	t	t
creeper_banner_pattern	Creeper Charge Banner Pattern	1	4	1	t	t
skull_banner_pattern	Skull Charge Banner Pattern	1	4	1	t	t
mojang_banner_pattern	Thing Banner Pattern	1	4	1	t	t
globe_banner_pattern	Globe Banner Pattern	1	4	1	t	t
piglin_banner_pattern	Snout Banner Pattern	1	4	1	t	f
composter	Composter	64	4	1	t	t
barrel	Barrel	64	4	1	t	t
smoker	Smoker	64	4	1	t	t
blast_furnace	Blast Furnace	64	4	1	t	t
cartography_table	Cartography Table	64	4	1	t	t
fletching_table	Fletching Table	64	4	1	t	t
grindstone	Grindstone	64	4	1	t	t
smithing_table	Smithing Table	64	4	1	t	t
stonecutter	Stonecutter	64	4	1	t	t
bell	Bell	64	4	1	t	t
lantern	Lantern	64	4	1	t	t
soul_lantern	Soul Lantern	64	4	1	t	t
sweet_berries	Sweet Berries	64	4	1	t	t
glow_berries	Glow Berries	64	4	1	t	t
campfire	Campfire	64	4	1	t	t
soul_campfire	Soul Campfire	64	4	1	t	t
shroomlight	Shroomlight	64	4	1	t	t
honeycomb	Honeycomb	64	4	1	t	t
bee_nest	Bee Nest	64	4	1	t	t
beehive	Beehive	64	4	1	t	t
honey_bottle	Honey Bottle	16	4	1	t	t
honeycomb_block	Honeycomb Block	64	4	1	t	t
lodestone	Lodestone	64	4	1	t	t
crying_obsidian	Crying Obsidian	64	4	1	t	t
blackstone	Blackstone	64	4	1	t	t
blackstone_slab	Blackstone Slab	64	4	1	t	t
blackstone_stairs	Blackstone Stairs	64	4	1	t	t
gilded_blackstone	Gilded Blackstone	64	4	1	t	f
polished_blackstone	Polished Blackstone	64	4	1	t	t
polished_blackstone_slab	Polished Blackstone Slab	64	4	1	t	t
polished_blackstone_stairs	Polished Blackstone Stairs	64	4	1	t	t
chiseled_polished_blackstone	Chiseled Polished Blackstone	64	4	1	t	t
polished_blackstone_bricks	Polished Blackstone Bricks	64	4	1	t	t
polished_blackstone_brick_slab	Polished Blackstone Brick Slab	64	4	1	t	t
polished_blackstone_brick_stairs	Polished Blackstone Brick Stairs	64	4	1	t	t
cracked_polished_blackstone_bricks	Cracked Polished Blackstone Bricks	64	4	1	t	t
respawn_anchor	Respawn Anchor	64	4	1	t	t
candle	Candle	64	4	1	t	t
white_candle	White Candle	64	4	1	t	t
orange_candle	Orange Candle	64	4	1	t	t
magenta_candle	Magenta Candle	64	4	1	t	t
light_blue_candle	Light Blue Candle	64	4	1	t	t
yellow_candle	Yellow Candle	64	4	1	t	t
lime_candle	Lime Candle	64	4	1	t	t
pink_candle	Pink Candle	64	4	1	t	t
gray_candle	Gray Candle	64	4	1	t	t
light_gray_candle	Light Gray Candle	64	4	1	t	t
cyan_candle	Cyan Candle	64	4	1	t	t
purple_candle	Purple Candle	64	4	1	t	t
blue_candle	Blue Candle	64	4	1	t	t
brown_candle	Brown Candle	64	4	1	t	t
green_candle	Green Candle	64	4	1	t	t
red_candle	Red Candle	64	4	1	t	t
black_candle	Black Candle	64	4	1	t	t
small_amethyst_bud	Small Amethyst Bud	64	4	1	t	t
medium_amethyst_bud	Medium Amethyst Bud	64	4	1	t	t
large_amethyst_bud	Large Amethyst Bud	64	4	1	t	t
amethyst_cluster	Amethyst Cluster	64	4	1	t	t
pointed_dripstone	Pointed Dripstone	64	4	1	t	t
ochre_froglight	Ochre Froglight	64	4	1	t	t
verdant_froglight	Verdant Froglight	64	4	1	t	t
pearlescent_froglight	Pearlescent Froglight	64	4	1	t	t
echo_shard	Echo Shard	64	4	1	t	f
bedrock	Bedrock	64	4	1	f	t
budding_amethyst	Budding Amethyst	64	4	1	f	t
petrified_oak_slab	Petrified Oak Slab	64	4	1	f	t
chorus_plant	Chorus Plant	64	4	1	f	t
spawner	Spawner	64	4	1	f	t
farmland	Farmland	64	4	1	f	t
infested_stone	Infested Stone	64	4	1	f	t
infested_cobblestone	Infested Cobblestone	64	4	1	f	t
infested_stone_bricks	Infested Stone Bricks	64	4	1	f	t
infested_mossy_stone_bricks	Infested Mossy Stone Bricks	64	4	1	f	t
infested_cracked_stone_bricks	Infested Cracked Stone Bricks	64	4	1	f	t
infested_chiseled_stone_bricks	Infested Chiseled Stone Bricks	64	4	1	f	t
infested_deepslate	Infested Deepslate	64	4	1	f	t
reinforced_deepslate	Reinforced Deepslate	64	4	1	f	t
end_portal_frame	End Portal Frame	64	4	1	f	t
command_block	Command Block	64	4	1	f	t
barrier	Barrier	64	4	1	f	t
light	Light	64	4	1	f	t
dirt_path	Dirt Path	64	4	1	f	t
repeating_command_block	Repeating Command Block	64	4	1	f	t
chain_command_block	Chain Command Block	64	4	1	f	t
structure_void	Structure Void	64	4	1	f	t
structure_block	Structure Block	64	4	1	f	t
jigsaw	Jigsaw Block	64	4	1	f	t
bundle	Bundle	1	4	1	f	t
allay_spawn_egg	Allay Spawn Egg	64	4	1	f	t
axolotl_spawn_egg	Axolotl Spawn Egg	64	4	1	f	t
bat_spawn_egg	Bat Spawn Egg	64	4	1	f	t
bee_spawn_egg	Bee Spawn Egg	64	4	1	f	t
blaze_spawn_egg	Blaze Spawn Egg	64	4	1	f	t
cat_spawn_egg	Cat Spawn Egg	64	4	1	f	t
cave_spider_spawn_egg	Cave Spider Spawn Egg	64	4	1	f	t
chicken_spawn_egg	Chicken Spawn Egg	64	4	1	f	t
cod_spawn_egg	Cod Spawn Egg	64	4	1	f	t
cow_spawn_egg	Cow Spawn Egg	64	4	1	f	t
creeper_spawn_egg	Creeper Spawn Egg	64	4	1	f	t
dolphin_spawn_egg	Dolphin Spawn Egg	64	4	1	f	t
donkey_spawn_egg	Donkey Spawn Egg	64	4	1	f	t
drowned_spawn_egg	Drowned Spawn Egg	64	4	1	f	t
elder_guardian_spawn_egg	Elder Guardian Spawn Egg	64	4	1	f	t
enderman_spawn_egg	Enderman Spawn Egg	64	4	1	f	t
endermite_spawn_egg	Endermite Spawn Egg	64	4	1	f	t
evoker_spawn_egg	Evoker Spawn Egg	64	4	1	f	t
fox_spawn_egg	Fox Spawn Egg	64	4	1	f	t
frog_spawn_egg	Frog Spawn Egg	64	4	1	f	t
ghast_spawn_egg	Ghast Spawn Egg	64	4	1	f	t
glow_squid_spawn_egg	Glow Squid Spawn Egg	64	4	1	f	t
goat_spawn_egg	Goat Spawn Egg	64	4	1	f	t
guardian_spawn_egg	Guardian Spawn Egg	64	4	1	f	t
hoglin_spawn_egg	Hoglin Spawn Egg	64	4	1	f	t
horse_spawn_egg	Horse Spawn Egg	64	4	1	f	t
husk_spawn_egg	Husk Spawn Egg	64	4	1	f	t
llama_spawn_egg	Llama Spawn Egg	64	4	1	f	t
magma_cube_spawn_egg	Magma Cube Spawn Egg	64	4	1	f	t
mooshroom_spawn_egg	Mooshroom Spawn Egg	64	4	1	f	t
mule_spawn_egg	Mule Spawn Egg	64	4	1	f	t
ocelot_spawn_egg	Ocelot Spawn Egg	64	4	1	f	t
panda_spawn_egg	Panda Spawn Egg	64	4	1	f	t
parrot_spawn_egg	Parrot Spawn Egg	64	4	1	f	t
phantom_spawn_egg	Phantom Spawn Egg	64	4	1	f	t
pig_spawn_egg	Pig Spawn Egg	64	4	1	f	t
piglin_spawn_egg	Piglin Spawn Egg	64	4	1	f	t
piglin_brute_spawn_egg	Piglin Brute Spawn Egg	64	4	1	f	t
pillager_spawn_egg	Pillager Spawn Egg	64	4	1	f	t
polar_bear_spawn_egg	Polar Bear Spawn Egg	64	4	1	f	t
pufferfish_spawn_egg	Pufferfish Spawn Egg	64	4	1	f	t
rabbit_spawn_egg	Rabbit Spawn Egg	64	4	1	f	t
ravager_spawn_egg	Ravager Spawn Egg	64	4	1	f	t
salmon_spawn_egg	Salmon Spawn Egg	64	4	1	f	t
sheep_spawn_egg	Sheep Spawn Egg	64	4	1	f	t
shulker_spawn_egg	Shulker Spawn Egg	64	4	1	f	t
silverfish_spawn_egg	Silverfish Spawn Egg	64	4	1	f	t
skeleton_spawn_egg	Skeleton Spawn Egg	64	4	1	f	t
skeleton_horse_spawn_egg	Skeleton Horse Spawn Egg	64	4	1	f	t
slime_spawn_egg	Slime Spawn Egg	64	4	1	f	t
spider_spawn_egg	Spider Spawn Egg	64	4	1	f	t
squid_spawn_egg	Squid Spawn Egg	64	4	1	f	t
stray_spawn_egg	Stray Spawn Egg	64	4	1	f	t
strider_spawn_egg	Strider Spawn Egg	64	4	1	f	t
tadpole_spawn_egg	Tadpole Spawn Egg	64	4	1	f	t
trader_llama_spawn_egg	Trader Llama Spawn Egg	64	4	1	f	t
tropical_fish_spawn_egg	Tropical Fish Spawn Egg	64	4	1	f	t
turtle_spawn_egg	Turtle Spawn Egg	64	4	1	f	t
vex_spawn_egg	Vex Spawn Egg	64	4	1	f	t
villager_spawn_egg	Villager Spawn Egg	64	4	1	f	t
vindicator_spawn_egg	Vindicator Spawn Egg	64	4	1	f	t
wandering_trader_spawn_egg	Wandering Trader Spawn Egg	64	4	1	f	t
warden_spawn_egg	Warden Spawn Egg	64	4	1	f	t
witch_spawn_egg	Witch Spawn Egg	64	4	1	f	t
wither_skeleton_spawn_egg	Wither Skeleton Spawn Egg	64	4	1	f	t
wolf_spawn_egg	Wolf Spawn Egg	64	4	1	f	t
zoglin_spawn_egg	Zoglin Spawn Egg	64	4	1	f	t
zombie_spawn_egg	Zombie Spawn Egg	64	4	1	f	t
zombie_horse_spawn_egg	Zombie Horse Spawn Egg	64	4	1	f	t
zombie_villager_spawn_egg	Zombie Villager Spawn Egg	64	4	1	f	t
zombified_piglin_spawn_egg	Zombified Piglin Spawn Egg	64	4	1	f	t
player_head	Player Head	64	4	1	f	t
command_block_minecart	Minecart with Command Block	1	4	1	f	t
knowledge_book	Knowledge Book	1	4	1	f	t
debug_stick	Debug Stick	1	4	1	f	t
frogspawn	Frogspawn	64	4	1	f	t
potion	Potion	1	4	1	f	t
potion{Potion:water}	Water Bottle	1	4	1	t	t
potion{Potion:empty}	Uncraftable Potion	1	4	1	f	t
potion{Potion:awkward}	Akward Potion	1	4	1	f	t
potion{Potion:thick}	Thick Potion	1	4	1	f	t
potion{Potion:mundane}	Mundane Potion	1	4	1	f	t
potion{Potion:regeneration}	Potion of Regeneration 	1	4	1	f	t
potion{Potion:swiftness}	Potion of Swiftness 	1	4	1	f	t
potion{Potion:fire_resistance}	Potion of Fire Resistance 	1	4	1	t	t
potion{Potion:poison}	Potion of Poison 	1	4	1	f	t
potion{Potion:healing}	Potion of Healing	1	4	1	t	t
potion{Potion:night_vision}	Potion of Night Vision	1	4	1	f	t
potion{Potion:weakness}	Potion of Weakness	1	4	1	t	t
potion{Potion:strength}	Potion of Strength	1	4	1	f	t
potion{Potion:slowness}	Potion of Slowness	1	4	1	f	t
potion{Potion:harming}	Potion of Harming	1	4	1	f	t
potion{Potion:water_breathing}	Potion of Water Breathing	1	4	1	f	t
potion{Potion:invisibility}	Potion of Invisibility 	1	4	1	t	t
potion{Potion:strong_regeneration}	Strong Potion of  Regeneration	1	4	1	f	t
potion{Potion:strong_swiftness}	Strong Potion of Swiftness	1	4	1	f	t
potion{Potion:strong_poison}	Strong Potion of Poison	1	4	1	f	t
potion{Potion:strong_healing}	Strong Potion of Healing	1	4	1	t	t
potion{Potion:strong_strength}	Strong Potion of Strength	1	4	1	f	t
potion{Potion:strong_leaping}	Strong Potion of Leaping	1	4	1	f	t
potion{Potion:strong_harming}	Strong Potion of Harming	1	4	1	f	t
potion{Potion:long_regeneration}	Long Potion of Regeneration	1	4	1	f	t
potion{Potion:long_swiftness}	Long Potion of Swiftness	1	4	1	f	t
potion{Potion:long_fire_resistance}	Long Potion of Fire Resistance	1	4	1	t	t
potion{Potion:long_poison}	Long Potion of Poison	1	4	1	f	t
potion{Potion:long_night_vision}	Long Potion of Night Vision	1	4	1	f	t
potion{Potion:long_weakness}	Long Potion of Weakness	1	4	1	t	t
potion{Potion:long_strength}	Long Potion of Strength	1	4	1	f	t
potion{Potion:long_slowness}	Long Potion of Slowness	1	4	1	f	t
potion{Potion:leaping}	Potion of Leaping	1	4	1	f	t
potion{Potion:long_water_breathing}	Long Potion of Water Breathing	1	4	1	f	t
potion{Potion:long_invisibility}	Long Potion of Invisibility	1	4	1	t	t
potion{Potion:turtle_master}	Potion of the Turtle Master	1	4	1	f	t
potion{Potion:long_turtle_master}	Long Potion of the Turtle Master	1	4	1	f	t
potion{Potion:strong_turtle_master}	Strong Potion of the Turtle Master	1	4	1	f	t
potion{Potion:slow_falling}	Potion of Slow Falling	1	4	1	f	t
potion{Potion:long_slow_falling}	Long Potion of Slow Falling	1	4	1	f	t
potion{Potion:luck}	Potion of Luck	1	4	1	f	t
potion{Potion:long_leaping}	Long Potion of Leaping	1	4	1	f	t
potion{Potion:strong_slowness}	Strong Potion of Slowness	1	4	1	f	t
splash_potion	Splash Potion	1	4	1	f	t
splash_potion{Potion:water}	Splash Water Bottle	1	4	1	t	t
splash_potion{Potion:mundane}	Mundane Splash Potion	1	4	1	f	t
splash_potion{Potion:thick}	Thick Splash Potion	1	4	1	f	t
splash_potion{Potion:awkward}	Awkward Splash Potion	1	4	1	f	t
splash_potion{Potion:uncraftable}	Splash Uncraftable Potion	1	4	1	f	t
splash_potion{Potion:night_vision}	Splash Potion of Night Vision	1	4	1	f	t
splash_potion{Potion:long_night_vision}	Long Splash Potion of Night Vision	1	4	1	f	t
splash_potion{Potion:invisibility}	Splash Potion of Invisibility	1	4	1	f	t
splash_potion{Potion:long_invisibility}	Long Splash Potion of Invisibility	1	4	1	f	t
splash_potion{Potion:leaping}	Splash Potion of Leaping	1	4	1	f	t
splash_potion{Potion:long_leaping}	Long Splash Potion of Leaping	1	4	1	f	t
splash_potion{Potion:strong_leaping}	Strong Splash Potion of Leaping	1	4	1	f	t
splash_potion{Potion:fire_resistance}	Splash Potion of Fire Resistance	1	4	1	t	t
splash_potion{Potion:long_fire_resistance}	Long Splash Potion of Fire Resistance	1	4	1	t	t
splash_potion{Potion:swiftness}	Splash Potion of Swiftness	1	4	1	f	t
splash_potion{Potion:long_swiftness}	Long Splash Potion of Swiftness	1	4	1	f	t
splash_potion{Potion:strong_swiftness}	Strong Splash Potion of Swiftness	1	4	1	f	t
splash_potion{Potion:slowness}	Splash Potion of Slowness	1	4	1	f	t
splash_potion{Potion:long_slowness}	Long Splash Potion of Slowness	1	4	1	f	t
splash_potion{Potion:strong_slowness}	Strong Splash Potion of Slowness	1	4	1	f	t
splash_potion{Potion:turtle_master}	Splash Potion of the Turtle Master	1	4	1	f	t
splash_potion{Potion:long_turtle_master}	Long Splash Potion of the Turtle Master	1	4	1	f	t
splash_potion{Potion:strong_turtle_master}	Strong Splash Potion of the Turtle Master	1	4	1	f	t
splash_potion{Potion:water_breathing}	Splash Potion of Water Breathing	1	4	1	f	t
splash_potion{Potion:long_water_breathing}	Long Splash Potion of Water Breathing	1	4	1	f	t
splash_potion{Potion:healing}	Splash Potion of Healing	1	4	1	f	t
splash_potion{Potion:strong_healing}	Strong Splash Potion of Healing	1	4	1	f	t
splash_potion{Potion:harming}	Splash Potion of Harming	1	4	1	f	t
splash_potion{Potion:strong_harming}	Strong Splash Potion of Harming	1	4	1	f	t
splash_potion{Potion:poison}	Splash Potion of Poision	1	4	1	f	t
splash_potion{Potion:long_poison}	Long Splash Potion of Poison	1	4	1	f	t
splash_potion{Potion:strong_poison}	Strong Splash Potion of Posion	1	4	1	f	t
splash_potion{Potion:regeneration}	Splash Potion of Regeneration	1	4	1	f	t
splash_potion{Potion:long_regeneration}	Long Splash Potion of Regeneration	1	4	1	f	t
splash_potion{Potion:strong_regeneration}	Strong Splash Potion of Regeneration	1	4	1	f	t
splash_potion{Potion:strength}	Splash Potion of Strength	1	4	1	f	t
splash_potion{Potion:long_strength}	Long Splash Potion of Strength	1	4	1	f	t
splash_potion{Potion:strong_strength}	Strong Splash Potion of Strength	1	4	1	f	t
splash_potion{Potion:weakness}	Splash Potion of Weakness	1	4	1	f	t
splash_potion{Potion:long_weakness}	Long Splash Potion of Weakness	1	4	1	f	t
splash_potion{Potion:luck}	Splash Potion of Luck	1	4	1	f	t
splash_potion{Potion:slow_falling}	Splash Potion of Slow Falling	1	4	1	f	t
splash_potion{Potion:long_slow_falling}	Long Splash Potion of Slow Falling	1	4	1	f	t
lingering_potion	Lingering Potion	1	4	1	f	t
lingering_potion{Potion:water}	Lingering Water Bottle	1	4	1	f	t
lingering_potion{Potion:mundane}	Mundane Lingering Potion	1	4	1	f	t
lingering_potion{Potion:thick}	Thick Lingering Potion	1	4	1	f	t
lingering_potion{Potion:awkward}	Awkward Lingering Potion	1	4	1	f	t
lingering_potion{Potion:uncraftable}	Lingering Uncraftable Potion	1	4	1	f	t
lingering_potion{Potion:night_vision}	Lingering Potion of Night Vision	1	4	1	f	t
lingering_potion{Potion:long_night_vision}	Long Lingering Potion of Night Vision	1	4	1	f	t
lingering_potion{Potion:invisibility}	Lingering Potion of Invisibility	1	4	1	f	t
lingering_potion{Potion:long_invisibility}	Long Lingering Potion of Invisibility	1	4	1	f	t
lingering_potion{Potion:leaping}	Lingering Potion of Leaping	1	4	1	f	t
lingering_potion{Potion:long_leaping}	Long Lingering Potion of Leaping	1	4	1	f	t
lingering_potion{Potion:strong_leaping}	Strong Lingering Potion of Leaping	1	4	1	f	t
lingering_potion{Potion:fire_resistance}	Lingering Potion of Fire Resistance	1	4	1	f	t
lingering_potion{Potion:long_fire_resistance}	Long Lingering Potion of Fire Resistance	1	4	1	f	t
lingering_potion{Potion:swiftness}	Lingering Potion of Swiftness	1	4	1	f	t
lingering_potion{Potion:long_swiftness}	Long Lingering Potion of Swiftness	1	4	1	f	t
lingering_potion{Potion:strong_swiftness}	Strong Lingering Potion of Swiftness	1	4	1	f	t
lingering_potion{Potion:slowness}	Lingering Potion of Slowness	1	4	1	f	t
lingering_potion{Potion:long_slowness}	Long Lingering Potion of Slowness	1	4	1	f	t
lingering_potion{Potion:strong_slowness}	Strong Lingering Potion of Slowness	1	4	1	f	t
lingering_potion{Potion:turtle_master}	Lingering Potion of the Turtle Master	1	4	1	f	t
lingering_potion{Potion:long_turtle_master}	Long Lingering Potion of the Turtle Master	1	4	1	f	t
lingering_potion{Potion:strong_turtle_master}	Strong Lingering Potion of the Turtle Master	1	4	1	f	t
lingering_potion{Potion:water_breathing}	Lingering Potion of Water Breathing	1	4	1	f	t
lingering_potion{Potion:long_water_breathing}	Long Lingering Potion of Water Breathing	1	4	1	f	t
lingering_potion{Potion:healing}	Lingering Potion of Healing	1	4	1	f	t
lingering_potion{Potion:strong_healing}	Strong Lingering Potion of Healing	1	4	1	f	t
lingering_potion{Potion:harming}	Lingering Potion of Harming	1	4	1	f	t
lingering_potion{Potion:strong_harming}	Strong Lingering Potion of Harming	1	4	1	f	t
lingering_potion{Potion:poison}	Lingering Potion of Poision	1	4	1	f	t
lingering_potion{Potion:long_poison}	Long Lingering Potion of Poison	1	4	1	f	t
lingering_potion{Potion:strong_poison}	Strong Lingering Potion of Posion	1	4	1	f	t
lingering_potion{Potion:regeneration}	Lingering Potion of Regeneration	1	4	1	f	t
lingering_potion{Potion:long_regeneration}	Long Lingering Potion of Regeneration	1	4	1	f	t
lingering_potion{Potion:strong_regeneration}	Strong Lingering Potion of Regeneration	1	4	1	f	t
lingering_potion{Potion:strength}	Lingering Potion of Strength	1	4	1	f	t
lingering_potion{Potion:long_strength}	Long Lingering Potion of Strength	1	4	1	f	t
lingering_potion{Potion:strong_strength}	Strong Lingering Potion of Strength	1	4	1	f	t
lingering_potion{Potion:weakness}	Lingering Potion of Weakness	1	4	1	f	t
lingering_potion{Potion:long_weakness}	Long Lingering Potion of Weakness	1	4	1	f	t
lingering_potion{Potion:luck}	Lingering Potion of Luck	1	4	1	f	t
lingering_potion{Potion:slow_falling}	Lingering Potion of Slow Falling	1	4	1	f	t
lingering_potion{Potion:long_slow_falling}	Long Lingering Potion of Slow Falling	1	4	1	f	t
tipped_arrow	Tipped Arrow	64	4	1	f	t
tipped_arrow{Potion:water}	Arrow of Splashing	64	4	1	f	t
tipped_arrow{Potion:mundane}	Tipped Arrow (Mundane)	64	4	1	f	t
tipped_arrow{Potion:thick}	Tipped Arrow (Thick)	64	4	1	f	t
tipped_arrow{Potion:awkward}	Tipped Arrow (Awkward)	64	4	1	f	t
tipped_arrow{Potion:uncraftable}	Uncraftable Tipped Arrow	64	4	1	f	t
tipped_arrow{Potion:night_vision}	Arrow of of Night Vision	64	4	1	f	t
tipped_arrow{Potion:long_night_vision}	Long Arrow of of Night Vision	64	4	1	f	t
tipped_arrow{Potion:invisibility}	Arrow of of Invisibility	64	4	1	f	t
tipped_arrow{Potion:long_invisibility}	Long Arrow of of Invisibility	64	4	1	f	t
tipped_arrow{Potion:leaping}	Arrow of of Leaping	64	4	1	f	t
tipped_arrow{Potion:long_leaping}	Long Arrow of of Leaping	64	4	1	f	t
tipped_arrow{Potion:strong_leaping}	Strong Arrow of of Leaping	64	4	1	f	t
tipped_arrow{Potion:fire_resistance}	Arrow of of Fire Resistance	64	4	1	f	t
tipped_arrow{Potion:long_fire_resistance}	Long Arrow of of Fire Resistance	64	4	1	f	t
tipped_arrow{Potion:swiftness}	Arrow of of Swiftness	64	4	1	f	t
tipped_arrow{Potion:long_swiftness}	Long Arrow of of Swiftness	64	4	1	f	t
tipped_arrow{Potion:strong_swiftness}	Strong Arrow of of Swiftness	64	4	1	f	t
tipped_arrow{Potion:slowness}	Arrow of of Slowness	64	4	1	f	t
tipped_arrow{Potion:long_slowness}	Long Arrow of of Slowness	64	4	1	f	t
tipped_arrow{Potion:strong_slowness}	Strong Arrow of of Slowness	64	4	1	f	t
tipped_arrow{Potion:turtle_master}	Arrow of of the Turtle Master	64	4	1	f	t
tipped_arrow{Potion:long_turtle_master}	Long Arrow of of the Turtle Master	64	4	1	f	t
tipped_arrow{Potion:strong_turtle_master}	Strong Arrow of of the Turtle Master	64	4	1	f	t
tipped_arrow{Potion:water_breathing}	Arrow of of Water Breathing	64	4	1	f	t
tipped_arrow{Potion:long_water_breathing}	Long Arrow of of Water Breathing	64	4	1	f	t
tipped_arrow{Potion:healing}	Arrow of of Healing	64	4	1	f	t
tipped_arrow{Potion:strong_healing}	Strong Arrow of of Healing	64	4	1	f	t
tipped_arrow{Potion:harming}	Arrow of of Harming	64	4	1	f	t
tipped_arrow{Potion:strong_harming}	Strong Arrow of of Harming	64	4	1	f	t
tipped_arrow{Potion:poison}	Arrow of of Poision	64	4	1	f	t
tipped_arrow{Potion:long_poison}	Long Arrow of of Poison	64	4	1	f	t
tipped_arrow{Potion:strong_poison}	Strong Arrow of of Posion	64	4	1	f	t
tipped_arrow{Potion:regeneration}	Arrow of of Regeneration	64	4	1	f	t
tipped_arrow{Potion:long_regeneration}	Long Arrow of of Regeneration	64	4	1	f	t
tipped_arrow{Potion:strong_regeneration}	Strong Arrow of of Regeneration	64	4	1	f	t
tipped_arrow{Potion:strength}	Arrow of of Strength	64	4	1	f	t
tipped_arrow{Potion:long_strength}	Long Arrow of of Strength	64	4	1	f	t
tipped_arrow{Potion:strong_strength}	Strong Arrow of of Strength	64	4	1	f	t
tipped_arrow{Potion:weakness}	Arrow of of Weakness	64	4	1	f	t
tipped_arrow{Potion:long_weakness}	Long Arrow of of Weakness	64	4	1	f	t
tipped_arrow{Potion:luck}	Arrow of of Luck	64	4	1	f	t
tipped_arrow{Potion:slow_falling}	Arrow of of Slow Falling	64	4	1	f	t
tipped_arrow{Potion:long_slow_falling}	Long Arrow of of Slow Falling	64	4	1	f	t
\.


--
-- Data for Name: smeltable_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.smeltable_items (item_id, smelting_xp, smelting_method_id) FROM stdin;
stone	0.1	1
cobbled_deepslate	0.1	1
cobblestone	0.1	1
sand	0.1	1
red_sand	0.1	1
coal_ore	0.1	2
deepslate_coal_ore	0.1	2
iron_ore	0.7	2
deepslate_iron_ore	0.7	2
copper_ore	0.7	2
deepslate_copper_ore	0.7	2
gold_ore	1	2
deepslate_gold_ore	1	2
redstone_ore	0.3	2
deepslate_redstone_ore	0.3	2
emerald_ore	1	2
deepslate_emerald_ore	1	2
lapis_ore	0.2	2
deepslate_lapis_ore	0.2	2
diamond_ore	1	2
deepslate_diamond_ore	1	2
nether_gold_ore	1	2
nether_quartz_ore	0.2	2
ancient_debris	2	2
oak_log	0.15	1
spruce_log	0.15	1
birch_log	0.15	1
jungle_log	0.15	1
acacia_log	0.15	1
dark_oak_log	0.15	1
mangrove_log	0.15	1
stripped_oak_log	0.15	1
stripped_spruce_log	0.15	1
stripped_birch_log	0.15	1
stripped_jungle_log	0.15	1
stripped_acacia_log	0.15	1
stripped_dark_oak_log	0.15	1
stripped_mangrove_log	0.15	1
stripped_oak_wood	0.15	1
stripped_spruce_wood	0.15	1
stripped_birch_wood	0.15	1
stripped_jungle_wood	0.15	1
stripped_acacia_wood	0.15	1
stripped_dark_oak_wood	0.15	1
stripped_mangrove_wood	0.15	1
oak_wood	0.15	1
spruce_wood	0.15	1
birch_wood	0.15	1
jungle_wood	0.15	1
acacia_wood	0.15	1
dark_oak_wood	0.15	1
mangrove_wood	0.15	1
wet_sponge	0.15	1
sandstone	0.1	1
sea_pickle	0.1	1
kelp	0.1	3
cactus	1	1
clay	0.35	1
netherrack	0.1	1
basalt	0.1	1
stone_bricks	0.1	1
deepslate_bricks	0.1	1
deepslate_tiles	0.1	1
nether_bricks	0.1	1
quartz_block	0.1	1
white_terracotta	0.1	1
orange_terracotta	0.1	1
magenta_terracotta	0.1	1
light_blue_terracotta	0.1	1
yellow_terracotta	0.1	1
lime_terracotta	0.1	1
pink_terracotta	0.1	1
gray_terracotta	0.1	1
light_gray_terracotta	0.1	1
cyan_terracotta	0.1	1
purple_terracotta	0.1	1
blue_terracotta	0.1	1
brown_terracotta	0.1	1
green_terracotta	0.1	1
red_terracotta	0.1	1
black_terracotta	0.1	1
red_sandstone	0.1	1
raw_iron	0.7	2
raw_copper	0.7	2
raw_gold	1	2
golden_sword	0.1	2
golden_shovel	0.1	2
golden_pickaxe	0.1	2
golden_axe	0.1	2
golden_hoe	0.1	2
iron_sword	0.1	2
iron_shovel	0.1	2
iron_pickaxe	0.1	2
iron_axe	0.1	2
iron_hoe	0.1	2
chainmail_helmet	0.1	2
chainmail_chestplate	0.1	2
chainmail_leggings	0.1	2
chainmail_boots	0.1	2
iron_helmet	0.1	2
iron_chestplate	0.1	2
iron_leggings	0.1	2
iron_boots	0.1	2
golden_helmet	0.1	2
golden_chestplate	0.1	2
golden_leggings	0.1	2
golden_boots	0.1	2
porkchop	0.35	3
clay_ball	0.3	1
cod	0.35	3
salmon	0.35	3
beef	0.35	3
chicken	0.35	3
potato	0.35	3
rabbit	0.35	3
iron_horse_armor	0.1	2
golden_horse_armor	0.1	2
mutton	0.35	3
chorus_fruit	0.1	1
polished_blackstone_bricks	0.1	1
\.


--
-- Data for Name: smelting_methods; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.smelting_methods (smelting_method_id, smelting_method_name) FROM stdin;
1	With Furnace Only
2	With Blast Furnace
3	With Smoker
\.


--
-- Data for Name: smelting_obtainable; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.smelting_obtainable (item_id, smelting_method_id) FROM stdin;
stone	1
deepslate	1
sponge	1
glass	1
smooth_quartz	1
smooth_red_sandstone	1
smooth_sandstone	1
smooth_stone	1
smooth_basalt	1
cracked_stone_bricks	1
cracked_deepslate_bricks	1
cracked_deepslate_tiles	1
cracked_nether_bricks	1
terracotta	1
white_glazed_terracotta	1
orange_glazed_terracotta	1
magenta_glazed_terracotta	1
light_blue_glazed_terracotta	1
yellow_glazed_terracotta	1
lime_glazed_terracotta	1
pink_glazed_terracotta	1
gray_glazed_terracotta	1
light_gray_glazed_terracotta	1
cyan_glazed_terracotta	1
purple_glazed_terracotta	1
blue_glazed_terracotta	1
brown_glazed_terracotta	1
green_glazed_terracotta	1
red_glazed_terracotta	1
black_glazed_terracotta	1
redstone	2
coal	2
charcoal	1
diamond	2
emerald	2
lapis_lazuli	2
quartz	2
iron_ingot	2
copper_ingot	2
gold_ingot	2
netherite_scrap	2
cooked_porkchop	3
brick	1
cooked_cod	3
cooked_salmon	3
lime_dye	1
green_dye	1
dried_kelp	3
cooked_beef	3
cooked_chicken	3
gold_nugget	2
baked_potato	3
nether_brick	1
cooked_rabbit	3
cooked_mutton	3
popped_chorus_fruit	1
iron_nugget	2
cracked_polished_blackstone_bricks	1
\.


--
-- Data for Name: survival_obtainable; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.survival_obtainable (item_id, survival_obtainable) FROM stdin;
stone	t
granite	t
polished_granite	t
diorite	t
polished_diorite	t
andesite	t
polished_andesite	t
deepslate	t
cobbled_deepslate	t
polished_deepslate	t
calcite	t
tuff	t
dripstone_block	t
grass_block	t
dirt	t
coarse_dirt	t
podzol	t
rooted_dirt	t
mud	t
crimson_nylium	t
warped_nylium	t
cobblestone	t
oak_planks	t
spruce_planks	t
birch_planks	t
jungle_planks	t
acacia_planks	t
dark_oak_planks	t
mangrove_planks	t
crimson_planks	t
warped_planks	t
oak_sapling	t
spruce_sapling	t
birch_sapling	t
jungle_sapling	t
acacia_sapling	t
dark_oak_sapling	t
mangrove_propagule	t
sand	t
red_sand	t
gravel	t
coal_ore	t
deepslate_coal_ore	t
iron_ore	t
deepslate_iron_ore	t
copper_ore	t
deepslate_copper_ore	t
gold_ore	t
deepslate_gold_ore	t
redstone_ore	t
deepslate_redstone_ore	t
emerald_ore	t
deepslate_emerald_ore	t
lapis_ore	t
deepslate_lapis_ore	t
diamond_ore	t
deepslate_diamond_ore	t
nether_gold_ore	t
nether_quartz_ore	t
ancient_debris	t
coal_block	t
raw_iron_block	t
raw_copper_block	t
raw_gold_block	t
amethyst_block	t
iron_block	t
copper_block	t
gold_block	t
diamond_block	t
netherite_block	t
exposed_copper	t
weathered_copper	t
oxidized_copper	t
cut_copper	t
exposed_cut_copper	t
weathered_cut_copper	t
oxidized_cut_copper	t
cut_copper_stairs	t
exposed_cut_copper_stairs	t
weathered_cut_copper_stairs	t
oxidized_cut_copper_stairs	t
cut_copper_slab	t
exposed_cut_copper_slab	t
weathered_cut_copper_slab	t
oxidized_cut_copper_slab	t
waxed_copper_block	t
waxed_exposed_copper	t
waxed_weathered_copper	t
waxed_oxidized_copper	t
waxed_cut_copper	t
waxed_exposed_cut_copper	t
waxed_weathered_cut_copper	t
waxed_oxidized_cut_copper	t
waxed_cut_copper_stairs	t
waxed_exposed_cut_copper_stairs	t
waxed_weathered_cut_copper_stairs	t
waxed_oxidized_cut_copper_stairs	t
waxed_cut_copper_slab	t
waxed_exposed_cut_copper_slab	t
waxed_weathered_cut_copper_slab	t
waxed_oxidized_cut_copper_slab	t
oak_log	t
spruce_log	t
birch_log	t
jungle_log	t
acacia_log	t
dark_oak_log	t
mangrove_log	t
mangrove_roots	t
muddy_mangrove_roots	t
crimson_stem	t
warped_stem	t
stripped_oak_log	t
stripped_spruce_log	t
stripped_birch_log	t
stripped_jungle_log	t
stripped_acacia_log	t
stripped_dark_oak_log	t
stripped_mangrove_log	t
stripped_crimson_stem	t
stripped_warped_stem	t
stripped_oak_wood	t
stripped_spruce_wood	t
stripped_birch_wood	t
stripped_jungle_wood	t
stripped_acacia_wood	t
stripped_dark_oak_wood	t
stripped_mangrove_wood	t
stripped_crimson_hyphae	t
stripped_warped_hyphae	t
oak_wood	t
spruce_wood	t
birch_wood	t
jungle_wood	t
acacia_wood	t
dark_oak_wood	t
mangrove_wood	t
crimson_hyphae	t
warped_hyphae	t
oak_leaves	t
spruce_leaves	t
birch_leaves	t
jungle_leaves	t
acacia_leaves	t
dark_oak_leaves	t
mangrove_leaves	t
azalea_leaves	t
flowering_azalea_leaves	t
sponge	t
wet_sponge	t
glass	t
tinted_glass	t
lapis_block	t
sandstone	t
chiseled_sandstone	t
cut_sandstone	t
cobweb	t
grass	t
fern	t
azalea	t
flowering_azalea	t
dead_bush	t
seagrass	t
sea_pickle	t
white_wool	t
orange_wool	t
magenta_wool	t
light_blue_wool	t
yellow_wool	t
lime_wool	t
pink_wool	t
gray_wool	t
light_gray_wool	t
cyan_wool	t
purple_wool	t
blue_wool	t
brown_wool	t
green_wool	t
red_wool	t
black_wool	t
dandelion	t
poppy	t
blue_orchid	t
allium	t
azure_bluet	t
red_tulip	t
orange_tulip	t
white_tulip	t
pink_tulip	t
oxeye_daisy	t
cornflower	t
lily_of_the_valley	t
wither_rose	t
spore_blossom	t
brown_mushroom	t
red_mushroom	t
crimson_fungus	t
warped_fungus	t
crimson_roots	t
warped_roots	t
nether_sprouts	t
weeping_vines	t
twisting_vines	t
sugar_cane	t
kelp	t
moss_carpet	t
moss_block	t
hanging_roots	t
big_dripleaf	t
small_dripleaf	t
bamboo	t
oak_slab	t
spruce_slab	t
birch_slab	t
jungle_slab	t
acacia_slab	t
dark_oak_slab	t
mangrove_slab	t
crimson_slab	t
warped_slab	t
stone_slab	t
smooth_stone_slab	t
sandstone_slab	t
cut_sandstone_slab	t
cobblestone_slab	t
brick_slab	t
stone_brick_slab	t
mud_brick_slab	t
nether_brick_slab	t
quartz_slab	t
red_sandstone_slab	t
cut_red_sandstone_slab	t
purpur_slab	t
prismarine_slab	t
prismarine_brick_slab	t
dark_prismarine_slab	t
smooth_quartz	t
smooth_red_sandstone	t
smooth_sandstone	t
smooth_stone	t
bricks	t
bookshelf	t
mossy_cobblestone	t
obsidian	t
torch	t
end_rod	t
chorus_flower	t
purpur_block	t
purpur_pillar	t
purpur_stairs	t
chest	t
crafting_table	t
furnace	t
ladder	t
cobblestone_stairs	t
snow	t
ice	t
snow_block	t
cactus	t
clay	t
jukebox	t
oak_fence	t
spruce_fence	t
birch_fence	t
jungle_fence	t
acacia_fence	t
dark_oak_fence	t
mangrove_fence	t
crimson_fence	t
warped_fence	t
pumpkin	t
carved_pumpkin	t
jack_o_lantern	t
netherrack	t
soul_sand	t
soul_soil	t
basalt	t
polished_basalt	t
smooth_basalt	t
soul_torch	t
glowstone	t
stone_bricks	t
mossy_stone_bricks	t
cracked_stone_bricks	t
chiseled_stone_bricks	t
packed_mud	t
mud_bricks	t
deepslate_bricks	t
cracked_deepslate_bricks	t
deepslate_tiles	t
cracked_deepslate_tiles	t
chiseled_deepslate	t
brown_mushroom_block	t
red_mushroom_block	t
mushroom_stem	t
iron_bars	t
chain	t
glass_pane	t
melon	t
vine	t
glow_lichen	t
brick_stairs	t
stone_brick_stairs	t
mud_brick_stairs	t
mycelium	t
lily_pad	t
nether_bricks	t
cracked_nether_bricks	t
chiseled_nether_bricks	t
nether_brick_fence	t
nether_brick_stairs	t
sculk	t
sculk_vein	t
sculk_catalyst	t
sculk_shrieker	t
enchanting_table	t
end_stone	t
end_stone_bricks	t
dragon_egg	t
sandstone_stairs	t
ender_chest	t
emerald_block	t
oak_stairs	t
spruce_stairs	t
birch_stairs	t
jungle_stairs	t
acacia_stairs	t
dark_oak_stairs	t
mangrove_stairs	t
crimson_stairs	t
warped_stairs	t
beacon	t
cobblestone_wall	t
mossy_cobblestone_wall	t
brick_wall	t
prismarine_wall	t
red_sandstone_wall	t
mossy_stone_brick_wall	t
granite_wall	t
stone_brick_wall	t
mud_brick_wall	t
nether_brick_wall	t
andesite_wall	t
red_nether_brick_wall	t
sandstone_wall	t
end_stone_brick_wall	t
diorite_wall	t
blackstone_wall	t
polished_blackstone_wall	t
polished_blackstone_brick_wall	t
cobbled_deepslate_wall	t
polished_deepslate_wall	t
deepslate_brick_wall	t
deepslate_tile_wall	t
anvil	t
chipped_anvil	t
damaged_anvil	t
chiseled_quartz_block	t
quartz_block	t
quartz_bricks	t
quartz_pillar	t
quartz_stairs	t
white_terracotta	t
orange_terracotta	t
magenta_terracotta	t
light_blue_terracotta	t
yellow_terracotta	t
lime_terracotta	t
pink_terracotta	t
gray_terracotta	t
light_gray_terracotta	t
cyan_terracotta	t
purple_terracotta	t
blue_terracotta	t
brown_terracotta	t
green_terracotta	t
red_terracotta	t
black_terracotta	t
hay_block	t
white_carpet	t
orange_carpet	t
magenta_carpet	t
light_blue_carpet	t
yellow_carpet	t
lime_carpet	t
pink_carpet	t
gray_carpet	t
light_gray_carpet	t
cyan_carpet	t
purple_carpet	t
blue_carpet	t
brown_carpet	t
green_carpet	t
red_carpet	t
black_carpet	t
terracotta	t
packed_ice	t
sunflower	t
lilac	t
rose_bush	t
peony	t
tall_grass	t
large_fern	t
white_stained_glass	t
orange_stained_glass	t
magenta_stained_glass	t
light_blue_stained_glass	t
yellow_stained_glass	t
lime_stained_glass	t
pink_stained_glass	t
gray_stained_glass	t
light_gray_stained_glass	t
cyan_stained_glass	t
purple_stained_glass	t
blue_stained_glass	t
brown_stained_glass	t
green_stained_glass	t
red_stained_glass	t
black_stained_glass	t
white_stained_glass_pane	t
orange_stained_glass_pane	t
magenta_stained_glass_pane	t
light_blue_stained_glass_pane	t
yellow_stained_glass_pane	t
lime_stained_glass_pane	t
pink_stained_glass_pane	t
gray_stained_glass_pane	t
light_gray_stained_glass_pane	t
cyan_stained_glass_pane	t
purple_stained_glass_pane	t
blue_stained_glass_pane	t
brown_stained_glass_pane	t
green_stained_glass_pane	t
red_stained_glass_pane	t
black_stained_glass_pane	t
prismarine	t
prismarine_bricks	t
dark_prismarine	t
prismarine_stairs	t
prismarine_brick_stairs	t
dark_prismarine_stairs	t
sea_lantern	t
red_sandstone	t
chiseled_red_sandstone	t
cut_red_sandstone	t
red_sandstone_stairs	t
magma_block	t
nether_wart_block	t
warped_wart_block	t
red_nether_bricks	t
bone_block	t
shulker_box	t
white_shulker_box	t
orange_shulker_box	t
magenta_shulker_box	t
light_blue_shulker_box	t
yellow_shulker_box	t
lime_shulker_box	t
pink_shulker_box	t
gray_shulker_box	t
light_gray_shulker_box	t
cyan_shulker_box	t
purple_shulker_box	t
blue_shulker_box	t
brown_shulker_box	t
green_shulker_box	t
red_shulker_box	t
black_shulker_box	t
white_glazed_terracotta	t
orange_glazed_terracotta	t
magenta_glazed_terracotta	t
light_blue_glazed_terracotta	t
yellow_glazed_terracotta	t
lime_glazed_terracotta	t
pink_glazed_terracotta	t
gray_glazed_terracotta	t
light_gray_glazed_terracotta	t
cyan_glazed_terracotta	t
purple_glazed_terracotta	t
blue_glazed_terracotta	t
brown_glazed_terracotta	t
green_glazed_terracotta	t
red_glazed_terracotta	t
black_glazed_terracotta	t
white_concrete	t
orange_concrete	t
magenta_concrete	t
light_blue_concrete	t
yellow_concrete	t
lime_concrete	t
pink_concrete	t
gray_concrete	t
light_gray_concrete	t
cyan_concrete	t
purple_concrete	t
blue_concrete	t
brown_concrete	t
green_concrete	t
red_concrete	t
black_concrete	t
white_concrete_powder	t
orange_concrete_powder	t
magenta_concrete_powder	t
light_blue_concrete_powder	t
yellow_concrete_powder	t
lime_concrete_powder	t
pink_concrete_powder	t
gray_concrete_powder	t
light_gray_concrete_powder	t
cyan_concrete_powder	t
purple_concrete_powder	t
blue_concrete_powder	t
brown_concrete_powder	t
green_concrete_powder	t
red_concrete_powder	t
black_concrete_powder	t
turtle_egg	t
dead_tube_coral_block	t
dead_brain_coral_block	t
dead_bubble_coral_block	t
dead_fire_coral_block	t
dead_horn_coral_block	t
tube_coral_block	t
brain_coral_block	t
bubble_coral_block	t
fire_coral_block	t
horn_coral_block	t
tube_coral	t
brain_coral	t
bubble_coral	t
fire_coral	t
horn_coral	t
dead_brain_coral	t
dead_bubble_coral	t
dead_fire_coral	t
dead_horn_coral	t
dead_tube_coral	t
tube_coral_fan	t
brain_coral_fan	t
bubble_coral_fan	t
fire_coral_fan	t
horn_coral_fan	t
dead_tube_coral_fan	t
dead_brain_coral_fan	t
dead_bubble_coral_fan	t
dead_fire_coral_fan	t
dead_horn_coral_fan	t
blue_ice	t
conduit	t
polished_granite_stairs	t
smooth_red_sandstone_stairs	t
mossy_stone_brick_stairs	t
polished_diorite_stairs	t
mossy_cobblestone_stairs	t
end_stone_brick_stairs	t
stone_stairs	t
smooth_sandstone_stairs	t
smooth_quartz_stairs	t
granite_stairs	t
andesite_stairs	t
red_nether_brick_stairs	t
polished_andesite_stairs	t
diorite_stairs	t
cobbled_deepslate_stairs	t
polished_deepslate_stairs	t
deepslate_brick_stairs	t
deepslate_tile_stairs	t
polished_granite_slab	t
smooth_red_sandstone_slab	t
mossy_stone_brick_slab	t
polished_diorite_slab	t
mossy_cobblestone_slab	t
end_stone_brick_slab	t
smooth_sandstone_slab	t
smooth_quartz_slab	t
granite_slab	t
andesite_slab	t
red_nether_brick_slab	t
polished_andesite_slab	t
diorite_slab	t
cobbled_deepslate_slab	t
polished_deepslate_slab	t
deepslate_brick_slab	t
deepslate_tile_slab	t
scaffolding	t
redstone	t
redstone_torch	t
redstone_block	t
repeater	t
comparator	t
piston	t
sticky_piston	t
slime_block	t
honey_block	t
observer	t
hopper	t
dispenser	t
dropper	t
lectern	t
target	t
lever	t
lightning_rod	t
daylight_detector	t
sculk_sensor	t
tripwire_hook	t
trapped_chest	t
tnt	t
redstone_lamp	t
note_block	t
stone_button	t
polished_blackstone_button	t
oak_button	t
spruce_button	t
birch_button	t
jungle_button	t
acacia_button	t
dark_oak_button	t
mangrove_button	t
crimson_button	t
warped_button	t
stone_pressure_plate	t
polished_blackstone_pressure_plate	t
light_weighted_pressure_plate	t
heavy_weighted_pressure_plate	t
oak_pressure_plate	t
spruce_pressure_plate	t
birch_pressure_plate	t
jungle_pressure_plate	t
acacia_pressure_plate	t
dark_oak_pressure_plate	t
mangrove_pressure_plate	t
crimson_pressure_plate	t
warped_pressure_plate	t
iron_door	t
oak_door	t
spruce_door	t
birch_door	t
jungle_door	t
acacia_door	t
dark_oak_door	t
mangrove_door	t
crimson_door	t
warped_door	t
iron_trapdoor	t
oak_trapdoor	t
spruce_trapdoor	t
birch_trapdoor	t
jungle_trapdoor	t
acacia_trapdoor	t
dark_oak_trapdoor	t
mangrove_trapdoor	t
crimson_trapdoor	t
warped_trapdoor	t
oak_fence_gate	t
spruce_fence_gate	t
birch_fence_gate	t
jungle_fence_gate	t
acacia_fence_gate	t
dark_oak_fence_gate	t
mangrove_fence_gate	t
crimson_fence_gate	t
warped_fence_gate	t
powered_rail	t
detector_rail	t
rail	t
activator_rail	t
saddle	t
minecart	t
chest_minecart	t
furnace_minecart	t
tnt_minecart	t
hopper_minecart	t
carrot_on_a_stick	t
warped_fungus_on_a_stick	t
elytra	t
oak_boat	t
oak_chest_boat	t
spruce_boat	t
spruce_chest_boat	t
birch_boat	t
birch_chest_boat	t
jungle_boat	t
jungle_chest_boat	t
acacia_boat	t
acacia_chest_boat	t
dark_oak_boat	t
dark_oak_chest_boat	t
mangrove_boat	t
mangrove_chest_boat	t
turtle_helmet	t
scute	t
flint_and_steel	t
apple	t
bow	t
arrow	t
coal	t
charcoal	t
diamond	t
emerald	t
lapis_lazuli	t
quartz	t
amethyst_shard	t
raw_iron	t
iron_ingot	t
raw_copper	t
copper_ingot	t
raw_gold	t
gold_ingot	t
netherite_ingot	t
netherite_scrap	t
wooden_sword	t
wooden_shovel	t
wooden_pickaxe	t
wooden_axe	t
wooden_hoe	t
stone_sword	t
stone_shovel	t
stone_pickaxe	t
stone_axe	t
stone_hoe	t
golden_sword	t
golden_shovel	t
golden_pickaxe	t
golden_axe	t
golden_hoe	t
iron_sword	t
iron_shovel	t
iron_pickaxe	t
iron_axe	t
iron_hoe	t
diamond_sword	t
diamond_shovel	t
diamond_pickaxe	t
diamond_axe	t
diamond_hoe	t
netherite_sword	t
netherite_shovel	t
netherite_pickaxe	t
netherite_axe	t
netherite_hoe	t
stick	t
bowl	t
mushroom_stew	t
string	t
feather	t
gunpowder	t
wheat_seeds	t
wheat	t
bread	t
leather_helmet	t
leather_chestplate	t
leather_leggings	t
leather_boots	t
chainmail_helmet	t
chainmail_chestplate	t
chainmail_leggings	t
chainmail_boots	t
iron_helmet	t
iron_chestplate	t
iron_leggings	t
iron_boots	t
diamond_helmet	t
diamond_chestplate	t
diamond_leggings	t
diamond_boots	t
golden_helmet	t
golden_chestplate	t
golden_leggings	t
golden_boots	t
netherite_helmet	t
netherite_chestplate	t
netherite_leggings	t
netherite_boots	t
flint	t
porkchop	t
cooked_porkchop	t
painting	t
golden_apple	t
enchanted_golden_apple	t
oak_sign	t
spruce_sign	t
birch_sign	t
jungle_sign	t
acacia_sign	t
dark_oak_sign	t
mangrove_sign	t
crimson_sign	t
warped_sign	t
bucket	t
water_bucket	t
lava_bucket	t
powder_snow_bucket	t
snowball	t
leather	t
milk_bucket	t
pufferfish_bucket	t
salmon_bucket	t
cod_bucket	t
tropical_fish_bucket	t
axolotl_bucket	t
tadpole_bucket	t
brick	t
clay_ball	t
dried_kelp_block	t
paper	t
book	t
slime_ball	t
egg	t
compass	t
recovery_compass	t
fishing_rod	t
clock	t
spyglass	t
glowstone_dust	t
cod	t
salmon	t
tropical_fish	t
pufferfish	t
cooked_cod	t
cooked_salmon	t
ink_sac	t
glow_ink_sac	t
cocoa_beans	t
white_dye	t
orange_dye	t
magenta_dye	t
light_blue_dye	t
yellow_dye	t
lime_dye	t
pink_dye	t
gray_dye	t
light_gray_dye	t
cyan_dye	t
purple_dye	t
blue_dye	t
brown_dye	t
green_dye	t
red_dye	t
black_dye	t
bone_meal	t
bone	t
sugar	t
cake	t
white_bed	t
orange_bed	t
magenta_bed	t
light_blue_bed	t
yellow_bed	t
lime_bed	t
pink_bed	t
gray_bed	t
light_gray_bed	t
cyan_bed	t
purple_bed	t
blue_bed	t
brown_bed	t
green_bed	t
red_bed	t
black_bed	t
cookie	t
filled_map	t
shears	t
melon_slice	t
dried_kelp	t
pumpkin_seeds	t
melon_seeds	t
beef	t
cooked_beef	t
chicken	t
cooked_chicken	t
rotten_flesh	t
ender_pearl	t
blaze_rod	t
ghast_tear	t
gold_nugget	t
nether_wart	t
glass_bottle	t
spider_eye	t
fermented_spider_eye	t
blaze_powder	t
magma_cream	t
brewing_stand	t
cauldron	t
ender_eye	t
glistering_melon_slice	t
experience_bottle	t
fire_charge	t
writable_book	t
written_book	t
item_frame	t
glow_item_frame	t
flower_pot	t
carrot	t
potato	t
baked_potato	t
poisonous_potato	t
map	t
golden_carrot	t
skeleton_skull	t
wither_skeleton_skull	t
zombie_head	t
creeper_head	t
dragon_head	t
nether_star	t
pumpkin_pie	t
firework_rocket	t
firework_star	t
enchanted_book	t
nether_brick	t
prismarine_shard	t
prismarine_crystals	t
rabbit	t
cooked_rabbit	t
rabbit_stew	t
rabbit_foot	t
rabbit_hide	t
armor_stand	t
iron_horse_armor	t
golden_horse_armor	t
diamond_horse_armor	t
leather_horse_armor	t
lead	t
name_tag	t
mutton	t
cooked_mutton	t
white_banner	t
orange_banner	t
magenta_banner	t
light_blue_banner	t
yellow_banner	t
lime_banner	t
pink_banner	t
gray_banner	t
light_gray_banner	t
cyan_banner	t
purple_banner	t
blue_banner	t
brown_banner	t
green_banner	t
red_banner	t
black_banner	t
end_crystal	t
chorus_fruit	t
popped_chorus_fruit	t
beetroot	t
beetroot_seeds	t
beetroot_soup	t
dragon_breath	t
spectral_arrow	t
shield	t
totem_of_undying	t
shulker_shell	t
iron_nugget	t
music_disc_13	t
music_disc_cat	t
music_disc_blocks	t
music_disc_chirp	t
music_disc_far	t
music_disc_mall	t
music_disc_mellohi	t
music_disc_stal	t
music_disc_strad	t
music_disc_ward	t
music_disc_11	t
music_disc_wait	t
music_disc_otherside	t
music_disc_pigstep	t
trident	t
phantom_membrane	t
nautilus_shell	t
heart_of_the_sea	t
crossbow	t
suspicious_stew	t
loom	t
flower_banner_pattern	t
creeper_banner_pattern	t
skull_banner_pattern	t
mojang_banner_pattern	t
globe_banner_pattern	t
piglin_banner_pattern	t
composter	t
barrel	t
smoker	t
blast_furnace	t
cartography_table	t
fletching_table	t
grindstone	t
smithing_table	t
stonecutter	t
bell	t
lantern	t
soul_lantern	t
sweet_berries	t
glow_berries	t
campfire	t
soul_campfire	t
shroomlight	t
honeycomb	t
bee_nest	t
beehive	t
honey_bottle	t
honeycomb_block	t
lodestone	t
crying_obsidian	t
blackstone	t
blackstone_slab	t
blackstone_stairs	t
gilded_blackstone	t
polished_blackstone	t
polished_blackstone_slab	t
polished_blackstone_stairs	t
chiseled_polished_blackstone	t
polished_blackstone_bricks	t
polished_blackstone_brick_slab	t
polished_blackstone_brick_stairs	t
cracked_polished_blackstone_bricks	t
respawn_anchor	t
candle	t
white_candle	t
orange_candle	t
magenta_candle	t
light_blue_candle	t
yellow_candle	t
lime_candle	t
pink_candle	t
gray_candle	t
light_gray_candle	t
cyan_candle	t
purple_candle	t
blue_candle	t
brown_candle	t
green_candle	t
red_candle	t
black_candle	t
small_amethyst_bud	t
medium_amethyst_bud	t
large_amethyst_bud	t
amethyst_cluster	t
pointed_dripstone	t
ochre_froglight	t
verdant_froglight	t
pearlescent_froglight	t
echo_shard	t
bedrock	f
budding_amethyst	f
petrified_oak_slab	f
chorus_plant	f
spawner	f
farmland	f
infested_stone	f
infested_cobblestone	f
infested_stone_bricks	f
infested_mossy_stone_bricks	f
infested_cracked_stone_bricks	f
infested_chiseled_stone_bricks	f
infested_deepslate	f
reinforced_deepslate	f
end_portal_frame	f
command_block	f
barrier	f
light	f
dirt_path	f
repeating_command_block	f
chain_command_block	f
structure_void	f
structure_block	f
jigsaw	f
bundle	f
allay_spawn_egg	f
axolotl_spawn_egg	f
bat_spawn_egg	f
bee_spawn_egg	f
blaze_spawn_egg	f
cat_spawn_egg	f
cave_spider_spawn_egg	f
chicken_spawn_egg	f
cod_spawn_egg	f
cow_spawn_egg	f
creeper_spawn_egg	f
dolphin_spawn_egg	f
donkey_spawn_egg	f
drowned_spawn_egg	f
elder_guardian_spawn_egg	f
enderman_spawn_egg	f
endermite_spawn_egg	f
evoker_spawn_egg	f
fox_spawn_egg	f
frog_spawn_egg	f
ghast_spawn_egg	f
glow_squid_spawn_egg	f
goat_spawn_egg	f
guardian_spawn_egg	f
hoglin_spawn_egg	f
horse_spawn_egg	f
husk_spawn_egg	f
llama_spawn_egg	f
magma_cube_spawn_egg	f
mooshroom_spawn_egg	f
mule_spawn_egg	f
ocelot_spawn_egg	f
panda_spawn_egg	f
parrot_spawn_egg	f
phantom_spawn_egg	f
pig_spawn_egg	f
piglin_spawn_egg	f
piglin_brute_spawn_egg	f
pillager_spawn_egg	f
polar_bear_spawn_egg	f
pufferfish_spawn_egg	f
rabbit_spawn_egg	f
ravager_spawn_egg	f
salmon_spawn_egg	f
sheep_spawn_egg	f
shulker_spawn_egg	f
silverfish_spawn_egg	f
skeleton_spawn_egg	f
skeleton_horse_spawn_egg	f
slime_spawn_egg	f
spider_spawn_egg	f
squid_spawn_egg	f
stray_spawn_egg	f
strider_spawn_egg	f
tadpole_spawn_egg	f
trader_llama_spawn_egg	f
tropical_fish_spawn_egg	f
turtle_spawn_egg	f
vex_spawn_egg	f
villager_spawn_egg	f
vindicator_spawn_egg	f
wandering_trader_spawn_egg	f
warden_spawn_egg	f
witch_spawn_egg	f
wither_skeleton_spawn_egg	f
wolf_spawn_egg	f
zoglin_spawn_egg	f
zombie_spawn_egg	f
zombie_horse_spawn_egg	f
zombie_villager_spawn_egg	f
zombified_piglin_spawn_egg	f
player_head	f
command_block_minecart	f
knowledge_book	f
debug_stick	f
frogspawn	f
potion	t
potion{Potion:water}	t
potion{Potion:empty}	t
potion{Potion:awkward}	t
potion{Potion:thick}	t
potion{Potion:mundane}	t
potion{Potion:regeneration}	t
potion{Potion:swiftness}	t
potion{Potion:fire_resistance}	t
potion{Potion:poison}	t
potion{Potion:healing}	t
potion{Potion:night_vision}	t
potion{Potion:weakness}	t
potion{Potion:strength}	t
potion{Potion:slowness}	t
potion{Potion:harming}	t
potion{Potion:water_breathing}	t
potion{Potion:invisibility}	t
potion{Potion:strong_regeneration}	t
potion{Potion:strong_swiftness}	t
potion{Potion:strong_poison}	t
potion{Potion:strong_healing}	t
potion{Potion:strong_strength}	t
potion{Potion:strong_leaping}	t
potion{Potion:strong_harming}	t
potion{Potion:long_regeneration}	t
potion{Potion:long_swiftness}	t
potion{Potion:long_fire_resistance}	t
potion{Potion:long_poison}	t
potion{Potion:long_night_vision}	t
potion{Potion:long_weakness}	t
potion{Potion:long_strength}	t
potion{Potion:long_slowness}	t
potion{Potion:leaping}	t
potion{Potion:long_water_breathing}	t
potion{Potion:long_invisibility}	t
potion{Potion:turtle_master}	t
potion{Potion:long_turtle_master}	t
potion{Potion:strong_turtle_master}	t
potion{Potion:slow_falling}	t
potion{Potion:long_slow_falling}	t
potion{Potion:luck}	f
potion{Potion:long_leaping}	t
potion{Potion:strong_slowness}	t
splash_potion	t
splash_potion{Potion:water}	t
splash_potion{Potion:mundane}	t
splash_potion{Potion:thick}	t
splash_potion{Potion:awkward}	t
splash_potion{Potion:uncraftable}	f
splash_potion{Potion:night_vision}	t
splash_potion{Potion:long_night_vision}	t
splash_potion{Potion:invisibility}	t
splash_potion{Potion:long_invisibility}	t
splash_potion{Potion:leaping}	t
splash_potion{Potion:long_leaping}	t
splash_potion{Potion:strong_leaping}	t
splash_potion{Potion:fire_resistance}	t
splash_potion{Potion:long_fire_resistance}	t
splash_potion{Potion:swiftness}	t
splash_potion{Potion:long_swiftness}	t
splash_potion{Potion:strong_swiftness}	t
splash_potion{Potion:slowness}	t
splash_potion{Potion:long_slowness}	t
splash_potion{Potion:strong_slowness}	t
splash_potion{Potion:turtle_master}	t
splash_potion{Potion:long_turtle_master}	t
splash_potion{Potion:strong_turtle_master}	t
splash_potion{Potion:water_breathing}	t
splash_potion{Potion:long_water_breathing}	t
splash_potion{Potion:healing}	t
splash_potion{Potion:strong_healing}	t
splash_potion{Potion:harming}	t
splash_potion{Potion:strong_harming}	t
splash_potion{Potion:poison}	t
splash_potion{Potion:long_poison}	t
splash_potion{Potion:strong_poison}	t
splash_potion{Potion:regeneration}	t
splash_potion{Potion:long_regeneration}	t
splash_potion{Potion:strong_regeneration}	t
splash_potion{Potion:strength}	t
splash_potion{Potion:long_strength}	t
splash_potion{Potion:strong_strength}	t
splash_potion{Potion:weakness}	t
splash_potion{Potion:long_weakness}	t
splash_potion{Potion:luck}	f
splash_potion{Potion:slow_falling}	t
splash_potion{Potion:long_slow_falling}	t
lingering_potion	t
lingering_potion{Potion:water}	t
lingering_potion{Potion:mundane}	t
lingering_potion{Potion:thick}	t
lingering_potion{Potion:awkward}	t
lingering_potion{Potion:uncraftable}	f
lingering_potion{Potion:night_vision}	t
lingering_potion{Potion:long_night_vision}	t
lingering_potion{Potion:invisibility}	t
lingering_potion{Potion:long_invisibility}	t
lingering_potion{Potion:leaping}	t
lingering_potion{Potion:long_leaping}	t
lingering_potion{Potion:strong_leaping}	t
lingering_potion{Potion:fire_resistance}	t
lingering_potion{Potion:long_fire_resistance}	t
lingering_potion{Potion:swiftness}	t
lingering_potion{Potion:long_swiftness}	t
lingering_potion{Potion:strong_swiftness}	t
lingering_potion{Potion:slowness}	t
lingering_potion{Potion:long_slowness}	t
lingering_potion{Potion:strong_slowness}	t
lingering_potion{Potion:turtle_master}	t
lingering_potion{Potion:long_turtle_master}	t
lingering_potion{Potion:strong_turtle_master}	t
lingering_potion{Potion:water_breathing}	t
lingering_potion{Potion:long_water_breathing}	t
lingering_potion{Potion:healing}	t
lingering_potion{Potion:strong_healing}	t
lingering_potion{Potion:harming}	t
lingering_potion{Potion:strong_harming}	t
lingering_potion{Potion:poison}	t
lingering_potion{Potion:long_poison}	t
lingering_potion{Potion:strong_poison}	t
lingering_potion{Potion:regeneration}	t
lingering_potion{Potion:long_regeneration}	t
lingering_potion{Potion:strong_regeneration}	t
lingering_potion{Potion:strength}	t
lingering_potion{Potion:long_strength}	t
lingering_potion{Potion:strong_strength}	t
lingering_potion{Potion:weakness}	t
lingering_potion{Potion:long_weakness}	t
lingering_potion{Potion:luck}	f
lingering_potion{Potion:slow_falling}	t
lingering_potion{Potion:long_slow_falling}	t
tipped_arrow	f
tipped_arrow{Potion:water}	f
tipped_arrow{Potion:mundane}	f
tipped_arrow{Potion:thick}	f
tipped_arrow{Potion:awkward}	f
tipped_arrow{Potion:uncraftable}	f
tipped_arrow{Potion:night_vision}	t
tipped_arrow{Potion:long_night_vision}	t
tipped_arrow{Potion:invisibility}	t
tipped_arrow{Potion:long_invisibility}	t
tipped_arrow{Potion:leaping}	t
tipped_arrow{Potion:long_leaping}	t
tipped_arrow{Potion:strong_leaping}	t
tipped_arrow{Potion:fire_resistance}	t
tipped_arrow{Potion:long_fire_resistance}	t
tipped_arrow{Potion:swiftness}	t
tipped_arrow{Potion:long_swiftness}	t
tipped_arrow{Potion:strong_swiftness}	t
tipped_arrow{Potion:slowness}	t
tipped_arrow{Potion:long_slowness}	t
tipped_arrow{Potion:strong_slowness}	t
tipped_arrow{Potion:turtle_master}	t
tipped_arrow{Potion:long_turtle_master}	t
tipped_arrow{Potion:strong_turtle_master}	t
tipped_arrow{Potion:water_breathing}	t
tipped_arrow{Potion:long_water_breathing}	t
tipped_arrow{Potion:healing}	t
tipped_arrow{Potion:strong_healing}	t
tipped_arrow{Potion:harming}	t
tipped_arrow{Potion:strong_harming}	t
tipped_arrow{Potion:poison}	t
tipped_arrow{Potion:long_poison}	t
tipped_arrow{Potion:strong_poison}	t
tipped_arrow{Potion:regeneration}	t
tipped_arrow{Potion:long_regeneration}	t
tipped_arrow{Potion:strong_regeneration}	t
tipped_arrow{Potion:strength}	t
tipped_arrow{Potion:long_strength}	t
tipped_arrow{Potion:strong_strength}	t
tipped_arrow{Potion:weakness}	t
tipped_arrow{Potion:long_weakness}	t
tipped_arrow{Potion:luck}	f
tipped_arrow{Potion:slow_falling}	t
tipped_arrow{Potion:long_slow_falling}	t
\.


--
-- Name: breaking_types_breakin_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.breaking_types_breakin_type_id_seq', 1, false);


--
-- Name: effects_effect_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.effects_effect_id_seq', 1, false);


--
-- Name: smelting_methods_smelting_method_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.smelting_methods_smelting_method_id_seq', 1, false);


--
-- Name: breaking_speeds breaking_speeds_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.breaking_speeds
    ADD CONSTRAINT breaking_speeds_pkey PRIMARY KEY (item_id, breaking_type_id);


--
-- Name: breaking_types breaking_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.breaking_types
    ADD CONSTRAINT breaking_types_pkey PRIMARY KEY (breaking_type_id);


--
-- Name: cooldown cooldown_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cooldown
    ADD CONSTRAINT cooldown_pkey PRIMARY KEY (item_id);


--
-- Name: effects effects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.effects
    ADD CONSTRAINT effects_pkey PRIMARY KEY (effect_id);


--
-- Name: food_effects food_effects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.food_effects
    ADD CONSTRAINT food_effects_pkey PRIMARY KEY (item_id, effect_id);


--
-- Name: food_items food_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.food_items
    ADD CONSTRAINT food_items_pkey PRIMARY KEY (item_id);


--
-- Name: fuel_duration fuel_duration_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fuel_duration
    ADD CONSTRAINT fuel_duration_pkey PRIMARY KEY (item_id);


--
-- Name: items items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (item_id);


--
-- Name: smeltable_items smeltable_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.smeltable_items
    ADD CONSTRAINT smeltable_items_pkey PRIMARY KEY (item_id);


--
-- Name: smelting_methods smelting_methods_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.smelting_methods
    ADD CONSTRAINT smelting_methods_pkey PRIMARY KEY (smelting_method_id);


--
-- Name: smelting_obtainable smelting_obtainable_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.smelting_obtainable
    ADD CONSTRAINT smelting_obtainable_pkey PRIMARY KEY (item_id);


--
-- Name: survival_obtainable survival_obtainable_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.survival_obtainable
    ADD CONSTRAINT survival_obtainable_pkey PRIMARY KEY (item_id);


--
-- Name: attack; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX attack ON public.items USING btree (attack_damage) INCLUDE (attack_speed);


--
-- Name: item_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX item_name ON public.items USING gin (item_name);


--
-- Name: breaking_speeds breaking_speeds_breaking_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.breaking_speeds
    ADD CONSTRAINT breaking_speeds_breaking_type_id_fkey FOREIGN KEY (breaking_type_id) REFERENCES public.breaking_types(breaking_type_id) NOT VALID;


--
-- Name: breaking_speeds breaking_speeds_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.breaking_speeds
    ADD CONSTRAINT breaking_speeds_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.items(item_id) NOT VALID;


--
-- Name: cooldown cooldown_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cooldown
    ADD CONSTRAINT cooldown_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.items(item_id) NOT VALID;


--
-- Name: food_effects food_effects_effect_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.food_effects
    ADD CONSTRAINT food_effects_effect_id_fkey FOREIGN KEY (effect_id) REFERENCES public.effects(effect_id) NOT VALID;


--
-- Name: food_effects food_effects_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.food_effects
    ADD CONSTRAINT food_effects_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.items(item_id) NOT VALID;


--
-- Name: food_items food_items_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.food_items
    ADD CONSTRAINT food_items_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.items(item_id) NOT VALID;


--
-- Name: fuel_duration fuel_duration_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fuel_duration
    ADD CONSTRAINT fuel_duration_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.items(item_id) NOT VALID;


--
-- Name: smeltable_items smeltable_items_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.smeltable_items
    ADD CONSTRAINT smeltable_items_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.items(item_id) NOT VALID;


--
-- Name: smeltable_items smeltable_items_smelting_method_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.smeltable_items
    ADD CONSTRAINT smeltable_items_smelting_method_id_fkey FOREIGN KEY (smelting_method_id) REFERENCES public.smelting_methods(smelting_method_id) NOT VALID;


--
-- Name: smelting_obtainable smelting_obtainable_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.smelting_obtainable
    ADD CONSTRAINT smelting_obtainable_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.items(item_id) NOT VALID;


--
-- Name: smelting_obtainable smelting_obtainable_smelting_method_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.smelting_obtainable
    ADD CONSTRAINT smelting_obtainable_smelting_method_id_fkey FOREIGN KEY (smelting_method_id) REFERENCES public.smelting_methods(smelting_method_id) NOT VALID;


--
-- Name: survival_obtainable survival_obtainable_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.survival_obtainable
    ADD CONSTRAINT survival_obtainable_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.items(item_id) NOT VALID;


--
-- Name: TABLE breaking_speeds; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.breaking_speeds TO standard_user;


--
-- Name: TABLE breaking_types; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.breaking_types TO standard_user;


--
-- Name: TABLE items; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.items TO standard_user;


--
-- Name: TABLE breaking_speeds_view; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.breaking_speeds_view TO standard_user;


--
-- Name: TABLE cooldown; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.cooldown TO standard_user;


--
-- Name: TABLE cooldown_view; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.cooldown_view TO standard_user;


--
-- Name: TABLE damage_per_second; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.damage_per_second TO standard_user;


--
-- Name: TABLE survival_obtainable; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.survival_obtainable TO standard_user;


--
-- Name: TABLE "default"; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public."default" TO standard_user;


--
-- Name: TABLE effects; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.effects TO standard_user;


--
-- Name: TABLE food_effects; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.food_effects TO standard_user;


--
-- Name: TABLE food_effects_view; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.food_effects_view TO standard_user;


--
-- Name: TABLE food_items; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.food_items TO standard_user;


--
-- Name: TABLE food_items_view; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.food_items_view TO standard_user;


--
-- Name: TABLE fuel_duration; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.fuel_duration TO standard_user;


--
-- Name: TABLE fuel_duration_view; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.fuel_duration_view TO standard_user;


--
-- Name: TABLE smeltable_items; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.smeltable_items TO standard_user;


--
-- Name: TABLE smelting_methods; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.smelting_methods TO standard_user;


--
-- Name: TABLE smeltable_items_view; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.smeltable_items_view TO standard_user;


--
-- Name: TABLE smelting_obtainable; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.smelting_obtainable TO standard_user;


--
-- Name: TABLE smelting_obtainable_view; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.smelting_obtainable_view TO standard_user;


--
-- Name: breaking_speeds_view; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.breaking_speeds_view;


--
-- Name: cooldown_view; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.cooldown_view;


--
-- Name: damage_per_second; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.damage_per_second;


--
-- Name: default; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public."default";


--
-- Name: food_effects_view; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.food_effects_view;


--
-- Name: food_items_view; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.food_items_view;


--
-- Name: fuel_duration_view; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.fuel_duration_view;


--
-- Name: smeltable_items_view; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.smeltable_items_view;


--
-- Name: smelting_obtainable_view; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.smelting_obtainable_view;


--
-- PostgreSQL database dump complete
--

