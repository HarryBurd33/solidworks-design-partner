#!/usr/bin/env node
// Original envelope renderer. Anatomy rendering primitives are vendored separately under MIT.
import { readFile, mkdir, writeFile, lstat } from 'node:fs/promises';
import { resolve } from 'node:path';
import { fitProjection, boxCorners, slabOf, cylinder, solidSvg, depthOf, figureSvg, pageHtml, iso } from '../vendor/anatomy/iso-kit.mjs';

const fail = message => { throw new Error(message); };
const esc = value => String(value).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
const object = (v, label) => { if (!v || Array.isArray(v) || typeof v !== 'object') fail(`${label} must be an object`); };
const keys = (v, allowed, label) => { for (const key of Object.keys(v)) if (!allowed.includes(key)) fail(`${label}: unknown field ${key}`); };
const text = (v, label) => { if (typeof v !== 'string' || !v.trim() || /[\x00-\x08\x0b\x0c\x0e-\x1f]/.test(v)) fail(`${label} must be nonempty text without control characters`); };
const number = (v, label, positive = false) => { if (typeof v !== 'number' || !Number.isFinite(v) || (positive && v <= 0)) fail(`${label} must be ${positive ? 'positive and ' : ''}finite`); };
const vector = (v, label, positive = false) => { if (!Array.isArray(v) || v.length !== 3) fail(`${label} must have three numbers`); v.forEach((n, i) => number(n, `${label}[${i}]`, positive)); };

function validate(input) {
  object(input, 'input'); keys(input, ['units', 'title', 'parts'], 'input');
  if (input.units !== 'mm') fail('units must be mm'); text(input.title, 'title');
  if (!Array.isArray(input.parts) || !input.parts.length) fail('parts must be a nonempty array');
  const ids = new Set();
  for (const p of input.parts) {
    object(p, 'part');
    keys(p, ['id', 'name', 'shape', 'position', 'size', 'radius', 'height', 'status', 'explode'], 'part');
    if (typeof p.id !== 'string' || !/^[A-Za-z][A-Za-z0-9_-]{0,63}$/.test(p.id) || ids.has(p.id)) fail('part ids must be unique safe identifiers (letter, then letters/digits/_/-, max64)');
    ids.add(p.id); text(p.name, 'part name');
    if (!['supplied', 'proposed', 'assumed'].includes(p.status)) fail('part status must be supplied, proposed, or assumed');
    vector(p.position, 'position'); if (p.explode !== undefined) vector(p.explode, 'explode');
    if (p.shape === 'box') {
      vector(p.size, 'box size', true);
      if (p.radius !== undefined || p.height !== undefined) fail('box uses size, not radius/height');
    } else if (p.shape === 'cylinder') {
      number(p.radius, 'cylinder radius', true); number(p.height, 'cylinder height', true);
      if (p.size !== undefined) fail('cylinder uses radius/height, not size');
    } else fail('shape must be box or cylinder');
  }
}

function geometry(p) {
  const [x, y, z] = p.position;
  const [w, d, h] = p.shape === 'box' ? p.size : [2 * p.radius, 2 * p.radius, p.height];
  const plan = { x: p.shape === 'box' ? x : x - p.radius, y: p.shape === 'box' ? y : y - p.radius, w, d, r: 0 };
  const corners = boxCorners(plan, z, z + h);
  const center = [plan.x + w / 2, plan.y + d / 2, z + h / 2];
  const move = p.explode ?? [0, 0, 0];
  const exploded = corners.map(c => c.map((n, i) => n + move[i]));
  if (![...corners.flat(), ...exploded.flat(), ...center].every(Number.isFinite)) fail('geometry exceeds finite numeric range');
  return { p, plan, z, h, corners, exploded, center, move };
}

