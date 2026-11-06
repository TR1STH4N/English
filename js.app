const $=(s,c=document)=>c.querySelector(s),$$=(s,c=document)=>[...c.querySelectorAll(s)];
const fine=matchMedia('(hover:hover) and (pointer:fine)').matches,rm=matchMedia('(prefers-reduced-motion:reduce)').matches;
const lerp=(a,b,t)=>a+(b-a)*t,clamp=(v,a=0,b=1)=>Math.min(b,Math.max(a,v)),php=n=>'₱'+n.toLocaleString('en-US');
if(fine)document.body.classList.add('fine');
/* ---------- split headlines ---------- */
$$('[data-split]').forEach(el=>{let n=0;el.innerHTML=el.textContent.trim().split(/\s+/).map(w=>`<span class="w"><i style="--d:${n++*70}ms">${w}</i></span>`).join(' ')});
/* ---------- reveal on view ---------- */
const io=new IntersectionObserver(es=>es.forEach(e=>{if(e.isIntersecting&&document.body.classList.contains('ready')){e.target.classList.add('vis');io.unobserve(e.target)}}),{threshold:.2});
function watch(){$$('.rv,[data-split]').forEach(el=>{if(!el.classList.contains('vis'))io.observe(el)})}
/* ---------- loader ---------- */
function start(){const b=document.body;b.classList.add('go','ready');setTimeout(()=>{b.classList.remove('lock');b.classList.add('done')},1000);
 $$('.hero .rv,.hero [data-split]').forEach(el=>el.classList.add('vis'));watch();
 $$('[data-split]').forEach(el=>{el.querySelectorAll('.w').forEach(w=>w.classList.add('vis'))})}
const minWait=new Promise(r=>setTimeout(r,rm?50:1500)),loaded=new Promise(r=>addEventListener('load',r));
Promise.all([minWait,loaded]).then(start);setTimeout(start,6000);
/* ---------- progress bar, cursor, magnetic ---------- */
let sy=0,vel=0;const bar=$('#bar');
const ring=$('#ring'),dot=$('#dot');let mx=innerWidth/2,my=innerHeight/2,rx=mx,ry=my;
addEventListener('pointermove',e=>{mx=e.clientX;my=e.clientY});
if(fine){document.addEventListener('pointerover',e=>ring.classList.toggle('big',!!e.target.closest('a,button,.tilt,input,select')));
 $$('.mag').forEach(b=>{b.addEventListener('pointermove',e=>{const r=b.getBoundingClientRect();b.style.transform=`translate(${(e.clientX-r.left-r.width/2)*.25}px,${(e.clientY-r.top-r.height/2)*.35}px)`});b.addEventListener('pointerleave',()=>b.style.transform='')})}
