import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
const cors={"Access-Control-Allow-Origin":"*","Access-Control-Allow-Headers":"authorization, x-client-info, apikey, content-type","Access-Control-Allow-Methods":"POST, OPTIONS","Content-Type":"application/json"};
Deno.serve(async(req)=>{
 if(req.method==="OPTIONS")return new Response("ok",{headers:cors});
 if(req.method!=="POST")return new Response(JSON.stringify({error:"Method not allowed"}),{status:405,headers:cors});
 const url=Deno.env.get("SUPABASE_URL")!, anon=Deno.env.get("SUPABASE_ANON_KEY")!, service=Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
 const auth=req.headers.get("Authorization")||"";
 const userClient=createClient(url,anon,{global:{headers:{Authorization:auth}}});
 const {data:{user}}=await userClient.auth.getUser();
 if(!user)return new Response(JSON.stringify({error:"Sign in required"}),{status:401,headers:cors});
 const {data:profile}=await userClient.from("pythonpath_profiles").select("role").eq("id",user.id).maybeSingle();
 if(profile?.role!=="admin")return new Response(JSON.stringify({error:"Admin access required"}),{status:403,headers:cors});
 const admin=createClient(url,service);
 const body=await req.json().catch(()=>({}));
 if(body.action==="stats"){
  const [users,lessons,progress]=await Promise.all([
   admin.from("pythonpath_profiles").select("id",{count:"exact",head:true}),
   admin.from("pythonpath_lessons").select("id",{count:"exact",head:true}),
   admin.from("pythonpath_progress").select("user_id",{count:"exact",head:true}).eq("status","completed")
  ]);
  return new Response(JSON.stringify({users:users.count||0,lessons:lessons.count||0,completions:progress.count||0}),{headers:cors});
 }
 if(body.action==="publish_lesson"){
  const l=body.lesson||{};
  if(typeof l.id!=="string"||typeof l.title!=="string"||l.id.length>80||l.title.length>160)return new Response(JSON.stringify({error:"Invalid lesson payload"}),{status:400,headers:cors});
  const {error}=await admin.from("pythonpath_lessons").upsert({id:l.id,title:l.title,module:String(l.module||"Python foundations"),level:String(l.level||"Beginner"),order_index:Number(l.order_index)||1000+Math.floor(Math.random()*1000000),summary:String(l.summary||""),content:l.content||{},published:l.published!==false});
  if(error)return new Response(JSON.stringify({error:error.message}),{status:400,headers:cors});
  return new Response(JSON.stringify({ok:true}),{headers:cors});
 }
 return new Response(JSON.stringify({error:"Unknown action"}),{status:400,headers:cors});
});