function render(input) {
  const width = 960, height = 560;
  const items = input.parts.map(geometry);
  const extremes = items.flatMap(i => [...i.corners, ...i.exploded]);
  const projection = fitProjection(extremes, width, height, { pad: 42 });
  if (![projection.scale, ...projection.origin].every(Number.isFinite) || projection.scale <= 0) fail('geometry cannot be projected at this numeric scale');
  const origin = iso([0, 0, 0], projection);
  const bodies = items.map(i => {
    const [x, y] = i.p.position;
    const shape = i.p.shape === 'box' ? slabOf(i.plan, i.z, i.h, projection) : cylinder(x, y, i.p.radius, i.z, i.h, projection);
    if (Object.values(shape).flat().some(value => typeof value === 'string' && /\b(?:NaN|Infinity)\b/.test(value))) fail('nonfinite SVG geometry');
    const displaced = iso(i.move, projection);
    const delta = displaced.map((n, at) => n - origin[at]);
    const depth = depthOf(i.center, projection);
    const explodedDepth = depthOf(i.center.map((n, at) => n + i.move[at]), projection);
    if (![...delta, depth, explodedDepth].every(Number.isFinite)) fail('projected positions exceed finite numeric range');
    return { id: i.p.id, depth, svg: `<g id="part-${esc(i.p.id)}" data-part="${esc(i.p.id)}" data-status="${esc(i.p.status)}" data-depth="${depth}" data-exploded-depth="${explodedDepth}" data-exploded-transform="translate(${delta[0]} ${delta[1]})"><title>${esc(i.p.name)} (${esc(i.p.status)})</title>${solidSvg(shape)}</g>` };
  }).sort((a, b) => a.depth - b.depth || a.id.localeCompare(b.id));
  const notice = 'Concept outline — not a SOLIDWORKS model or engineering verification';
  const label = `${input.title}. ${notice}. Simplified part envelopes in millimeters.`;
  const groups = `<g id="parts">${bodies.map(b => b.svg).join('')}</g>`;
  const staticSvg = figureSvg({ width, height, label, body: `<text x="20" y="24" fill="#263442" font-family="system-ui,sans-serif" font-size="14">${notice}</text>${groups}`, standalone: 'light' });
  const rows = input.parts.map(p => {
    const dims = p.shape === 'box' ? p.size.join(' × ') : `radius ${p.radius}, height ${p.height}`;
    return `<tr><th scope="row">${esc(p.id)}</th><td>${esc(p.name)}</td><td>${esc(p.status)}</td><td>${esc(p.shape)}</td><td>${esc(p.position.join(', '))}</td><td>${esc(dims)}</td><td>${esc((p.explode ?? [0, 0, 0]).join(', '))}</td></tr>`;
  }).join('');
  const style = `<style>body{background:#f5f6f8!important;color:#263442!important}.iso-page{margin:28px auto 56px}h1{font-size:26px;line-height:1.25;margin:0 0 10px}h2{font-size:18px}p{max-width:85ch}.notice{font-weight:650}.controls{padding:14px 0}label{display:inline-flex;gap:9px;align-items:center;cursor:pointer}input{width:18px;height:18px;accent-color:#215b83}input:focus-visible{outline:3px solid #215b83;outline-offset:3px}.figure{background:white;border:1px solid #c9d3dd;border-radius:10px;overflow:hidden}.table-wrap{overflow-x:auto}table{border-collapse:collapse;width:100%;font-size:13px}th,td{text-align:left;padding:10px;border-bottom:1px solid #ccd4dd}thead{background:#e9eef4}caption{text-align:left;margin:8px 0}.subtle{color:#4c5b6b}</style>`;
  const fig = figureSvg({ width, height, label, body: groups });
  const body = `${style}<header><h1>${esc(input.title)}</h1><p class="notice">${notice}</p><p class="subtle">Simplified box/cylinder envelopes. No Boolean holes, tolerance analysis, true collision checks, or physical-fit verification.</p></header><div class="controls"><label for="exploded"><input id="exploded" type="checkbox" aria-controls="outline-figure">Exploded view</label> <span id="view-state" role="status" aria-live="polite">Assembled view</span></div><div class="figure" id="outline-figure">${fig}</div><h2>Parts and parameters</h2><p>All dimensions and positions are in mm. Boxes use a minimum-corner position; cylinders use an XY center and bottom Z. Explode vectors are display offsets, not manufacturing geometry.</p><div class="table-wrap"><table><caption>Parameters used to draw this outline</caption><thead><tr><th scope="col">ID</th><th scope="col">Part</th><th scope="col">Status</th><th scope="col">Shape</th><th scope="col">Position x, y, z</th><th scope="col">Size / radius, height</th><th scope="col">Explode dx, dy, dz</th></tr></thead><tbody>${rows}</tbody></table></div>`;
  // No user text enters executable JavaScript. Numeric transforms are read from fixed attributes.
  const script = `const control=document.getElementById('exploded');const group=document.getElementById('parts');const nodes=[...group.children];function update(){for(const node of nodes){if(control.checked)node.setAttribute('transform',node.dataset.explodedTransform);else node.removeAttribute('transform')}nodes.sort((a,b)=>Number(control.checked?a.dataset.explodedDepth:a.dataset.depth)-Number(control.checked?b.dataset.explodedDepth:b.dataset.depth));for(const node of nodes)group.append(node);document.getElementById('view-state').textContent=control.checked?'Exploded view':'Assembled view'}control.checked=new URLSearchParams(location.search).get('view')==='exploded';control.addEventListener('change',update);update();`;
  const html = pageHtml({ title: input.title, theme: 'light', width, body, script });
  return { svg: staticSvg, html };
}

async function main() {
  const [major, minor] = process.versions.node.split('.').map(Number);
  if (major < 20 || (major === 20 && minor < 10)) fail('Node.js 20.10+ is required');
  if (process.argv.length !== 4) fail('Usage: node scripts/render-outline.mjs INPUT.json NEW_OUTPUT_DIR');
  const inputPath = resolve(process.argv[2]), outputPath = resolve(process.argv[3]);
  try { await lstat(outputPath); fail('Output directory already exists; choose a new path'); } catch (error) { if (error.code !== 'ENOENT') throw error; }
  const original = await readFile(inputPath, 'utf8');
  const input = JSON.parse(original); validate(input);
  const result = render(input); // Complete validation and rendering before any output writes.
  await mkdir(outputPath); // Nonrecursive and exclusive: parent must already exist.
  await writeFile(resolve(outputPath, 'outline.svg'), result.svg, { flag: 'wx' });
  await writeFile(resolve(outputPath, 'outline.html'), result.html, { flag: 'wx' });
  await writeFile(resolve(outputPath, 'parameters.json'), original, { flag: 'wx' });
  console.log(JSON.stringify({ status: 'generated-concept-only', parts: input.parts.length, files: ['outline.svg', 'outline.html', 'parameters.json'] }));
}
main().catch(error => { console.error(`render-outline: ${error.message}`); process.exitCode = 1; });