/* ---------- marquee ---------- */
const mts=$$('.mt').map(el=>({el,x:0,d:+el.dataset.dir,w:0}));
/* ---------- 3D scene ---------- */
const S=$$('[data-pose]').map(el=>({el,p:el.dataset.pose.split(',').map(Number)}));
const sc3={ok:false};
try{
 if(!window.THREE)throw 0;
 const cv=$('#gl'),r=new THREE.WebGLRenderer({canvas:cv,antialias:true,alpha:true});r.setPixelRatio(Math.min(devicePixelRatio,2));
 const sc=new THREE.Scene(),cam=new THREE.PerspectiveCamera(32,1,.1,100);cam.position.z=9;
 const gold=new THREE.MeshStandardMaterial({color:0xcfa94e,metalness:.95,roughness:.25,flatShading:true});
 const dark=new THREE.MeshStandardMaterial({color:0x0d0b08,metalness:.6,roughness:.45});
 const g=new THREE.Group();sc.add(g);
 const disc=new THREE.Mesh(new THREE.CylinderGeometry(1.6,1.6,.22,64),dark);disc.rotation.x=Math.PI/2;g.add(disc);
 g.add(new THREE.Mesh(new THREE.TorusGeometry(1.6,.11,24,96),gold));
 const ring2=new THREE.Mesh(new THREE.TorusGeometry(1.36,.025,12,96),gold);ring2.position.z=.11;g.add(ring2);
 const tex=new THREE.TextureLoader().load('logo.png');tex.anisotropy=8;
 const face=new THREE.Mesh(new THREE.PlaneGeometry(2.3,2.3),new THREE.MeshBasicMaterial({map:tex,transparent:true}));face.position.z=.13;g.add(face);
 const back=face.clone();back.position.z=-.13;back.rotation.y=Math.PI;g.add(back);
 sc.add(new THREE.AmbientLight(0xffffff,.45));
 const l1=new THREE.PointLight(0xf0d78c,2.4,40);l1.position.set(4,4,6);sc.add(l1);
 const l2=new THREE.PointLight(0xcfa94e,1.3,40);l2.position.set(-5,-3,4);sc.add(l2);
 /* faceted shards drifting past */
 const shards=[];for(let i=0;i<18;i++){const m=new THREE.Mesh(new THREE.IcosahedronGeometry(.1+Math.random()*.22,0),gold);
  m.userData={x:(Math.random()-.5)*2.4,y:Math.random()*8,z:-2+Math.random()*4,sp:.0006+Math.random()*.0016,rot:(Math.random()-.5)*.02};sc.add(m);shards.push(m)}
 /* gold dust */
 const N=420,pos=new Float32Array(N*3);for(let i=0;i<N;i++){pos[i*3]=(Math.random()-.5)*16;pos[i*3+1]=(Math.random()-.5)*10;pos[i*3+2]=(Math.random()-.5)*8-1}
 const pg=new THREE.BufferGeometry();pg.setAttribute('position',new THREE.BufferAttribute(pos,3));
 const dust=new THREE.Points(pg,new THREE.PointsMaterial({color:0xf0d78c,size:.035,transparent:true,opacity:.75,depthWrite:false}));sc.add(dust);
 function size(){r.setSize(innerWidth,innerHeight,false);cam.aspect=innerWidth/innerHeight;cam.updateProjectionMatrix()}size();addEventListener('resize',size);
 const mob=()=>innerWidth<1000;
 const cur={x:0,y:0,s:1,t:0};let spin=0,px=0,py=0;const t0=performance.now();
 function pose(){const mid=scrollY+innerHeight*.5,tops=S.map(o=>o.el.getBoundingClientRect().top+scrollY);
  let i=0;while(i<S.length-1&&tops[i+1]<=mid)i++;
  const a=S[i].p,b=S[Math.min(i+1,S.length-1)].p,span=(tops[Math.min(i+1,S.length-1)]-tops[i])||1;
  let f=clamp((mid-tops[i])/span);f=clamp((f-.4)/.5);f=f*f*(3-2*f);if(i==S.length-1)f=0;
  return a.map((v,k)=>lerp(v,b[k],f))}
 sc3.ok=true;
 sc3.frame=t=>{
  const hH=Math.tan(cam.fov*Math.PI/360)*cam.position.z,hW=hH*cam.aspect,p=pose(),m=mob();
  cur.x=lerp(cur.x,m?0:p[0]*hW,.08);cur.y=lerp(cur.y,p[1]*hH+(m?hH*.15:0),.08);cur.s=lerp(cur.s,p[2]*(m?.7:1),.08);cur.t=lerp(cur.t,p[3],.06);
  spin=lerp(spin,vel*.012,.1);px=lerp(px,(mx/innerWidth-.5)*.7,.06);py=lerp(py,(my/innerHeight-.5)*.5,.06);
  g.position.set(cur.x,cur.y+(rm?0:Math.sin(t*.9)*.07),0);g.scale.setScalar(cur.s);
  g.rotation.y=cur.t*Math.PI*2+px+spin+(rm?0:Math.sin(t*.5)*.25);g.rotation.x=py+spin*.4;
  l1.position.x=4+Math.sin(t*.7)*3;l2.position.y=-3+Math.cos(t*.5)*2;
  shards.forEach(s=>{const u=s.userData;s.position.x=u.x*hW*.95;s.position.y=(((u.y-scrollY*u.sp*6)%8)+8)%8*1-4;s.position.z=u.z;s.rotation.x+=u.rot+.002;s.rotation.y+=u.rot*1.3});
  dust.rotation.y=t*.03+px*.2;dust.position.y=scrollY*.0009;
  r.render(sc,cam)};
}catch(e){$('#gl').hidden=true}
/* ---------- main loop ---------- */
const t0=performance.now();let last=scrollY;
(function loop(){requestAnimationFrame(loop);
 sy=scrollY;vel=lerp(vel,sy-last,.15);last=sy;
 const max=document.documentElement.scrollHeight-innerHeight;bar.style.transform=`scaleX(${max>0?sy/max:0})`;
 rx=lerp(rx,mx,.18);ry=lerp(ry,my,.18);ring.style.transform=`translate(${rx}px,${ry}px)`;dot.style.transform=`translate(${mx}px,${my}px)`;
 mts.forEach(m=>{if(!m.w)m.w=m.el.firstElementChild.offsetWidth/3;if(!rm)m.x+=m.d*(.6+Math.abs(vel)*.25);if(m.x<=-m.w)m.x+=m.w;if(m.x>=0&&m.d>0)m.x-=m.w;m.el.style.transform=`translateX(${m.x}px) skewX(${clamp(-vel*.25,-8,8)}deg)`});
 if(sc3.ok)sc3.frame((performance.now()-t0)/1000)})();
