export default async (req: Request) => {
  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'Method not allowed' }), {
      status: 405,
      headers: { 'content-type': 'application/json' },
    });
  }

  try {
    const body = await req.json();
    const amount = Number(body.amount);
    const currency = body.currency || 'ZAR';
    const reference = body.reference;
    const description = body.description || 'Wallet top-up';

    if (!amount || amount <= 0 || !reference) {
      return new Response(JSON.stringify({ error: 'Missing required payment fields.' }), {
        status: 400,
        headers: { 'content-type': 'application/json' },
      });
    }

    const secretKey = Deno.env.get('YOCO_SECRET_KEY');
    if (!secretKey) {
      return new Response(JSON.stringify({ error: 'YOCO_SECRET_KEY is not configured.' }), {
        status: 500,
        headers: { 'content-type': 'application/json' },
      });
    }

    const checkoutPayload = {
      amountInCents: Math.round(amount * 100),
      currency,
      reference,
      description,
    };

    const yocoResponse = await fetch('https://online.yoco.com/v1/checkout', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${secretKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(checkoutPayload),
    });

    const yocoData = await yocoResponse.json();
    if (!yocoResponse.ok) {
      return new Response(JSON.stringify({ error: yocoData }), {
        status: yocoResponse.status,
        headers: { 'content-type': 'application/json' },
      });
    }

    const checkoutUrl =
      yocoData.checkout_url ||
      yocoData.checkoutUrl ||
      yocoData.redirect_url ||
      yocoData.redirectUrl ||
      yocoData.url ||
      yocoData.paymentUrl;

    return new Response(JSON.stringify({ checkout_url: checkoutUrl ?? null, yoco: yocoData }), {
      status: 200,
      headers: { 'content-type': 'application/json' },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error instanceof Error ? error.message : String(error) }), {
      status: 500,
      headers: { 'content-type': 'application/json' },
    });
  }
};
