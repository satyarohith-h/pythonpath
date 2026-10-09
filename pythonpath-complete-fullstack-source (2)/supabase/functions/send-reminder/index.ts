// Scheduled reminder function. Configure a trusted scheduler and set REMINDER_SECRET.
// Do not expose REMINDER_SECRET in frontend code. This template sends no email until an email
// provider is configured; use Resend API key as a Supabase secret and verified sender domain.
Deno.serve(async(req)=>{
 if(req.method!=="POST")return new Response("Method not allowed",{status:405});
 const secret=Deno.env.get("REMINDER_SECRET");
 if(!secret||req.headers.get("x-reminder-secret")!==secret)return new Response("Unauthorized",{status:401});
 const resend=Deno.env.get("RESEND_API_KEY"),from=Deno.env.get("REMINDER_FROM_EMAIL");
 if(!resend||!from)return Response.json({error:"Configure RESEND_API_KEY and REMINDER_FROM_EMAIL secrets."},{status:503});
 const url=Deno.env.get("SUPABASE_URL")!,service=Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
 const {createClient}=await import("https://esm.sh/@supabase/supabase-js@2");
 const admin=createClient(url,service);
 const {data:users,error}=await admin.from("pythonpath_profiles").select("id,display_name,last_active_date");
 if(error)return Response.json({error:error.message},{status:500});
 // Auth user emails are fetched one at a time using the admin API. Add consent/preferences before enabling scheduled campaigns.
 let sent=0,skipped=0;
 for(const p of users||[]){
  const {data:{user}}=await admin.auth.admin.getUserById(p.id);
  if(!user?.email||p.last_active_date===new Date().toISOString().slice(0,10)){skipped++;continue}
  const resp=await fetch("https://api.resend.com/emails",{method:"POST",headers:{"Authorization":`Bearer ${resend}`,"Content-Type":"application/json"},body:JSON.stringify({from,to:[user.email],subject:"Your next PythonPath step is waiting",text:`Hi ${p.display_name||"learner"},\\n\\nTake a few minutes today to continue your Python learning journey.\\n\\nOpen PythonPath to continue learning.\\n\\nYou received this transactional learning reminder from PythonPath.`})});
  if(resp.ok)sent++;else skipped++;
 }
 return Response.json({sent,skipped});
});