/* ---------- smooth anchors ---------- */
$$('a[href^="#"]').forEach(a=>a.addEventListener('click',e=>{const t=$(a.getAttribute('href'));if(t){e.preventDefault();t.scrollIntoView({behavior:rm?'auto':'smooth'})}}));
/* ---------- shop ---------- */
const COLORS={Onyx:'#171717',Navy:'#16243f',Oxblood:'#4d1420',Forest:'#143429'};
const PRODUCTS=[
 {id:'blazer',name:'Crest Blazer',note:'Wool blend · gold buttons',price:8900,sizes:1,
  svg:'<path class="fab" d="M58 24l28-10 14 52 14-52 28 10 38 40-6 160h-62V96l-12-12-12 12v128H26L20 64z"/><path d="M86 14l14 52 14-52M100 66l-14 30M100 66l14 30" stroke="#cfa94e" stroke-width="1.5" fill="none"/><circle cx="100" cy="150" r="3.2" fill="#cfa94e"/><circle cx="100" cy="180" r="3.2" fill="#cfa94e"/><image href="logo.png" x="124" y="104" width="26" height="26"/>'},
 {id:'shirt',name:'Formal Shirt',note:'Poplin · stitched crest',price:3400,sizes:1,
  svg:'<path class="fab" d="M62 22l38 14 38-14 40 32-14 40-18-6v128H54V88l-18 6-14-40z"/><path d="M62 22l38 30 38-30M100 52v176" stroke="#cfa94e" stroke-width="1.2" fill="none" opacity=".7"/><image href="logo.png" x="118" y="92" width="24" height="24"/>'},
 {id:'tie',name:'Silk Tie',note:'Woven silk · gold panther',price:1800,sizes:0,
  svg:'<path class="fab" d="M84 12h32l-6 28 16 150-26 36-26-36 16-150z"/><path d="M84 12h32l-6 28H90z" fill="#000" opacity=".35"/><image href="logo.png" x="86" y="104" width="28" height="28"/>'},
 {id:'pin',name:'Gold Crest Pin',note:'Cast panther · 24k finish',price:2600,sizes:0,
  svg:'<circle cx="100" cy="110" r="78" class="fab"/><circle cx="100" cy="110" r="78" fill="none" stroke="#cfa94e" stroke-width="4"/><image href="logo.png" x="46" y="56" width="108" height="108"/>'}];
const SIZES=['XS','S','M','L','XL'],state={cart:[],sel:{}};
PRODUCTS.forEach(p=>state.sel[p.id]={c:'Onyx',s:'M'});
$('#grid').innerHTML=PRODUCTS.map((p,i)=>`<div class="card rv" data-id="${p.id}" style="--d:${i*110}ms"><div class="tilt" style="--c:${COLORS.Onyx}">
 <div class="art"><svg viewBox="0 0 200 240" aria-hidden="true">${p.svg}</svg></div>
 <div class="info"><h3>${p.name}</h3><small>${p.note}</small><span class="price">${php(p.price)}</span>
 <div class="row"><div class="sw" role="group" aria-label="Cloth">${Object.entries(COLORS).map(([n,c],k)=>`<button style="--c:${c}" data-c="${n}" aria-label="${n}" aria-pressed="${k==0}"></button>`).join('')}</div>
 ${p.sizes?`<div class="sz" role="group" aria-label="Size">${SIZES.map(s=>`<button data-s="${s}" aria-pressed="${s=='M'}">${s}</button>`).join('')}</div>`:''}</div>
 <button class="btn fill add">Add to order</button></div></div></div>`).join('');
