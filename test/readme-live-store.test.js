#!/usr/bin/env node
'use strict';
/* README.md and STORE.md must match live Store 3.0.2.
 *
 * This is this extension repo's record, not the site repo's README/STORE.md.
 * Watching the current files pass does not prove the guard can fail. */

var assert = require('assert');
var fs = require('fs');
var path = require('path');

var ROOT = path.join(__dirname, '..');

function load(rel) {
  return fs.readFileSync(path.join(ROOT, rel), 'utf8');
}

function fail(label, message) {
  throw new Error((label || 'live store') + ': ' + message);
}

function reject(name, fn, expect) {
  var threw = false;
  var message = '';
  try {
    fn();
  } catch (err) {
    threw = true;
    message = err.message || String(err);
  }
  if (!threw) throw new Error('FAIL ' + name + ': planted live-store defect escaped');
  assert.ok(expect.test(message),
    name + ' must fail matching ' + expect + ', got: ' + message);
  process.stdout.write('REJECT ' + name + '\n');
}

function validateLiveDocs(text, label) {
  label = label || 'docs';
  if (!/\b3\.0\.2\b/.test(text)) fail(label, 'must name live Store 3.0.2');
  if (/\b3\.1\.1\b/.test(text)) fail(label, 'must not name 3.1.1 as live');
  if (!/https:\/\/wifiodds\.com\//.test(text)) {
    fail(label, 'must name the live product URL https://wifiodds.com/');
  }
  text.split(/\n/).forEach(function (line) {
    if (/smithfamai\.com\/unitedstarlink/.test(line) && !/retired/.test(line)) {
      fail(label, 'must not present smithfamai.com/unitedstarlink as the live product URL');
    }
  });
  if (!/labels only/.test(text) && !/labels-only/.test(text)) {
    fail(label, 'must say Google Flights is labels only');
  }
  if (!/Best WiFi/.test(text)) fail(label, 'must name Best WiFi');
  if (!/refuses/.test(text) && !/cannot pick a winner/.test(text) &&
      !/If those checks fail/.test(text)) {
    fail(label, 'must say Best WiFi refuses a thin lead');
  }
  ['United', 'Alaska', 'Navan'].forEach(function (host) {
    if (text.indexOf(host) === -1) fail(label, 'must name ' + host);
  });
  if (/Delta,\s*American,\s*Southwest/.test(text) ||
      /Emirates,\s*Qatar,\s*jetBlue/.test(text)) {
    fail(label, 'must not dump a keyword-stuffed airline brand list');
  }
  if (/United ✕ Starlink Route Optimizer/.test(text) ||
      /the entire app/.test(text)) {
    fail(label, 'must not sell the retired encyclopedia as the live product');
  }
  if (/ConnectScore/.test(text)) {
    fail(label, 'must not name ConnectScore as a live customer metric');
  }
  if (label === 'README' && !/Streaming score/.test(text)) {
    fail(label, 'must name Streaming score');
  }
}

function validateStoreRecord(text) {
  validateLiveDocs(text, 'STORE.md');
  if (!/not a rewrite of the/.test(text)) {
    fail('STORE.md', 'must say it is not a rewrite of the Chrome Web Store listing');
  }
}

validateLiveDocs(load('README.md'), 'README');
process.stdout.write('PASS clean: README matches live Store 3.0.2\n');
validateStoreRecord(load('STORE.md'));
process.stdout.write('PASS clean: STORE.md matches live Store 3.0.2\n');

var liveReadme = load('README.md');
var liveStore = load('STORE.md');

reject('retired slogan product', function () {
  validateLiveDocs(liveReadme.replace(
    'A free Chrome overlay for airline-direct search.',
    'United ✕ Starlink Route Optimizer\n\nThe entire app — no build step.'
  ), 'slogan');
}, /retired encyclopedia/);

reject('3.1.1 as live', function () {
  validateLiveDocs(liveReadme + '\nChrome Web Store version 3.1.1 is live.\n', 'version');
}, /3\.1\.1/);

reject('retired product URL', function () {
  validateLiveDocs(liveReadme.replace(
    'The public product URL is https://wifiodds.com/ .',
    'Live: https://smithfamai.com/unitedstarlink/'
  ), 'url');
}, /smithfamai\.com\/unitedstarlink/);

reject('keyword-stuffed brand list', function () {
  validateLiveDocs(liveReadme.replace(
    'The overlay scores United, Alaska, and Navan search results.',
    'The overlay scores United, Alaska, Navan, Delta, American, Southwest, Emirates, Qatar, jetBlue search results.'
  ), 'brands');
}, /keyword-stuffed/);

reject('store listing rewrite claim missing', function () {
  validateStoreRecord(liveStore.replace(
    'It is not a rewrite of the Chrome Web Store listing.',
    'Paste this over the Chrome Web Store listing.'
  ));
}, /not a rewrite/);

reject('ConnectScore as live customer metric', function () {
  validateLiveDocs(liveReadme.replace(
    '**Streaming score**',
    '**STREAMING / ConnectScore**'
  ), 'README');
}, /ConnectScore/);

process.stdout.write('readme-live-store: 2 PASS, 6 REJECT\n');
