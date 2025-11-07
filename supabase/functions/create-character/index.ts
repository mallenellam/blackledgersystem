import { serve } from "https://deno.land/std/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

serve(async (req) => {
  try {
    const { user_id, name, alias, bio, role } = await req.json();

    const { data, error } = await supabase.rpc("create_character", {
      p_owner_user_id: user_id,
      p_name: name,
      p_alias: alias,
      p_bio: bio,
      p_role: role
    });

    if (error) throw error;
    return new Response(JSON.stringify({ character_id: data }), {
      headers: { "Content-Type": "application/json" },
      status: 200
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), {
      headers: { "Content-Type": "application/json" },
      status: 400
    });
  }
});