$$('.card').forEach(card=>{
 const id=card.dataset.id,t=$('.tilt',card);
 card.addEventListener('click',e=>{const b=e.target.closest('button');if(!b)return;
  if(b.dataset.c){state.sel[id].c=b.dataset.c;t.style.setProperty('--c',COLORS[b.dataset.c]);$$('.sw button',card).forEach(x=>x.setAttribute('aria-pressed',x===b))}
  else if(b.dataset.s){state.sel[id].s=b.dataset.s;$$('.sz button',card).forEach(x=>x.setAttribute('aria-pressed',x===b))}
  else if(b.classList.contains('add')){add(id);toast('Added to your order')}});
 if(fine){card.addEventListener('pointermove',e=>{const r=t.getBoundingClientRect(),x=(e.clientX-r.left)/r.width,y=(e.clientY-r.top)/r.height;
   t.style.setProperty('--ry',(x-.5)*16+'deg');t.style.setProperty('--rx',-(y-.5)*16+'deg');t.style.setProperty('--mx',x*100+'%');t.style.setProperty('--my',y*100+'%')});
  card.addEventListener('pointerleave',()=>{t.style.setProperty('--ry','0deg');t.style.setProperty('--rx','0deg')})}});
function add(id){const p=PRODUCTS.find(x=>x.id==id),s=state.sel[id],size=p.sizes?s.s:'—',k=id+s.c+size,ex=state.cart.find(i=>i.k==k);
 ex?ex.q++:state.cart.push({k,id,name:p.name,price:p.price,c:s.c,size,q:1});render();const b=$('#count');b.classList.remove('pop');void b.offsetWidth;b.classList.add('pop')}
function render(){const n=state.cart.reduce((a,i)=>a+i.q,0),tot=state.cart.reduce((a,i)=>a+i.q*i.price,0);
 $('#count').textContent=n;$('#total').textContent=php(tot);$('#checkout').disabled=!n;$('#checkout').style.opacity=n?1:.4;
 $('#items').innerHTML=n?state.cart.map(i=>`<div class="it" style="--c:${COLORS[i.c]}"><i><img src="logo.png" alt=""></i><div><b>${i.name}</b><small>${i.c} · ${i.size}</small><div class="qty"><button data-k="${i.k}" data-d="-1" aria-label="Less">−</button>${i.q}<button data-k="${i.k}" data-d="1" aria-label="More">+</button></div></div><div class="price">${php(i.q*i.price)}</div></div>`).join(''):'<p class="empty">Your order is empty.</p>'}
$('#items').addEventListener('click',e=>{const b=e.target.closest('button[data-k]');if(!b)return;const i=state.cart.find(x=>x.k==b.dataset.k);i.q+=+b.dataset.d;if(i.q<1)state.cart=state.cart.filter(x=>x!==i);render()});
const drawer=$('#drawer'),veil=$('#veil'),modal=$('#modal');
function openDrawer(o=true){drawer.classList.toggle('on',o);veil.classList.toggle('on',o);drawer.setAttribute('aria-hidden',!o)}
$('#cartBtn').onclick=()=>openDrawer();$('#close').onclick=veil.onclick=()=>{openDrawer(false);modal.classList.remove('on')};
addEventListener('keydown',e=>{if(e.key=='Escape'){openDrawer(false);modal.classList.remove('on')}});
$('#checkout').onclick=()=>{if(!state.cart.length)return;openDrawer(false);veil.classList.add('on');
 $('#sheet').innerHTML=`<h3>Delivery details</h3><form id="f"><label>Full name</label><input required autocomplete="name"><label>Street and district</label><input required autocomplete="street-address"><label>Payment</label><select><option>Cash on delivery</option><option>GCash (demo)</option><option>Card (demo)</option></select><div class="tot" style="margin:22px 0 16px"><span>Total</span><span>${$('#total').textContent}</span></div><button class="btn fill" style="width:100%;justify-content:center">Place order</button></form>`;
 modal.classList.add('on');$('#sheet input').focus();
 $('#f').onsubmit=e=>{e.preventDefault();const no='ESP-'+Math.floor(1000+Math.random()*9000);
  $('#sheet').innerHTML=`<div class="done-box"><img src="logo.png" alt=""><h3>Order placed</h3><p class="lead" style="margin:10px auto 22px">Order <b style="color:var(--gold2)">${no}</b> is confirmed. This is a prototype, nothing was charged.</p><button class="btn fill" id="ok">Back to the collection</button></div>`;
  state.cart=[];render();$('#ok').onclick=()=>{modal.classList.remove('on');veil.classList.remove('on')}}};
let tt;function toast(m){const t=$('#toast');t.textContent=m;t.classList.add('on');clearTimeout(tt);tt=setTimeout(()=>t.classList.remove('on'),1600)}
render();
