-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.attributes_ref (
  key text NOT NULL,
  label text NOT NULL,
  CONSTRAINT attributes_ref_pkey PRIMARY KEY (key)
);
CREATE TABLE public.character_attributes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  character_id uuid NOT NULL,
  attr_key text NOT NULL,
  die_size integer NOT NULL CHECK (die_size = ANY (ARRAY[4, 6, 8, 10, 12])),
  CONSTRAINT character_attributes_pkey PRIMARY KEY (id),
  CONSTRAINT character_attributes_character_id_fkey FOREIGN KEY (character_id) REFERENCES public.characters(id),
  CONSTRAINT character_attributes_attr_key_fkey FOREIGN KEY (attr_key) REFERENCES public.attributes_ref(key)
);
CREATE TABLE public.character_cyberware (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  character_id uuid NOT NULL,
  cyberware_id uuid NOT NULL,
  installed_at timestamp with time zone DEFAULT now(),
  uses_remaining integer,
  plus_vs_ice ARRAY DEFAULT '{}'::text[],
  minus_vs_ice ARRAY DEFAULT '{}'::text[],
  disposable boolean DEFAULT false,
  craft_quality text,
  crafted_by_character_id uuid,
  crafted_roll_event_id uuid,
  CONSTRAINT character_cyberware_pkey PRIMARY KEY (id),
  CONSTRAINT character_cyberware_character_id_fkey FOREIGN KEY (character_id) REFERENCES public.characters(id),
  CONSTRAINT character_cyberware_cyberware_id_fkey FOREIGN KEY (cyberware_id) REFERENCES public.cyberware_catalog(id),
  CONSTRAINT character_cyberware_crafted_by_character_id_fkey FOREIGN KEY (crafted_by_character_id) REFERENCES public.characters(id),
  CONSTRAINT character_cyberware_crafted_roll_event_id_fkey FOREIGN KEY (crafted_roll_event_id) REFERENCES public.roll_events(id)
);
CREATE TABLE public.character_jobs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  character_id uuid,
  job_id uuid,
  crew_id uuid,
  status text DEFAULT 'accepted'::text CHECK (status = ANY (ARRAY['accepted'::text, 'completed'::text, 'failed'::text, 'abandoned'::text])),
  accepted_at timestamp with time zone DEFAULT now(),
  completed_at timestamp with time zone,
  reward_collected boolean DEFAULT false,
  CONSTRAINT character_jobs_pkey PRIMARY KEY (id),
  CONSTRAINT character_jobs_crew_id_fkey FOREIGN KEY (crew_id) REFERENCES public.crews(id),
  CONSTRAINT character_jobs_character_id_fkey FOREIGN KEY (character_id) REFERENCES public.characters(id),
  CONSTRAINT character_jobs_job_id_fkey FOREIGN KEY (job_id) REFERENCES public.jobs(id)
);
CREATE TABLE public.character_programs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  character_id uuid NOT NULL,
  program_id uuid NOT NULL,
  source text,
  installed_at timestamp with time zone DEFAULT now(),
  CONSTRAINT character_programs_pkey PRIMARY KEY (id),
  CONSTRAINT character_programs_character_id_fkey FOREIGN KEY (character_id) REFERENCES public.characters(id),
  CONSTRAINT character_programs_program_id_fkey FOREIGN KEY (program_id) REFERENCES public.program_catalog(id)
);
CREATE TABLE public.character_skills (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  character_id uuid NOT NULL,
  skill_id uuid NOT NULL,
  die_size integer NOT NULL CHECK (die_size = ANY (ARRAY[4, 6, 8, 10, 12])),
  ticks integer NOT NULL DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT character_skills_pkey PRIMARY KEY (id),
  CONSTRAINT character_skills_character_id_fkey FOREIGN KEY (character_id) REFERENCES public.characters(id),
  CONSTRAINT character_skills_skill_id_fkey FOREIGN KEY (skill_id) REFERENCES public.skills(id)
);
CREATE TABLE public.characters (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  owner_user_id uuid,
  name text NOT NULL,
  alias text,
  role text,
  bio text,
  status text DEFAULT 'active'::text,
  heat integer DEFAULT 0,
  notoriety integer DEFAULT 0,
  faction_id uuid,
  last_seen_location_id uuid,
  last_updated_at timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now(),
  current_stress integer NOT NULL DEFAULT 0,
  body_die_size integer NOT NULL DEFAULT 8,
  base_body_die_size integer NOT NULL DEFAULT 8,
  mind_die_size integer NOT NULL DEFAULT 8,
  base_mind_die_size integer NOT NULL DEFAULT 8,
  needs_stabilization boolean NOT NULL DEFAULT false,
  stim_expires_at timestamp with time zone,
  combat_status text NOT NULL DEFAULT 'active'::text,
  persona text,
  role_tags ARRAY,
  user_id uuid,
  CONSTRAINT characters_pkey PRIMARY KEY (id),
  CONSTRAINT characters_owner_user_id_fkey FOREIGN KEY (owner_user_id) REFERENCES public.users(id),
  CONSTRAINT characters_faction_id_fkey FOREIGN KEY (faction_id) REFERENCES public.factions(id),
  CONSTRAINT characters_last_seen_location_id_fkey FOREIGN KEY (last_seen_location_id) REFERENCES public.locations(id),
  CONSTRAINT characters_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.clocks (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  max_segments integer NOT NULL CHECK (max_segments > 0),
  filled_segments integer NOT NULL DEFAULT 0 CHECK (filled_segments >= 0),
  faction_id uuid,
  character_id uuid,
  visibility text NOT NULL DEFAULT 'gm_only'::text CHECK (visibility = ANY (ARRAY['gm_only'::text, 'players_can_see'::text])),
  last_updated_at timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT clocks_pkey PRIMARY KEY (id),
  CONSTRAINT clocks_faction_id_fkey FOREIGN KEY (faction_id) REFERENCES public.factions(id),
  CONSTRAINT clocks_character_id_fkey FOREIGN KEY (character_id) REFERENCES public.characters(id)
);
CREATE TABLE public.crew_members (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  crew_id uuid,
  character_id uuid,
  role_in_crew text,
  joined_at timestamp with time zone DEFAULT now(),
  CONSTRAINT crew_members_pkey PRIMARY KEY (id),
  CONSTRAINT crew_members_crew_id_fkey FOREIGN KEY (crew_id) REFERENCES public.crews(id),
  CONSTRAINT crew_members_character_id_fkey FOREIGN KEY (character_id) REFERENCES public.characters(id)
);
CREATE TABLE public.crews (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  disbanded_at timestamp with time zone,
  CONSTRAINT crews_pkey PRIMARY KEY (id)
);
CREATE TABLE public.cyberware_catalog (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  bound_attr_key text NOT NULL,
  tier integer NOT NULL CHECK (tier >= 1 AND tier <= 5),
  per_scene_uses integer,
  passive_step integer NOT NULL DEFAULT 0,
  grants_auto_clean boolean NOT NULL DEFAULT false,
  corp_tagged boolean NOT NULL DEFAULT true,
  glitch_risk integer NOT NULL DEFAULT 0,
  description text,
  category text DEFAULT 'cyberware'::text,
  CONSTRAINT cyberware_catalog_pkey PRIMARY KEY (id),
  CONSTRAINT cyberware_catalog_bound_attr_key_fkey FOREIGN KEY (bound_attr_key) REFERENCES public.attributes_ref(key)
);
CREATE TABLE public.events (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text,
  type text NOT NULL,
  visibility text NOT NULL DEFAULT 'gm_only'::text CHECK (visibility = ANY (ARRAY['gm_only'::text, 'public'::text, 'player_specific'::text])),
  location_id uuid,
  involved_faction_id uuid,
  involved_character_id uuid,
  timestamp_in_world text,
  logged_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT events_pkey PRIMARY KEY (id),
  CONSTRAINT events_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id),
  CONSTRAINT events_involved_faction_id_fkey FOREIGN KEY (involved_faction_id) REFERENCES public.factions(id),
  CONSTRAINT events_involved_character_id_fkey FOREIGN KEY (involved_character_id) REFERENCES public.characters(id),
  CONSTRAINT events_logged_by_fkey FOREIGN KEY (logged_by) REFERENCES public.users(id)
);
CREATE TABLE public.exposure_attempts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  intel_id uuid NOT NULL,
  character_id uuid NOT NULL,
  skill_name text NOT NULL,
  skill_level integer NOT NULL,
  roll integer NOT NULL,
  target_dc integer NOT NULL,
  success boolean NOT NULL,
  clock_advanced boolean DEFAULT false,
  notes text,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  team_id uuid,
  CONSTRAINT exposure_attempts_pkey PRIMARY KEY (id),
  CONSTRAINT exposure_attempts_intel_id_fkey FOREIGN KEY (intel_id) REFERENCES public.intel_items(id),
  CONSTRAINT exposure_attempts_character_id_fkey FOREIGN KEY (character_id) REFERENCES public.characters(id),
  CONSTRAINT exposure_attempts_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id),
  CONSTRAINT exposure_attempts_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id)
);
CREATE TABLE public.factions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  type text NOT NULL,
  public_description text,
  true_agenda text,
  influence_rating integer DEFAULT 1,
  stability_rating integer DEFAULT 5,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT factions_pkey PRIMARY KEY (id)
);
CREATE TABLE public.fixers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  handle text UNIQUE,
  faction text,
  description text,
  contact_frequency integer DEFAULT 1,
  reputation integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT fixers_pkey PRIMARY KEY (id)
);
CREATE TABLE public.heat (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  crew_id uuid,
  source text,
  value integer DEFAULT 1,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT heat_pkey PRIMARY KEY (id),
  CONSTRAINT heat_crew_id_fkey FOREIGN KEY (crew_id) REFERENCES public.crews(id)
);
CREATE TABLE public.intel (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  job_id uuid,
  discovered_by uuid,
  intel_type text,
  title text,
  description text,
  visibility text DEFAULT 'crew'::text CHECK (visibility = ANY (ARRAY['private'::text, 'crew'::text, 'public'::text])),
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT intel_pkey PRIMARY KEY (id),
  CONSTRAINT intel_job_id_fkey FOREIGN KEY (job_id) REFERENCES public.jobs(id),
  CONSTRAINT intel_discovered_by_fkey FOREIGN KEY (discovered_by) REFERENCES public.characters(id)
);
CREATE TABLE public.intel_items (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  source_id uuid,
  title text NOT NULL,
  content text,
  preview text,
  difficulty integer NOT NULL DEFAULT 1 CHECK (difficulty >= 0 AND difficulty <= 10),
  visibility text NOT NULL DEFAULT 'gm_only'::text CHECK (visibility = ANY (ARRAY['gm_only'::text, 'players_can_see'::text, 'public'::text])),
  tied_clock_id uuid,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT intel_items_pkey PRIMARY KEY (id),
  CONSTRAINT intel_items_source_id_fkey FOREIGN KEY (source_id) REFERENCES public.intel_sources(id),
  CONSTRAINT intel_items_tied_clock_id_fkey FOREIGN KEY (tied_clock_id) REFERENCES public.clocks(id),
  CONSTRAINT intel_items_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id)
);
CREATE TABLE public.intel_reveals (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  intel_id uuid NOT NULL,
  skill_tag text NOT NULL,
  reveal_tier integer NOT NULL DEFAULT 1,
  preview text,
  content text,
  reveal_diff_mod integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT intel_reveals_pkey PRIMARY KEY (id),
  CONSTRAINT intel_reveals_intel_id_fkey FOREIGN KEY (intel_id) REFERENCES public.intel_items(id)
);
CREATE TABLE public.intel_sources (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  owner_faction_id uuid,
  description text,
  sensitivity integer NOT NULL DEFAULT 1 CHECK (sensitivity >= 0 AND sensitivity <= 5),
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT intel_sources_pkey PRIMARY KEY (id),
  CONSTRAINT intel_sources_owner_faction_id_fkey FOREIGN KEY (owner_faction_id) REFERENCES public.factions(id)
);
CREATE TABLE public.jobs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  fixer_id uuid,
  title text NOT NULL,
  synopsis text,
  briefing_text text,
  risk_tier integer DEFAULT 1 CHECK (risk_tier >= 1 AND risk_tier <= 10),
  entropy_die text DEFAULT 'd6'::text,
  required_roles ARRAY,
  reward_credits integer DEFAULT 0,
  heat_on_accept integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  expires_at timestamp with time zone,
  status text DEFAULT 'available'::text CHECK (status = ANY (ARRAY['available'::text, 'accepted'::text, 'completed'::text, 'failed'::text])),
  CONSTRAINT jobs_pkey PRIMARY KEY (id),
  CONSTRAINT jobs_fixer_id_fkey FOREIGN KEY (fixer_id) REFERENCES public.fixers(id)
);
CREATE TABLE public.locations (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  type text NOT NULL,
  description text,
  danger_level integer DEFAULT 1,
  controlling_faction_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT locations_pkey PRIMARY KEY (id),
  CONSTRAINT locations_controlling_faction_id_fkey FOREIGN KEY (controlling_faction_id) REFERENCES public.factions(id)
);
CREATE TABLE public.program_catalog (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  program_type text NOT NULL,
  counters_ice ARRAY,
  is_illegal boolean NOT NULL DEFAULT true,
  is_glitchy boolean NOT NULL DEFAULT false,
  base_cost numeric,
  rarity text,
  CONSTRAINT program_catalog_pkey PRIMARY KEY (id)
);
CREATE TABLE public.roll_events (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  actor_character_id uuid,
  actor_team_id uuid,
  scene_tag text,
  description text,
  control_die_size integer NOT NULL,
  entropy_die_size integer NOT NULL,
  rolled_control integer NOT NULL,
  rolled_entropy integer NOT NULL,
  margin integer NOT NULL,
  band text NOT NULL CHECK (band = ANY (ARRAY['CLEAN'::text, 'SUCCESS'::text, 'MIXED'::text, 'FAIL'::text, 'CRASH'::text])),
  stress_delta integer NOT NULL DEFAULT 0,
  gm_bank_note text,
  created_at timestamp with time zone DEFAULT now(),
  damage_track text CHECK ((damage_track = ANY (ARRAY['body'::text, 'mind'::text])) OR damage_track IS NULL),
  step_down_applied integer NOT NULL DEFAULT 0,
  run_id uuid,
  bank_spent text,
  job_id uuid,
  CONSTRAINT roll_events_pkey PRIMARY KEY (id),
  CONSTRAINT roll_events_actor_character_id_fkey FOREIGN KEY (actor_character_id) REFERENCES public.characters(id),
  CONSTRAINT roll_events_actor_team_id_fkey FOREIGN KEY (actor_team_id) REFERENCES public.teams(id),
  CONSTRAINT roll_events_run_id_fkey FOREIGN KEY (run_id) REFERENCES public.runs(id),
  CONSTRAINT roll_events_job_id_fkey FOREIGN KEY (job_id) REFERENCES public.jobs(id)
);
CREATE TABLE public.run_loadouts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  run_id uuid NOT NULL,
  character_id uuid NOT NULL,
  program_id uuid NOT NULL,
  slotted_at timestamp with time zone DEFAULT now(),
  active boolean NOT NULL DEFAULT true,
  CONSTRAINT run_loadouts_pkey PRIMARY KEY (id),
  CONSTRAINT run_loadouts_run_id_fkey FOREIGN KEY (run_id) REFERENCES public.runs(id),
  CONSTRAINT run_loadouts_character_id_fkey FOREIGN KEY (character_id) REFERENCES public.characters(id),
  CONSTRAINT run_loadouts_program_id_fkey FOREIGN KEY (program_id) REFERENCES public.program_catalog(id)
);
CREATE TABLE public.run_members (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  run_id uuid NOT NULL,
  character_id uuid NOT NULL,
  role_on_run text,
  outcome text DEFAULT 'ok'::text,
  exfilled boolean DEFAULT false,
  eligible_for_cut boolean DEFAULT true,
  personal_heat integer DEFAULT 0,
  gm_notes text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT run_members_pkey PRIMARY KEY (id),
  CONSTRAINT run_members_run_id_fkey FOREIGN KEY (run_id) REFERENCES public.runs(id),
  CONSTRAINT run_members_character_id_fkey FOREIGN KEY (character_id) REFERENCES public.characters(id)
);
CREATE TABLE public.run_payouts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  run_id uuid NOT NULL,
  character_id uuid NOT NULL,
  amount numeric NOT NULL,
  currency text DEFAULT 'cred'::text,
  share_pct numeric,
  paid_at timestamp with time zone DEFAULT now(),
  paid_by uuid,
  notes text,
  CONSTRAINT run_payouts_pkey PRIMARY KEY (id),
  CONSTRAINT run_payouts_run_id_fkey FOREIGN KEY (run_id) REFERENCES public.runs(id),
  CONSTRAINT run_payouts_character_id_fkey FOREIGN KEY (character_id) REFERENCES public.characters(id),
  CONSTRAINT run_payouts_paid_by_fkey FOREIGN KEY (paid_by) REFERENCES public.users(id)
);
CREATE TABLE public.runs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  team_id uuid NOT NULL,
  code_name text NOT NULL,
  target_name text NOT NULL,
  target_type text,
  objective text NOT NULL,
  objective_type text,
  total_pay numeric,
  currency text DEFAULT 'cred'::text,
  cut_policy text,
  status text NOT NULL DEFAULT 'planning'::text,
  planned_start timestamp with time zone,
  actual_start timestamp with time zone,
  actual_end timestamp with time zone,
  heat_level integer NOT NULL DEFAULT 0,
  gm_notes text,
  created_at timestamp with time zone DEFAULT now(),
  created_by uuid,
  heat_clock_id uuid,
  CONSTRAINT runs_pkey PRIMARY KEY (id),
  CONSTRAINT runs_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id),
  CONSTRAINT runs_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id),
  CONSTRAINT runs_heat_clock_id_fkey FOREIGN KEY (heat_clock_id) REFERENCES public.clocks(id)
);
CREATE TABLE public.skills (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  domain_attr_key text NOT NULL,
  is_preset boolean NOT NULL DEFAULT false,
  CONSTRAINT skills_pkey PRIMARY KEY (id),
  CONSTRAINT skills_domain_attr_key_fkey FOREIGN KEY (domain_attr_key) REFERENCES public.attributes_ref(key)
);
CREATE TABLE public.team_intel_attempts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  team_id uuid NOT NULL,
  legacy_intel_id uuid,
  legacy_actor_character_id uuid,
  attempted_at timestamp with time zone NOT NULL DEFAULT now(),
  legacy_base_dc integer,
  legacy_total_members_tested integer,
  failure_count integer NOT NULL DEFAULT 0,
  clock_id uuid,
  clock_advanced_by integer NOT NULL DEFAULT 0,
  triggered_by_user uuid,
  roll_event_id uuid,
  run_id uuid,
  requested_by_character_id uuid,
  target text,
  intel_type text,
  locked_result text,
  gm_visible_detail text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT team_intel_attempts_pkey PRIMARY KEY (id),
  CONSTRAINT team_intel_attempts_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id),
  CONSTRAINT team_intel_attempts_intel_id_fkey FOREIGN KEY (legacy_intel_id) REFERENCES public.intel_items(id),
  CONSTRAINT team_intel_attempts_actor_character_id_fkey FOREIGN KEY (legacy_actor_character_id) REFERENCES public.characters(id),
  CONSTRAINT team_intel_attempts_clock_id_fkey FOREIGN KEY (clock_id) REFERENCES public.clocks(id),
  CONSTRAINT team_intel_attempts_triggered_by_user_fkey FOREIGN KEY (triggered_by_user) REFERENCES public.users(id),
  CONSTRAINT team_intel_attempts_roll_event_id_fkey FOREIGN KEY (roll_event_id) REFERENCES public.roll_events(id),
  CONSTRAINT team_intel_attempts_run_id_fkey FOREIGN KEY (run_id) REFERENCES public.runs(id),
  CONSTRAINT team_intel_attempts_requested_by_character_id_fkey FOREIGN KEY (requested_by_character_id) REFERENCES public.characters(id)
);
CREATE TABLE public.team_intel_view_data (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  team_id uuid NOT NULL,
  intel_id uuid NOT NULL,
  skill_tag text NOT NULL,
  reveal_tier integer NOT NULL,
  success boolean NOT NULL DEFAULT false,
  dc integer NOT NULL,
  roll_total integer NOT NULL,
  skill_level integer NOT NULL,
  d20 integer NOT NULL,
  preview text,
  revealed_content text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT team_intel_view_data_pkey PRIMARY KEY (id),
  CONSTRAINT team_intel_view_data_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id),
  CONSTRAINT team_intel_view_data_intel_id_fkey FOREIGN KEY (intel_id) REFERENCES public.intel_items(id)
);
CREATE TABLE public.team_members (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  team_id uuid NOT NULL,
  character_id uuid NOT NULL,
  role text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT team_members_pkey PRIMARY KEY (id),
  CONSTRAINT team_members_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id),
  CONSTRAINT team_members_character_id_fkey FOREIGN KEY (character_id) REFERENCES public.characters(id)
);
CREATE TABLE public.teams (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT teams_pkey PRIMARY KEY (id),
  CONSTRAINT teams_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id)
);
CREATE TABLE public.users (
  id uuid NOT NULL,
  display_name text NOT NULL,
  role text NOT NULL CHECK (role = ANY (ARRAY['gm'::text, 'player'::text])),
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT users_pkey PRIMARY KEY (id),
  CONSTRAINT users_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.world_state_flags (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  flag_key text NOT NULL UNIQUE,
  label text NOT NULL,
  value text NOT NULL,
  description text,
  last_changed_at timestamp with time zone DEFAULT now(),
  changed_by uuid,
  CONSTRAINT world_state_flags_pkey PRIMARY KEY (id),
  CONSTRAINT world_state_flags_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES public.users(id)
);