import { test } from 'node:test';
import assert from 'node:assert/strict';
import { once } from 'node:events';
import { createBroker } from './server.ts';

test('mock authorization, state validation, session protection and logout', async () => {
  const server=createBroker({bootstrap:'local-secret',redirectURI:'http://127.0.0.1/oauth/callback',callbackURL:'sonos-demo://authorized',origin:'http://127.0.0.1',mock:true});
  server.listen(0,'127.0.0.1');await once(server,'listening');
  const address=server.address();assert.ok(address && typeof address!=='string');
  const base=`http://127.0.0.1:${address.port}`;
  const call=(path:string,token='',method='POST')=>fetch(base+path,{method,headers:{Authorization:'Bearer '+token},redirect:'manual'});
  try {
    assert.equal((await call('/session','wrong')).status,401);
    const session=await (await call('/session','local-secret')).json();
    assert.equal((await call('/token',session.sessionToken)).status,401);
    const start=await (await call('/auth/start',session.sessionToken)).json();
    assert.equal((await call('/mock/authorize?state=wrong','','GET')).status,400);
    const callback=await call('/mock/authorize?state='+start.state,'','GET');
    assert.equal(callback.status,302);assert.equal(new URL(callback.headers.get('location')!).searchParams.get('state'),start.state);
    assert.equal((await call('/mock/authorize?state='+start.state,'','GET')).status,400);
    const token=await (await call('/token',session.sessionToken)).json();
    assert.equal(token.accessToken,'mock-access');assert.equal(token.refresh_token,undefined);
    assert.equal((await call('/session',session.sessionToken,'DELETE')).status,200);
    assert.equal((await call('/token',session.sessionToken)).status,401);
  } finally { server.close();await once(server,'close'); }
});

test('refresh requests share an exchange and canceled authorization cannot replay', async () => {
  let exchanges = 0;
  const fetcher: typeof fetch = async () => {
    exchanges++;
    await new Promise(resolve => setTimeout(resolve, 40));
    return Response.json({access_token:'access-'+exchanges,refresh_token:'server-only',expires_in:3600});
  };
  const server=createBroker({bootstrap:'secret',clientID:'id',secret:'secret',redirectURI:'http://127.0.0.1/oauth/callback',callbackURL:'sonos-demo://authorized',origin:'http://127.0.0.1',fetcher});
  server.listen(0,'127.0.0.1');await once(server,'listening');
  const address=server.address();assert.ok(address && typeof address!=='string');
  const base=`http://127.0.0.1:${address.port}`;
  const call=(path:string,token='',method='POST')=>fetch(base+path,{method,headers:{Authorization:'Bearer '+token},redirect:'manual'});
  try {
    const {sessionToken}=await (await call('/session','secret')).json();
    const first=await (await call('/auth/start',sessionToken)).json();
    assert.equal((await call('/oauth/callback?state='+first.state+'&error=access_denied','','GET')).status,400);
    assert.equal((await call('/oauth/callback?state='+first.state+'&code=code','','GET')).status,400);
    const second=await (await call('/auth/start',sessionToken)).json();
    assert.equal((await call('/oauth/callback?state='+second.state+'&code=code','','GET')).status,302);
    const responses=await Promise.all(Array.from({length:10},()=>call('/token/refresh',sessionToken)));
    for(const response of responses) assert.equal(response.status,200);
    assert.equal(exchanges,2);
    const body=await responses[0].json();assert.equal(body.accessToken,'access-2');assert.equal(body.refresh_token,undefined);
  } finally { server.close();await once(server,'close'); }
});
