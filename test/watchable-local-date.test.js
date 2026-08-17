#!/usr/bin/env node
'use strict';
/* Auto-watch lower bound is America/Denver local calendar date, not UTC.
 *
 * Instant 2026-08-17T01:00:00.000Z is 2026-08-16 in Denver. Using
 * toISOString().slice(0,10) as "today" would drop same-day local departures
 * after 18:00 America/Denver. FROM/TO/Go stays gone.
 */

var assert = require('assert');
var fs = require('fs');
var path = require('path');
var vm = require('vm');

var ROOT = path.join(__dirname, '..');
var popup = fs.readFileSync(path.join(ROOT, 'extension', 'popup.js'), 'utf8');
var html = fs.readFileSync(path.join(ROOT, 'extension', 'popup.html'), 'utf8');

var instant = new Date('2026-08-17T01:00:00.000Z');
var utcDate = instant.toISOString().slice(0, 10);
assert.strictEqual(utcDate, '2026-08-17', 'UTC date of the fixture instant');

var denverDate = new Intl.DateTimeFormat('en-CA', {
  timeZone: 'America/Denver',
  year: 'numeric',
  month: '2-digit',
  day: '2-digit'
}).format(instant);
assert.strictEqual(denverDate, '2026-08-16', 'America/Denver date of the fixture instant');

assert.ok(/function localCalendarDate\(now\)/.test(popup), 'localCalendarDate(now) must exist');
assert.ok(/America\/Denver/.test(popup), 'popup.js must use America/Denver');
assert.ok(/en-CA/.test(popup), 'popup.js must use en-CA');

var helperMatch = popup.match(/function localCalendarDate\(now\) \{[\s\S]*?\n\}/);
assert.ok(helperMatch, 'could not extract localCalendarDate');
var localCalendarDate = vm.runInNewContext(helperMatch[0] + '\nlocalCalendarDate;');
assert.strictEqual(localCalendarDate(instant), '2026-08-16',
  'localCalendarDate must return Denver date for the fixture instant');

var wdMatch = popup.match(/function watchableDeps\([\s\S]*?\n\}/);
assert.ok(wdMatch, 'watchableDeps missing');
assert.ok(!/toISOString\(\)\.slice\(0,\s*10\)/.test(wdMatch[0]),
  'watchableDeps must not use toISOString().slice(0,10) for today');
assert.ok(/localCalendarDate/.test(wdMatch[0]),
  'watchableDeps must use localCalendarDate');
assert.ok(/America\/Denver/.test(popup),
  'watchableDeps path must sit on America/Denver');

assert.ok(!/id=["']usl-from["']/.test(html) && !/id=["']usl-to["']/.test(html),
  'FROM/TO inputs must stay gone');
assert.ok(!/>\s*Go\s*</.test(html), 'Go button must stay gone');
assert.ok(!/placeholder=["']FROM["']/i.test(html) && !/placeholder=["']TO["']/i.test(html),
  'FROM/TO placeholders must stay gone');

process.stdout.write('ok\n');
