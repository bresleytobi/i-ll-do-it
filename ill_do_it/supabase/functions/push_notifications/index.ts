import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const FCM_SERVER_KEY = Deno.env.get('FCM_SERVER_KEY');
const SUPABASE_URL = Deno.env.get('SUPABASE_URL');
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');

serve(async (req) => {
  const supabase = createClient(SUPABASE_URL!, SUPABASE_SERVICE_ROLE_KEY!);
  
  // This function is triggered by a database webhook on 'messages' table INSERT
  const { record } = await req.json();
  const { sender_id, receiver_id, content } = record;

  // 1. Fetch sender's name
  const { data: sender } = await supabase
    .from('users')
    .select('display_name')
    .eq('id', sender_id)
    .single();

  // 2. Fetch receiver's push token
  const { data: receiver } = await supabase
    .from('users')
    .select('push_token')
    .eq('id', receiver_id)
    .single();

  if (receiver?.push_token) {
    // 3. Send notification via FCM
    const message = {
      to: receiver.push_token,
      notification: {
        title: sender?.display_name || 'New Message',
        body: content,
        sound: 'default'
      },
      data: {
        type: 'chat',
        sender_id: sender_id
      }
    };

    const response = await fetch('https://fcm.googleapis.com/fcm/send', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `key=${FCM_SERVER_KEY}`
      },
      body: JSON.stringify(message)
    });

    return new Response(JSON.stringify({ success: true }), { status: 200 });
  }

  return new Response(JSON.stringify({ success: false, reason: 'No push token' }), { status: 200 });
})
