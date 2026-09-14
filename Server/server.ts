import http from 'node:http';
import { randomBytes, timingSafeEqual } from 'node:crypto';
import { pathToFileURL } from 'node:url';

type Token = { access_token: string; refresh_token: string; expires_in: number };
type Session = { expires: number; token?: Token; tokenExpires?: number; pending?: Promise<void> };
type Config = { bootstrap: string; clientID?: string; secret?: string; redirectURI: string; callbackURL: string; origin: string; mock?: boolean; fetcher?: typeof fetch };
export function createBroker(config: Config) {
  if (!config.bootstrap || !config.callbackURL || !config.redirectURI) throw new Error('Missing configuration');
  const sessions = new Map<string, Session>();
  const states = new Map<string, { session: string; expires: number }>();
  const fetcher = config.fetcher ?? fetch;
  const random = () => randomBytes(32).toString('base64url');
  const equal = (a: string, b: string) => { const x = Buffer.from(a), y = Buffer.from(b); return x.length === y.length && timingSafeEqual(x,y); };
  const clean = () => {
    for (const [id, value] of sessions) if (value.expires < Date.now()) sessions.delete(id);
    for (const [id, value] of states) if (value.expires < Date.now() || !sessions.has(value.session)) states.delete(id);
  };
  async function exchange(params: Record<string,string>): Promise<Token> {
    if (config.mock) return {access_token:'mock-access',refresh_token:'mock-refresh',expires_in:3600};
    if (!config.clientID || !config.secret) throw new Error('Server OAuth credentials missing');
    const response = await fetcher('https://api.sonos.com/login/v3/oauth/access', {
      method:'POST', headers:{Authorization:'Basic '+Buffer.from(config.clientID+':'+config.secret).toString('base64'), 'Content-Type':'application/x-www-form-urlencoded'},
      body:new URLSearchParams(params), signal:AbortSignal.timeout(15000)
    });
    if (!response.ok) throw new Error('Sonos token exchange rejected');
    const token = await response.json() as Token;
    if (!token.access_token || !token.refresh_token || !Number.isFinite(token.expires_in) || token.expires_in <= 0) throw new Error('Invalid token response');
    return token;
  }
  const server = http.createServer(async (req,res) => {
    clean();
    res.setHeader('Cache-Control','no-store'); res.setHeader('Content-Type','application/json');
    const send = (status:number, data:unknown) => { res.writeHead(status); res.end(JSON.stringify(data)); };
    const redirect = (location:string) => { res.writeHead(302,{Location:location});res.end(); };
    try {
      const url = new URL(req.url ?? '/', config.origin);
      const bearer = req.headers.authorization?.replace(/^Bearer /,'') ?? '';
      if (url.pathname === '/session' && req.method === 'POST') {
        if (!equal(bearer,config.bootstrap)) return send(401,{error:'Unauthorized'});
        if (sessions.size >= 100) return send(429,{error:'Session limit reached'});
        const id=random();sessions.set(id,{expires:Date.now()+8*3600_000});return send(200,{sessionToken:id});
      }
      if (url.pathname === '/oauth/callback' || (config.mock && url.pathname === '/mock/authorize')) {
        const state=url.searchParams.get('state') ?? '';
        const entry=states.get(state); states.delete(state);
        if (!entry || url.searchParams.getAll('state').length !== 1) return send(400,{error:'Invalid state'});
        const current=sessions.get(entry.session);
        if (!current || entry.expires < Date.now()) return send(401,{error:'Expired session'});
        const code = config.mock ? 'fixture' : url.searchParams.get('code');
        if (!code || url.searchParams.has('error')) return send(400,{error:'Authorization canceled'});
        const token=await exchange({grant_type:'authorization_code',code,redirect_uri:config.redirectURI});
        if (sessions.get(entry.session) !== current) return send(401,{error:'Signed out'});
        current.token=token;current.tokenExpires=Date.now()+token.expires_in*1000;
        const callback=new URL(config.callbackURL);callback.searchParams.set('state',state);
        return redirect(callback.href);
      }
      const current=sessions.get(bearer);
      if (!current) return send(401,{error:'Unauthorized'});
      if (url.pathname === '/session' && req.method === 'DELETE') {
        sessions.delete(bearer);clean();return send(200,{});
      }
      if (url.pathname === '/auth/start' && req.method === 'POST') {
        for (const [id,value] of states) if (value.session===bearer) states.delete(id);
        const state=random();states.set(state,{session:bearer,expires:Date.now()+5*60_000});
        const auth=config.mock ? new URL('/mock/authorize',config.origin) : new URL('https://api.sonos.com/login/v3/oauth');
        auth.search=new URLSearchParams({client_id:config.clientID ?? 'mock',response_type:'code',scope:'playback-control-all',redirect_uri:config.redirectURI,state}).toString();
        return send(200,{url:auth.href,state});
      }
      if (['/token','/token/refresh'].includes(url.pathname) && req.method==='POST') {
        if (!current.token) return send(401,{error:'Authorize first'});
        if (url.pathname.endsWith('/refresh') || (current.tokenExpires ?? 0) < Date.now()+30_000) {
          if (!current.pending) {
            const refresh=current.token.refresh_token;
            current.pending=exchange({grant_type:'refresh_token',refresh_token:refresh}).then(token => {
              if (sessions.get(bearer)!==current) throw new Error('Signed out');
              current.token=token;current.tokenExpires=Date.now()+token.expires_in*1000;
            }).finally(()=>{current.pending=undefined;});
          }
          await current.pending;
        }
        return send(200,{accessToken:current.token.access_token,expiresAt:(current.tokenExpires ?? 0)/1000});
      }
      send(404,{error:'Not found'});
    } catch {
      send(502,{error:'Authentication service unavailable'});
    }
  });
  server.requestTimeout=20000;server.headersTimeout=10000;
  return server;
}
if (process.argv[1] && import.meta.url===pathToFileURL(process.argv[1]).href) {
  const port=Number(process.env.PORT ?? 8787);const origin=process.env.PUBLIC_ORIGIN ?? `http://127.0.0.1:${port}`;
  const server=createBroker({bootstrap:process.env.DEMO_BOOTSTRAP_TOKEN ?? '',clientID:process.env.SONOS_CLIENT_ID,secret:process.env.SONOS_CLIENT_SECRET,
    redirectURI:process.env.SONOS_REDIRECT_URI ?? `${origin}/oauth/callback`, callbackURL:process.env.APP_CALLBACK_URL ?? 'sonos-demo://authorized',origin,mock:process.env.SONOS_MOCK==='1'});
  server.listen(port,'127.0.0.1',()=>console.log(`Auth example listening at ${origin}`));
}
